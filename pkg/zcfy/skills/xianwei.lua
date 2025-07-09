local xianwei = fk.CreateSkill {
  name = "sxfy__xianwei",
}

Fk:loadTranslationTable{
  ["sxfy__xianwei"] = "险卫",
  [":sxfy__xianwei"] = "当一名角色成为【杀】的目标后，你可以将手牌中一张装备牌置入其装备区，若如此做，当其需响应此【杀】使用【闪】时，"..
  "视为其使用一张【闪】。若不为你，你可以摸一张牌。",

  ["#sxfy__xianwei-invoke"] = "险卫：你可以将一张装备置入 %dest 装备区，视为其使用【闪】",
  ["#sxfy__xianwei-draw"] = "险卫：是否摸一张牌？",
}

xianwei:addEffect(fk.TargetConfirmed, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(xianwei.name) and
      data.card.trueName == "slash" and target:hasEmptyEquipSlot() and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local ids = table.filter(player:getCardIds("h"), function (id)
      return target:canMoveCardIntoEquip(id, false)
    end)
    local card = room:askToCards(player, {
      skill_name = xianwei.name,
      include_equip = false,
      min_num = 1,
      max_num = 1,
      pattern = tostring(Exppattern{ id = ids }),
      prompt = "#sxfy__xianwei-invoke::"..target.id,
      cancelable = true,
    })
    if #card > 0 then
      event:setCostData(self, {tos = {target}, cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1] ---@type ServerPlayer
    local id = event:getCostData(self).cards[1]
    room:moveCardIntoEquip(to, id, xianwei.name, false, player)
    data.extra_data = data.extra_data or {}
    data.extra_data.sxfy__xianwei = true
    if target ~= player and not player.dead and
      room:askToSkillInvoke(player, {
        skill_name = xianwei.name,
        prompt = "#sxfy__xianwei-draw",
      }) then
      player:drawCards(1, xianwei.name)
    end
  end,
})

xianwei:addEffect(fk.AskForCardUse, {
  priority = 1.1,
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if target == player and Exppattern:Parse(data.pattern):matchExp("jink|0|nosuit|none") and
      not player:prohibitUse(Fk:cloneCard("jink")) and
      data.eventData and data.eventData.card and data.eventData.card.trueName == "slash" then
      local use_event = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard, true)
      if use_event and use_event.data.card == data.eventData.card then
        local use = use_event.data
        return use.extra_data and use.extra_data.sxfy__xianwei
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    local new_card = Fk:cloneCard("jink")
    new_card.skillName = xianwei.name
    local result = {
      from = player,
      card = new_card,
      tos = {},
    }
    data.result = result
    return true
  end,
})

return xianwei
