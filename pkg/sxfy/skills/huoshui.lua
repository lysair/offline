local huoshui = fk.CreateSkill {
  name = "sxfy__huoshui",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["sxfy__huoshui"] = "祸水",
  [":sxfy__huoshui"] = "锁定技，判定区有牌的其他角色受到的伤害+1。",
}

huoshui:addEffect(fk.DamageInflicted, {
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    return target ~= player and player:hasSkill(huoshui.name) and
      #target:getCardIds("j") > 0
  end,
  on_cost = function (self, event, target, player, data)
    event:setCostData(self, {tos = {target}})
    return true
  end,
  on_use = function(self, event, target, player, data)
    data:changeDamage(1)
  end,
})

return huoshui
