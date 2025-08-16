local hanci = fk.CreateSkill {
  name = "hanci",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["hanci"] = "寒慈",
  [":hanci"] = "锁定技，当一名角色获得技能后，你与其各摸一张牌。",
}

hanci:addEffect(fk.EventAcquireSkill, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(hanci.name) and
      data.skill:isPlayerSkill(target) and player.room:getBanner("RoundCount") and not target.dead
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, hanci.name)
    if not target.dead then
      target:drawCards(1, hanci.name)
    end
  end,
})

return hanci
