local zhongwang = fk.CreateSkill {
  name = "shzj_xiangfan__zhongwang",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["shzj_xiangfan__zhongwang"] = "众望",
  [":shzj_xiangfan__zhongwang"] = "锁定技，摸牌阶段，你改为令所有其他角色依次选择是否将至少一张牌置于牌堆顶，然后你摸五张牌；"..
  "回合结束时，若你本回合满足以下至少两项条件，则本回合以此法将牌置于牌堆顶的角色各摸两张牌，否则你与这些角色各失去1点体力："..
  "造成过伤害；未弃置过牌；手牌最少。",

  ["#shzj_xiangfan__zhongwang-ask"] = "众望：你可以将任意张牌置于牌堆顶，回合结束时根据 %src 的条件执行效果",
  ["@@shzj_xiangfan__zhongwang-turn"] = "众望",

  ["$shzj_xiangfan__zhongwang1"] = "有此三罪，吾何颜复立于朝？",
  ["$shzj_xiangfan__zhongwang2"] = "此战之败，皆我一人之过也！",
}

zhongwang:addEffect(fk.EventPhaseProceeding, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zhongwang.name) and data.phase == Player.Draw and
      not data.phase_end
  end,
  on_cost = function (self, event, target, player, data)
    event:setCostData(self, {tos = player.room:getOtherPlayers(player)})
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    data.phase_end = true
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if not p.dead and not p:isNude() then
        local cards = room:askToCards(p, {
          min_num = 1,
          max_num = 999,
          include_equip = true,
          skill_name = zhongwang.name,
          cancelable = true,
          prompt = "#shzj_xiangfan__zhongwang-ask:"..player.id,
        })
        if #cards > 0 then
          if #cards == 1 then
            room:moveCards({
              ids = cards,
              from = p,
              toArea = Card.DrawPile,
              moveReason = fk.ReasonPut,
              skillName = zhongwang.name,
              proposer = p,
            })
          else
            local result = room:askToGuanxing(p, {
              cards = cards,
              bottom_limit = { 0, 0 },
              skill_name = zhongwang.name,
              skip = true,
            })
            room:moveCards({
              ids = table.reverse(result.top),
              from = player,
              toArea = Card.DrawPile,
              moveReason = fk.ReasonPut,
              skillName = zhongwang.name,
              proposer = p,
            })
          end
          if not p.dead then
            room:setPlayerMark(p, "@@shzj_xiangfan__zhongwang-turn", 1)
          end
        end
      end
    end
    if not player.dead then
      player:drawCards(5, zhongwang.name)
    end
  end,
})

zhongwang:addEffect(fk.TurnEnd, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zhongwang.name)
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(zhongwang.name)
    local n = 0
    if #room.logic:getActualDamageEvents(1, function (e)
      return e.data.from == player
    end, Player.HistoryTurn) > 0 then
      n = n + 1
    end
    local events = room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
      for _, move in ipairs(e.data) do
        if move.from == player and move.moveReason == fk.ReasonDiscard and
          table.find(move.moveInfo, function (info)
            return info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip
          end) then
          return true
        end
      end
    end, Player.HistoryTurn)
    if #events == 0 then
      n = n + 1
    end
    if table.every(room.alive_players, function(p)
      return p:getHandcardNum() >= player:getHandcardNum()
    end) then
      n = n + 1
    end
    if n > 1 then
      room:notifySkillInvoked(player, zhongwang.name, "support")
      for _, p in ipairs(room:getOtherPlayers(player)) do
        if p:getMark("@@shzj_xiangfan__zhongwang-turn") > 0 then
          p:drawCards(2, zhongwang.name)
        end
      end
    else
      room:notifySkillInvoked(player, zhongwang.name, "negative")
      for _, p in ipairs(room:getAlivePlayers()) do
        if p == player or p:getMark("@@shzj_xiangfan__zhongwang-turn") > 0 then
          room:loseHp(p, 1, zhongwang.name)
        end
      end
    end
  end,
})

return zhongwang
