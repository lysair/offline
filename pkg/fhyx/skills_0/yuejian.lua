local yuejian = fk.CreateSkill {
  name = "ofl_shiji__yuejian"
}

Fk:loadTranslationTable{
  ['ofl_shiji__yuejian'] = '约俭',
  ['#ofl_shiji__yuejian'] = '约俭：你可以视为使用一张基本牌',
  [':ofl_shiji__yuejian'] = '你的手牌上限+X（X为你的体力上限）。当你需使用一张基本牌时，若你本轮未使用过基本牌，你可以视为使用之。',
}

yuejian:addEffect('viewas', {
  pattern = ".|.|.|.|.|basic",
  prompt = "#ofl_shiji__yuejian",
  interaction = function(skill)
    local all_names = U.getAllCardNames("b")
    local names = U.getViewAsCardNames(player, yuejian.name, all_names)
    return U.CardNameBox { choices = names, all_choices = all_names }
  end,
  card_filter = Util.FalseFunc,
  view_as = function(self, player, cards)
    if not skill.interaction.data then return nil end
    local card = Fk:cloneCard(skill.interaction.data)
    card.skillName = yuejian.name
    return card
  end,
  enabled_at_play = function(self, player)
    return player:getMark("ofl_shiji__yuejian-round") == 0
  end,
  enabled_at_response = function(self, player, response)
    return not response and player:getMark("ofl_shiji__yuejian-round") == 0
  end,

  on_acquire = function (self, player, is_start)
    local room = player.room
    if #room.logic:getEventsOfScope(GameEvent.UseCard, 1, function(e)
      local use = e.data[1]
      return use.from == player.id and use.card.type == Card.TypeBasic
    end, Player.HistoryRound) > 0 then
      room:setPlayerMark(player, "ofl_shiji__yuejian-round", 1)
    end
  end,
})

yuejian:addEffect(fk.AfterCardUseDeclared, {
  can_refresh = function(self, event, target, player, data)
    return target == player and data.card.type == Card.TypeBasic and player:getMark("ofl_shiji__yuejian-round") == 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "ofl_shiji__yuejian-round", 1)
  end,
})

yuejian:addEffect('maxcards', {
  correct_func = function(self, player)
    if player:hasSkill(yuejian.name) then
      return player.maxHp
    else
      return 0
    end
  end,
})

return yuejian
