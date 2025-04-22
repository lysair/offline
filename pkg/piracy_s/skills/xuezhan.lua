local xuezhan = fk.CreateSkill {
  name = "ofl__xuezhan",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl__xuezhan"] = "血战",
  [":ofl__xuezhan"] = "锁定技，你的锦囊牌均视为【决斗】；你使用【决斗】不能被【无懈可击】响应。",
}

xuezhan:addEffect(fk.AfterCardUseDeclared, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xuezhan.name) and data.card.trueName == "duel"
  end,
  on_use = function(self, event, target, player, data)
    data.unoffsetableList = table.simpleClone(player.room.players)
  end
})

xuezhan:addEffect("filter", {
  anim_type = "offensive",
  card_filter = function(self, to_select, player)
    return player:hasSkill(xuezhan.name) and to_select.type == Card.TypeTrick and
      table.contains(player:getCardIds("h"), to_select.id)
  end,
  view_as = function(self, player, to_select)
    return Fk:cloneCard("duel", to_select.suit, to_select.number)
  end,
})

return xuezhan
