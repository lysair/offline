local xianxi = fk.CreateSkill{
  name = "ofl_tx__xianxi",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_tx__xianxi"] = "先袭",
  [":ofl_tx__xianxi"] = "锁定技，每轮开始时，你执行一个额外回合。",
}

xianxi:addEffect(fk.RoundStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(xianxi.name)
  end,
  on_use = function(self, event, target, player, data)
    player:gainAnExtraTurn(true, xianxi.name)
  end,
})

return xianxi
