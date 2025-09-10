local houfa = fk.CreateSkill {
  name = "houfa",
}

Fk:loadTranslationTable{
  ["houfa"] = "后发",
  [":houfa"] = "准备阶段，你本轮攻击范围增加你已损失体力值。每回合限一次，当你对座次小于你的角色造成伤害时，你可以将手牌摸至其体力上限。",

  ["@houfa-round"] = "攻击范围+",
}

houfa:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(houfa.name) and player.phase == Player.Start and
      player:isWounded()
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "@houfa-round", player:getLostHp())
  end,
})

houfa:addEffect(fk.DamageCaused, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(houfa.name) and
      player.seat > data.to.seat and player:getHandcardNum() < data.to.maxHp and
      player:usedSkillTimes(self.name, Player.HistoryTurn) == 0
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(data.to.maxHp - player:getHandcardNum(), houfa.name)
  end,
})

houfa:addEffect("atkrange", {
  correct_func = function(self, from, to)
    return from:getMark("@houfa-round")
  end,
})

return houfa
