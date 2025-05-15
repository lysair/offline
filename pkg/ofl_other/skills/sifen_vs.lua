local sifen_vs = fk.CreateSkill {
  name = "sifen&",
}

Fk:loadTranslationTable{
  ["sifen&"] = "俟奋",
  [":sifen&"] = "你可以将等量张红色牌当【决斗】对“俟奋”目标使用。",

  ["#sifen&"] = "俟奋：你可以将%arg张红色牌当【决斗】对 %dest 使用",
}

sifen_vs:addEffect("viewas", {
  anim_type = "offensive",
  prompt = function (self, player, selected_cards, selected)
    local info = player:getMark("sifen-phase")[1]
    return "#sifen&::"..info[1]..":"..info[2]
  end,
  handly_pile = true,
  card_filter = function (self, player, to_select, selected)
    return table.find(player:getMark("sifen-phase"), function (info)
      return info[2] > #selected
    end) and Fk:getCardById(to_select).color == Card.Red
  end,
  view_as = function(self, player, cards)
    if not table.find(player:getMark("sifen-phase"), function (info)
      return info[2] == #cards
    end) then
      return
    end
    local card = Fk:cloneCard("duel")
    card.skillName = sifen_vs.name
    card:addSubcards(cards)
    return card
  end,
  enabled_at_response = function (self, player, response)
    return not response
  end,
})

sifen_vs:addEffect("prohibit", {
  is_prohibited = function (self, from, to, card)
    if card and table.contains(card.skillNames, sifen_vs.name) and to then
      return not table.find(from:getMark("sifen-phase"), function (info)
        return info[1] == to.id and info[2] == #card.subcards
      end)
    end
  end,
})

return sifen_vs
