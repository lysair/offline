local yongrong = fk.CreateSkill {
  name = "yongrong",
}

Fk:loadTranslationTable{
  ["yongrong"] = "雍容",
  [":yongrong"] = "每回合限一次，当你造成/受到伤害时，若受伤角色/伤害来源的手牌数小于你，你可以交给其一张牌，令此伤害+1/-1。",

  ["#yongrong1-invoke"] = "雍容：是否交给 %dest 一张牌，令你对其造成的伤害+1？",
  ["#yongrong2-invoke"] = "雍容：是否交给 %dest 一张牌，令其对你造成的伤害-1？",
}

yongrong:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yongrong.name) and
      player:usedEffectTimes(self.name, Player.HistoryTurn) == 0 and
      data.to:getHandcardNum() < player:getHandcardNum()
  end,
  on_cost = function(self, event, target, player, data)
    local card = player.room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      skill_name = yongrong.name,
      cancelable = true,
      prompt = "#yongrong1-invoke::" .. data.to.id,
    })
    if #card > 0 then
      event:setCostData(self, {tos = {data.to}, cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    data:changeDamage(1)
    room:moveCardTo(event:getCostData(self).cards, Card.PlayerHand, data.to, fk.ReasonGive, yongrong.name, nil, false, player)
  end,
})

yongrong:addEffect(fk.DamageInflicted, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yongrong.name) and
      player:usedEffectTimes(self.name, Player.HistoryTurn) == 0 and
      data.from and data.from:getHandcardNum() < player:getHandcardNum() and not data.from.dead
  end,
  on_cost = function(self, event, target, player, data)
    local card = player.room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      skill_name = yongrong.name,
      cancelable = true,
      prompt = "#yongrong2-invoke::" .. data.from.id,
    })
    if #card > 0 then
      event:setCostData(self, {tos = {data.from}, cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    data:changeDamage(-1)
    room:moveCardTo(event:getCostData(self).cards, Card.PlayerHand, data.from, fk.ReasonGive, yongrong.name, nil, false, player)
  end,
})

return yongrong
