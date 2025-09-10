local manyong = fk.CreateSkill {
  name = "manyong",
}

Fk:loadTranslationTable{
  ["manyong"] = "蛮勇",
  [":manyong"] = "回合开始时，若你的装备区内没有<a href=':iron_bud'>【铁蒺藜骨朵】</a>，你可以从游戏外使用之。回合结束时，"..
  "你可以弃置装备区内的【铁蒺藜骨朵】。【铁蒺藜骨朵】离开装备区后销毁。",

  ["#manyong-use"] = "蛮勇：是否从游戏外装备【铁蒺藜骨朵】？",
  ["#manyong-discard"] = "蛮勇：是否弃置装备区内的【铁蒺藜骨朵】？",
}

manyong:addEffect(fk.TurnStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(manyong.name) and
      not table.find(player:getEquipments(Card.SubtypeWeapon), function(id)
        return Fk:getCardById(id).name == "iron_bud"
      end) then
      local cards = table.filter(player.room:getBanner(manyong.name) or {}, function (id)
        return player.room:getCardArea(id) == Card.Void
      end)
      return #cards > 0 and not player:isProhibited(player, Fk:getCardById(cards[1]))
    end
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = manyong.name,
      prompt = "#manyong-use",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = table.filter(player.room:getBanner(manyong.name) or {}, function (id)
      return player.room:getCardArea(id) == Card.Void
    end)
    local card = Fk:getCardById(cards[1])
    room:setCardMark(card, MarkEnum.DestructOutMyEquip, 1)
    room:useCard({
      from = player,
      tos = {player},
      card = card,
    })
  end,
})

manyong:addAcquireEffect(function (self, player, is_start)
  local room = player.room
  if room:getBanner(manyong.name) == nil then
    local id = room:printCard("iron_bud", Card.Spade, 5).id
    room:setBanner(manyong.name, {id})
  end
end)

manyong:addEffect(fk.TurnEnd, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(manyong.name) and
      table.find(player:getEquipments(Card.SubtypeWeapon), function(id)
        return Fk:getCardById(id).name == "iron_bud"
      end)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = manyong.name,
      prompt = "#manyong-discard",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = table.filter(player:getEquipments(Card.SubtypeWeapon), function(id)
      return Fk:getCardById(id).name == "iron_bud"
    end)
    room:throwCard(cards, manyong.name, player, player)
  end,
})

return manyong
