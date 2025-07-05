local porui = fk.CreateSkill {
  name = "sxfy__porui",
}

Fk:loadTranslationTable {
  ["sxfy__porui"] = "破锐",
  [":sxfy__porui"] = "一名角色的结束阶段，你可以弃置一张基本牌，然后若其体力值：不大于你，你弃置其装备区内的一张牌；不小于你，"..
  "你视为对其使用一张无距离限制的【杀】。",

  ["#sxfy__porui-invoke"] = "破锐：弃一张基本牌，根据 %dest 与你体力值的关系执行效果",
  ["#sxfy__porui-discard"] = "破锐：弃置 %dest 装备区一张牌",
}

porui:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(porui.name) and target.phase == Player.Finish and
      not target.dead and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local card = room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = porui.name,
      pattern = ".|.|.|.|.|basic",
      prompt = "#sxfy__porui-invoke::"..target.id,
      cancelable = true,
      skip = true,
    })
    if #card > 0 then
      event:setCostData(self, {tos = {target}, cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(event:getCostData(self).cards, porui.name, player, player)
    if player.dead or target.dead then return end
    if player.hp >= target.hp and #target:getCardIds("e") > 0 then
      local card = room:askToChooseCard(player, {
        target = target,
        flag = "e",
        skill_name = porui.name,
        prompt = "#sxfy__porui-discard::"..target.id,
      })
      room:throwCard(card, porui.name, target, player)
      if player.dead or target.dead then return end
    end
    if player.hp <= target.hp and target ~= player then
      room:useVirtualCard("slash", nil, player, target, porui.name, true)
    end
  end,
})

return porui
