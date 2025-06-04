local sangu_viewas = fk.CreateSkill {
  name = "ofl__sangu&",
}

Fk:loadTranslationTable{
  ["ofl__sangu&"] = "三顾",
  [":ofl__sangu&"] = "出牌阶段每种牌名限一次，你可以将一张手牌当一张“三顾”牌使用。",

  ["#ofl__sangu"] = "三顾：你可以将一张手牌当一张“三顾”牌使用",
}

sangu_viewas:addEffect("viewas", {
  prompt = "#ofl__sangu",
  interaction = function(self, player)
    local all_names = player:getTableMark("@$ofl__sangu-phase")
    local names = player:getViewAsCardNames("ofl__sangu", all_names)
    if #names == 0 then return end
    return UI.CardNameBox { choices = names, all_choices = all_names }
  end,
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and table.contains(player:getHandlyIds(), to_select)
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 or self.interaction.data == nil then return end
    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcard(cards[1])
    card.skillName = "ofl__sangu"
    return card
  end,
  before_use = function(self, player, use)
    local room = player.room
    room:removeTableMark(player, "@$ofl__sangu-phase", use.card.name)
    if player:getMark("@$ofl__sangu-phase") == 0 then
      room:handleAddLoseSkills(player, "-ofl__sangu&", nil, false, true)
    end
  end,
})

return sangu_viewas
