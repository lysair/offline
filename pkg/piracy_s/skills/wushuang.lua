local wushuang = fk.CreateSkill {
  name = "ofl__wushuang",
  tags = { Skill.Compulsory },
  dynamic_desc = function (self, player)
    if player:getMark(self.name) == 0 then
      return "wushuang"
    elseif player:getMark(self.name) == 1 then
      return "ofl__wushuang_inner:ofl__wushuang_1:"
    elseif player:getMark(self.name) == 2 then
      return "ofl__wushuang_inner:ofl__wushuang_1:ofl__wushuang_2"
    end
  end,
}

Fk:loadTranslationTable{
  ["ofl__wushuang"] = "无双",
  [":ofl__wushuang"] = "锁定技，当你使用【杀】指定目标后，其使用【闪】抵消此【杀】的方式改为需连续使用两张【闪】；当你使用【决斗】指定目标后，"..
  "或当你成为【决斗】的目标后，你令其打出【杀】响应此【决斗】的方式改为需连续打出两张【杀】。<br>" ..
  "二级：增加效果：当其他角色弃置的【决斗】进入弃牌堆后，你获得之。<br>" ..
  "三级：增加效果：你使用【杀】伤害基数值+1，目标角色每使用一张【闪】进行响应，此【杀】对其造成的伤害-1。",

  [":ofl__wushuang_inner"] = "锁定技，当你使用【杀】指定目标后，其使用【闪】抵消此【杀】的方式改为需连续使用两张【闪】；"..
  "当你使用【决斗】指定目标后，或当你成为【决斗】的目标后，你令其打出【杀】响应此【决斗】的方式改为需连续打出两张【杀】。<br>{1}<br>{2}",
  ["ofl__wushuang_1"] = "当其他角色弃置的【决斗】进入弃牌堆后，你获得之。",
  ["ofl__wushuang_2"] = "你使用【杀】伤害基数值+1，目标角色每使用一张【闪】进行响应，此【杀】对其造成的伤害-1。",
}

---@type TrigSkelSpec<AimFunc>
local spec = {
  on_use = function(self, event, target, player, data)
    data.fixedResponseTimes = 2
    if data.card.trueName == "duel" then
      data.fixedAddTimesResponsors = data.fixedAddTimesResponsors or {}
      table.insertIfNeed(data.fixedAddTimesResponsors, (event == fk.TargetSpecified) and data.to or data.from)
    end
  end,
}

wushuang:addEffect(fk.TargetSpecified, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(wushuang.name) and
      table.contains({ "slash", "duel" }, data.card.trueName)
  end,
  on_use = spec.on_use
})

wushuang:addEffect(fk.TargetConfirmed, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(wushuang.name) and data.card.trueName == "duel"
  end,
  on_use = spec.on_use
})

wushuang:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(wushuang.name) and player:getMark(wushuang.name) > 0 then
      local ids = {}
      for _, move in ipairs(data) do
        if move.moveReason == fk.ReasonDiscard and move.from and move.from ~= player then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand and Fk:getCardById(info.cardId).name == "duel" then
              table.insertIfNeed(ids, info.cardId)
            end
          end
        end
      end
      ids = table.filter(ids, function (id)
        return table.contains(player.room.discard_pile, id)
      end)
      ids = player.room.logic:moveCardsHoldingAreaCheck(ids)
      if #ids > 0 then
        event:setCostData(self, {cards = ids})
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = table.simpleClone(event:getCostData(self).cards)
    room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonJustMove, wushuang.name, nil, true, player)
  end,
})

wushuang:addEffect(fk.CardUsing, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(wushuang.name) and
      player:getMark(wushuang.name) > 1 and data.card.trueName == "slash"
  end,
  on_use = function (self, event, target, player, data)
    data.additionalDamage = (data.additionalDamage or 0) + 1
  end,
})

wushuang:addEffect(fk.DamageInflicted, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(wushuang.name) and player:getMark(wushuang.name) > 1 and data.card and data.card.trueName == "slash" then
      local use_event = player.room.logic:getCurrentEvent():findParent(GameEvent.CardEffect)
      if use_event then
        local use = use_event.data
        if use.from == player then
          local n = #use_event:searchEvents(GameEvent.UseCard, data.damage, function (e)
            local u = e.data
            return u.from == target and u.card.trueName == "jink" and u.responseToEvent == use
          end)
          if n > 0 then
            event:setCostData(self, {extra_data = -n})
            return true
          end
        end
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    data:changeDamage(event:getCostData(self).extra_data)
  end,
})

return wushuang
