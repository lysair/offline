local chenlue = fk.CreateSkill {
  name = "qshm__chenlue",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable{
  ["qshm__chenlue"] = "沉略",
  [":qshm__chenlue"] = "限定技，出牌阶段，你可以令所有其他角色展示手牌，你从场上、其他角色的手牌、因〖散士〗移出游戏的牌中获得所有“死士”牌，"..
  "本回合你使用“死士”牌无次数限制。此阶段结束时，将这些牌移出游戏直到你死亡。",

  ["#qshm__chenlue"] = "沉略：获得所有“死士”，此阶段结束时移出游戏！",
  ["#qshm__chenlue_pile"] = "沉略",

  ["$qshm__chenlue1"] = "经年之谋将成，我辈岂能踌躇。",
  ["$qshm__chenlue2"] = "众流汇于江海，可引暗潮漫城。",
}

chenlue:addEffect("active", {
  anim_type = "drawcard",
  prompt = "#qshm__chenlue",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(chenlue.name, Player.HistoryGame) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    room:doIndicate(player, room:getOtherPlayers(player, false))
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if not p:isKongcheng() and not p.dead then
        p:showCards(p:getCardIds("h"))
      end
    end
    if player.dead or player:getMark("@qshm__sanshi") == 0 then return end
    local cards = table.filter(player:getCardIds("ej"), function(id)
      return Fk:getCardById(id).number == player:getMark("@qshm__sanshi")
    end)
    table.insertTableIfNeed(cards, player:getTableMark("qshm__sanshi_removed"))
    room:setPlayerMark(player, "qshm__sanshi_removed", 0)
    for _, p in ipairs(room:getOtherPlayers(player)) do
      table.insertTableIfNeed(cards,
        table.filter(p:getCardIds("hej"), function(id)
          return Fk:getCardById(id).number == player:getMark("@qshm__sanshi")
        end))
    end
    if #cards > 0 then
      room.logic:getCurrentEvent():findParent(GameEvent.Phase, true):addCleaner(function()
        if not player.dead and player:hasSkill(chenlue.name) then
          player:addToPile("#qshm__chenlue_pile", cards, true, chenlue.name)
        end
      end)
      room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonPrey, chenlue.name, nil, true, player)
    end
  end,
})

chenlue:addEffect(fk.PreCardUse, {
  can_refresh = function (self, event, target, player, data)
    return target == player and player:usedSkillTimes(chenlue.name, Player.HistoryTurn) > 0 and
      not data.card:isVirtual() and data.card.number == player:getMark("@qshm__sanshi")
  end,
  on_refresh = function (self, event, target, player, data)
    data.extraUse = true
  end,
})

chenlue:addEffect("targetmod", {
  bypass_times = function (self, player, skill, scope, card, to)
    return card and player:usedSkillTimes(chenlue.name, Player.HistoryTurn) > 0 and
      not card:isVirtual() and card.number == player:getMark("@qshm__sanshi")
  end,
})

return chenlue
