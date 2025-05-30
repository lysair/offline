local jiangzhan = fk.CreateSkill {
  name = "jiangzhan",
}

Fk:loadTranslationTable{
  ["jiangzhan"] = "将战",
  [":jiangzhan"] = "其他角色的准备阶段，你可以废除一个装备栏，视为对其使用一张【决斗】。",

  ["#jiangzhan-invoke"] = "将战：你可以废除一个装备栏，视为对 %dest 使用【决斗】",
}

jiangzhan:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(jiangzhan.name) and target.phase == Player.Start and
      #player:getAvailableEquipSlots() > 0 and not target.dead and player:canUseTo(Fk:cloneCard("duel"), target)
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local choices = player:getAvailableEquipSlots()
    table.insert(choices, "Cancel")
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = jiangzhan.name,
      prompt = "#jiangzhan-invoke::"..target.id,
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
      room:useVirtualCard("duel", nil, player, target, jiangzhan.name)
    end
  end,
})

return jiangzhan
