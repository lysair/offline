local duanzhi = fk.CreateSkill {
  name = "duanzhi",
}

Fk:loadTranslationTable{
  ["duanzhi"] = "断指",
  [":duanzhi"] = "当你成为其他角色使用的牌的目标后，你可以弃置其至多两张牌，然后你失去1点体力。",

  ["#duanzhi-invoke"] = "断指：你可以弃置 %src 至多两张牌，然后失去1点体力",
}

duanzhi:addEffect(fk.TargetConfirmed, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(duanzhi.name) and
      data.from ~= player and not data.from.dead
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = duanzhi.name,
      prompt = "#duanzhi-invoke:" .. data.from.id,
    }) then
      event:setCostData(self, {tos = {data.from}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if not data.from:isNude() then
      local cards = room:askToChooseCards(player, {
        target = data.from,
        min = 1,
        max = 2,
        flag = "he",
        skill_name = duanzhi.name
      })
      if #cards > 0 then
        room:throwCard(cards, duanzhi.name, data.from, player)
      end
    end
    if not player.dead then
      room:loseHp(player, 1, duanzhi.name)
    end
  end,
})

return duanzhi
