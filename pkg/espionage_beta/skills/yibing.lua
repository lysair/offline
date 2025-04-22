local yibing = fk.CreateSkill {
  name = "yibing",
}

Fk:loadTranslationTable{
  ['yibing'] = '义兵',
  ['#yibing-slash'] = '义兵：你可以将这些牌当无距离次数限制的【杀】使用（直接选择【杀】的目标）',
  [':yibing'] = '当你于摸牌阶段外获得牌后，你可以将这些牌当无距离次数限制的【杀】使用，此【杀】结算结束前，你不能发动〖义兵〗。',
}

yibing:addEffect(fk.AfterCardsMove, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(yibing.name) and player:getMark(yibing.name) == 0 then
      for _, move in ipairs(target.data) do
        if move.to == player.id and move.toArea == Player.Hand and player.phase ~= Player.Draw then
          for _, info in ipairs(move.moveInfo) do
            if table.contains(player:getCardIds("h"), info.cardId) then
              return true
            end
          end
        end
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    local cards = {}
    for _, move in ipairs(target.data) do
      if move.to == player.id and move.toArea == Player.Hand then
        for _, info in ipairs(move.moveInfo) do
          if table.contains(player:getCardIds("h"), info.cardId) then
            table.insertIfNeed(cards, info.cardId)
          end
        end
      end
    end
    self:doCost(event, nil, player, cards)
  end,
  on_cost = function(self, event, target, player, data)
    local use = player.room:askToUseRealCard(player, {
      pattern = "slash",
      skill_name = yibing.name,
      prompt = "#yibing-slash",
      cancelable = true,
      skip = false
    }, target.data, {}, true)
    if use then
      event:setCostData(self, use)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, yibing.name, 1)
    local use = event:getCostData(self)
    use.extra_data = use.extra_data or {}
    use.extra_data.yibing_user = player.id
    player.room:useCard(use)
  end,
  can_refresh = function (self, event, target, player, data)
    return target.data.extra_data and target.data.extra_data.yibing_user == player.id
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:setPlayerMark(player, yibing.name, 0)
  end,
})

return yibing
