local cibei = fk.CreateSkill {
  name = "ofl__cibei",
}

Fk:loadTranslationTable{
  ["ofl__cibei"] = "刺北",
  [":ofl__cibei"] = "当【杀】使用结算结束后，若此【杀】造成过伤害，你可以将此【杀】与一张不为【杀】的“刺”交换，然后弃置一名角色区域内的一张牌。"..
  "一名角色的回合结束时，若所有“刺”均为【杀】，你获得所有“刺”，然后本局游戏你获得以下效果：你使用【杀】无距离次数限制；每回合结束时，你获得"..
  "弃牌堆中你本回合被弃置的所有【杀】。",

  ["$ofl__cibei1"] = "杀一人而救千万人者，仁也，龙必当仁不让。",
  ["$ofl__cibei2"] = "只身犯险地，譬苍鹰击其殿，何做第二人想。",
}

cibei:addEffect(fk.CardUseFinished, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(cibei.name) and #player:getPile("hanlong_ci") > 0 and
      data.card.trueName == "slash" and #Card:getIdList(data.card) == 1 and data.damageDealt and
      table.find(player:getPile("hanlong_ci"), function(id)
        return Fk:getCardById(id).trueName ~= "slash"
      end) and
      Fk:getCardById(Card:getIdList(data.card)[1], true).trueName == "slash" and
      player.room:getCardArea(data.card) == Card.Processing
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = cibei.name,
      prompt = "#cibei-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local result = room:askToPoxi(player, {
      poxi_type = "cibei",
      data = {
        { "hanlong_ci", player:getPile("hanlong_ci") },
        { "slash", Card:getIdList(data.card) },
      },
      cancelable = false,
    })
    local cards1, cards2 = {result[1]}, {result[2]}
    if table.contains(player:getPile("hanlong_ci"), result[2]) then
      cards1, cards2 = {result[2]}, {result[1]}
    end
    room:moveCards({
      ids = cards1,
      from = player,
      toArea = Card.DiscardPile,
      moveReason = fk.ReasonJustMove,
      skillName = cibei.name,
      proposer = player,
      moveVisible = true,
    },
    {
      ids = cards2,
      to = player,
      toArea = Card.PlayerSpecial,
      specialName = "hanlong_ci",
      moveReason = fk.ReasonJustMove,
      skillName = cibei.name,
      proposer = player,
      moveVisible = true,
    })
    if not player.dead then
      local targets = table.filter(room.alive_players, function(p)
        return not p:isAllNude()
      end)
      if #targets > 0 then
        local to = room:askToChoosePlayers(player, {
          min_num = 1,
          max_num = 1,
          targets = targets,
          skill_name = cibei.name,
          prompt = "#cibei-choose",
          cancelable = false,
        })[1]
        if to == player then
          local cards = table.filter(player:getCardIds("hej"), function (id)
            return not player:prohibitDiscard(id)
          end)
          if #cards > 0 then
            local id = room:askToCards(player, {
              min_num = 1,
              max_num = 1,
              include_equip = true,
              skill_name = cibei.name,
              pattern = tostring(Exppattern{ id = cards }),
              cancelable = false,
              expand_pile = player:getCardIds("j"),
            })
            room:throwCard(id, cibei.name, player, player)
          end
        else
          local id = room:askToChooseCard(player, {
            target = to,
            flag = "hej",
            skill_name = cibei.name,
          })
          room:throwCard(id, cibei.name, to, player)
        end
      end
    end
  end,
})

cibei:addEffect(fk.TurnEnd, {
  anim_type = "big",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(cibei.name) and
      #player:getPile("hanlong_ci") > 0 and
      table.every(player:getPile("hanlong_ci"), function(id)
        return Fk:getCardById(id).trueName == "slash"
      end)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, cibei.name, 1)
    room:moveCardTo(player:getPile("hanlong_ci"), Card.PlayerHand, player, fk.ReasonJustMove, cibei.name, nil, true, player)
  end,
})

cibei:addEffect(fk.PreCardUse, {
  can_refresh = function(self, event, target, player, data)
    return target == player and data.card.trueName == "slash" and player:getMark(cibei.name) > 0
  end,
  on_refresh = function(self, event, target, player, data)
    data.extraUse = true
  end,
})

cibei:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card)
    return card and card.trueName == "slash" and player:getMark(cibei.name) > 0
  end,
  bypass_distances = function(self, player, skill, card)
    return card and card.trueName == "slash" and player:getMark(cibei.name) > 0
  end,
})

cibei:addEffect(fk.TurnEnd, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:getMark(cibei.name) > 0 and
      #player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
        for _, move in ipairs(e.data) do
          if move.from == player and move.moveReason == fk.ReasonDiscard then
            for _, info in ipairs(move.moveInfo) do
              if Fk:getCardById(info.cardId).trueName == "slash" and info.fromArea == Card.PlayerHand and
              table.contains(player.room.discard_pile, info.cardId) then
                return true
              end
            end
          end
        end
      end, Player.HistoryTurn) > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = {}
    room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
      for _, move in ipairs(e.data) do
        if move.from == player and move.moveReason == fk.ReasonDiscard then
          for _, info in ipairs(move.moveInfo) do
            if Fk:getCardById(info.cardId).trueName == "slash" and info.fromArea == Card.PlayerHand and
              table.contains(room.discard_pile, info.cardId) then
              table.insertIfNeed(cards, info.cardId)
            end
          end
        end
      end
    end, Player.HistoryTurn)
    room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonJustMove, cibei.name, nil, true, player)
  end,
})

return cibei
