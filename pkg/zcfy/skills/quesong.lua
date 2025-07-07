local quesong = fk.CreateSkill {
  name = "sxfy__quesong",
}

Fk:loadTranslationTable{
  ["sxfy__quesong"] = "雀颂",
  [":sxfy__quesong"] = "一名角色的结束阶段，若你本回合受到过伤害，你可以令一名角色回复1点体力。",

  ["#sxfy__quesong-choose"] = "雀颂：你可以令一名角色回复1点体力",
}

quesong:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(quesong.name) and target.phase == Player.Finish and
      #player.room.logic:getActualDamageEvents(1, function(e)
        return e.data.to == player
      end) > 0 and
      table.find(player.room.alive_players, function(p)
        return p:isWounded()
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function(p)
      return p:isWounded()
    end)
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = quesong.name,
      prompt = "#sxfy__quesong-choose",
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:recover{
      who = event:getCostData(self).tos[1],
      num = 1,
      recoverBy = player,
      skillName = quesong.name,
    }
  end,
})

return quesong
