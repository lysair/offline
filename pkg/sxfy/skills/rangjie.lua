local rangjie = fk.CreateSkill {
  name = "sxfy__rangjie",
}

Fk:loadTranslationTable{
  ["sxfy__rangjie"] = "让节",
  [":sxfy__rangjie"] = "当你受到伤害后，你可以移动场上一张牌。",

  ["#sxfy__rangjie-move"] = "让节：你可以移动场上一张牌",
}

rangjie:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(rangjie.name) and #player.room:canMoveCardInBoard() > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = room:askToChooseToMoveCardInBoard(player, {
      skill_name = rangjie.name,
      prompt = "#sxfy__rangjie-move",
      cancelable = true
    })
    if #targets > 0 then
      event:setCostData(self, {tos = targets})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = event:getCostData(self).tos
    room:askToMoveCardInBoard(player, {
      skill_name = rangjie.name,
      target_one = targets[1],
      target_two = targets[2],
    })
  end,
})

return rangjie
