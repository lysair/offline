local pinghe = fk.CreateSkill {
  name = "sxfy__pinghe",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["sxfy__pinghe"] = "冯河",
  [":sxfy__pinghe"] = "锁定技，你的手牌上限基值为你已损失的体力值；当你受到其他角色造成的伤害时，你防止此伤害并减1点体力上限。",
}

pinghe:addEffect(fk.DamageInflicted, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(pinghe.name) and
      player.maxHp > 1 and data.from and data.from ~= player
  end,
  on_use = function(self, event, target, player, data)
    data.prevented = true
    player.room:changeMaxHp(player, -1)
  end,
})

pinghe:addEffect("maxcards", {
  fixed_func = function(self, player)
    if player:hasSkill(pinghe.name) then
      return player:getLostHp()
    end
  end,
})

return pinghe
