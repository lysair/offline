local skill = fk.CreateSkill {
  name = "change_whip_subtype",
}

Fk:loadTranslationTable{
  ["change_whip_subtype"] = "指定类别",
  [":change_whip_subtype"] = "出牌阶段，你可以为手牌中的【刑鞭】指定副类别。",

  ["#change_whip_subtype"] = "指定【刑鞭】的副类别",
  ["@caning_whip"] = "",
}

skill:addEffect("active", {
  prompt = "#change_whip_subtype",
  target_num = 0,
  on_use = function(self, room, effect)
    local player = effect.from
    local sub_types = {
      "weapon",
      "armor",
      "defensive_horse",
      "offensive_horse",
      "treasure",
    }
    local choice = room:askToChoice(player, {
      choices = sub_types,
      skill_name = skill.name,
    })
    local card = Fk:getCardById(effect.cards[1])
    room:setCardMark(card, "@caning_whip", Fk:translate(choice))
    if Fk.printed_cards[card.id] then
      Fk.printed_cards[card.id].sub_type = table.indexOf(sub_types, choice) + 2
    else
      Fk.cards[card.id].sub_type = table.indexOf(sub_types, choice) + 2
    end
  end
})

return skill
