local choujue = fk.CreateSkill {
  name = "ofl_tx__choujue",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_tx__choujue"] = "仇绝",
  [":ofl_tx__choujue"] = "锁定技，结束阶段，你选择一名其他角色，你与其各失去1点体力，然后依次视为对其使用【杀】、【决斗】。",

  ["#ofl_tx__choujue-choose"] = "仇绝：与一名角色各失去1点体力，然后视为对其使用【杀】和【决斗】！",
}

choujue:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(choujue.name) and player.phase == Player.Finish and
      #player.room:getOtherPlayers(player, false) > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room:getOtherPlayers(player, false),
      skill_name = choujue.name,
      prompt = "#ofl_tx__choujue-choose",
      cancelable = false,
    })[1]
    room:loseHp(player, 1, choujue.name)
    if to.dead then return end
    room:loseHp(to, 1, choujue.name)
    for _, name in ipairs({"slash", "duel"}) do
      if player.dead or to.dead then return end
      room:useVirtualCard(name, nil, player, to, choujue.name, true)
    end
  end,
})

return choujue
