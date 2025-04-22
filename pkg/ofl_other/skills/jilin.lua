local jilin = fk.CreateSkill {
  name = "jilin",
}

Fk:loadTranslationTable{
  ["jilin"] = "戢鳞",
  [":jilin"] = "游戏开始时，将牌堆顶三张牌暗置于你武将牌上，称为“志”；当你成为其他角色使用牌的目标时，你可以明置一张暗置的“志”令此牌对你无效；"..
  "回合开始时，你可以用任意张手牌替换等量暗置的“志”。",

  ["$yingtian_ambition"] = "志",
  ["#jilin-invoke"] = "戢鳞：是否明置一张“志”，令 %dest 对你使用的%arg无效？",
  ["#jilin"] = "戢鳞：你可以用手牌替换等量暗置的“志”",
}

jilin:addEffect(fk.GameStart, {
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(jilin.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    player:addToPile("$yingtian_ambition", player.room:getNCards(3), false, jilin.name, player)
  end,
})

jilin:addLoseEffect(function (self, player, is_death)
  if not player:hasSkill("yingyou", true) then
    local room = player.room
    room:setPlayerMark(player, "yingtian_ambition_shown", 0)
    room:moveCards({
      ids = player:getPile("$yingtian_ambition"),
      from = player,
      toArea = Card.DiscardPile,
      moveReason = fk.ReasonPutIntoDiscardPile,
    })
  end
end)

Fk:addPoxiMethod{
  name = "jilin",
  prompt = function (data, extra_data)
    return "#jilin"
  end,
  card_filter = function(to_select, selected, data, extra_data)
    return not table.contains(extra_data.shown, to_select)
  end,
  feasible = function(selected, data, extra_data)
    return #selected > 0 and #selected % 2 == 0 and
      #table.filter(selected, function (id)
        return table.contains(data[1][2], id)
      end) * 2 == #selected
  end,
}

jilin:addEffect(fk.TargetConfirming, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jilin.name) and data.from ~= player and
      table.find(player:getPile("$yingtian_ambition"), function (id)
        return not table.contains(player:getTableMark("yingtian_ambition_shown"), id)
      end)
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local cards = table.filter(player:getPile("$yingtian_ambition"), function (id)
      return not table.contains(player:getTableMark("yingtian_ambition_shown"), id)
    end)
    local card = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      pattern = tostring(Exppattern{ id = cards }),
      prompt = "#jilin-invoke::"..data.from.id..":"..data.card:toLogString(),
      skill_name = jilin.name,
      expand_pile = player:getPile("$yingtian_ambition"),
    })
    if #card > 0 then
      event:setCostData(skill, {cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    data.use.nullifiedTargets = data.use.nullifiedTargets or {}
    table.insertIfNeed(data.use.nullifiedTargets, player)
    room:addTableMark(player, "yingtian_ambition_shown", event:getCostData(self).cards[1])
  end,
})

jilin:addEffect(fk.TurnStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jilin.name) and not player:isKongcheng() and
      table.find(player:getPile("$yingtian_ambition"), function (id)
        return not table.contains(player:getTableMark("yingtian_ambition_shown"), id)
      end)
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local cards = room:askToPoxi(player, {
      poxi_type = jilin.name,
      data = {
        { "$yingtian_ambition", player:getPile("$yingtian_ambition") },
        { "$Hand", player:getCardIds("h") },
      },
      extra_data = { shown = player:getTableMark("yingtian_ambition_shown") },
      cancelable = true,
    })
    if #cards > 0 then
      event:setCostData(self, {cards = cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local cards1 = table.filter(event:getCostData(self).cards, function (id)
      return table.contains(player:getCardIds("h"), id)
    end)
    local cards2 = table.filter(event:getCostData(self).cards, function (id)
      return table.contains(player:getPile("$yingtian_ambition"), id)
    end)
    player.room:swapCardsWithPile(player, cards1, cards2, jilin.name, "$yingtian_ambition", false, player)
  end,
})

jilin:addEffect("visibility", {
  card_visible = function(self, player, card)
    if table.find(Fk:currentRoom().alive_players, function (p)
      return table.contains(p:getPile("$yingtian_ambition"), card.id) and
        table.contains(p:getTableMark("yingtian_ambition_shown"), card.id)
    end) then
      return true
    end
  end,
})

return jilin
