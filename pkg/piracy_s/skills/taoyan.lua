local taoyan = fk.CreateSkill {
  name = "ofl__taoyan",
}

Fk:loadTranslationTable{
  ["ofl__taoyan"] = "桃宴",
  [":ofl__taoyan"] = "回合开始时，你可以令至多两名其他角色各摸一张牌并从游戏外获得一张【桃】。",

  ["#ofl__taoyan-choose"] = "桃宴：令至多两名其他角色各摸一张牌并获得一张【桃】",
}

taoyan:addEffect(fk.TurnStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(taoyan.name) and
      #player.room:getOtherPlayers(player, false) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local tos = room:askToChoosePlayers(player, {
      targets = room:getOtherPlayers(player, false),
      min_num = 1,
      max_num = 2,
      prompt = "#ofl__taoyan-choose",
      skill_name = taoyan.name,
      cancelable = true,
    })
    if #tos > 0 then
      room:sortByAction(tos)
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(event:getCostData(self).tos) do
      if not p.dead then
        p:drawCards(1, taoyan.name)
      end
      if not p.dead then
        local banner = room:getBanner(taoyan.name) or {}
        local c
        for _, id in ipairs(banner) do
          if room:getCardArea(id) == Card.Void then
            c = id
            break
          end
        end
        if c == nil then
          c = room:printCard("peach", Card.Heart, table.random({3, 4, 6, 7, 8, 9})).id
        end
        room:setCardMark(Fk:getCardById(c), MarkEnum.DestructIntoDiscard, 1)
        room:moveCardTo(c, Card.PlayerHand, p, fk.ReasonJustMove, taoyan.name, nil, true, player)
      end
    end
  end,
})

return taoyan
