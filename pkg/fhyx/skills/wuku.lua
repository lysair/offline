local wuku = fk.CreateSkill {
  name = "ofl_shiji__wuku",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_shiji__wuku"] = "武库",
  [":ofl_shiji__wuku"] = "锁定技，当你使用装备牌时或其他角色失去装备区内的一张牌时，你获得1枚“武库”标记（至多3枚）。",

  ["$ofl_shiji__wuku1"] = "人非生而知之，但敏而求之也。",
  ["$ofl_shiji__wuku2"] = "广习经籍，只为上能弼国，下可安民。",
  ["$ofl_shiji__wuku3"] = "千计万策，随江即来也。",
  ["$ofl_shiji__wuku4"] = "万结之绳，不过一剑即解。",
}

wuku:addEffect(fk.CardUsing, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(wuku.name) and
      data.card.type == Card.TypeEquip and player:getMark("@wuku") < 3
  end,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "@wuku", 1)
  end,
})

wuku:addEffect(fk.BeforeCardsMove, {
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(wuku.name) and player:getMark("@wuku") < 3 then
      for _, move in ipairs(data) do
        if move.from ~= player then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerEquip then
              return true
            end
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if player:getMark("@wuku") == 2 then
      room:addPlayerMark(player, "@wuku", 1)
    else
      local n = 0
      for _, move in ipairs(data) do
        if move.from ~= player then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerEquip then
              n = n + 1
            end
          end
        end
      end
      room:addPlayerMark(player, "@wuku", math.min(n, 3 - player:getMark("@wuku")))
    end
  end,
})

return wuku
