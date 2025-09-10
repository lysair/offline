local xueyi = fk.CreateSkill{
  name = "ofl_mou__xueyi",
  tags = { Skill.Lord, Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_mou__xueyi"] = "血裔",
  [":ofl_mou__xueyi"] = "主公技，锁定技，你的手牌上限+2X（X为其他群势力角色数）。当你使用牌结算后，你令响应过此牌的其他群势力角色"..
  "本阶段不能使用或打出手牌。",

  ["@@ofl_mou__xueyi-phase"] = "禁用手牌",

  ["$ofl_mou__xueyi1"] = "天下诸公，皆是我袁门故吏！",
  ["$ofl_mou__xueyi2"] = "累四世功名，今朝定声震寰宇！",
}

xueyi:addEffect(fk.CardUseFinished, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xueyi.name) and
      #data.tos > 0 and data.extra_data and data.extra_data.ofl_mou__xueyi and
      table.find(data.extra_data.ofl_mou__xueyi, function (p)
        return not p.dead and p.kingdom == "qun"
      end) and
      player.room.logic:getCurrentEvent():findParent(GameEvent.Phase, true)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(data.extra_data.ofl_mou__xueyi) do
      if not p.dead and p.kingdom == "qun" then
        room:setPlayerMark(p, "@@ofl_mou__xueyi-phase", 1)
      end
    end
  end,
})

local spec = {
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local use_event = room.logic:getCurrentEvent():findParent(GameEvent.UseCard, true)
    if use_event == nil then return end
    local use = use_event.data
    use.extra_data = use.extra_data or {}
    use.extra_data.ofl_mou__xueyi = use.extra_data.ofl_mou__xueyi or {}
    table.insertIfNeed(use.extra_data.ofl_mou__xueyi, player)
  end,
}
xueyi:addEffect(fk.AfterAskForCardUse, {
  can_refresh = function(self, event, target, player, data)
    return target == player and data.eventData and data.result and data.result.from == player
  end,
  on_refresh = spec.on_refresh,
})
xueyi:addEffect(fk.AfterAskForCardResponse, {
  can_refresh = function(self, event, target, player, data)
    return target == player and data.eventData and data.result
  end,
  on_refresh = spec.on_refresh,
})
xueyi:addEffect(fk.AfterAskForNullification, {
  can_refresh = function(self, event, target, player, data)
    return data.eventData and data.result and data.result.from == player
  end,
  on_refresh = spec.on_refresh,
})

xueyi:addEffect("maxcards", {
  correct_func = function(self, player)
    if player:hasSkill(xueyi.name) then
      local hmax = 0
      for _, p in ipairs(Fk:currentRoom().alive_players) do
        if p ~= player and p.kingdom == "qun" then
          hmax = hmax + 1
        end
      end
      return hmax * 2
    end
  end,
})

xueyi:addEffect("prohibit", {
  prohibit_use = function(self, player, card)
    if player:getMark("@@ofl_mou__xueyi-phase") > 0 then
      local subcards = card:isVirtual() and card.subcards or {card.id}
      return #subcards > 0 and table.every(subcards, function(id)
        return table.contains(player:getCardIds("h"), id)
      end)
    end
  end,
  prohibit_response = function (self, player, card)
    if player:getMark("@@ofl_mou__xueyi-phase") > 0 then
      local subcards = card:isVirtual() and card.subcards or {card.id}
      return #subcards > 0 and table.every(subcards, function(id)
        return table.contains(player:getCardIds("h"), id)
      end)
    end
  end,
})

return xueyi
