local bimeng = fk.CreateSkill {
  name = "bimeng",
}

Fk:loadTranslationTable{
  ["bimeng"] = "蔽蒙",
  [":bimeng"] = "出牌阶段限一次，你可以将X张手牌当任意一张基本牌或普通锦囊牌使用（X为你的体力值）。",

  ["#bimeng"] = "蔽蒙：你可以将%arg张手牌当任意基本牌或普通锦囊牌使用",
}

bimeng:addEffect("viewas", {
  prompt = function (self, player, selected_cards)
    return "#bimeng:::"..player.hp
  end,
  interaction = function(self, player)
    local all_names = Fk:getAllCardNames("bt")
    local names = player:getViewAsCardNames(bimeng.name, all_names)
    if #names > 0 then
      return UI.CardNameBox { choices = names, all_choices = all_names }
    end
  end,
  handly_pile = true,
  card_filter = function (self, player, to_select, selected)
    return #selected < player.hp and table.contains(player:getHandlyIds(), to_select)
  end,
  view_as = function(self, player, cards)
    if #cards ~= player.hp or not self.interaction.data then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = bimeng.name
    card:addSubcards(cards)
    return card
  end,
  enabled_at_play = function (self, player)
    return player:usedSkillTimes(bimeng.name, Player.HistoryPhase) == 0 and player.hp > 0
  end,
})

return bimeng
