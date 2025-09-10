local diaodu = fk.CreateSkill {
  name = "sxfy__diaodu",
}

Fk:loadTranslationTable{
  ["sxfy__diaodu"] = "调度",
  [":sxfy__diaodu"] = "准备阶段，你可以移动一名角色装备区内的一张牌，然后其摸一张牌。",

  ["#sxfy__diaodu-move"] = "调度：你可以移动场上一张装备牌，失去装备的角色摸一张牌",
}

diaodu:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(diaodu.name) and player.phase == Player.Start and
      #player.room:canMoveCardInBoard("e") > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = room:askToChooseToMoveCardInBoard(player, {
      skill_name = diaodu.name,
      flag = "e",
      prompt = "#sxfy__diaodu-move",
      cancelable = true,
    })
    if #targets > 0 then
      event:setCostData(self, {tos = targets})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = event:getCostData(self).tos
    local result = room:askToMoveCardInBoard(player, {
      skill_name = diaodu.name,
      flag = "e",
      target_one = targets[1],
      target_two = targets[2],
    })
    if result == nil or result.from.dead then return end
    result.from:drawCards(1, diaodu.name)
  end,
})

return diaodu
