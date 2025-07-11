local dulie = fk.CreateSkill {
  name = "sxfy__dulie",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["sxfy__dulie"] = "笃烈",
  [":sxfy__dulie"] = "锁定技，未受伤的其他角色与你互相计算距离时始终为1；当你成为与你距离大于1的角色使用【杀】的目标时，你进行判定，"..
  "若结果为<font color='red'>♥</font>，取消之。",
}

dulie:addEffect(fk.TargetConfirming, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(dulie.name) and
      data.card.trueName == "slash" and data.from:compareDistance(player, 1, ">")
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local judge = {
      who = player,
      reason = dulie.name,
      pattern = ".|.|heart",
    }
    room:judge(judge)
    if judge:matchPattern() then
      data:cancelTarget(player)
    end
  end,
})

dulie:addEffect("distance", {
  fixed_func = function (self, from, to)
    if from:hasSkill(dulie.name) and not to:isWounded() then
      return 1
    end
    if to:hasSkill(dulie.name) and not from:isWounded() then
      return 1
    end
  end,
})

return dulie
