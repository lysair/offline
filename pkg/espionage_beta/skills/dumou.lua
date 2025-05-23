local dumou = fk.CreateSkill {
  name = "dumou",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["dumou"] = "毒谋",
  [":dumou"] = "锁定技，你的回合内，其他角色的黑色手牌均视为【毒】，你的【毒】均视为【过河拆桥】。",
}

dumou:addEffect("filter", {
  card_filter = function(self, card, player, to_select)
    if Fk:currentRoom().current:hasSkill(dumou.name) and
      table.contains(player:getCardIds("h"), card.id) then
      if Fk:currentRoom().current == player then
        return card.trueName == "poison"
      else
        return card.color == Card.Black
      end
    end
  end,
  view_as = function(self, player, to_select)
    local card
    if Fk:currentRoom().current == player then
      card = Fk:cloneCard("es__poison", to_select.suit, to_select.number)
    else
      card = Fk:cloneCard("dismantlement", to_select.suit, to_select.number)
    end
    card.skillName = dumou.name
    return card
  end,
})

return dumou
