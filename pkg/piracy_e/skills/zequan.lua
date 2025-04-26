local zequan = fk.CreateSkill {
  name = "ofl__zequan",
}

Fk:loadTranslationTable{
  ["ofl__zequan"] = "责权",
  [":ofl__zequan"] = "你可以将一张装备牌当未以此法使用过的锦囊牌对体力不小于你的其他角色使用。",

  ["#ofl__zequan"] = "责权：将一张装备牌当任意锦囊牌对体力不小于你的其他角色使用",
}

local U = require "packages/utility/utility"

zequan:addEffect("viewas", {
  pattern = ".|.|.|.|.|trick",
  prompt = "#ofl__zequan",
  interaction = function(self, player)
    local all_names = Fk:getAllCardNames("t")
    local names = player:getViewAsCardNames(zequan.name, all_names, nil, player:getTableMark(zequan.name))
    if #names == 0 then return end
    return U.CardNameBox { choices = names, all_choices = all_names }
  end,
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).type == Card.TypeEquip and Fk.all_card_types[self.interaction.data] ~= nil
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 or Fk.all_card_types[self.interaction.data] == nil then return end
    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcard(cards[1])
    card.skillName = zequan.name
    return card
  end,
  before_use = function(self, player, use)
    player.room:addTableMark(player, zequan.name, use.card.trueName)
  end,
  enabled_at_play = Util.TrueFunc,
  enabled_at_response = function(self, player, response)
    return not response and
      #player:getViewAsCardNames(zequan.name, Fk:getAllCardNames("t"), nil, player:getTableMark(zequan.name)) > 0
  end,
})

zequan:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, zequan.name, 0)
end)

zequan:addEffect("prohibit", {
  is_prohibited = function(self, from, to, card)
    return table.contains(card.skillNames, zequan.name) and (from == to or from.hp > to.hp)
  end,
})

return zequan
