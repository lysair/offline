local skill = fk.CreateSkill {
  name = "#shzj__dragon_phoenix_skill",
  attached_equip = "shzj__dragon_phoenix",
}

Fk:loadTranslationTable{
  ["#shzj__dragon_phoenix_skill"] = "飞龙夺凤",
  ["shzj__dragon_phoenix_skill_discard"] = "令%dest弃置一张牌",
}

skill:addEffect(fk.TargetSpecified, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skill.name) and data.card.trueName == "slash" and
      player:usedSkillTimes(skill.name, Player.HistoryTurn) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local all_choices = {"draw1", "shzj__dragon_phoenix_skill_discard::"..data.to, "Cancel"}
    local choices = table.simpleClone(all_choices)
    if data.to.dead or data.to:isNude() then
      table.remove(choices, 2)
    end
    local choice = player.room:askToChoice(player, {
      choices = choices,
      skill_name = skill.name,
      all_choices = all_choices,
    })
    if choice ~= "Cancel" then
      event:setCostData(self, {tos = {data.to}, choice = choice})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    -- room:setEmotion(player, "./packages/hegemony/image/anim/dragon_phoenix")
    if event:getCostData(self).choice == "draw1" then
      player:drawCards(1, skill.name)
    else
      room:askToDiscard(data.to, {
        min_num = 1,
        max_num = 1,
        include_equip = true,
        skill_name = skill.name,
        cancelable = false,
      })
    end
  end,
})

return skill
