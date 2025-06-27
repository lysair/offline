local bozhan = fk.CreateSkill {
  name = "bozhan",
}

Fk:loadTranslationTable{
  ["bozhan"] = "膊战",
  [":bozhan"] = "其他角色的准备阶段，你可以废除一个装备栏，视为对其使用一张【决斗】。",

  ["#bozhan-invoke"] = "膊战：你可以废除一个装备栏，视为对 %dest 使用【决斗】",
}

bozhan:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(bozhan.name) and target.phase == Player.Start and
      #player:getAvailableEquipSlots() > 0 and not target.dead and player:canUseTo(Fk:cloneCard("duel"), target)
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local choices = player:getAvailableEquipSlots()
    table.insert(choices, "Cancel")
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = bozhan.name,
      prompt = "#bozhan-invoke::"..target.id,
    })
    if choice ~= "Cancel" then
      event:setCostData(self, {tos = {target}, choice = choice})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:abortPlayerArea(player, event:getCostData(self).choice)
    if not player.dead and not target.dead then
      room:useVirtualCard("duel", nil, player, target, bozhan.name)
    end
  end,
})

return bozhan
