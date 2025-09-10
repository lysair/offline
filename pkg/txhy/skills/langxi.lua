local langxi = fk.CreateSkill {
  name = "ofl_tx__langxi",
}

Fk:loadTranslationTable{
  ["ofl_tx__langxi"] = "狼袭",
  [":ofl_tx__langxi"] = "准备阶段，你可以对一名角色随机造成0~X点伤害（X为此技能发动次数，至多为3）。",

  ["#ofl_tx__langxi-choose"] = "狼袭：对一名角色随机造成0~%arg点伤害！",

  ["$ofl_tx__langxi1"] = "袭夺之势，如狼噬骨。",
  ["$ofl_tx__langxi2"] = "引吾至此，怎能不袭掠之？"
}

langxi:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(langxi.name) and player.phase == Player.Start
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      targets = room.alive_players,
      min_num = 1,
      max_num = 1,
      prompt = "#ofl_tx__langxi-choose:::"..math.min(3, 1 + player:usedSkillTimes(langxi.name, Player.HistoryGame)),
      skill_name = langxi.name,
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:damage({
      from = player,
      to = event:getCostData(self).tos[1],
      damage = math.random(0, math.min(3, player:usedSkillTimes(langxi.name, Player.HistoryGame))),
      skillName = langxi.name,
    })
  end,
})

return langxi
