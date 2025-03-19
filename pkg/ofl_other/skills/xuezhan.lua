local xuezhan = fk.CreateSkill {
  name = "ofl__xuezhan"
}

Fk:loadTranslationTable{
  ['ofl__xuezhan'] = '血战',
  ['#ofl__xuezhan_filter'] = '血战',
  [':ofl__xuezhan'] = '锁定技，你的锦囊牌均视为【决斗】；你使用【决斗】不能被【无懈可击】响应。',
}

xuezhan:addEffect(fk.AfterCardUseDeclared, {
  global = false,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xuezhan) and data.card.trueName == "duel"
  end,
  on_use = function(self, event, target, player, data)
    data.unoffsetableList = table.map(player.room.alive_players, Util.IdMapper)
  end
})

xuezhan:addEffect('filter', {
  frequency = Skill.Compulsory,
  main_skill = xuezhan,
  card_filter = function(self, player, to_select)
    return player:hasSkill(xuezhan) and to_select.type == Card.TypeTrick and table.contains(player:getCardIds("h"), to_select.id)
  end,
  view_as = function(self, player, to_select)
    local card = Fk:cloneCard("duel", to_select.suit, to_select.number)
    card.skillName = xuezhan.name
    return card
  end,
})

return xuezhan
