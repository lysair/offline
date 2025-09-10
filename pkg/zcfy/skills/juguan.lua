local juguan = fk.CreateSkill{
  name = "sxfy__juguan",
}

Fk:loadTranslationTable{
  ["sxfy__juguan"] = "拒关",
  [":sxfy__juguan"] = "出牌阶段限一次，你可以将一张手牌当【杀】或【决斗】使用。准备阶段，若你未受伤，你本回合摸牌阶段摸牌数+2。",
}

juguan:addEffect("viewas", {
  anim_type = "offensive",
  prompt = "#juguan",
  interaction = UI.CardNameBox {choices = {"slash", "duel"}},
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and table.contains(player:getHandlyIds(), to_select)
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 or not self.interaction.data then return end
    local c = Fk:cloneCard(self.interaction.data)
    c.skillName = juguan.name
    c:addSubcard(cards[1])
    return c
  end,
  enabled_at_play = function(self, player)
    return player:usedEffectTimes(self.name, Player.HistoryPhase) == 0
  end,
})

juguan:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(juguan.name) and player.phase == Player.Start and
      not player:isWounded()
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    player.room:addPlayerMark(player, "sxfy__juguan-turn", 1)
  end,
})

juguan:addEffect(fk.DrawNCards, {
  can_refresh = function (self, event, target, player, data)
    return target == player and player:getMark("sxfy__juguan-turn") > 0
  end,
  on_refresh = function (self, event, target, player, data)
    data.n = data.n + 2 * player:getMark("sxfy__juguan-turn")
  end,
})

return juguan
