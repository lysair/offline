local xiuluo = fk.CreateSkill {
  name = "ofl_tx__xiuluo",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_tx__xiuluo"] = "修罗",
  [":ofl_tx__xiuluo"] = "锁定技，你跳过判定阶段和弃牌阶段；当你翻至背面朝上时，防止之。当你受到伤害时，你令此伤害减半（向上取整），"..
  "然后视为对伤害来源使用一张无视防具的【杀】，此【杀】造成伤害后，你回复等量的体力。",
}

xiuluo:addEffect(fk.EventPhaseChanging, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xiuluo.name) and
      table.contains({ Player.Judge, Player.Discard }, data.phase) and not data.skipped
  end,
  on_use = function (self, event, target, player, data)
    data.skipped = true
  end,
})

xiuluo:addEffect(fk.BeforeTurnOver, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xiuluo.name) and player.faceup
  end,
  on_use = function (self, event, target, player, data)
    data.prevented = true
  end,
})

xiuluo:addEffect(fk.DamageInflicted, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xiuluo.name)
  end,
  on_use = function (self, event, target, player, data)
    data:changeDamage(-math.ceil(data.damage / 2))
    if data.from and not data.from.dead and data.from ~= player then
      player.room:useVirtualCard("slash", nil, player, data.from, xiuluo.name, true)
    end
  end,
})

xiuluo:addEffect(fk.Damage, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and data.card and
      table.contains(data.card.skillNames, xiuluo.name) and not player.dead
  end,
  on_use = function (self, event, target, player, data)
    player.room:recover{
      who = player,
      num = data.damage,
      recoverBy = player,
      skillName = xiuluo.name,
    }
  end,
})

xiuluo:addEffect(fk.TargetSpecified, {
  can_refresh = function(self, event, target, player, data)
    return table.contains(data.card.skillNames, xiuluo.name) and not data.to.dead
  end,
  on_refresh = function(self, event, target, player, data)
    data.to:addQinggangTag(data)
  end,
})

return xiuluo
