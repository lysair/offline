local liangfan = fk.CreateSkill {
  name = "ofl__liangfan"
}

Fk:loadTranslationTable{
  ['ofl__liangfan'] = '量反',
  ['ofl__mengda_letter'] = '函',
  ['@@ofl__mengda_letter-turn'] = '函',
  ['#ofl__liangfan-invoke'] = '量反：是否获得 %dest 一张牌？',
  [':ofl__liangfan'] = '回合开始时，若你有“函”，你获得之，然后失去1点体力；当你本回合内使用此牌造成伤害后，你可以获得受伤角色的一张牌。',
  ['$ofl__liangfan1'] = '今举兵投魏，必可封王拜相，一展宏图。',
  ['$ofl__liangfan2'] = '今举义军事若成，吾为复汉元勋也。',
}

liangfan:addEffect(fk.TurnStart, {
  mute = true,
  can_trigger = function(self, event, target, player)
    return target == player and player:hasSkill(skill.name) and #player:getPile("ofl__mengda_letter") > 0
  end,
  on_cost = function(self, event, target, player)
    return true
  end,
  on_use = function (skill, event, target, player)
    local room = player.room
    player:broadcastSkillInvoke("ld__liangfan")
    room:notifySkillInvoked(player, skill.name, "drawcard")
    for _, id in ipairs(player:getPile("ofl__mengda_letter")) do
      room:setCardMark(Fk:getCardById(id), "@@ofl__mengda_letter-turn", 1)
    end
    room:obtainCard(player, player:getPile("ofl__mengda_letter"), true)
    if not player.dead then
      room:loseHp(player, 1, skill.name)
    end
  end,
})

liangfan:addEffect(fk.Damage, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:usedSkillTimes(skill.name, Player.HistoryTurn) > 0 and
      data.card and data.card:getMark("@@ofl__mengda_letter-turn") > 0 and
      not data.to:isNude() and not player.dead and not data.to.dead
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = skill.name,
      prompt = "#ofl__liangfan-invoke::"..data.to.id
    })
  end,
  on_use = function (skill, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, skill.name, "control")
    room:doIndicate(player.id, {data.to.id})
    local card = room:askToChooseCard(player, {
      target = data.to,
      flag = "he",
      skill_name = skill.name
    })
    room:obtainCard(player, card, false, fk.ReasonPrey)
  end,
})

return liangfan
