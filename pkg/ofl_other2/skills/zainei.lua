local zainei = fk.CreateSkill {
  name = "ofl__zainei"
}

Fk:loadTranslationTable{
  ['ofl__zainei'] = '载内',
  ['#ofl__zainei'] = '载内：选择一名角色，你与其距离视为1直到你进入濒死状态！',
  [':ofl__zainei'] = '限定技，出牌阶段，你可以选择一名其他角色，然后你与其距离视为1，直到你进入濒死状态。',
}

zainei:addEffect('active', {
  anim_type = "offensive",
  frequency = Skill.Limited,
  card_num = 0,
  target_num = 1,
  prompt = "#ofl__zainei",
  can_use = function(self, player)
    return player:usedSkillTimes(zainei.name, Player.HistoryGame) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, cards)
    return #selected == 0 and to_select ~= player.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:addTableMark(player, zainei.name, effect.tos[1])
  end,
})

zainei:addEffect('distance', {
  fixed_func = function(self, from, to)
    if table.contains(from:getTableMark("ofl__zainei"), to.id) then
      return 1
    end
  end,
})

zainei:addEffect(fk.EnterDying, {
  can_refresh = function(self, event, target, player, data)
    return target == player
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "ofl__zainei", 0)
  end,
})

return zainei
