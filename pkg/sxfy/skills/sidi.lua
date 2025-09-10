local sidi = fk.CreateSkill {
  name = "sxfy__sidi",
}

Fk:loadTranslationTable{
  ["sxfy__sidi"] = "司敌",
  [":sxfy__sidi"] = "当一名角色打出【杀】时，你可以摸一张牌。",
}

sidi:addEffect(fk.CardResponding, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(sidi.name) and data.card.trueName == "slash"
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, sidi.name)
  end,
})

return sidi
