local zhuying = fk.CreateSkill {
  name = "zhuying",
}

Fk:loadTranslationTable{
  ["zhuying"] = "驻营",
  [":zhuying"] = "当其他角色受到非属性伤害时，你可以令其横置。",

  ["#zhuying-invoke"] = "驻营：是否令 %dest 横置？",
}

zhuying:addEffect(fk.DamageInflicted, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(zhuying.name) and
      not target.chained and data.damageType ~= fk.NormalDamage
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = zhuying.name,
      prompt = "#zhuying-invoke::"..target.id,
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    target:setChainState(true)
  end,
})

return zhuying