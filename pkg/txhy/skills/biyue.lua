local biyue = fk.CreateSkill {
  name = "ofl_tx__biyue",
}

Fk:loadTranslationTable{
  ["ofl_tx__biyue"] = "闭月",
  [":ofl_tx__biyue"] = "每名角色的回合结束时，你摸一张牌。",

  ["$ofl_tx__biyue1"] = "失礼了～",
  ["$ofl_tx__biyue2"] = "羡慕吧～",
}

biyue:addEffect(fk.TurnEnd, {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(biyue.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    player:drawCards(1, biyue.name)
  end,
})

return biyue
