local xieyu = fk.CreateSkill {
  name = "ofl_tx__xieyu",
  tags = { Skill.Compulsory, Skill.Switch },
}

Fk:loadTranslationTable{
  ["ofl_tx__xieyu"] = "邪域",
  [":ofl_tx__xieyu"] = "转换技，锁定技，每轮开始时，你令本轮："..
  "阳：所有角色受到的火焰伤害+1，防止你受到的除火焰伤害以外的伤害；"..
  "阴：所有角色受到的雷电伤害+1，防止你受到的除雷电伤害以外的伤害。",

  ["@ofl_tx__xieyu-round"] = "邪域",
}

xieyu:addEffect(fk.RoundStart, {
  anim_type = "switch",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(xieyu.name)
  end,
  on_use = function (self, event, target, player, data)
    player.room:setPlayerMark(player, "@ofl_tx__xieyu-round", player:getSwitchSkillState(xieyu.name, true, true))
  end,
})

xieyu:addEffect(fk.DamageInflicted, {
  can_refresh = function (self, event, target, player, data)
    if player:getMark("@ofl_tx__xieyu-round") == "yang" and data.damageType == fk.FireDamage then
      return true
    elseif player:getMark("@ofl_tx__xieyu-round") == "yin" and data.damageType == fk.ThunderDamage then
      return true
    end
  end,
  on_refresh = function (self, event, target, player, data)
    data:changeDamage(1)
  end,
})

xieyu:addEffect(fk.DetermineDamageInflicted, {
  can_refresh = function (self, event, target, player, data)
    if target == player then
      if player:getMark("@ofl_tx__xieyu-round") == "yang" and data.damageType ~= fk.FireDamage then
        return true
      elseif player:getMark("@ofl_tx__xieyu-round") == "yin" and data.damageType ~= fk.ThunderDamage then
        return true
      end
    end
  end,
  on_refresh = function (self, event, target, player, data)
    data:preventDamage()
  end,
})

return xieyu
