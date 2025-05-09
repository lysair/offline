local chenzhi = fk.CreateSkill {
  name = "chenzhi",
  tags = { Skill.Compulsory }
}

Fk:loadTranslationTable{
  ["chenzhi"] = "沉滞",
  [":chenzhi"] = "锁定技，当你摸牌时，改为从游戏外扑克牌摸等量的牌（包括初始手牌）。扑克牌视为基本牌，进入弃牌堆后销毁。",

  ["poker"] = "牌",
}

chenzhi:addEffect(fk.BeforeDrawCard, {
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(chenzhi.name) and data.num > 0
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local cards = table.random(room:getBanner(chenzhi.name), data.num)
    if #cards < data.num then
      room:sendLog{
        type = "#NoCardDraw",
        toast = true,
      }
      room:gameOver("")
    end
    room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonDraw, data.skillName)
    return true
  end,
})

chenzhi:addEffect(fk.DrawInitialCards, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(chenzhi.name)
  end,
  on_refresh = function(self, event, target, player, data)
    data.fix_ids = player.room:getBanner(chenzhi.name)
  end,
})

chenzhi:addAcquireEffect(function (self, player, is_start)
  local room = player.room
  if not room:getBanner(chenzhi.name) then
    local ids = {}
    for suit = 1, 4, 1 do
      for number = 1, 13, 1 do
        local card = room:printCard("poker", suit, number)
        room:setCardMark(card, MarkEnum.DestructIntoDiscard, 1)
        table.insert(ids, card.id)
      end
    end
    room:setBanner(chenzhi.name, ids)
  end
end)

return chenzhi
