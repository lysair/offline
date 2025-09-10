local diwan = fk.CreateSkill {
  name = "ofl__diwan",
}

Fk:loadTranslationTable{
  ["ofl__diwan"] = "敌万",
  [":ofl__diwan"] = "每回合限一次，当你使用【杀】指定目标后，你可以摸X张牌（X为此牌的目标数）。",
}

diwan:addEffect(fk.TargetSpecified, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(diwan.name) and
      player:usedSkillTimes(diwan.name, Player.HistoryTurn) == 0 and
      data.card.trueName == "slash" and data.firstTarget and
      #data.use.tos > 0
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(#data.use.tos, diwan.name)
  end,
})

return diwan
