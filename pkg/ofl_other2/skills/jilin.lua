local jilin = fk.CreateSkill {
  name = "jilin"
}

Fk:loadTranslationTable{
  ['jilin'] = '戢鳞',
  ['$yingtian_ambition'] = '志',
  ['yingyou'] = '英猷',
  ['#jilin_trigger'] = '戢鳞',
  ['#jilin-invoke'] = '戢鳞：是否明置一张“志”，令 %dest 对你使用的%arg无效？',
  ['#jilin_trigger2'] = '戢鳞',
  [':jilin'] = '游戏开始时，将牌堆顶三张牌暗置于你武将牌上，称为“志”；当你成为其他角色使用牌的目标时，你可以明置一张暗置的“志”令此牌对你无效；回合开始时，你可以用任意张手牌替换等量暗置的“志”。',
}

jilin:addEffect(fk.GameStart, {
  anim_type = "special",
  can_trigger = function(self, event, target, player)
    return player:hasSkill(jilin.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (skill, event, target, player)
    player:addToPile("$yingtian_ambition", player.room:getNCards(3), false, jilin.name, player.id)
  end,

  on_lose = function (self, player, is_death)
    if not player:hasSkill("yingyou", true) then
      local room = player.room
      room:setPlayerMark(player, "yingtian_ambition_shown", 0)
      room:moveCards({
        ids = player:getPile("$yingtian_ambition"),
        from = player.id,
        toArea = Card.DiscardPile,
        moveReason = fk.ReasonPutIntoDiscardPile,
      })
    end
  end,
})

jilin:addEffect(fk.TargetConfirming, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jilin.name) and data.from ~= player.id and
      table.find(player:getPile("$yingtian_ambition"), function (id)
        return not table.contains(player:getTableMark("yingtian_ambition_shown"), id)
      end)
  end,
  on_cost = function (skill, event, target, player, data)
    local cards = table.filter(player:getPile("$yingtian_ambition"), function (id)
      return not table.contains(player:getTableMark("yingtian_ambition_shown"), id)
    end)
    local card = player.room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      pattern = tostring(Exppattern{ id = cards }),
      prompt = "#jilin-invoke::"..data.from..":"..data.card:toLogString(),
      skill_name = jilin.name
    })
    if #card > 0 then
      event:setCostData(skill, {cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if data.card.type == Card.TypeEquip or data.card.subtype == Card.SubtypeDelayedTrick then
      data.tos = {}
    else
      table.insertIfNeed(data.nullifiedTargets, player.id)
    end
    room:addTableMark(player, "yingtian_ambition_shown", event:getCostData(skill).cards[1])
  end,
})

jilin:addEffect(fk.TurnStart, {
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jilin.name) and not player:isKongcheng() and
      table.find(player:getPile("$yingtian_ambition"), function (id)
        return not table.contains(player:getTableMark("yingtian_ambition_shown"), id)
      end)
  end,
  on_cost = function (skill, event, target, player, data)
    local cards = player.room:askToPoxi(player, {
      poxi_type = "jilin",
      data = {
        { "$yingtian_ambition", player:getPile("$yingtian_ambition") },
        { "$Hand", player:getCardIds("h") },
      },
      extra_data = { shown = player:getTableMark("yingtian_ambition_shown") },
      cancelable = true
    })
    if #cards > 0 then
      event:setCostData(skill, {cards = cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local cards1 = table.filter(event:getCostData(skill).cards, function (id)
      return table.contains(player:getCardIds("h"), id)
    end)
    local cards2 = table.filter(event:getCostData(skill).cards, function (id)
      return table.contains(player:getPile("$yingtian_ambition"), id)
    end)
    U.swapCardsWithPile(player, cards1, cards2, "jilin", "$yingtian_ambition", false, player.id)
  end,
})

jilin:addEffect(fk.VisibilitySkill, {
  card_visible = function(self, player, card)
    if table.find(Fk:currentRoom().alive_players, function (p)
      return table.contains(p:getPile("$yingtian_ambition"), card.id) and
        table.contains(p:getTableMark("yingtian_ambition_shown"), card.id)
    end) then
      return true
    end
  end
})

return jilin
