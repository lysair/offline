local xiaosi = fk.CreateSkill{
  name = "sxfy__xiaosi",
}

Fk:loadTranslationTable{
  ["sxfy__xiaosi"] = "效死",
  [":sxfy__xiaosi"] = "出牌阶段限一次，你可以展示一名角色的所有手牌，弃置你与其至多各一张基本牌，然后你可以使用这些牌（无距离次数限制）。",

  ["#sxfy__xiaosi"] = "效死：展示一名角色所有手牌，弃置你与其各一张牌，然后你可以使用这些牌",
  ["#sxfy__xiaosi-discard"] = "效死：弃置你与其至多各一张基本牌",
  ["#sxfy__xiaosi-use"] = "效死：你可以使用这些牌（无距离次数限制）",
}

Fk:addPoxiMethod{
  name = "sxfy__xiaosi",
  prompt = "#sxfy__xiaosi-discard",
  card_filter = function(to_select, selected, data)
    if Fk:getCardById(to_select).type == Card.TypeBasic and
      not Self:prohibitDiscard(to_select) and
      #selected < 2 then
      if #selected == 0 then
        return true
      else
        if table.contains(data[1][2], selected[1]) then
          return not table.contains(data[1][2], to_select)
        else
          return table.contains(data[1][2], to_select)
        end
      end
    end
  end,
  feasible = Util.TrueFunc,
}

xiaosi:addEffect("active", {
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  prompt = "#sxfy__xiaosi",
  can_use = function(self, player)
    return player:usedSkillTimes(xiaosi.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and not to_select:isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    target:showCards(target:getCardIds("h"))
    if player.dead or (player:isKongcheng() and target:isKongcheng()) then return end
    local cards = {}
    if target == player then
      cards = room:askToDiscard(player, {
        min_num = 2,
        max_num = 2,
        include_equip = false,
        skill_name = xiaosi.name,
        pattern = ".|.|.|.|.|basic",
        prompt = "#sxfy__xiaosi-discard",
        cancelable = true,
      })
    else
      local data = {}
      if not target:isKongcheng() then
        table.insert(data, { target.general, target:getCardIds("h") })
      end
      if not player:isKongcheng() then
        table.insert(data, { player.general, player:getCardIds("h") })
      end
      cards = room:askToPoxi(player, {
        poxi_type = "sxfy__xiaosi",
        data = data,
        cancelable = true,
      })
      if #cards > 0 then
        local cards1 = table.filter(cards, function(id) return table.contains(player:getCardIds("h"), id) end)
        local cards2 = table.filter(cards, function(id) return table.contains(target:getCardIds("h"), id) end)
        local moves = {}
        if #cards1 > 0 then
          table.insert(moves, {
            from = player,
            ids = cards1,
            toArea = Card.DiscardPile,
            moveReason = fk.ReasonDiscard,
            proposer = player,
            skillName = xiaosi.name,
          })
        end
        if #cards2 > 0 then
          table.insert(moves, {
            from = target,
            ids = cards2,
            toArea = Card.DiscardPile,
            moveReason = fk.ReasonDiscard,
            proposer = player,
            skillName = xiaosi.name,
          })
        end
        room:moveCards(table.unpack(moves))
      end
    end
    while not player.dead do
      cards = table.filter(cards, function (id)
        return table.contains(room.discard_pile, id)
      end)
      if #cards == 0 then return false end
      local use = room:askToUseRealCard(player, {
        pattern = cards,
        skill_name = xiaosi.name,
        prompt = "#sxfy__xiaosi-use",
        extra_data = {
          bypass_distances = true,
          bypass_times = true,
          extraUse = true,
          expand_pile = cards,
        },
        skip = true,
      })
      if use then
        table.removeOne(cards, use.card:getEffectiveId())
        room:useCard(use)
      else
        break
      end
    end
  end,
})

return xiaosi
