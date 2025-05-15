local jueyi = fk.CreateSkill {
  name = "jueyi",
}

Fk:loadTranslationTable{
  ["jueyi"] = "决意",
  [":jueyi"] = "出牌阶段开始时，你可以重铸至多两张牌，所有角色本回合不能弃置与重铸牌花色相同的牌，直到有角色进入濒死状态。",

  ["#jueyi-invoke"] = "决意：重铸至多两张牌，所有角色本回合不能弃置这些花色的牌",
}

jueyi:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jueyi.name) and player.phase == Player.Play and
      not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cards = room:askToCards(player, {
      min_num = 1,
      max_num = 2,
      include_equip = true,
      skill_name = jueyi.name,
      prompt = "#jueyi-invoke",
      cancelable = true,
    })
    if #cards > 0 then
      event:setCostData(self, {cards = cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = event:getCostData(self).cards
    room:recastCard(cards, player, jueyi.name)
    local banner = room:getBanner("jueyi-turn") or {}
    for _, id in ipairs(cards) do
      table.insertIfNeed(banner, Fk:getCardById(id).suit)
    end
    table.removeOne(banner, Card.NoSuit)
    room:setBanner("jueyi-turn", banner)
  end,
})

jueyi:addEffect(fk.EnterDying, {
  can_refresh = function (self, event, target, player, data)
    return target == player
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:setBanner("jueyi-turn", 0)
  end,
})

jueyi:addEffect("prohibit", {
  prohibit_discard = function (self, player, card)
    return Fk:currentRoom():getBanner("jueyi-turn") and
      table.contains(Fk:currentRoom():getBanner("jueyi-turn"), card.suit)
  end,
})

return jueyi
