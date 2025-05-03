local renzheng = fk.CreateSkill {
  name = "sxfy__renzheng",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["sxfy__renzheng"] = "仁政",
  [":sxfy__renzheng"] = "锁定技，当有伤害被防止时，你令当前回合角色摸一张牌。",
}

renzheng:addEffect(fk.DamageFinished, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(renzheng.name) and data.prevented
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, renzheng.name)
  end,
})

return renzheng
