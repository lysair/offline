local moji = fk.CreateSkill {
  name = "ofl_tx__moji",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_tx__moji"] = "魔戟",
  [":ofl_tx__moji"] = "锁定技，当你造成伤害后，你下次造成伤害+X（X为本次伤害值的一半，向上取整）。",

  ["@ofl_tx__moji"] = "造成伤害+",
}

moji:addEffect(fk.Damage, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(moji.name)
  end,
  on_use = function (self, event, target, player, data)
    player.room:addPlayerMark(player, "@ofl_tx__moji", (data.damage + 1) // 2)
  end,
})

moji:addEffect(fk.DamageCaused, {
  can_refresh = function (self, event, target, player, data)
    return target == player and player:getMark("@ofl_tx__moji") > 0
  end,
  on_refresh = function (self, event, target, player, data)
    data:changeDamage(player:getMark("@ofl_tx__moji"))
    player.room:setPlayerMark(player, "@ofl_tx__moji", 0)
  end,
})

return moji
