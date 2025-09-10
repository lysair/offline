local weizhen = fk.CreateSkill {
  name = "ofl_tx__weizhen",
}

Fk:loadTranslationTable{
  ["ofl_tx__weizhen"] = "巍镇",
  [":ofl_tx__weizhen"] = "出牌阶段开始时，你可以指定一名其他角色，此阶段当你对其造成伤害后，你摸X张牌并令其获得X枚“镇”标记（X为伤害值）。"..
  "弃牌阶段结束时，有“镇”标记的角色选择一项并移去所有“镇”标记：1.交给你“镇”标记数量张红色牌；2.不能使用或打出手牌直到你下回合开始。"..
  "若其选择1，则你执行<a href='os__coop'>同心效果</a>：从游戏外获得一张【决斗】。",

  ["#ofl_tx__weizhen-tongxin"] = "选择一名角色成为你的 “巍镇” 同心角色",
  ["@ofl_tx__weizhen_tongxin"] = "巍镇同心",
  ["#ofl_tx__weizhen-choose"] = "巍镇：指定一名角色，此阶段对其造成伤害后你摸牌并执行效果",
  ["@ofl_tx__weizhen"] = "镇",
  ["@@ofl_tx__weizhen_prohibit"] = "禁用手牌",
  ["#ofl_tx__weizhen-give"] = "巍镇：交给 %src %arg张红色牌，否则你不能使用打出手牌直到其下回合开始",
}

weizhen:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(weizhen.name) and player.phase == Player.Play and
      #player.room:getOtherPlayers(player, false) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room:getOtherPlayers(player, false),
      prompt = "#ofl_tx__weizhen-choose",
      skill_name = weizhen.name,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local to = event:getCostData(self).tos[1]
    player.room:setPlayerMark(player, "ofl_tx__weizhen-phase", to)
  end,
})

weizhen:addEffect(fk.Damage, {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(weizhen.name) and
      player:getMark("ofl_tx__weizhen-phase") == data.to
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if not data.to.dead then
      room:addPlayerMark(data.to, "@ofl_tx__weizhen", data.damage)
    end
    player:drawCards(data.damage, weizhen.name)
  end,
})

weizhen:addEffect(fk.EventPhaseEnd, {
  anim_type = "control",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(weizhen.name) and player.phase == Player.Discard and
      table.find(player.room:getOtherPlayers(player, false), function (p)
        return p:getMark("@ofl_tx__weizhen") > 0
      end)
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local tos = table.filter(room:getOtherPlayers(player), function (p)
      return p:getMark("@ofl_tx__weizhen") > 0
    end)
    event:setCostData(self, {tos = tos})
    return true
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if p:getMark("@ofl_tx__weizhen") > 0 then
        local n = p:getMark("@ofl_tx__weizhen")
        room:setPlayerMark(p, "@ofl_tx__weizhen", 0)
        if not player.dead then
          local cards = room:askToCards(p, {
            min_num = n,
            max_num = n,
            include_equip = true,
            skill_name = weizhen.name,
            pattern = ".|.|red",
            prompt = "#ofl_tx__weizhen-give:"..player.id.."::"..n,
            cancelable = true,
          })
          if #cards > 0 then
            local tongxin = player:getMark("@ofl_tx__weizhen_tongxin")
            room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonGive, weizhen.name, nil, false, p)
            if not player.dead then
              local ids = table.filter(room:getBanner(weizhen.name), function (id)
                return room:getCardArea(id) == Card.Void
              end)
              if #ids > 0 then
                local id = table.random(ids)
                room:setCardMark(Fk:getCardById(id), MarkEnum.DestructIntoDiscard, 1)
                room:moveCardTo(id, Card.PlayerHand, player, fk.ReasonJustMove, weizhen.name, nil, true, player)
              end
            end
            if tongxin ~= 0 and not tongxin.dead then
              local ids = table.filter(room:getBanner(weizhen.name), function (id)
                return room:getCardArea(id) == Card.Void
              end)
              if #ids > 0 then
                local id = table.random(ids)
                room:setCardMark(Fk:getCardById(id), MarkEnum.DestructIntoDiscard, 1)
                room:moveCardTo(id, Card.PlayerHand, tongxin, fk.ReasonJustMove, weizhen.name, nil, true, tongxin)
              end
            end
          else
            room:addTableMarkIfNeed(p, "@@ofl_tx__weizhen_prohibit", player)
          end
        end
      end
    end
  end,
})

weizhen:addEffect("prohibit", {
  prohibit_use = function(self, player, card)
    if player:getMark("@@ofl_tx__weizhen_prohibit") ~= 0 then
      local subcards = card:isVirtual() and card.subcards or {card.id}
      return #subcards > 0 and table.every(subcards, function(id)
        return table.contains(player:getCardIds("h"), id)
      end)
    end
  end,
  prohibit_response = function (self, player, card)
    if player:getMark("@@ofl_tx__weizhen_prohibit") ~= 0 then
      local subcards = card:isVirtual() and card.subcards or {card.id}
      return #subcards > 0 and table.every(subcards, function(id)
        return table.contains(player:getCardIds("h"), id)
      end)
    end
  end,
})

weizhen:addEffect(fk.TurnStart, {
  anim_type = "support",
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(weizhen.name) and
      #player.room:getOtherPlayers(player, false) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room:getOtherPlayers(player, false),
      prompt = "#ofl_tx__weizhen-tongxin",
      skill_name = weizhen.name,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local to = event:getCostData(self).tos[1]
    player.room:setPlayerMark(player, "@ofl_tx__weizhen_tongxin", to)
  end,

  can_refresh = function(self, event, target, player, data)
    return target == player
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@ofl_tx__weizhen_tongxin", 0)
    for _, p in ipairs(room:getOtherPlayers(player, false)) do
      room:removeTableMark(p, "@@ofl_tx__weizhen_prohibit", player)
    end
  end,
})

weizhen:addAcquireEffect(function (self, player, is_start)
  local room = player.room
  local banner = room:getBanner(weizhen.name) or {}
  for _, info in ipairs({
    {"duel", Card.Spade, 1},
    {"duel", Card.Club, 1},
  }) do
    local id = room:printCard(info[1], info[2], info[3]).id
    table.insert(banner, id)
  end
  room:setBanner(weizhen.name, banner)
end)

weizhen:addLoseEffect(function (self, player, is_death)
  local room = player.room
  room:setPlayerMark(player, "@ofl_tx__weizhen_tongxin", 0)
  for _, p in ipairs(room:getOtherPlayers(player, false)) do
    room:setPlayerMark(p, "@ofl_tx__weizhen", 0)
    room:removeTableMark(p, "@@ofl_tx__weizhen_prohibit", player)
  end
end)

return weizhen
