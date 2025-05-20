local fenxun = fk.CreateSkill {
  name = "qshm__fenxun",
}

Fk:loadTranslationTable{
  ["qshm__fenxun"] = "奋迅",
  [":qshm__fenxun"] = "出牌阶段限一次，你可以弃置至少一张张牌并选择一名其他角色，本回合你与其的距离视为1，当你本回合下次对其造成伤害后，"..
  "你获得其等量手牌。",

  ["#qshm__fenxun"] = "奋迅：弃任意张牌，本回合你与一名角色的距离视为1，下次对其造成伤害获得其等量手牌",
  ["@qshm__fenxun-turn"] = "被奋迅",
}

fenxun:addEffect("active", {
  anim_type = "offensive",
  min_card_num = 1,
  target_num = 1,
  prompt = "#qshm__fenxun",
  can_use = function(self, player)
    return player:usedSkillTimes(fenxun.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, player, to_select, selected)
    return not player:prohibitDiscard(to_select)
  end,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    room:addTableMarkIfNeed(player, "qshm__fenxun-turn", target.id)
    room:setPlayerMark(target, "@qshm__fenxun-turn", #effect.cards)
    room:throwCard(effect.cards, fenxun.name, player, player)
  end,
})

fenxun:addEffect(fk.Damage, {
  anim_type = "offensive",
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and table.contains(player:getTableMark("qshm__fenxun-turn"), data.to.id) and
      data.to:getMark("@qshm__fenxun-turn") > 0
  end,
  on_cost = function (self, event, target, player, data)
    event:setCostData(self, {tos = {data.to}})
    return true
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local n = data.to:getMark("@qshm__fenxun-turn")
    room:setPlayerMark(data.to, "@qshm__fenxun-turn", 0)
    if not data.to:isKongcheng() then
      local cards = data.to:getCardIds("h")
      if #cards > n then
        cards = room:askToChooseCards(player, {
          target = data.to,
          min = n,
          max = n,
          flag = "h",
          skill_name = fenxun.name,
        })
      end
      room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonPrey, fenxun.name, nil, false, player)
    end
  end,
})

fenxun:addEffect("distance", {
  fixed_func = function(self, from, to)
    if table.contains(from:getTableMark("qshm__fenxun-turn"), to.id) then
      return 1
    end
  end,
})

return fenxun
