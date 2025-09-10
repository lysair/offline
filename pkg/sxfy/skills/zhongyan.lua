local zhongyanl = fk.CreateSkill {
  name = "sxfy__zhongyanl",
  tags = { Skill.Lord },
}

Fk:loadTranslationTable{
  ["sxfy__zhongyanl"] = "终焉",
  [":sxfy__zhongyanl"] = "主公技，当群势力角色死亡时，你可以回复1点体力。",
}

zhongyanl:addEffect(fk.Death, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(zhongyanl.name) and target.kingdom == "qun" and player:isWounded()
  end,
  on_use = function(self, event, target, player, data)
    player.room:recover{
      who = player,
      num = 1,
      recoverBy = player,
      skillName = zhongyanl.name,
    }
  end,
})

return zhongyanl
