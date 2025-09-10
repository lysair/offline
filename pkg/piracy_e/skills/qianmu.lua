
local qianmu = fk.CreateSkill {
  name = "qianmu",
}

Fk:loadTranslationTable{
  ["qianmu"] = "浅目",
  [":qianmu"] = "每回合各限一次，你可以展示并将一张<font color='red'>♦</font>牌当基本牌、<font color='red'>♥</font>牌当锦囊牌"..
  "使用或打出。",

  ["#qianmu"] = "浅目：将<font color='red'>♦</font>牌当基本牌、<font color='red'>♥</font>牌当锦囊牌使用或打出",
}

qianmu:addEffect("viewas", {
  pattern = ".",
  prompt = "#qianmu",
  interaction = function(self, player)
    local all_names = {}
    if not table.contains(player:getTableMark("qianmu-turn"), "basic") then
      all_names = Fk:getAllCardNames("b")
    end
    if not table.contains(player:getTableMark("qianmu-turn"), "trick") then
      table.insertTable(all_names, Fk:getAllCardNames("td"))
    end
    local names = player:getViewAsCardNames(qianmu.name, all_names)
    if #names == 0 then return end
    return UI.CardNameBox {choices = names, all_choices = all_names}
  end,
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    if #selected == 0 and self.interaction.data ~= nil then
      if Fk:cloneCard(self.interaction.data).type == Card.TypeBasic then
        return Fk:getCardById(to_select).suit == Card.Diamond
      else
        return Fk:getCardById(to_select).suit == Card.Heart
      end
    end
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 or self.interaction.data == nil then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = qianmu.name
    card:addSubcard(cards[1])
    return card
  end,
  before_use = function (self, player, use)
    local room = player.room
    local id = Card:getIdList(use.card)[1]
    player:showCards({id})
    if room:getCardOwner(id) ~= player then
      return qianmu.name
    end
    room:addTableMark(player, "qianmu-turn", use.card:getTypeString())
  end,
  enabled_at_play = function (self, player)
    return #player:getTableMark("qianmu-turn") < 2
  end,
  enabled_at_response = function (self, player, response)
    if not table.contains(player:getTableMark("qianmu-turn"), "basic") and
      #player:getViewAsCardNames(qianmu.name, Fk:getAllCardNames("b")) > 0 then
      return true
    end
    if not table.contains(player:getTableMark("qianmu-turn"), "trick") and
      #player:getViewAsCardNames(qianmu.name, Fk:getAllCardNames("td")) > 0 then
      return true
    end
  end,
})

qianmu:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, "qianmu-turn", 0)
end)

qianmu:addAI(nil, "vs_skill")

return qianmu
