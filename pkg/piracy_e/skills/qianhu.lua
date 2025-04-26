local qianhu = fk.CreateSkill {
  name = "ofl__qianhu",
}

Fk:loadTranslationTable{
  ["ofl__qianhu"] = "前呼",
  [":ofl__qianhu"] = "出牌阶段，你可以弃置两张红色牌视为使用一张【决斗】，若你造成了伤害，你摸一张牌。",

  ["#ofl__qianhu"] = "前呼：弃置两张红色牌视为使用【决斗】，若你造成伤害则摸一张牌",
}

qianhu:addEffect("viewas", {
  anim_type = "offensive",
  prompt = "#ofl__qianhu",
  card_filter = function(self, player, to_select, selected)
    return #selected < 2 and Fk:getCardById(to_select).color == Card.Red and not player:prohibitDiscard(to_select)
  end,
  view_as = function(self, player, cards)
    if #cards ~= 2 then return end
    local card = Fk:cloneCard("duel")
    card.skillName = qianhu.name
    self.cost_data = cards
    return card
  end,
  before_use = function(self, player, use)
    player.room:throwCard(self.cost_data, qianhu.name, player, player)
  end,
  after_use = function (self, player, use)
    if not player.dead and use.damageDealt and
      table.find(player.room:getOtherPlayers(player, false, true), function (p)
        return use.damageDealt[p] ~= nil
      end) then
      player:drawCards(1, qianhu.name)
    end
  end,
})

return qianhu
