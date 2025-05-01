local taoyuan = fk.CreateSkill {
  name = "taoyuan",
}

Fk:loadTranslationTable{
  ["taoyuan"] = "桃园",
  [":taoyuan"] = "出牌阶段限一次，你可以弃置两张牌，令一名角色从游戏外获得一张【桃园结义】。（游戏外共有3张【桃园结义】，进入弃牌堆时销毁）",

  ["#taoyuan"] = "桃园：弃置两张牌，令一名角色从游戏外获得一张【桃园结义】",
}

taoyuan:addEffect("active", {
  anim_type = "support",
  card_num = 2,
  target_num = 1,
  prompt = "#taoyuan",
  can_use = function (self, player)
    return player:usedSkillTimes(taoyuan.name, Player.HistoryPhase) == 0 and
      table.find(Fk:currentRoom():getBanner(taoyuan.name), function (id)
        return Fk:currentRoom():getCardArea(id) == Card.Void
      end)
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected < 2 and not player:prohibitDiscard(to_select)
  end,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    room:throwCard(effect.cards, taoyuan.name, player, player)
    if player.dead or target.dead then return end
    local card = table.filter(room:getBanner(taoyuan.name), function (id)
      return room:getCardArea(id) == Card.Void
    end)
    if #card > 0 then
      card = Fk:getCardById(card[1])
      room:setCardMark(card, MarkEnum.DestructIntoDiscard, 1)
      room:moveCardTo(card, Card.PlayerHand, target, fk.ReasonJustMove, taoyuan.name, nil, true, player)
    end
  end,
})

taoyuan:addAcquireEffect(function (self, player, is_start)
  local room = player.room
  if not room:getBanner(taoyuan.name) then
    local ids = {}
    for _ = 1, 3 do
      local id = room:printCard("god_salvation", Card.Heart, 1).id
      table.insert(ids, id)
    end
    room:setBanner(taoyuan.name, ids)
  end
end)

return taoyuan
