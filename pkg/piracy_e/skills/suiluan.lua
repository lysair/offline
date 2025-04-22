local suiluan = fk.CreateSkill {
  name = "ofl__suiluan",
}

Fk:loadTranslationTable{
  ["ofl__suiluan"] = "随乱",
  [":ofl__suiluan"] = "群势力技，你使用【杀】可以多指定至多两个目标，若如此做，此【杀】结算后，所有目标角色依次可以对你使用一张【杀】，"..
  "当你以此法受到伤害后，你变更势力至蜀。",

  ["#ofl__suiluan-choose"] = "随乱：你可以为此%arg额外指定至多两个目标",
  ["#ofl__suil__use"] = "随乱：你可以对 %src 使用一张【杀】",
}

suiluan:addEffect(fk.AfterCardTargetDeclared, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(suiluan.name) and data.card.trueName == "slash" and
      #data:getExtraTargets() > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local tos = room:askToChoosePlayers(player, {
      targets = data:getExtraTargets(),
      min_num = 1,
      max_num = 2,
      prompt = "#ofl__suiluan-choose:::"..data.card:toLogString(),
      skill_name = suiluan.name,
    })
    if #tos > 0 then
      room:sortByAction(tos)
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    data.extra_data = data.extra_data or {}
    data.extra_data.ofl__suiluan = player.id
    for _, p in ipairs(event:getCostData(self).tos) do
      data:addTarget(p)
    end
  end,
})

suiluan:addEffect(fk.CardUseFinished, {
  anim_type = "negative",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if target == player then
      return data.extra_data and data.extra_data.ofl__suiluan and data.extra_data.ofl__suiluan == player.id and
        table.find(data.tos, function(p)
          return not p.dead and p:canUseTo(Fk:cloneCard("slash"), player)
        end)
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(data.tos) do
      if player.dead then return end
      if not p.dead and p:canUseTo(Fk:cloneCard("slash"), player) then
        local use = room:askToUseCard(p, {
          skill_name = "ofl__suiluan",
          pattern = "slash",
          prompt = "#ofl__suiluan-use:"..player.id,
          cancelable = true,
          extra_data = {
            bypass_distances = true,
            bypass_times = true,
            extraUse = true,
            must_targets = {player.id},
          }
        })
        if use then
          use.extra_data = use.extra_data or {}
          use.extra_data.ofl__suiluan_use = player.id
          room:useCard(use)
        end
      end
    end
  end,
})

suiluan:addEffect(fk.Damaged, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if target == player and data.card and player.kingdom ~= "shu" and not player.dead then
      local room = player.room
      local use_event = room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
      if not use_event then return false end
      local use = use_event.data
      return use.extra_data and use.extra_data.ofl__suiluan_use == player.id
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:changeKingdom(player, "shu", true)
  end,
})

return suiluan
