local juezhu = fk.CreateSkill {
  name = "sxfy__juezhu",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["sxfy__juezhu"] = "角逐",
  [":sxfy__juezhu"] = "锁定技，当你造成伤害后，你本回合使用牌无次数限制；当你受到伤害后，你视为对伤害来源使用一张【决斗】。",
}

juezhu:addEffect(fk.Damage, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(juezhu.name)
  end,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "sxfy__juezhu-turn", 1)
  end,
})

juezhu:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(juezhu.name) and
      data.from and not data.from.dead and data.from ~= player
  end,
  on_use = function(self, event, target, player, data)
    player.room:useVirtualCard("duel", nil, player, data.from, juezhu.name)
  end,
})

juezhu:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card, to)
    return card and player:getMark("sxfy__juezhu-turn") > 0
  end,
})

return juezhu
