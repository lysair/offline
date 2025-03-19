local xiongshi = fk.CreateSkill {
  name = "ofl__xiongshi&"
}

Fk:loadTranslationTable{
  ['ofl__xiongshi&'] = '凶势',
  ['#ofl__xiongshi&'] = '凶势：你可以将一张手牌置于高升的武将牌上',
  ['ofl__xiongshi'] = '凶势',
  [':ofl__xiongshi&'] = '出牌阶段限一次，你可以将一张手牌置于高升的武将牌上。',
}

xiongshi:addEffect('active', {
  anim_type = "support",
  card_num = 1,
  target_num = 1,
  prompt = "#ofl__xiongshi&",
  can_use = function(self, player)
    return player:usedSkillTimes(xiongshi.name) == 0
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and table.contains(player:getCardIds("h"), to_select)
  end,
  target_filter = function(self, player, to_select, selected, cards)
    return #selected == 0 and Fk:currentRoom():getPlayerById(to_select):hasSkill(xiongshi.name)
  end,
  on_use = function(self, room, effect)
    local target = room:getPlayerById(effect.tos[1])
    target:addToPile("ofl__xiongshi", effect.cards, false, "ofl__xiongshi", effect.from)
  end,
})

return xiongshi
