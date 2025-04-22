local zhaxiang = fk.CreateSkill({
  name = "ofl__zhaxiang",
})

Fk:loadTranslationTable{
  ["ofl__zhaxiang"] = "诈降",
  [":ofl__zhaxiang"] = "出牌阶段限一次，你可以减1点体力上限，令你本回合使用牌不能被响应。",

  ["#ofl__zhaxiang"] = "诈降：减1点体力上限，令你本回合使用牌不能被响应！",
}

zhaxiang:addEffect("active", {
  anim_type = "offensive",
  prompt = "#ofl__zhaxiang",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(zhaxiang.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    room:changeMaxHp(effect.from, -1)
  end,
})

zhaxiang:addEffect(fk.CardUsing, {
  anim_type = "offensive",
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and player:usedSkillTimes(zhaxiang.name, Player.HistoryTurn) > 0 and
      (data.card.trueName == "slash" or data.card:isCommonTrick())
  end,
  on_use = function (self, event, target, player, data)
    data.disresponsiveList = table.simpleClone(player.room.players)
  end,
})

return zhaxiang
