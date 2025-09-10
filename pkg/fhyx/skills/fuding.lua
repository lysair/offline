local fuding = fk.CreateSkill {
  name = "ofl_shiji__fuding",
}

Fk:loadTranslationTable{
  ["ofl_shiji__fuding"] = "抚定",
  [":ofl_shiji__fuding"] = "每轮限一次，当一名其他角色进入濒死状态时，你可以交给其至多五张牌，若如此做，当其脱离濒死状态时，"..
  "你摸等量的牌并回复1点体力。",

  ["#ofl_shiji__fuding-invoke"] = "抚定：你可以交给 %dest 至多五张牌，其脱离濒死状态后你摸等量牌并回复1点体力",

  ["$ofl_shiji__fuding1"] = "正使祸至，共死何苦？",
  ["$ofl_shiji__fuding2"] = "诸君不可自乱阵脚，且暂待消息。",
}

fuding:addEffect(fk.EnterDying, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(fuding.name) and target ~= player and
      not player:isNude() and player:usedSkillTimes(fuding.name, Player.HistoryRound) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cards = room:askToCards(player, {
      min_num = 1,
      max_num = 5,
      skill_name = fuding.name,
      cancelable = true,
      prompt = "#ofl_shiji__fuding-invoke::" .. target.id,
    })
    if #cards > 0 then
      event:setCostData(self, {tos = {target}, cards = cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = event:getCostData(self).cards
    room:moveCardTo(cards, Card.PlayerHand, target, fk.ReasonGive, fuding.name, nil, false, player)
    data.extra_data = data.extra_data or {}
    data.extra_data.ofl_shiji__fuding = data.extra_data.ofl_shiji__fuding or {}
    table.insert(data.extra_data.ofl_shiji__fuding, {player.id, #cards})
  end,
})

fuding:addEffect(fk.AfterDying, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return not target.dead and not player.dead and data.extra_data and
      data.extra_data.ofl_shiji__fuding and
      table.find(data.extra_data.ofl_shiji__fuding, function(info)
        return info[1] == player.id
      end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local info = table.find(data.extra_data.ofl_shiji__fuding, function(info)
      return info[1] == player.id
    end)
    if info == nil then return end
    player:drawCards(info[2], fuding.name)
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
