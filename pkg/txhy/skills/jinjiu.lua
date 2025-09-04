local jinjiu = fk.CreateSkill {
  name = "ofl_tx__jinjiu",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_tx__jinjiu"] = "禁酒",
  [":ofl_tx__jinjiu"] = "锁定技，你的【酒】视为【杀】，你以此法使用的【杀】伤害+1；你的回合内，其他角色不能使用【酒】。",

  ["$ofl_tx__jinjiu1"] = "贬酒阙色，所以无污。",
  ["$ofl_tx__jinjiu2"] = "避嫌远疑，所以无误。",
}

jinjiu:addEffect(fk.PreCardUse, {
  can_refresh = function (self, event, target, player, data)
    return target == player and table.contains(data.card.skillNames, jinjiu.name)
  end,
  on_refresh = function (self, event, target, player, data)
    data.additionalDamage = (data.additionalDamage or 0) + 1
  end,
})

jinjiu:addEffect("filter", {
  anim_type = "offensive",
  card_filter = function(self, card, player, isJudgeEvent)
    return player:hasSkill(jinjiu.name) and card.name == "analeptic" and
      (table.contains(player:getCardIds("h"), card.id) or isJudgeEvent)
  end,
  view_as = function(self, player, card)
    local c = Fk:cloneCard("slash", card.suit, card.number)
    c.skillName = jinjiu.name
    return c
  end,
})

jinjiu:addEffect("prohibit", {
  prohibit_use = function (self, player, card)
    if Fk:currentRoom().current:hasSkill(jinjiu.name) then
      return player ~= Fk:currentRoom().current and card and card.name == "analeptic"
    end
  end,
})

return jinjiu
