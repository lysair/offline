local qishe = fk.CreateSkill {
  name = "ofl__qishe",
}

Fk:loadTranslationTable{
  ["ofl__qishe"] = "齐射",
  [":ofl__qishe"] = "游戏开始时，你从游戏外获得一张【万箭齐发】；结束阶段，你可以从弃牌堆获得一张【万箭齐发】。",

  ["#ofl__qishe-invoke"] = "齐射：是否从弃牌堆获得一张【万箭齐发】？",
}

qishe:addEffect(fk.GameStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(qishe.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = room:printCard("archery_attack", Card.Heart, 1)
    room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonJustMove, qishe.name, nil, true, player)
  end,
})

qishe:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(qishe.name) and player.phase == Player.Finish and
      table.find(player.room.discard_pile, function (id)
        return Fk:getCardById(id).trueName == "archery_attack"
      end)
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = qishe.name,
      prompt = "#ofl__qishe-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = room:getCardsFromPileByRule("archery_attack", 1, "discardPile")
    room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonJustMove, qishe.name, nil, true, player)
  end,
})

return qishe
