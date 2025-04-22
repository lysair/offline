local qibian = fk.CreateSkill({
  name = "ofl__qibian",
})

Fk:loadTranslationTable{
  ["ofl__qibian"] = "七辩",
  [":ofl__qibian"] = "每轮开始时，你将牌堆顶七张牌置于你的武将牌上，称为“才”；每轮结束时，将“才”置入弃牌堆。",

  ["$ofl__qibian"] = "才",
}

qibian:addEffect(fk.RoundStart, {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(qibian.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    player:addToPile("$ofl__qibian", player.room:getNCards(7), false, qibian.name)
  end,
})

qibian:addEffect(fk.RoundEnd, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return #player:getPile("$ofl__qibian") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    player.room:moveCardTo(player:getPile("$ofl__qibian"), Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, qibian.name)
  end,
})

return qibian
