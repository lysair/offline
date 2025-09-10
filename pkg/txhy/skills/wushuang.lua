local wushuang = fk.CreateSkill {
  name = "ofl_tx__wushuang",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_tx__wushuang"] = "无双",
  [":ofl_tx__wushuang"] = "锁定技，你使用的【杀】需两张【闪】才能抵消；与你进行【决斗】的角色每次响应需打出两张【杀】。"..
  "当你因【杀】或【决斗】造成伤害后，摸X张牌（X为伤害值）。",

  ["$ofl_tx__wushuang1"] = "谁能挡我！",
  ["$ofl_tx__wushuang2"] = "神挡杀神，佛挡杀佛！",
}

local spec = {
  on_use = function(self, event, target, player, data)
    local to = (event == fk.TargetConfirmed and data.card.trueName == "duel") and data.from or data.to
    data:setResponseTimes(2, to)
  end,
}

wushuang:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(wushuang.name) and
      table.contains({ "slash", "duel" }, data.card.trueName)
  end,
  on_use = spec.on_use,
})
wushuang:addEffect(fk.TargetConfirmed, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(wushuang.name) and data.card.trueName == "duel"
  end,
  on_use = spec.on_use,
})

wushuang:addEffect(fk.Damage, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(wushuang.name) and
      data.card and table.contains({ "slash", "duel" }, data.card.trueName)
  end,
  on_use = function (self, event, target, player, data)
    player:drawCards(data.damage, wushuang.name)
  end,
})

return wushuang
