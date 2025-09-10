local zhongshi = fk.CreateSkill {
  name = "zhongshi",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["zhongshi"] = "忠事",
  [":zhongshi"] = "锁定技，你对横置状态与你不同的角色造成伤害时，此伤害+1。",
}

zhongshi:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zhongshi.name) and
      ((player.chained and not data.to.chained) or (not player.chained and data.to.chained))
  end,
  on_use = function(self, event, target, player, data)
    data:changeDamage(1)
  end,
})

return zhongshi