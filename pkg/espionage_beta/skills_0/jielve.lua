local jielve = fk.CreateSkill {
  name = "jielve"
}

Fk:loadTranslationTable{
  ['jielve'] = '劫掠',
  ['#jielve'] = '劫掠：你可以将两张相同颜色的牌当【趁火打劫】使用',
  [':jielve'] = '出牌阶段限一次，你可以将两张相同颜色的牌当【趁火打劫】使用。你使用【趁火打劫】效果改为：目标角色展示所有手牌，你选择一项：1.将其中一张牌交给另一名角色；2.你对其造成1点伤害。',
}

jielve:addEffect('viewas', {
  anim_type = "control",
  prompt = "#jielve",
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    if #selected == 1 then
      return Fk:getCardById(to_select).color == Fk:getCardById(selected[1]).color
    elseif #selected > 1 then
      return false
    end
    return true
  end,
  view_as = function(self, player, cards)
    if #cards ~= 2 then return end
    local card = Fk:cloneCard("looting")
    card:addSubcards(cards)
    card.skillName = jielve.name
    return card
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(jielve.name, Player.HistoryPhase) == 0 and not player:isNude()
  end,
})

jielve:addEffect(fk.PreCardEffect, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill("jielve") and data.from == player.id and data.card.trueName == "looting"
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local card = data.card:clone()
    local c = table.simpleClone(data.card)
    for k, v in pairs(c) do
      if card[k] == nil then
        card[k] = v
      end
    end
    card.skill = jielve__lootingSkill
    data.card = card
  end,
})

return jielve
