local liezhou = fk.CreateSkill {
  name = "ofl__liezhou",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl__liezhou"] = "烈舟",
  [":ofl__liezhou"] = "锁定技，你造成的伤害均改为火焰伤害；当你对武将牌横置的角色造成伤害后，你摸X张牌（X为伤害值）。",
}

liezhou:addEffect(fk.PreDamage, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(liezhou.name)
  end,
  on_use = function(self, event, target, player, data)
    data.damageType = fk.FireDamage
  end,
})

liezhou:addEffect(fk.Damage, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(liezhou.name) and (data.extra_data or {}).ofl__liezhou
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(data.damage, liezhou.name)
  end,
})

liezhou:addEffect(fk.DamageCaused, {
  can_refresh = function(self, event, target, player, data)
    return target == player and data.to.chained
  end,
  on_refresh = function(self, event, target, player, data)
    data.extra_data = data.extra_data or {}
    data.extra_data.ofl__liezhou = true
  end,
})

return liezhou