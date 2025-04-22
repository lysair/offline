local ofl_shiji__miewu = fk.CreateSkill {
  name = "ofl_shiji__miewu"
}

Fk:loadTranslationTable{
  ['ofl_shiji__miewu'] = '灭吴',
  ['#ofl_shiji__miewu'] = '灭吴：你可以将一张牌当任意基本牌或普通锦囊牌使用或打出',
  [':ofl_shiji__miewu'] = '每回合每种牌名限一次，你可以移去1枚“武库”标记，将一张牌当任意一张基本牌或普通锦囊牌使用或打出。',
  ['$ofl_shiji__miewu1'] = '驭虬吞江为平地，剑指东南定吴夷。',
  ['$ofl_shiji__miewu2'] = '九州从来向一统，岂容伪朝至两分？',
}

ofl_shiji__miewu:addEffect("viewas", {
  pattern = ".",
  prompt = "#ofl_shiji__miewu",
  interaction = function(self, player)
    local names, all_names = {}, {}
    local mark = player:getTableMark(ofl_shiji__miewu.name .. "-turn")
    for _, id in ipairs(Fk:getAllCardIds()) do
      local card = Fk:getCardById(id)
      if (card.type == Card.TypeBasic or card:isCommonTrick()) and not card.is_derived then
        table.insertIfNeed(all_names, card.name)
        local to_use = Fk:cloneCard(card.name)
        if not table.contains(mark, card.trueName) and
          ((Fk.currentResponsePattern == nil and player:canUse(to_use) and not player:prohibitUse(to_use)) or
          (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(to_use))) then
          table.insertIfNeed(names, card.name)
        end
      end
    end
    if #names == 0 then return false end
    return UI.ComboBox { choices = names, all_choices = all_names }
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 or not skill.interaction.data then return end
    local card = Fk:cloneCard(skill.interaction.data)
    card:addSubcards(cards)
    card.skillName = ofl_shiji__miewu.name
    return card
  end,
  before_use = function(self, player, use)
    local room = player.room
    room:removePlayerMark(player, "@wuku", 1)
    room:addTableMark(player, ofl_shiji__miewu.name .. "-turn", use.card.trueName)
  end,
  enabled_at_play = function(self, player)
    return player:getMark("@wuku") > 0 and not player:isNude()
  end,
  enabled_at_response = function(self, player, response)
    return player:getMark("@wuku") > 0 and not player:isNude()
  end,
})

return ofl_shiji__miewu
