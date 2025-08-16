local chaofu = fk.CreateSkill {
  name = "chaofu",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["chaofu"] = "朝缚",
  [":chaofu"] = "锁定技，若你的技能数小于一号位，当你使用基本牌后，你减1点体力上限；你受到的伤害值均改为1。",
}

chaofu:addEffect(fk.CardUseFinished, {
  anim_type = "negative",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(chaofu.name) and
      data.card.type == Card.TypeBasic and #player:getSkillNameList() < #player.room:getPlayerBySeat(1):getSkillNameList()
  end,
  on_use = function(self, event, target, player, data)
    player.room:changeMaxHp(player, -1)
  end,
})

chaofu:addEffect(fk.DetermineDamageInflicted, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(chaofu.name) and
      data.damage > 1
  end,
  on_use = function(self, event, target, player, data)
    data:changeDamage(1 - data.damage)
  end,
})

return chaofu
