local ironBudSkill = fk.CreateSkill {
  name = "#iron_bud_skill"
}

Fk:loadTranslationTable{
  ['#iron_bud_skill'] = '铁蒺藜骨朵',
  ['iron_bud'] = '铁蒺藜骨朵',
  ['#iron_bud_skill-invoke'] = '是否将【铁蒺藜骨朵】本回合的攻击范围改为%arg？',
}

ironBudSkill:addEffect(fk.EventPhaseStart, {
  attached_equip = "iron_bud",
  can_trigger = function(self, event, target, player)
    return target == player and player:hasSkill(ironBudSkill.name) and player.phase == Player.Start and player.hp ~= 2
  end,
  on_cost = function(self, event, target, player)
    return player.room:askToSkillInvoke(player, {
      skill_name = ironBudSkill.name,
      prompt = "#iron_bud_skill-invoke:::" .. player.hp
    })
  end,
  on_use = function(self, event, target, player)
    player.room:setPlayerMark(player, "iron_bud-turn", player.hp)
  end
})

return ironBudSkill
