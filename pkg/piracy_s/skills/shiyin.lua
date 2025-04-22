local shiyin = fk.CreateSkill {
  name = "ofl__shiyin",
}

Fk:loadTranslationTable{
  ["ofl__shiyin"] = "识音",
  [":ofl__shiyin"] = "当你于你的回合内获得手牌后，你可以展示这些牌，根据花色数使你本回合使用下一张牌时执行效果："..
  "不小于1，不能被响应；不小于2，造成的伤害+1；不小于3，摸一张牌。",

  ["#ofl__shiyin-invoke"] = "识音：你可以展示你获得的牌，本回合使用下一张牌时执行效果",
  ["@ofl__shiyin-turn"] = "识音",
}

shiyin:addEffect(fk.AfterCardsMove, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(shiyin.name) then
      for _, move in ipairs(data) do
        if move.to == player and move.toArea == Player.Hand then
          for _, info in ipairs(move.moveInfo) do
            if table.contains(player:getCardIds("h"), info.cardId) then
              return true
            end
          end
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = shiyin.name,
      prompt = "#ofl__shiyin-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local ids, suits = {}, {}
    for _, move in ipairs(data) do
      if move.to == player and move.toArea == Player.Hand then
        for _, info in ipairs(move.moveInfo) do
          if table.contains(player:getCardIds("h"), info.cardId) then
            table.insertIfNeed(ids, info.cardId)
            table.insertIfNeed(suits, Fk:getCardById(info.cardId).suit)
          end
        end
      end
    end
    table.removeOne(suits, Card.NoSuit)
    player:showCards(ids)
    if player.dead or #suits == 0 then return end
    room:setPlayerMark(player, "@ofl__shiyin-turn", math.max(#suits, player:getMark("@ofl__shiyin-turn")))
  end,
})

shiyin:addEffect(fk.CardUsing, {
  anim_type = "offensive",
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and player:getMark("@ofl__shiyin-turn") > 0
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local n = player:getMark("@ofl__shiyin-turn")
    room:setPlayerMark(player, "@ofl__shiyin-turn", 0)
    data.disresponsiveList = table.simpleClone(room.players)
    if n > 1 then
      data.additionalDamage = (data.additionalDamage or 0) + 1
    end
    if n > 2 then
      player:drawCards(1, shiyin.name)
    end
  end,
})

return shiyin
