
local wangyuan = fk.CreateSkill {
  name = "ofl_tx__wangyuan",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_tx__wangyuan"] = "亡怨",
  [":ofl_tx__wangyuan"] = "锁定技，当一名角色死亡后，你加1点体力上限并回复1点体力，本局游戏你造成属性伤害+1。",

  ["@ofl_tx__wangyuan"] = "亡怨",
}

wangyuan:addEffect(fk.Deathed, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(wangyuan.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, 1)
    if player.dead then return end
    room:recover{
      who = player,
      num = 1,
      recoverBy = player,
      skillName = wangyuan.name,
    }
    if player.dead then return end
    room:addPlayerMark(player, "@ofl_tx__wangyuan", 1)
  end,
})

wangyuan:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(wangyuan.name) and
      data.damageType ~= fk.NormalDamage and player:getMark("@ofl_tx__wangyuan") > 0
  end,
  on_use = function (self, event, target, player, data)
    data:changeDamage(player:getMark("@ofl_tx__wangyuan"))
  end,
})

wangyuan:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, "@ofl_tx__wangyuan", 0)
end)

return wangyuan
