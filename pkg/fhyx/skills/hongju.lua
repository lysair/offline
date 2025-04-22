local hongju = fk.CreateSkill {
  name = "fhyx__hongju"
}

Fk:loadTranslationTable{
  ['fhyx__hongju'] = '鸿举',
  ['$fhyx__glory'] = '荣',
  ['fhyx__qingce'] = '清侧',
  [':fhyx__hongju'] = '觉醒技，准备阶段，若“荣”数不小于3，你摸等同于“荣”数的牌，然后减1点体力上限，获得〖清侧〗。',
}

hongju:addEffect(fk.EventPhaseStart, {
  global = false,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(hongju.name) and
      player.phase == Player.Start and
      player:usedSkillTimes(hongju.name, Player.HistoryGame) == 0
  end,
  can_wake = function(self, event, target, player, data)
    return #player:getPile("$fhyx__glory") > 2
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(#player:getPile("$fhyx__glory"), hongju.name)
    if player.dead then return end
    room:changeMaxHp(player, -1)
    if player.dead then return end
    room:handleAddLoseSkills(player, "fhyx__qingce", nil, true, false)
  end,
})

return hongju
