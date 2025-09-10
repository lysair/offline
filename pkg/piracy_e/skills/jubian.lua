local jubian = fk.CreateSkill {
  name = "jubian",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["jubian"] = "惧鞭",
  [":jubian"] = "锁定技，当你受到其他角色造成的伤害时，若你的手牌数大于体力值，你将手牌弃至体力值，防止此伤害。",
}

jubian:addEffect(fk.DamageInflicted, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jubian.name) and
      data.from and data.from ~= player and player:getHandcardNum() > player.hp
  end,
  on_use = function(self, event, target, player, data)
    data:preventDamage()
    local n = player:getHandcardNum() - player.hp
    player.room:askToDiscard(player, {
      min_num = n,
      max_num = n,
      include_equip = false,
      skill_name = jubian.name,
      cancelable = false,
    })
  end,
})

return jubian
