local zuifu = fk.CreateSkill {
  name = "ofl__zuifu",
}

Fk:loadTranslationTable{
  ["ofl__zuifu"] = "罪缚",
  [":ofl__zuifu"] = "每回合限一次，当一名角色于其摸牌阶段外获得牌后，若没有角色处于濒死状态，你可以对其造成1点伤害。",

  ["#ofl__zuifu-invoke"] = "罪缚：是否对 %dest 造成1点伤害？",
}

zuifu:addEffect(fk.AfterCardsMove, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(zuifu.name) and player:usedSkillTimes(zuifu.name, Player.HistoryTurn) == 0 and
      not table.find(player.room.alive_players, function (p)
        return p.dying
      end) then
      for _, move in ipairs(data) do
        if move.to and move.toArea == Player.Hand and move.to.phase ~= Player.Draw then
          return true
        end
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    local room = player.room
    local targets = {}
    for _, move in ipairs(data) do
      if move.to and move.toArea == Player.Hand and move.to.phase ~= Player.Draw then
        table.insertIfNeed(targets, move.to)
      end
    end
    room:sortByAction(targets)
    for _, to in ipairs(targets) do
      if not player:hasSkill(zuifu.name) or
        player:usedSkillTimes(zuifu.name, Player.HistoryTurn) > 0 or
        table.find(room.alive_players, function (p)
          return p.dying
        end) then return end
      if not to.dead then
        event:setCostData(self, {tos = {to}})
        self:doCost(event, target, player, data)
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    return room:askToSkillInvoke(player, {
      skill_name = zuifu.name,
      prompt = "#ofl__zuifu-invoke::" .. to.id,
    })
  end,
  on_use = function(self, event, target, player, data)
    player.room:damage{
      from = player,
      to = event:getCostData(self).tos[1],
      damage = 1,
      skillName = zuifu.name,
    }
  end,
})

return zuifu
