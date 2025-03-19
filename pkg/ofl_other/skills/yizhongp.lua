local yizhongp = fk.CreateSkill {
  name = "yizhongp"
}

Fk:loadTranslationTable{
  ['yizhongp'] = '倚众',
  [':yizhongp'] = '锁定技，当一名角色成为起义军后，其获得1点护甲。',
}

yizhongp:addEffect("fk.JoinInsurrectionary", {
  anim_type = "support",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player)
    return player:hasSkill(yizhongp.name)
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    room:changeShield(target, 1)
  end,
})

return yizhongp
