local shenzhuo = fk.CreateSkill {
  name = "sxfy__shenzhuo",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["sxfy__shenzhuo"] = "神著",
  [":sxfy__shenzhuo"] = "锁定技，当你使用指定与你距离为1的角色为目标时，你摸一张牌，此【杀】不计入次数限制。",
}

shenzhuo:addEffect(fk.TargetSpecifying, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(shenzhuo.name) and
      data.card.trueName == "slash" and data.to:compareDistance(player, 1, "==")
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, shenzhuo.name)
    if not data.use.extraUse then
      data.use.extraUse = true
      player:addCardUseHistory(data.card.trueName, -1)
    end
  end,
})

return shenzhuo
