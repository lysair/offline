local wudu = fk.CreateSkill {
  name = "sxfy__wudu",
}

Fk:loadTranslationTable{
  ["sxfy__wudu"] = "无度",
  [":sxfy__wudu"] = "当一名没有手牌的角色受到伤害时，你可以减1点体力上限，防止此伤害。",

  ["#sxfy__wudu-invoke"] = "无度：是否减1点体力上限，防止 %dest 受到的伤害？",
}

wudu:addEffect(fk.DamageInflicted, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(wudu.name) and target:isKongcheng() and not target.dead
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askToSkillInvoke(player, {
      skill_name = wudu.name,
      prompt = "#sxfy__wudu-invoke::"..data.to.id,
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:changeMaxHp(player, -1)
    data:preventDamage()
  end,
})

return wudu
