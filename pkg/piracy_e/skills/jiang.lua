local jiang = fk.CreateSkill {
  name = "ofl__jiang",
}

Fk:loadTranslationTable{
  ["ofl__jiang"] = "激昂",
  [":ofl__jiang"] = "当你使用红色牌时，你可以摸一张牌。",
}

jiang:addEffect(fk.CardUsing, {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(jiang.name) and
      data.card.color == Card.Red
  end,
  on_use = function (self, event, target, player, data)
    player:drawCards(1, jiang.name)
  end,
})

return jiang
