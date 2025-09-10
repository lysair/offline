local longyi = fk.CreateSkill {
  name = "longyi",
}

Fk:loadTranslationTable{
  ["longyi"] = "龙裔",
  [":longyi"] = "你可以将所有手牌当任意一张基本牌使用或打出，若其中有：锦囊牌，你摸一张牌；装备牌，此牌不可被响应。",

  ["#longyi"] = "龙裔：你可以将所有手牌当任意一张基本牌使用或打出",
}

longyi:addEffect("viewas", {
  anim_type = "special",
  pattern = ".|.|.|.|.|basic",
  prompt = "#longyi",
  interaction = function(self, player)
    local all_names = Fk:getAllCardNames("b")
    local names = player:getViewAsCardNames(longyi.name, all_names, player:getCardIds("h"))
    if #names > 0 then
      return UI.CardNameBox { choices = names, all_choices = all_names }
    end
  end,
  card_filter = Util.FalseFunc,
  view_as = function(self, player, cards)
    if not self.interaction.data then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = longyi.name
    card:addSubcards(player:getCardIds("h"))
    return card
  end,
  before_use = function(self, player, use)
    if table.find(use.card.subcards, function (id)
      return Fk:getCardById(id).type == Card.TypeTrick
    end) then
      player:drawCards(1, longyi.name)
    end
    if table.find(use.card.subcards, function (id)
      return Fk:getCardById(id).type == Card.TypeEquip
    end) then
      use.disresponsiveList = table.simpleClone(player.room.players)
    end
  end,
  enabled_at_play = function(self, player)
    return not player:isKongcheng()
  end,
  enabled_at_response = function(self, player, response)
    return not player:isKongcheng()
  end,
})

longyi:addAI(nil, "vs_skill")

return longyi
