local jielve = fk.CreateSkill {
  name = "jielve",
}

Fk:loadTranslationTable{
  ["jielve"] = "劫掠",
  [":jielve"] = "出牌阶段限一次，你可以将两张相同颜色的牌当【趁火打劫】使用。你使用【趁火打劫】效果改为：目标角色展示所有手牌，你选择一项："..
  "1.将其中一张牌交给另一名角色；2.你对其造成1点伤害。",

  ["#jielve"] = "劫掠：你可以将两张相同颜色的牌当【趁火打劫】使用",
}

jielve:addEffect("viewas", {
  anim_type = "control",
  prompt = "#jielve",
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    if #selected == 1 then
      return Fk:getCardById(to_select).color == Fk:getCardById(selected[1]).color
    elseif #selected > 1 then
      return false
    end
    return Fk:getCardById(to_select).color ~= Card.NoColor
  end,
  view_as = function(self, player, cards)
    if #cards ~= 2 then return end
    local card = Fk:cloneCard("looting")
    card:addSubcards(cards)
    card.skillName = jielve.name
    return card
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(jielve.name, Player.HistoryPhase) == 0
  end,
})

jielve:addEffect(fk.PreCardEffect, {
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(jielve.name) and data.from == player and data.card.name == "looting"
  end,
  on_refresh = function(self, event, target, player, data)
    local card = data.card:clone()
    local c = table.simpleClone(data.card)
    for k, v in pairs(c) do
      card[k] = v
    end
    card.skill = Fk.skills["jielve__looting_skill"]
    data.card = card
  end,
})

return jielve
