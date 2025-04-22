local ofl_shiji__huishig = fk.CreateSkill {
  name = "ofl_shiji__huishig"
}

Fk:loadTranslationTable{
  ['ofl_shiji__huishig'] = '辉逝',
  ['#ofl_shiji__huishig-choose'] = '辉逝：你可以令一名角色视为已满足觉醒条件（若没有则摸四张牌）',
  ['#ofl_shiji__huishig-choice'] = '辉逝：选择令 %dest 视为满足条件的觉醒技',
  [':ofl_shiji__huishig'] = '限定技，当你进入濒死状态时，你可以选择一名角色，若其有未发动的觉醒技，你可以选择其中一个令其视为已满足觉醒条件，否则其摸四张牌。',
}

ofl_shiji__huishig:addEffect(fk.EnterDying, {
  frequency = Skill.Limited,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(ofl_shiji__huishig) and player:usedSkillTimes(ofl_shiji__huishig.name, Player.HistoryGame) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local to = player.room:askToChoosePlayers(player, {
      targets = table.map(player.room.alive_players, function(p)
        return p.id 
      end),
      min_num = 1,
      max_num = 1,
      prompt = "#ofl_shiji__huishig-choose",
      skill_name = ofl_shiji__huishig.name,
    })
    if #to > 0 then
      event:setCostData(self, to[1])
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(event:getCostData(self))
    local skills = table.map(table.filter(to.player_skills, function(s)
      return s.frequency == Skill.Wake and to:usedSkillTimes(s.name, Player.HistoryGame) == 0 
    end), function(s) return s.name end)
    if #skills > 0 then
      local choice = room:askToChoice(player, {
        choices = skills,
        skill_name = ofl_shiji__huishig.name,
        prompt = "#ofl_shiji__huishig-choice::"..to.id,
        detailed = true,
      })
      room:addTableMarkIfNeed(to, MarkEnum.StraightToWake, choice)
    else
      to:drawCards(4, ofl_shiji__huishig.name)
    end
  end,
})

return ofl_shiji__huishig
