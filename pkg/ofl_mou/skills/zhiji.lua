local zhiji = fk.CreateSkill {
  name = "ofl_mou__zhiji",
  tags = { Skill.Wake },
}

Fk:loadTranslationTable{
  ["ofl_mou__zhiji"] = "志继",
  [":ofl_mou__zhiji"] = "觉醒技，当你进入濒死状态时，你将体力回复至2点，减1点体力上限并获得“北伐”，" ..
  "然后若你手牌数最少，则你摸两张牌。",

  ["$ofl_mou__zhiji1"] = "蜀汉大业，虽身小亦鼎力而为！",
  ["$ofl_mou__zhiji2"] = "丞相北伐大业未完，吾必尽力图之。",
}

zhiji:addEffect(fk.EnterDying, {
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(zhiji.name) and
      player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  can_wake = function(self, event, target, player, data)
    return player.dying
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if player.hp < 2 then
      room:recover{
        who = player,
        num = 2 - player.hp,
        recoverBy = player,
        skillName = zhiji.name,
      }
      if player.dead then return end
    end
    room:changeMaxHp(player, -1)
    if player.dead then return end
    room:handleAddLoseSkills(player, "ofl_mou__beifa")
    if table.every(room.alive_players, function(p)
      return p:getHandcardNum() >= player:getHandcardNum()
    end) then
      player:drawCards(2, zhiji.name)
    end
  end,
})

return zhiji
