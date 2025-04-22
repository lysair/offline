local yujun = fk.CreateSkill {
  name = "ofl__yujun",
}

Fk:loadTranslationTable{
  ["ofl__yujun"] = "御军",
  [":ofl__yujun"] = "处于连环状态的角色受到属性伤害时，你可以翻面并失去1点体力，摸三张牌，防止其受到的伤害。",

  ["#ofl__yujun-invoke"] = "御军：你可以翻面、失去1点体力、摸三张牌，防止 %dest 受到的伤害",
}

yujun:addEffect(fk.DamageInflicted, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(yujun.name) and target.chained and data.damageType ~= fk.NormalDamage
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = yujun.name,
      prompt = "#ofl__yujun-invoke::"..target.id,
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    data:preventDamage()
    player:turnOver()
    if player.dead then return end
    room:loseHp(player, 1, yujun.name)
    if player.dead then return end
    player:drawCards(3, yujun.name)
  end,
})

return yujun