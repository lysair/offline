local tianxiang = fk.CreateSkill({
  name = "ofl_mou__tianxiang",
})

Fk:loadTranslationTable{
  ["ofl_mou__tianxiang"] = "天香",
  [":ofl_mou__tianxiang"] = "当你受到伤害时，你可以展示两张手牌，令一名其他角色选择获得其中一张牌，若此牌：为<font color='red'>♥</font>，"..
  "你将此伤害转移给其；不为<font color='red'>♥</font>，其本回合不能使用与此牌类别相同的手牌。",

  ["#ofl_mou__tianxiang-choose"] = "天香：展示两张手牌，令一名角色获得一张，若为<font color='red'>♥</font>则伤害转移给其，否则其本回合"..
  "不能使用此类别的手牌",
  ["#ofl_mou__tianxiang-prey"] = "天香：获得其中一张牌",
  ["@ofl_mou__tianxiang-turn"] = "天香",

  ["$ofl_mou__tianxiang1"] = "江东明珠，可不是汝掌中之物！",
  ["$ofl_mou__tianxiang2"] = "容冠国色，华茂天香。",
}

tianxiang:addEffect(fk.DamageInflicted, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(tianxiang.name) and
      player:getHandcardNum() > 1 and #player.room:getOtherPlayers(player, false) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local tos, cards = room:askToChooseCardsAndPlayers(player, {
      min_card_num = 2,
      max_card_num = 2,
      min_num = 1,
      max_num = 1,
      targets = room:getOtherPlayers(player, false),
      pattern = ".|.|.|hand",
      skill_name = tianxiang.name,
      prompt = "#ofl_mou__tianxiang-choose",
      cancelable = true,
    })
    if #tos > 0 and #cards == 2 then
      event:setCostData(self, {tos = tos, cards = cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local cards = event:getCostData(self).cards
    player:showCards(cards)
    if to.dead or player.dead then return end
    cards = table.filter(cards, function(id)
      return table.contains(player:getCardIds("h"), id)
    end)
    if #cards == 0 then return end
    local card = cards[1]
    if #cards > 1 then
      card = room:askToChooseCard(to, {
        target = target,
        flag = { card_data = {{ player.general, cards }} },
        skill_name = tianxiang.name,
        prompt = "#ofl_mou__tianxiang-prey",
      })
    end
    local yes = Fk:getCardById(card).suit == Card.Heart
    local type = Fk:getCardById(card):getTypeString()
    room:moveCardTo(cards, Card.PlayerHand, to, fk.ReasonPrey, tianxiang.name, nil, true, to)
    if yes then
      if not to.dead then
        local n = data.damage
        data:preventDamage()
        room:damage{
          from = data.from,
          to = to,
          damage = n,
          damageType = data.damageType,
          skillName = data.skillName,
          chain = data.chain,
          card = data.card,
        }
      end
    elseif not to.dead then
      room:addTableMark(to, "@ofl_mou__tianxiang-turn", type.."_char")
    end
  end,
})

tianxiang:addEffect("prohibit", {
  prohibit_use = function(self, player, card)
    if card and table.contains(player:getTableMark("@ofl_mou__tianxiang-turn"), card:getTypeString().."_char") then
      local subcards = card:isVirtual() and card.subcards or {card.id}
      return #subcards > 0 and table.every(subcards, function(id)
        return table.contains(player:getCardIds("h"), id)
      end)
    end
  end,
})

return tianxiang
