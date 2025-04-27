local ofl_shiji__boming = fk.CreateSkill {
  name = "ofl_shiji__boming"
}

Fk:loadTranslationTable{
  ['ofl_shiji__boming'] = '博名',
  ['#ofl_shiji__boming'] = '博名：你可以将一张牌交给一名其他角色',
  [':ofl_shiji__boming'] = '出牌阶段限两次，你可以将一张牌交给一名其他角色。结束阶段，你摸X张牌（X为本局游戏你发动此技能交给过牌的角色数）。',
  ['$ofl_shiji__boming1'] = '君子执仁立志，吾……断无先行之理！',
  ['$ofl_shiji__boming2'] = '人无礼不生，事无礼不成，诸君且先行！',
}

ofl_shiji__boming:addEffect('active', {
  anim_type = "support",
  card_num = 1,
  target_num = 1,
  prompt = "#ofl_shiji__boming",
  can_use = function(self, player)
    return player:usedSkillTimes(ofl_shiji__boming.name, Player.HistoryPhase) < 2
  end,
  card_filter = Util.TrueFunc,
  target_filter = function(self, player, to_select, selected)
    return to_select ~= player.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:addTableMarkIfNeed(player, ofl_shiji__boming.name, target.id)
    room:moveCardTo(effect.cards, Card.PlayerHand, target, fk.ReasonGive, ofl_shiji__boming.name, nil, false, player.id)
  end,
})

ofl_shiji__boming:addEffect(fk.EventPhaseStart, {
  mute = true,
  can_trigger = function(self, event, player, data)
    return player.phase == Player.Finish and player:hasSkill(ofl_shiji__boming) and #player:getTableMark("ofl_shiji__boming") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, player, data)
    player:broadcastSkillInvoke("ofl_shiji__boming")
    player.room:notifySkillInvoked(player, "ofl_shiji__boming", "drawcard")
    player:drawCards(#player:getTableMark("ofl_shiji__boming"), ofl_shiji__boming.name)
  end,
})

return ofl_shiji__boming
