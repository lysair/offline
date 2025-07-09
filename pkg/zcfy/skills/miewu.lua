local miewu = fk.CreateSkill {
  name = "sxfy__miewu",
}

Fk:loadTranslationTable{
  ["sxfy__miewu"] = "灭吴",
  [":sxfy__miewu"] = "每回合限一次，你可以将一张装备牌当任意一张基本牌或普通锦囊牌使用或打出。",

  ["#sxfy__miewu"] = "灭吴：将一张装备牌当任意一张基本牌或普通锦囊牌使用或打出",
}

miewu:addEffect("viewas", {
  pattern = ".",
  prompt = "#sxfy__miewu",
  interaction = function(self, player)
    local all_names = Fk:getAllCardNames("bt")
    local names = player:getViewAsCardNames(miewu.name, all_names)
    if #names == 0 then return end
    return UI.CardNameBox {choices = names, all_choices = all_names}
  end,
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).type == Card.TypeEquip
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 or not self.interaction.data then return end
    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcards(cards)
    card.skillName = miewu.name
    return card
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(miewu.name, Player.HistoryTurn) == 0
  end,
  enabled_at_response = function(self, player, response)
    return player:usedSkillTimes(miewu.name, Player.HistoryTurn) == 0
  end,
})

return miewu
