local huishig = fk.CreateSkill {
  name = "ofl_shiji__huishig",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable{
  ["ofl_shiji__huishig"] = "辉逝",
  [":ofl_shiji__huishig"] = "限定技，当你进入濒死状态时，你可以选择一名角色，若其有未发动的觉醒技，你可以选择其中一个令其视为已满足觉醒条件，"..
  "否则其摸四张牌。",

  ["#ofl_shiji__huishig-choose"] = "辉逝：你可以令一名角色视为已满足觉醒条件（若没有则摸四张牌）",
  ["#ofl_shiji__huishig-choice"] = "辉逝：选择令 %dest 视为满足条件的觉醒技",

  ["$ofl_shiji__huishig1"] = "纵殒身祭命，亦要助明公大业。",
  ["$ofl_shiji__huishig2"] = "人亦如星，或居空而渺然，或为彗而明夜。",
  ["$ofl_shiji__huishig3"] = "寿数长短不足与明公大事相较。",
  ["$ofl_shiji__huishig4"] = "目下万物皆为成吾等之愿。",
}

huishig:addEffect(fk.EnterDying, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(huishig.name) and
      player:usedSkillTimes(huishig.name, Player.HistoryGame) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = player.room:askToChoosePlayers(player, {
      targets = room.alive_players,
      min_num = 1,
      max_num = 1,
      prompt = "#ofl_shiji__huishig-choose",
      skill_name = huishig.name,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local skills = table.filter(to:getSkillNameList(), function(s)
      return Fk.skills[s]:hasTag(Skill.Wake) and to:usedSkillTimes(s, Player.HistoryGame) == 0
    end)
    if #skills > 0 then
      local choice = room:askToChoice(player, {
        choices = skills,
        skill_name = huishig.name,
        prompt = "#ofl_shiji__huishig-choice::"..to.id,
        detailed = true,
      })
      room:addTableMarkIfNeed(to, "@huishig", choice)
      room:addTableMarkIfNeed(to, MarkEnum.StraightToWake, choice)
    else
      to:drawCards(4, huishig.name)
    end
  end,
})

huishig:addEffect(fk.SkillEffect, {
  can_refresh = function(self, event, target, player, data)
    return target == player and data.skill:hasTag(Skill.Wake) and
      table.contains(player:getTableMark("@huishig"), data.skill.name)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:removeTableMark(player, "@huishig", data.skill.name)
    room:removeTableMark(player, MarkEnum.StraightToWake, data.skill.name)
  end,
})

return huishig
