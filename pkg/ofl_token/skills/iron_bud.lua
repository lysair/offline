local skill = fk.CreateSkill {
  name = "#iron_bud_skill",
  attached_equip = "iron_bud",
}

Fk:loadTranslationTable{
  ["#iron_bud_skill"] = "铁蒺藜骨朵",
  ["#iron_bud_skill-invoke"] = "是否将【铁蒺藜骨朵】本回合的攻击范围改为%arg？",
}

skill:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skill.name) and player.phase == Player.Start and
      player.hp ~= 2
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = skill.name,
      prompt = "#iron_bud_skill-invoke:::" .. player.hp,
    })
  end,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "iron_bud-turn", player.hp)
  end
})

return skill
