local qiaobian = fk.CreateSkill {
  name = "ofl__qiaobian"
}

Fk:loadTranslationTable{
  ["ofl__qiaobian"] = "巧变",
  [":ofl__qiaobian"] = "其他角色的准备阶段，你可以将一张牌扣置于你的武将牌上，称为“巧”。当其本回合使用牌后，你展示“巧”，"..
  "若“巧”与此牌类别：相同，其获得“巧”，然后结束出牌阶段；不同，你摸一张牌。本回合结束阶段，你将“巧”收回手牌。",

  ["#ofl__qiaobian-invoke"] = "巧变：你可以扣置一张牌，本回合 %dest 使用牌后，根据类别是否与扣置牌相同执行效果",
  ["$ofl__qiaobian"] = "巧",
}

qiaobian:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(qiaobian.name) and target.phase == Player.Start and
      not target.dead and not player:isNude()
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local cards = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = qiaobian.name,
      prompt = "#ofl__qiaobian-invoke::"..target.id,
      cancelable = true,
    })
    if #cards > 0 then
      event:setCostData(self, {cards = cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player:addToPile("$ofl__qiaobian", event:getCostData(self).cards, false, qiaobian.name, player)
  end,
})

qiaobian:addEffect(fk.CardUseFinished, {
  anim_type = "control",
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return #player:getPile("$ofl__qiaobian") > 0 and target == player.room.current and
      player:usedSkillTimes(qiaobian.name, Player.HistoryTurn) > 0
  end,
  on_cost = function (self, event, target, player, data)
    event:setCostData(self, {tos = {target}})
    return true
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local types = table.map(player:getPile("$ofl__qiaobian"), function (id)
      return Fk:getCardById(id).type
    end)
    room:showCards(player:getPile("$ofl__qiaobian"))
    if table.contains(types, data.card.type) then
      if not target.dead then
        room:moveCardTo(player:getPile("$ofl__qiaobian"), Card.PlayerHand, target, fk.ReasonJustMove, qiaobian.name, nil, true, target)
      end
      if target.phase == Player.Play then
        target:endPlayPhase()
      end
    elseif not player.dead then
      player:drawCards(1, qiaobian.name)
    end
  end,
})

qiaobian:addEffect(fk.EventPhaseStart, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return target.phase == Player.Finish and #player:getPile("$ofl__qiaobian") > 0
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:moveCardTo(player:getPile("$ofl__qiaobian"), Card.PlayerHand, player, fk.ReasonJustMove, qiaobian.name, nil, false, player)
  end,
})

return qiaobian
