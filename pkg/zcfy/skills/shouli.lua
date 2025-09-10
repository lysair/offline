local shouli = fk.CreateSkill{
  name = "sxfy__shouli",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["sxfy__shouli"] = "狩骊",
  [":sxfy__shouli"] = "锁定技，每回合各限一次：当一张坐骑牌进入一名角色的装备区后，你对一名角色造成1点伤害；"..
  "当一张坐骑牌进入弃牌堆后，你回复1点体力并获得之。",

  ["#sxfy__shouli-damage"] = "狩骊：对一名角色造成1点伤害",
  ["#sxfy__shouli-prey"] = "狩骊：获得其中一张牌",
}

shouli:addEffect(fk.AfterCardsMove, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(shouli.name) and player:usedEffectTimes(self.name, Player.HistoryTurn) == 0 then
      for _, move in ipairs(data) do
        if move.toArea == Card.PlayerEquip then
          for _, info in ipairs(move.moveInfo) do
            if (Fk:getCardById(info.cardId).sub_type == Card.SubtypeDefensiveRide or
              Fk:getCardById(info.cardId).sub_type == Card.SubtypeOffensiveRide) then
              return true
            end
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room.alive_players,
      skill_name = shouli.name,
      prompt = "#sxfy__shouli-damage",
      cancelable = false,
    })[1]
    room:damage{
      from = player,
      to = to,
      damage = 1,
      skillName = shouli.name,
    }
  end,
})

shouli:addEffect(fk.AfterCardsMove, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(shouli.name) and player:usedEffectTimes(self.name, Player.HistoryTurn) == 0 then
      for _, move in ipairs(data) do
        if move.toArea == Card.DiscardPile then
          for _, info in ipairs(move.moveInfo) do
            if (Fk:getCardById(info.cardId).sub_type == Card.SubtypeDefensiveRide or
              Fk:getCardById(info.cardId).sub_type == Card.SubtypeOffensiveRide) and
              table.contains(player.room.discard_pile, info.cardId) then
              return true
            end
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:recover{
      who = player,
      num = 1,
      recoverBy = player,
      skillName = shouli.name,
    }
    if player.dead then return end
    local cards = {}
    for _, move in ipairs(data) do
      if move.toArea == Card.DiscardPile then
        for _, info in ipairs(move.moveInfo) do
          if (Fk:getCardById(info.cardId).sub_type == Card.SubtypeDefensiveRide or
            Fk:getCardById(info.cardId).sub_type == Card.SubtypeOffensiveRide) and
            table.contains(player.room.discard_pile, info.cardId) then
            table.insertIfNeed(cards, info.cardId)
          end
        end
      end
    end
    cards = player.room.logic:moveCardsHoldingAreaCheck(cards)
    if #cards == 0 then return end
    if #cards > 1 then
      cards = room:askToChooseCard(player, {
        target = player,
        flag = { card_data = {{ "pile_discard", cards }} },
        skill_name = shouli.name,
        prompt = "#sxfy__shouli-prey",
      })
    end
    room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonJustMove, shouli.name, nil, true, player)
  end,
})

return shouli
