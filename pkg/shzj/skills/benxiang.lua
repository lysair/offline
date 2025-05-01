local benxiang = fk.CreateSkill {
  name = "benxiang",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["benxiang"] = "奔降",
  [":benxiang"] = "锁定技，当你杀死一名角色后，你令一名其他角色摸三张牌。",

  ["#benxiang-choose"] = "奔降：令一名其他角色摸三张牌",
}

benxiang:addEffect(fk.Deathed, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(benxiang.name) and data.killer == player and
      #player.room:getOtherPlayers(player, false) > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room:getOtherPlayers(player, false),
      skill_name = benxiang.name,
      prompt = "#benxiang-choose",
      cancelable = false,
    })[1]
    to:drawCards(3, benxiang.name)
  end,
})

return benxiang
