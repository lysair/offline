local fuhai = fk.CreateSkill {
  name = "sxfy__fuhai",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["sxfy__fuhai"] = "覆海",
  [":sxfy__fuhai"] = "锁定技，你对体力上限与其武将牌上体力上限不同的角色使用牌无距离限制，其不能响应此牌。一名角色死亡时，"..
  "你加1点体力上限。",
}

fuhai:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(fuhai.name) and
      data.to.maxHp ~= Fk.generals[data.to.general].maxHp
  end,
  on_use = function(self, event, target, player, data)
    data.use.disresponsiveList = data.use.disresponsiveList or {}
    table.insert(data.use.disresponsiveList, data.to)
  end,
})

fuhai:addEffect(fk.Death, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(fuhai.name)
  end,
  on_use = function(self, event, target, player, data)
    player.room:changeMaxHp(player, 1)
  end,
})

fuhai:addEffect("targetmod", {
  bypass_distances = function (self, player, skill, card, to)
    return player:hasSkill(fuhai.name) and card and to and to.maxHp ~= Fk.generals[to.general].maxHp
  end,
})

return fuhai
