local tuizhi = fk.CreateSkill {
  name = "tuizhi",
}

Fk:loadTranslationTable{
  ["tuizhi"] = "退制",
  [":tuizhi"] = "你可以展示并弃置一种颜色的所有手牌，视为使用一张基本牌，若造成了伤害，你摸一张牌。",

  ["#tuizhi"] = "退制：选择视为使用的基本牌，然后弃置一种颜色的手牌",
  ["#tuizhi-choice"] = "退制：展示并弃置一种颜色的所有手牌",
}

tuizhi:addEffect("viewas", {
  pattern = ".|.|.|.|.|basic",
  filter_pattern = {
    min_num = 0,
    max_num = 0,
    pattern = "",
    subcards = {}
  },
  prompt = "#tuizhi",
  interaction = function(self, player)
    local all_names = Fk:getAllCardNames("b")
    local names = player:getViewAsCardNames(tuizhi.name, all_names)
    if #names == 0 then return end
    return UI.CardNameBox {choices = names, all_names = all_names}
  end,
  card_filter = Util.FalseFunc,
  view_as = function(self, player, cards)
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = tuizhi.name
    return card
  end,
  before_use = function (self, player, use)
    local room = player.room
    local choices = {}
    for _, id in ipairs(player:getCardIds("h")) do
      if not player:prohibitDiscard(id) and Fk:getCardById(id).color ~= Card.NoColor then
        table.insertIfNeed(choices, Fk:getCardById(id):getColorString())
      end
    end
    if #choices == 0 then
      return tuizhi.name
    end
    local color = room:askToChoice(player, {
      choices = choices,
      skill_name = tuizhi.name,
      prompt = "#tuizhi-choice",
    })
    local cards = table.filter(player:getCardIds("h"), function (id)
      return Fk:getCardById(id):getColorString() == color
    end)
    player:showCards(cards)
    cards = table.filter(cards, function (id)
      return not player:prohibitDiscard(id) and table.contains(player:getCardIds("h"), id)
    end)
    if #cards == 0 then
      return tuizhi.name
    end
    room:throwCard(cards, tuizhi.name, player, player)
  end,
  after_use = function (self, player, use)
    if use.damageDealt and not player.dead then
      player:drawCards(1, tuizhi.name)
    end
  end,
  enabled_at_play = function (self, player)
    return table.find(player:getCardIds("h"), function (id)
      return not player:prohibitDiscard(id) and Fk:getCardById(id).color ~= Card.NoColor
    end)
  end,
  enabled_at_response = function (self, player, response)
    return not response and
      table.find(player:getCardIds("h"), function (id)
        return not player:prohibitDiscard(id) and Fk:getCardById(id).color ~= Card.NoColor
      end)
  end,
})

return tuizhi
