local shangyi = fk.CreateSkill {
  name = "sxfy__shangyi",
}

Fk:loadTranslationTable{
  ["sxfy__shangyi"] = "尚义",
  [":sxfy__shangyi"] = "出牌阶段限一次，你可以选择一名有手牌的其他角色，你与其同时互相观看手牌并弃置其中一张牌，若颜色相同，你获得获得这些牌。",

  ["#sxfy__shangyi"] = "尚义：与一名角色互相观看并弃置一张手牌，若颜色相同你获得获得这些牌",
  ["#sxfy__shangyi-ask"] = "尚义：观看并弃置对方一张手牌",
}

shangyi:addEffect("active", {
  anim_type = "control",
  prompt = "#sxfy__shangyi",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(shangyi.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= player and not to_select:isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local ret = {}
    local req = Request:new(player:isKongcheng() and {player} or {player, target}, "AskForUseActiveSkill")
    req.focus_text = shangyi.name
    req.focus_players = player:isKongcheng() and {player} or {player, target}
      req:setData(player, {
        "choose_cards_skill",
        "#sxfy__shangyi-ask",
        false,
        {
          num = 1,
          min_num = 1,
          include_equip = false,
          skillName = shangyi.name,
          pattern = tostring(Exppattern{ id = target:getCardIds("h") }),
          expand_pile = target:getCardIds("h"),
        },
      })
    req:setDefaultReply(player, ret[p] or table.random(target:getCardIds("h"), 1))
    if not player:isKongcheng() then
      req:setData(target, {
        "choose_cards_skill",
        "#sxfy__shangyi-ask",
        false,
        {
          num = 1,
          min_num = 1,
          include_equip = false,
          skillName = shangyi.name,
          pattern = tostring(Exppattern{ id = player:getCardIds("h") }),
          expand_pile = player:getCardIds("h"),
        },
      })
      req:setDefaultReply(target, ret[p] or table.random(player:getCardIds("h"), 1))
    end
    req:ask()
    local ids, moves = {}, {}
    local result = req:getResult(player)
    local ids1 = {}
    if result ~= "" then
      if result.card then
        ids1 = result.card.subcards
      else
        ids1 = result
      end
    end
    table.insertTable(ids, ids1)
    table.insert(moves, {
      ids = ids1,
      from = target,
      toArea = Card.DiscardPile,
      moveReason = fk.ReasonDiscard,
      skillName = shangyi.name,
      proposer = player,
      moveVisible = true,
    })
    if not player:isKongcheng() then
      result = req:getResult(target)
      local ids2 = {}
      if result ~= "" then
        if result.card then
          ids2 = result.card.subcards
        else
          ids2 = result
        end
      end
      table.insertTable(ids, ids2)
      table.insert(moves, {
        ids = ids2,
        from = player,
        toArea = Card.DiscardPile,
        moveReason = fk.ReasonDiscard,
        skillName = shangyi.name,
        proposer = target,
        moveVisible = true,
      })
    end
    room:moveCards(table.unpack(moves))
    if not player.dead and table.every(ids, function (id)
      return Fk:getCardById(id):compareColorWith(Fk:getCardById(ids[1]))
    end) then
      ids = table.filter(ids, function (id)
        return table.contains(room.discard_pile, id)
      end)
      if #ids > 0 then
        room:moveCardTo(ids, Card.PlayerHand, player, fk.ReasonJustMove, shangyi.name, nil, true, player)
      end
    end
  end,
})

return shangyi
