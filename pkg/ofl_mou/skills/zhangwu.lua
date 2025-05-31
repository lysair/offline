local zhangwu = fk.CreateSkill {
  name = "ofl_mou__zhangwu",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable{
  ["ofl_mou__zhangwu"] = "章武",
  [":ofl_mou__zhangwu"] = "限定技，出牌阶段，你可以移去任意“仁望”标记并摸等量的牌，然后〖仁德〗失效直到你进入濒死状态，本回合你使用【杀】"..
  "无距离限制。",

  ["#ofl_mou__zhangwu"] = "制衡：移去任意“仁望”标记并摸等量牌，本回合使用【杀】无距离限制，“仁德”失效直到你进入濒死状态",

  ["$ofl_mou__zhangwu1"] = "铸剑章武，昭朕肃烈之志！",
  ["$ofl_mou__zhangwu2"] = "起誓鸣戎，决吾共死之意！",
}

zhangwu:addEffect("active", {
  anim_type = "drawcard",
  prompt = "#ofl_mou__zhangwu",
  card_num = 0,
  target_num = 0,
  interaction = function(self, player)
    return UI.Spin {
      from = 1,
      to = player:getMark("@mou__renwang"),
    }
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(zhangwu.name, Player.HistoryGame) == 0 and player:getMark("@mou__renwang") > 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    room:removePlayerMark(player, "@mou__renwang", self.interaction.data)
    player:drawCards(self.interaction.data)
    if player.dead then return end
    room:setPlayerMark(player, zhangwu.name, 1)
    room:invalidateSkill(player, "mou__rende", nil, zhangwu.name)
  end,
})

zhangwu:addEffect(fk.EnterDying, {
  can_refresh = function (self, event, target, player, data)
    return target == player and player:getMark(zhangwu.name) > 0
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, zhangwu.name, 0)
    room:validateSkill(player, "mou__rende", nil, zhangwu.name)
  end,
})

zhangwu:addEffect("targetmod", {
  bypass_distances = function(self, player, skill, card)
    return player:usedSkillTimes(zhangwu.name, Player.HistoryTurn) > 0 and skill.trueName == "slash_skill"
  end,
})

return zhangwu
