local zequan = fk.CreateSkill {
  name = "ofl__zequan"
}

Fk:loadTranslationTable{
  ['ofl__zequan'] = '责权',
  ['#ofl__zequan'] = '责权：将一张装备牌当任意锦囊牌对体力不小于你的其他角色使用',
  ['@$ofl__zequan'] = '责权',
  [':ofl__zequan'] = '你可以将一张装备牌当未以此法使用过的锦囊牌对体力不小于你的其他角色使用。',
}

zequan:addEffect('viewas', {
  pattern = ".|.|.|.|.|trick",
  prompt = "#ofl__zequan",
  interaction = function(self, player)
    local all_names = U.getAllCardNames("t")
    return U.CardNameBox {
      choices = U.getViewAsCardNames(player, zequan.name, all_names, nil, player:getTableMark("@$ofl__zequan")),
      all_choices = all_names,
      default_choice = zequan.name,
    }
  end,
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).type == Card.TypeEquip and Fk.all_card_types[skill.interaction.data] ~= nil
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 or Fk.all_card_types[skill.interaction.data] == nil then return end
    local card = Fk:cloneCard(skill.interaction.data)
    card:addSubcard(cards[1])
    card.skillName = zequan.name
    return card
  end,
  before_use = function(self, player, use)
    player.room:addTableMark(player, "@$ofl__zequan", use.card.trueName)
  end,
  enabled_at_play = Util.TrueFunc,
  enabled_at_response = function(self, player, response)
    if response then return end
    for _, id in ipairs(Fk:getAllCardIds()) do
      local card = Fk:getCardById(id)
      if card:isCommonTrick() and not card.is_derived and not card.is_passive and
        Exppattern:Parse(Fk.currentResponsePattern):match(card) and
        not table.contains(player:getTableMark("@$ofl__zequan"), card.trueName) then
        return true
      end
    end
  end,
  on_lose = function(self, player)
    player.room:setPlayerMark(player, "@$ofl__zequan", 0)
  end,
})

zequan:addEffect('prohibit', {
  name = "#ofl__zequan_prohibit",
  is_prohibited = function(self, from, to, card)
    return table.contains(card.skillNames, "ofl__zequan") and (from == to or from.hp > to.hp)
  end,
})

return zequan
