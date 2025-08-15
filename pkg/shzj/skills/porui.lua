local porui = fk.CreateSkill {
  name = "shzj_xiangfan__porui",
}

Fk:loadTranslationTable{
  ["shzj_xiangfan__porui"] = "破锐",
  [":shzj_xiangfan__porui"] = "每轮限两次，其他角色的结束阶段，你可以弃置两张牌，然后视为对一名本回合失去过牌的角色使用X+1张【杀】"..
  "（X为其本回合失去的牌数且至多为5）。",

  ["#shzj_xiangfan__porui-invoke"] = "破锐：你可以弃置两张牌，然后视为对一名角色使用其失去牌数+1张【杀】",
  ["#shzj_xiangfan__porui-choose"] = "破锐：视为对一名角色使用其失去牌数+1张【杀】",

  ["$shzj_xiangfan__porui1"] = "",
  ["$shzj_xiangfan__porui2"] = "",
}

porui:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  times = function(self, player)
    return 2 - player:usedSkillTimes(porui.name, Player.HistoryRound)
  end,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(porui.name) and target.phase == Player.Finish and target ~= player and
      #player:getCardIds("he") > 1 and player:usedSkillTimes(porui.name, Player.HistoryRound) < 2
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cards = room:askToDiscard(player, {
      min_num = 2,
      max_num = 2,
      include_equip = true,
      skill_name = porui.name,
      prompt = "#shzj_xiangfan__porui-invoke",
      cancelable = true,
      skip = true,
    })
    if #cards > 1 then
      event:setCostData(self, {cards = cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(event:getCostData(self).cards, porui.name, player, player)
    if player.dead then return end
    local num_map = {}
    room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
      for _, move in ipairs(e.data) do
        if move.from and move.from ~= player and not move.from.dead and
          (move.to ~= move.from or (move.toArea ~= Card.PlayerHand and move.toArea ~= Card.PlayerEquip)) then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
              num_map[tostring(move.from.id)] = num_map[tostring(move.from.id)] or 0
              num_map[tostring(move.from.id)] = math.min(5, num_map[tostring(move.from.id)] + 1)
            end
          end
        end
      end
    end, Player.HistoryTurn)
    local targets = table.filter(room.alive_players, function (p)
      return num_map[tostring(p.id)]
    end)
    if #targets == 0 then return end
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = porui.name,
      prompt = "#shzj_xiangfan__porui-choose",
      cancelable = false,
      target_tip_name = "porui",
      extra_data = num_map,
    })[1]
    for _ = 1, num_map[tostring(to.id)] + 1, 1 do
      if player.dead or to.dead or not room:useVirtualCard("slash", nil, player, to, porui.name, true) then break end
    end
  end,
})

return porui
