local tunquan = fk.CreateSkill {
  name = "ofl__tunquan",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl__tunquan"] = "屯犬",
  [":ofl__tunquan"] = "锁定技，准备阶段，你令你本局游戏摸牌阶段的摸牌数，手牌上限和每回合首次受到的伤害+1，直到你发动〖迁军〗。",

  ["@ofl__tunquan"] = "屯犬",
}

tunquan:addEffect(fk.EventPhaseStart, {
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(tunquan.name) and player.phase == Player.Start
  end,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "@ofl__tunquan", 1)
  end
})

tunquan:addEffect(fk.DrawNCards, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@ofl__tunquan") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    data.n = data.n + player:getMark("@ofl__tunquan")
  end
})

tunquan:addEffect(fk.DamageInflicted, {
  anim_type = "negative",
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and player:getMark("@ofl__tunquan") > 0 and
      player:usedEffectTimes(self.name, Player.HistoryTurn) == 0 and
      #player.room.logic:getActualDamageEvents(1, function (e)
        return e.data.to == player
      end, Player.HistoryTurn) == 0
  end,
  on_use = function (self, event, target, player, data)
    data:changeDamage(player:getMark("@ofl__tunquan"))
  end,
})

tunquan:addEffect("maxcards", {
  correct_func = function(self, player)
    return player:getMark("@ofl__tunquan")
  end,
})

return tunquan
