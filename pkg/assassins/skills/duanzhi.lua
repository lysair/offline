local duanzhi = fk.CreateSkill {
  name = "duanzhi"
}

Fk:loadTranslationTable{
  ['duanzhi'] = '断指',
  ['#duanzhi-invoke'] = '断指：你可以弃置 %src 至多两张牌，然后失去1点体力',
  [':duanzhi'] = '当你成为其他角色使用的牌的目标后，你可以弃置其至多两张牌，然后你失去1点体力。',
}

duanzhi:addEffect(fk.TargetConfirmed, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skill.name) and data.from ~= player.id and
      not player.room:getPlayerById(data.from).dead
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = skill.name,
      prompt = "#duanzhi-invoke:" .. data.from
    }) then
      room:doIndicate(player.id, {data.from})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local from = room:getPlayerById(data.from)
    if not from:isNude() then
      local cards = room:askToChooseCards(player, {
        target = from,
        min = 0,
        max = 2,
        flag = "he",
        skill_name = skill.name
      })
      if #cards > 0 then
        room:throwCard(cards, skill.name, from, player)
      end
    end
    if not player.dead then
      room:loseHp(player, 1, skill.name)
    end
  end,
})

return duanzhi
