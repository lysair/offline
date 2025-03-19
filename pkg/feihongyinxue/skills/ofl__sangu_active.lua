local ofl__sangu_active = fk.CreateSkill {
  name = "ofl__sangu&"
}

Fk:loadTranslationTable{
  ['ofl__sangu&'] = '三顾',
  ['#ofl__sangu'] = '三顾：你可以将一张手牌当一张“三顾”牌使用',
  ['@$ofl__sangu-phase'] = '三顾',
  [':ofl__sangu&'] = '出牌阶段每种牌名限一次，你可以将一张手牌当一张“三顾”牌使用。',
}

ofl__sangu_active:addEffect('viewas', {
  pattern = ".",
  prompt = "#ofl__sangu",
  interaction = function()
    return UI.ComboBox {choices = Self.player:getMark("@$ofl__sangu-phase")}
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:currentRoom():getCardArea(to_select) == Player.Hand
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 or not skill.interaction.data then return end
    local card = Fk:cloneCard(skill.interaction.data)
    card:addSubcard(cards[1])
    card.skillName = ofl__sangu_active.name
    return card
  end,
  before_use = function(self, player, use)
    player.room:removeTableMark(player, "@$ofl__sangu-phase", use.card.name)
  end,
  enabled_at_play = function(self, player)
    return not player:isKongcheng() and player:getMark("@$ofl__sangu-phase") ~= 0
  end,
  enabled_at_response = function(self, player, response)
    return not response and not player:isKongcheng() and player:getMark("@$ofl__sangu-phase") ~= 0
  end,
})

return ofl__sangu_active
