local xianshouz = fk.CreateSkill {
  name = "xianshouz",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["xianshouz"] = "献首",
  [":xianshouz"] = "锁定技，当你杀死一名角色后，你令一名其他角色回复2点体力。",

  ["#xianshou-invoke"] = "献首：令一名其他角色回复2点体力",
}

xianshouz:addEffect(fk.Deathed, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(xianshouz.name) and data.killer == player and
      table.find(player.room:getOtherPlayers(player, false), function(p)
        return p:isWounded()
      end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player, false), function(p)
      return p:isWounded()
    end)
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = xianshouz.name,
      prompt = "#xianshouz-choose",
      cancelable = false,
    })[1]
    room:recover({
      who = to,
      num = 2,
      recoverBy = player,
      skillName = xianshouz.name,
    })
  end,
})

return xianshouz
