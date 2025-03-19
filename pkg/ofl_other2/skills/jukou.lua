local jukou = fk.CreateSkill {
  name = "ofl__jukou"
}

Fk:loadTranslationTable{
  ['ofl__jukou'] = '举寇',
  ['ofl__jukou1'] = '摸一张牌',
  ['ofl__jukou2'] = '获得武将牌上的牌',
  ['@@ofl__jukou1-turn'] = '禁止使用杀',
  ['@@ofl__jukou2-turn'] = '禁止使用手牌',
  [':ofl__jukou'] = '出牌阶段限一次，你可以令一名角色摸一张牌/获得其武将牌上的所有牌，然后其本回合不能使用【杀】/手牌。',
}

jukou:addEffect('active', {
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  prompt = function(self, player)
    return "#" .. self.interaction.data
  end,
  interaction = function()
    return UI.ComboBox {choices = {"ofl__jukou1", "ofl__jukou2"}}
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(jukou.name) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, cards)
    if #selected == 0 then
      if self.interaction.data == "ofl__jukou1" then
        return true
      elseif self.interaction.data == "ofl__jukou2" then
        for _, ids in pairs(Fk:currentRoom():getPlayerById(to_select).special_cards) do
          if #ids > 0 then
            return true
          end
        end
      end
    end
  end,
  on_use = function(self, room, effect)
    local target = room:getPlayerById(effect.tos[1])
    room:setPlayerMark(target, "@@" .. self.interaction.data .. "-turn", 1)
    if self.interaction.data == "ofl__jukou1" then
      target:drawCards(1, jukou.name)
    elseif self.interaction.data == "ofl__jukou2" then
      local cards = {}
      for _, ids in pairs(target.special_cards) do
        table.insertTableIfNeed(cards, ids)
      end
      room:moveCardTo(cards, Card.PlayerHand, target, fk.ReasonJustMove, jukou.name, nil, false, target.id)
    end
  end,
})

jukou:addEffect('prohibit', {
  name = "#ofl__jukou_prohibit",
  prohibit_use = function(self, player, card)
    if player:getMark("@@ofl__jukou1-turn") > 0 and card.trueName == "slash" then
      return true
    end
    if player:getMark("@@ofl__jukou2-turn") > 0 then
      local subcards = card:isVirtual() and card.subcards or {card.id}
      return #subcards > 0 and table.every(subcards, function(id)
        return table.contains(player:getCardIds("h"), id)
      end)
    end
  end,
})

return jukou
