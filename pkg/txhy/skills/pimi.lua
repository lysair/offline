local pimi = fk.CreateSkill {
  name = "ofl_tx__pimi",
}

Fk:loadTranslationTable{
  ["ofl_tx__pimi"] = "披靡",
  [":ofl_tx__pimi"] = "当你使用【杀】造成伤害时，你可以废除受伤角色一种装备栏。装备栏均被废除的角色不能响应你使用的牌。",

  ["#ofl_tx__pimi-invoke"] = "披靡：你可以废除 %dest 一种装备栏",
}

pimi:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(pimi.name) and
      data.card and data.card.trueName == "slash" and
      #data.to:getAvailableEquipSlots() > 0 and not data.to.dead
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local choices = {}
    for _, slot in ipairs(data.to:getAvailableEquipSlots()) do
      if slot == Player.OffensiveRideSlot or slot == Player.DefensiveRideSlot then
        table.insertIfNeed(choices, "RideSlot")
      else
        table.insert(choices, slot)
      end
    end
    table.insert(choices, "Cancel")
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = pimi.name,
      prompt = "#ofl_tx__pimi-invoke::"..data.to.id,
    })
    if choice ~= "Cancel" then
      event:setCostData(self, {choice = choice, tos = {data.to}})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local choice = event:getCostData(self).choice
    if choice == "RideSlot" then
      choice = { Player.OffensiveRideSlot, Player.DefensiveRideSlot }
    end
    room:abortPlayerArea(data.to, choice)
  end,
})

pimi:addEffect(fk.CardUsing, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(pimi.name) then
      if data.card.trueName == "slash" then
        return table.find(data.tos, function(p)
          return #p:getAvailableEquipSlots() == 0
        end)
      elseif data.card:isCommonTrick() then
        return table.find(player.room.alive_players, function(p)
          return #p:getAvailableEquipSlots() == 0
        end)
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    data.disresponsiveList = data.disresponsiveList or {}
    for _, p in ipairs(player.room.alive_players) do
      if #p:getAvailableEquipSlots() == 0 then
        table.insertIfNeed(data.disresponsiveList, p)
      end
    end
  end,
})

return pimi
