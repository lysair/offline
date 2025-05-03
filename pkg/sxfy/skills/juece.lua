local juece = fk.CreateSkill {
  name = "sxfy__juece",
}

Fk:loadTranslationTable{
  ["sxfy__juece"] = "绝策",
  [":sxfy__juece"] = "结束阶段，你可以对一名本回合失去过至少两张牌的角色造成1点伤害。",

  ["#sxfy__juece-choose"] = "绝策：你可以对其中一名角色造成1点伤害！",
}

juece:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(juece.name) and player.phase == Player.Finish then
      local dat = {}
      player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
        for _, move in ipairs(e.data) do
          if move.from then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
                dat[move.from] = (dat[move.from] or 0) + 1
              end
            end
          end
        end
      end, Player.HistoryTurn)
      local targets = {}
      for p, n in pairs(dat) do
        if n > 1 then
          table.insert(targets, p)
        end
      end
      if #targets > 0 then
        event:setCostData(self, {targets = targets})
        return true
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = event:getCostData(self).targets,
      skill_name = juece.name,
      prompt = "#sxfy__juece-choose",
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:damage{
      from = player,
      to = event:getCostData(self).tos[1],
      damage = 1,
      skillName = juece.name,
    }
  end,
})

return juece
