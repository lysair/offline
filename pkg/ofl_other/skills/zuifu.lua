local zuifu = fk.CreateSkill {
  name = "ofl__zuifu"
}

Fk:loadTranslationTable{
  ['ofl__zuifu'] = '罪缚',
  ['#ofl__zuifu-invoke'] = '罪缚：是否对 %dest 造成1点伤害？',
  [':ofl__zuifu'] = '每回合限一次，当一名角色于其摸牌阶段外获得牌后，若没有角色处于濒死状态，你可以对其造成1点伤害。',
}

zuifu:addEffect(fk.AfterCardsMove, {
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(zuifu.name) and player:usedSkillTimes(zuifu.name, Player.HistoryTurn) == 0 and
      not table.find(player.room.alive_players, function (p)
        return p.dying
      end) then
      for _, move in ipairs(data) do
        if move.to and move.toArea == Player.Hand and player.room:getPlayerById(move.to).phase ~= Player.Draw then
          return true
        end
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    local room = player.room
    local targets = {}
    for _, move in ipairs(data) do
      if move.to and move.toArea == Player.Hand and room:getPlayerById(move.to).phase ~= Player.Draw then
        table.insertIfNeed(targets, move.to)
      end
    end
    for _, id in ipairs(targets) do
      if not player:hasSkill(zuifu.name) or player:usedSkillTimes(zuifu.name, Player.HistoryTurn) > 0 or
        table.find(room.alive_players, function (p)
          return p.dying
        end) then return end
      local p = room:getPlayerById(id)
      if not p.dead then
        self:doCost(event, p, player, data)
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askToSkillInvoke(player, {
      skill_name = zuifu.name,
      prompt = "#ofl__zuifu-invoke::" .. target.id
    }) then
      event:setCostData(self, {tos = {target.id}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local cost_data = event:getCostData(self)
    if cost_data then
      player.room:damage{
        from = player,
        to = target,
        damage = 1,
        skillName = zuifu.name,
      }
    end
  end,
})

return zuifu
