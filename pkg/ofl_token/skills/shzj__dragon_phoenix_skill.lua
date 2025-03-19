local shzj__dragon_phoenix_skill = fk.CreateSkill {
  name = "#shzj__dragon_phoenix_skill"
}

Fk:loadTranslationTable{
  ['#shzj__dragon_phoenix_skill'] = '飞龙夺凤',
  ['shzj__dragon_phoenix'] = '飞龙夺凤',
  ['shzj__dragon_phoenix_skill_discard'] = '令%dest弃置一张牌',
}

shzj__dragon_phoenix_skill:addEffect(fk.TargetSpecified, {
  attached_equip = "shzj__dragon_phoenix",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skill.name) and data.card.trueName == "slash" and
      player:usedSkillTimes(shzj__dragon_phoenix_skill.name, Player.HistoryTurn) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local all_choices = {"draw1", "shzj__dragon_phoenix_skill_discard::"..data.to, "Cancel"}
    local choices = table.simpleClone(all_choices)
    local to = player.room:getPlayerById(data.to)
    if to.dead or to:isNude() then
      table.remove(choices, 2)
    end
    local choice = player.room:askToChoice(player, {
      choices = choices,
      skill_name = skill.name,
      all_choices = all_choices,
      cancelable = false
    })
    if choice ~= "Cancel" then
      event:setCostData(skill, choice)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    -- room:setEmotion(player, "./packages/hegemony/image/anim/dragon_phoenix")
    if event:getCostData(skill) == "draw1" then
      player:drawCards(1, shzj__dragon_phoenix_skill.name)
    else
      local to = player.room:getPlayerById(data.to)
      room:askToDiscard(to, {
        min_num = 1,
        max_num = 1,
        include_equip = true,
        skill_name = skill.name,
        cancelable = false,
        prompt = "#dragon_phoenix-invoke"
      })
    end
  end,
})

return shzj__dragon_phoenix_skill
