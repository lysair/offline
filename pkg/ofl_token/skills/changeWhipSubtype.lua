local changeWhipSubtype = fk.CreateSkill {
  name = "changeWhipSubtype"
}

Fk:loadTranslationTable{
  ['changeWhipSubtype'] = '指定类别',
  ['#changeWhipSubtype'] = '指定【刑鞭】的副类别',
  ['@caning_whip'] = '',
  [':changeWhipSubtype'] = '出牌阶段，你可以为手牌中的【刑鞭】指定副类别。',
}

changeWhipSubtype:addEffect('active', {
  card_num = 1,
  target_num = 0,
  prompt = "#" .. changeWhipSubtype.name,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).type == Card.TypeEquip and
      Fk:currentRoom():getCardArea(to_select) ~= Player.Equip
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local choice = room:askToChoice(player, {
      choices = sub_types
    })
    local card = Fk:getCardById(effect.cards[1])
    room:setCardMark(card, "@caning_whip", Fk:translate(choice))
    Fk.printed_cards[effect.cards[1]].sub_type = table.indexOf(sub_types, choice) + 2
  end
})

return changeWhipSubtype
