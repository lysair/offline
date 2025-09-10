local skill = fk.CreateSkill {
  name = "#xuanhua_axe_skill",
  tags = { Skill.Compulsory },
  attached_equip = "xuanhua_axe",
}

Fk:loadTranslationTable{
  ["#xuanhua_axe_skill"] = "宣花斧",
  ["#xuanhua_axe_skill-choose"] = "宣花斧：选择与 %dest 距离1的一名角色为额外目标",
}

skill:addEffect(fk.AfterCardTargetDeclared, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skill.name) and data.card.trueName == "slash" and
      table.find(data:getExtraTargets(), function(p)
        return p:distanceTo(data.tos[1]) == 1
      end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(data:getExtraTargets(), function(p)
      return p:distanceTo(data.tos[1]) == 1
    end)
    local to = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#xuanhua_axe_skill-choose::"..data.tos[1].id,
      skill_name = skill.name,
      cancelable = false,
    })[1]
    data:addTarget(to)
  end,
})

return skill
