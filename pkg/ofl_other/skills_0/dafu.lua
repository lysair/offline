local dafu = fk.CreateSkill {
  name = "ofl__dafu"
}

Fk:loadTranslationTable{
  ['ofl__dafu'] = '打富',
  ['#ofl__dafu-invoke'] = '打富：是否令 %dest 摸一张牌，其不能响应此%arg？',
  [':ofl__dafu'] = '当你使用伤害牌指定目标后，你可以令目标角色摸一张牌，然后其不能响应此牌。',
}

dafu:addEffect(fk.TargetSpecified, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skill.name) and data.card.is_damage_card
  end,
  on_cost = function (self, event, target, player, data)
    if player.room:askToSkillInvoke(player, { skill_name = skill.name, prompt = "#ofl__dafu-invoke::"..data.to..":"..data.card:toLogString() }) then
      event:setCostData(skill, {tos = {data.to}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    data.disresponsiveList = data.disresponsiveList or {}
    table.insertIfNeed(data.disresponsiveList, data.to)
    player.room:getPlayerById(data.to):drawCards(1, skill.name)
  end,
})

return dafu
