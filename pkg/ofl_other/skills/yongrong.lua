local yongrong = fk.CreateSkill {
  name = "yongrong"
}

Fk:loadTranslationTable{
  ['yongrong'] = '雍容',
  ['#yongrong1-invoke'] = '雍容：是否交给 %dest 一张牌，令你对其造成的伤害+1？',
  ['#yongrong2-invoke'] = '雍容：是否交给 %dest 一张牌，令其对你造成的伤害-1？',
  [':yongrong'] = '每回合限一次，当你造成/受到伤害时，若受伤角色/伤害来源的手牌数小于你，你可以交给其一张牌，令此伤害+1/-1。',
}

yongrong:addEffect(fk.DamageCaused, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(yongrong) and player:usedSkillTimes(yongrong.name, Player.HistoryTurn) == 0 then
      return data.to:getHandcardNum() < player:getHandcardNum()
    end
  end,
  on_cost = function(self, event, target, player, data)
    local prompt = "#yongrong1-invoke::" .. data.to.id
    local tos = {data.to.id}

    local card = player.room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      skill_name = yongrong.name,
      cancelable = true,
      prompt = prompt
    })
    if #card > 0 then
      event:setCostData(skill, {tos = tos, cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room

    player:broadcastSkillInvoke(yongrong.name, 1)
    room:notifySkillInvoked(player, yongrong.name, "offensive")
    data.damage = data.damage + 1
    room:moveCardTo(event:getCostData(skill).cards, Card.PlayerHand, data.to, fk.ReasonGive, yongrong.name, nil, false, player.id)
  end,
})

yongrong:addEffect(fk.DamageInflicted, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(yongrong) and player:usedSkillTimes(yongrong.name, Player.HistoryTurn) == 0 then
      return data.from:getHandcardNum() < player:getHandcardNum()
    end
  end,
  on_cost = function(self, event, target, player, data)
    local prompt = "#yongrong2-invoke::" .. data.from.id
    local tos = {data.from.id}

    local card = player.room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      skill_name = yongrong.name,
      cancelable = true,
      prompt = prompt
    })
    if #card > 0 then
      event:setCostData(skill, {tos = tos, cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room

    player:broadcastSkillInvoke(yongrong.name, 2)
    room:notifySkillInvoked(player, yongrong.name, "defensive")
    data.damage = data.damage - 1
    room:moveCardTo(event:getCostData(skill).cards, Card.PlayerHand, data.from, fk.ReasonGive, yongrong.name, nil, false, player.id)
  end,
})

return yongrong
