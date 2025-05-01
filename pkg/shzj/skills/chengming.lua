
local chengming = fk.CreateSkill {
  name = "chengming",
  tags = { Skill.Lord, Skill.Limited },
}

Fk:loadTranslationTable{
  ["chengming"] = "承命",
  [":chengming"] = "主公技，限定技，当你进入濒死状态时，你可以令一名其他蜀势力角色获得你区域内的所有牌，你将体力值回复至1点，若其有锁定技，"..
  "其获得技能〖仁德〗。",

  ["#chengming-choose"] = "承命：令一名蜀势力角色获得你区域内所有牌，你回复体力至1点，若其有锁定技其获得“仁德”",
}

chengming:addEffect(fk.EnterDying, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(chengming.name) and
      player:usedSkillTimes(self.name, Player.HistoryGame) == 0 and
      table.find(player.room:getOtherPlayers(player, false), function (p)
        return p.kingdom == "shu"
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player, false), function (p)
      return p.kingdom == "shu"
    end)
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = chengming.name,
      prompt = "#chengming-choose",
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    if not player:isAllNude() then
      room:moveCardTo(player:getCardIds("hej"), Card.PlayerHand, to, fk.ReasonPrey, chengming.name, nil, false, to)
    end
    if player.hp < 1 and player:isWounded() and not player.dead then
      room:recover{
        who = player,
        num = 1 - player.hp,
        recoverBy = player,
        skillName = chengming.name,
      }
    end
    if not to.dead and table.find(to:getSkillNameList(), function (s)
      return Fk.skills[s]:hasTag(Skill.Compulsory, false)
    end) and not to:hasSkill("ex__rende", true) then
      room:handleAddLoseSkills(to, "ex__rende")
    end
  end,
})

return chengming
