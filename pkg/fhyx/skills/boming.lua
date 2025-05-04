local boming = fk.CreateSkill {
  name = "ofl_shiji__boming",
}

Fk:loadTranslationTable{
  ["ofl_shiji__boming"] = "博名",
  [":ofl_shiji__boming"] = "出牌阶段限两次，你可以将一张牌交给一名其他角色。结束阶段，你摸X张牌（X为本局游戏你发动此技能交给过牌的角色数）。",

  ["#ofl_shiji__boming"] = "博名：你可以将一张牌交给一名其他角色",

  ["$ofl_shiji__boming1"] = "君子执仁立志，吾……断无先行之理！",
  ["$ofl_shiji__boming2"] = "人无礼不生，事无礼不成，诸君且先行！",
}

boming:addEffect("active", {
  anim_type = "support",
  prompt = "#ofl_shiji__boming",
  card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    return player:usedEffectTimes(self.name, Player.HistoryPhase) < 2
  end,
  target_filter = function(self, player, to_select, selected)
    return to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    room:addTableMarkIfNeed(player, boming.name, target.id)
    room:moveCardTo(effect.cards, Card.PlayerHand, target, fk.ReasonGive, boming.name, nil, false, player)
  end,
})

boming:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(boming.name) and player.phase == Player.Finish and
      #player:getTableMark("ofl_shiji__boming") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player:drawCards(#player:getTableMark("ofl_shiji__boming"), boming.name)
  end,
})

return boming
