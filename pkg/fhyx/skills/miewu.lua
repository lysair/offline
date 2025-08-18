local miewu = fk.CreateSkill {
  name = "ofl_shiji__miewu",
}

Fk:loadTranslationTable{
  ["ofl_shiji__miewu"] = "灭吴",
  [":ofl_shiji__miewu"] = "每回合每种牌名限一次，你可以移去1枚“武库”标记，将一张牌当任意一张基本牌或普通锦囊牌使用或打出。",

  ["#ofl_shiji__miewu"] = "灭吴：你可以将一张牌当任意基本牌或普通锦囊牌使用或打出",

  ["$ofl_shiji__miewu1"] = "驭虬吞江为平地，剑指东南定吴夷。",
  ["$ofl_shiji__miewu2"] = "九州从来向一统，岂容伪朝至两分？",
}

miewu:addEffect("viewas", {
  pattern = ".",
  prompt = "#ofl_shiji__miewu",
  interaction = function(self, player)
    local all_names = Fk:getAllCardNames("bt")
    local names = player:getViewAsCardNames(miewu.name, all_names, nil, player:getTableMark("ofl_shiji__miewu-turn"))
    return UI.CardNameBox { choices = names, all_choices = all_names }
  end,
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 or not self.interaction.data then return end
    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcards(cards)
    card.skillName = miewu.name
    return card
  end,
  before_use = function(self, player, use)
    local room = player.room
    room:removePlayerMark(player, "@wuku", 1)
    room:addTableMark(player, "ofl_shiji__miewu-turn", use.card.trueName)
  end,
  enabled_at_play = function(self, player)
    return player:getMark("@wuku") > 0 and
      #player:getViewAsCardNames(miewu.name, Fk:getAllCardNames("bt"), nil, player:getTableMark("ofl_shiji__miewu-turn")) > 0
  end,
  enabled_at_response = function(self, player, response)
    return player:getMark("@wuku") > 0 and
      #player:getViewAsCardNames(miewu.name, Fk:getAllCardNames("bt"), nil, player:getTableMark("ofl_shiji__miewu-turn")) > 0
  end,
})

miewu:addAI(nil, "vs_skill")

return miewu
