local yongdou = fk.CreateSkill {
  name = "ofl_tx__yongdou",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_tx__yongdou"] = "勇斗",
  [":ofl_tx__yongdou"] = "锁定技，当你使用【决斗】指定目标后，你摸一张牌。你响应【决斗】的结算流程中，你的手牌均视为【杀】。",
}

yongdou:addEffect(fk.TargetSpecified, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yongdou.name) and
      data.card.name == "duel" and data.firstTarget
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, yongdou.name)
  end,
})

yongdou:addEffect(fk.CardEffecting, {
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(yongdou.name) and
      data.card.name == "duel" and (data.from == player or data.to == player)
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "ofl_tx__yongdou-phase", 1)
    player:filterHandcards()
  end,
})

yongdou:addEffect(fk.CardEffectFinished, {
  can_refresh = function(self, event, target, player, data)
    return data.card.name == "duel"
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "ofl_tx__yongdou-phase", 0)
    player:filterHandcards()
  end,
})

yongdou:addEffect("filter", {
  mute = true,
  card_filter = function(self, card, player)
    return player:hasSkill(yongdou.name) and player:getMark("ofl_tx__yongdou-phase") > 0 and
      table.contains(player:getCardIds("h"), card.id)
  end,
  view_as = function(self, player, card)
    return Fk:cloneCard("slash", card.suit, card.number)
  end,
})

return yongdou
