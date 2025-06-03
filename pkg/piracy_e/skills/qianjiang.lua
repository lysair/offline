local qianjiang = fk.CreateSkill {
  name = "qianjiang",
  tags = { Skill.Lord },
}

Fk:loadTranslationTable{
  ["qianjiang"] = "遣将",
  [":qianjiang"] = "主公技，当一名角色阵亡后，你可以令一名魏势力角色与其交换座次。",

  ["#qianjiang-choose"] = "遣将：你可以令一名魏势力角色与 %dest 交换座次",
}

qianjiang:addEffect(fk.Death, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(qianjiang.name) and
      table.find(player.room.alive_players, function (p)
        return p.kingdom == "wei"
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function (p)
      return p.kingdom == "wei"
    end)
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = qianjiang.name,
      prompt = "#qianjiang-choose",
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:swapSeat(event:getCostData(self).tos[1], target)
  end,
})

return qianjiang
