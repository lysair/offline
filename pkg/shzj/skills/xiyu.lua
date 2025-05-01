local xiyu = fk.CreateSkill {
  name = "xiyu",
}

Fk:loadTranslationTable{
  ["xiyu"] = "西御",
  [":xiyu"] = "一名角色使用转化牌或虚拟牌指定一个目标后，你可以摸一张牌。",
}

xiyu:addEffect(fk.TargetSpecified, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(xiyu.name) and data.card:isVirtual()
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, xiyu.name)
  end,
})

return xiyu
