local jixin = fk.CreateSkill {
  name = "ofl__jixin",
}

Fk:loadTranslationTable{
  ["ofl__jixin"] = "技新",
  [":ofl__jixin"] = "当你首次使用一种牌名的牌后，你可以摸X张牌并展示，这些牌不计入手牌上限且使用时无距离次数限制（X为你本轮发动此技能次数）。",

  ["@@ofl__jixin-inhand"] = "技新",
}

jixin:addEffect(fk.CardUseFinished, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jixin.name) and
      data.extra_data and data.extra_data.ofl__jixin
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = player:drawCards(player:usedSkillTimes(jixin.name, Player.HistoryRound), jixin.name)
    cards = table.filter(cards, function (id)
      return table.contains(player:getCardIds("h"), id)
    end)
    if #cards > 0 then
      player:showCards(cards)
    end
    for _, id in ipairs(cards) do
      if table.contains(player:getCardIds("h"), id) then
        room:setCardMark(Fk:getCardById(id), "@@ofl__jixin-inhand", 1)
      end
    end
  end,

  can_refresh = function (self, event, target, player, data)
    return target == player and player:hasSkill(jixin.name, true) and
      not table.contains(player:getTableMark(jixin.name), data.card.trueName)
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:addTableMark(player, jixin.name, data.card.trueName)
    data.extra_data = data.extra_data or {}
    data.extra_data.ofl__jixin = true
  end,
})

jixin:addEffect("maxcards", {
  exclude_from = function (self, player, card)
    return card:getMark("@@ofl__jixin-inhand") > 0
  end,
})

jixin:addEffect(fk.PreCardUse, {
  can_refresh = function (self, event, target, player, data)
    return target == player and
      #Card:getIdList(data.card) > 0 and
      table.every(Card:getIdList(data.card), function (id)
        return Fk:getCardById(id):getMark("@@ofl__jixin-inhand") > 0
      end)
  end,
  on_refresh = function (self, event, target, player, data)
    data.extraUse = true
  end,
})

jixin:addEffect("targetmod", {
  bypass_times = function(self, player, skill_name, scope, card, to)
    return card and card:getMark("@@ofl__jixin-inhand") > 0
  end,
  bypass_distances = function(self, player, skill_name, card)
    return card and card:getMark("@@ofl__jixin-inhand") > 0
  end,
})

jixin:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, jixin.name, 0)
end)

return jixin
