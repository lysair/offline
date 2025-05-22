local pianchong = fk.CreateSkill {
  name = "ofl__pianchong",
}

Fk:loadTranslationTable{
  ["ofl__pianchong"] = "偏宠",
  [":ofl__pianchong"] = "摸牌阶段，你可以改为获得牌堆底的一张牌，此牌倒置（标记为“偏宠”），然后你摸一张牌，直到你下回合开始："..
  "你每失去一张倒置牌后，摸一张牌；你每失去一张未倒置的手牌后，获得牌堆底的一张牌并倒置。",

  ["@ofl__pianchong"] = "偏宠",
  ["@@ofl__pianchong"] = "偏宠",

  ["$ofl__pianchong1"] = "挽指玉瓶绘淡彩，一眸春水映江南。",
  ["$ofl__pianchong2"] = "小楫行舟慕胧色，烟雨独钟我一人。",
}

pianchong:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(pianchong.name) and player.phase == Player.Draw
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    data.phase_end = true
    player:drawCards(1, pianchong.name, "bottom", "@@ofl__pianchong")
    if player.dead then return end
    player:drawCards(1, pianchong.name)
    if player.dead then return end
    room:setPlayerMark(player, "@ofl__pianchong", 1)
  end,
})

pianchong:addEffect(fk.TurnStart, {
  can_refresh = function(self, event, target, player, data)
    return target == player
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@ofl__pianchong", 0)
  end,
})

pianchong:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if player:getMark("@ofl__pianchong") > 0 and not player.dead then
      local x, y = 0, 0
      for _, move in ipairs(data) do
        if move.from == player and move.ofl__pianchong then
          x = x + move.ofl__pianchong[1]
          y = y + move.ofl__pianchong[2]
        end
      end
      if x > 0 or y > 0 then
        event:setCostData(self, {extra_data = {x, y}})
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local dat = event:getCostData(self).extra_data
    local x, y = table.unpack(dat)
    if x > 0 then
      player:drawCards(x, pianchong.name)
      if player.dead then return end
    end
    if y > 0 then
      player:drawCards(y, pianchong.name, "bottom", "@@ofl__pianchong")
    end
  end,

  can_refresh = function (self, event, target, player, data)
    for _, move in ipairs(data) do
      if move.from == player then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand then
            return true
          end
        end
      end
    end
  end,
  on_refresh = function (self, event, target, player, data)
    for _, move in ipairs(data) do
      if move.from == player then
        local x, y = 0, 0
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand then
            local card = Fk:getCardById(info.cardId)
            if card:getMark("@@ofl__pianchong") > 0 then
              x = x + 1
              player.room:setCardMark(card, "@@ofl__pianchong", 0)
            else
              y = y + 1
            end
          end
        end
        if player:getMark("@ofl__pianchong") > 0 then
          move.ofl__pianchong = {x, y}
        end
      end
    end
  end,
})



return pianchong
