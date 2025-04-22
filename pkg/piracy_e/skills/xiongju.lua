local xiongju = fk.CreateSkill {
  name = "xiongju",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["xiongju"] = "雄踞",
  [":xiongju"] = "锁定技，游戏开始时，你从游戏外获得两张<a href=':jingxiang_golden_age'>【荆襄盛世】</a>，然后加X点体力上限，回复X点体力；"..
  "你的起始手牌数+X、手牌上限+X（X为场上势力数）。",
}

xiongju:addEffect(fk.GameStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(xiongju.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = {}
    for _ = 1, 2 do
      local id = room:printCard("jingxiang_golden_age", Card.Heart, 5).id
      table.insert(cards, id)
    end
    room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonJustMove, xiongju.name, nil, true, player)
    if not player.dead then
      local kingdoms = {}
      for _, p in ipairs(room.alive_players) do
        table.insertIfNeed(kingdoms, p.kingdom)
      end
      room:changeMaxHp(player, #kingdoms)
      if player:isWounded() and not player.dead then
        room:recover{
          who = player,
          num = player.maxHp - player.hp,
          recoverBy = player,
          skillName = xiongju.name,
        }
      end
    end
  end,
})

xiongju:addEffect(fk.DrawInitialCards, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xiongju.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local kingdoms = {}
    for _, p in ipairs(room.alive_players) do
      table.insertIfNeed(kingdoms, p.kingdom)
    end
    data.num = data.num + #kingdoms
  end,
})

xiongju:addEffect("maxcards", {
  correct_func = function(self, player)
    if player:hasSkill(xiongju.name) then
      local kingdoms = {}
      for _, p in ipairs(Fk:currentRoom().alive_players) do
        table.insertIfNeed(kingdoms, p.kingdom)
      end
      return #kingdoms
    end
  end,
})

return xiongju
