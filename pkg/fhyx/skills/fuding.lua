local fuding = fk.CreateSkill {
  name = "ofl_shiji__funding"
}

Fk:loadTranslationTable{
  ['ofl_shiji__funding'] = '抚定',
  ['#ofl_shiji__funding-invoke'] = '抚定：你可以交给 %dest 至多五张牌，其脱离濒死状态后你摸等量牌并回复1点体力',
  [':ofl_shiji__funding'] = '每轮限一次，当一名其他角色进入濒死状态时，你可以交给其至多五张牌，若如此做，当其脱离濒死状态时，你摸等量的牌并回复1点体力。',
}

fuding:addEffect(fk.EnterDying, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(funding) and target ~= player and not player:isNude() and
      player:usedSkillTimes(funding.name, Player.HistoryRound) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local cards = player.room:askToCards(player, {
      min_num = 1,
      max_num = 5,
      skill_name = fuding.name,
      cancelable = true,
      prompt = "#ofl_shiji__funding-invoke::" .. target.id
    })
    if #cards > 0 then
      event:setCostData(self, cards)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:moveCardTo(event:getCostData(self), Card.PlayerHand, target, fk.ReasonGive, fuding.name)
    data.extra_data = data.extra_data or {}
    data.extra_data.ofl_shiji__funding = {player.id, #event:getCostData(self)}
  end,
})

fuding:addEffect(fk.AfterDying, {
  can_trigger = function(self, event, target, player, data)
    return not target.dead and data.extra_data and
      data.extra_data.ofl_shiji__funding and data.extra_data.ofl_shiji__funding[1] == player.id and
      not player.dead
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(data.extra_data.ofl_shiji__funding[2], fuding.name)
    if player:isWounded() and not player.dead then
      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = fuding.name,
      }
    end
  end,
})

return fuding
