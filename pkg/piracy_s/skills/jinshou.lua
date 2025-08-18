local jinshou = fk.CreateSkill {
  name = "ofl__jinshou",
}

Fk:loadTranslationTable{
  ["ofl__jinshou"] = "烬守",
  [":ofl__jinshou"] = "结束阶段，若你本回合体力值未变化过，你可以弃置所有手牌并失去1点体力，若如此做，直到你下回合开始，"..
  "其他角色使用的仅指定你为目标的伤害牌无效。",

  ["#ofl__jinshou-invoke"] = "烬守：你可以弃置所有手牌并失去1点体力，直到你下回合开始以你为唯一目标的伤害牌无效",
  ["@@ofl__jinshou"] = "烬守",
}

jinshou:addEffect(fk.EventPhaseStart, {
  anim_type = "defensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(jinshou.name) and player.phase == Player.Finish and
      #player.room.logic:getEventsOfScope(GameEvent.ChangeHp, 1, function (e)
        return e.data.who == player
      end, Player.HistoryTurn) == 0
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = jinshou.name,
      prompt = "#ofl__jinshou-invoke",
    })
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    player:throwAllCards("h", jinshou.name)
    if player.dead then return end
    room:loseHp(player, 1, jinshou.name)
    if player.dead then return end
    room:setPlayerMark(player, "@@ofl__jinshou", 1)
  end,
})

jinshou:addEffect(fk.PreCardEffect, {
  anim_type = "defensive",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if player:getMark("@@ofl__jinshou") > 0 and data.card.is_damage_card and data.to == player then
      local use_event = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard, true)
      return use_event and use_event.data:isOnlyTarget(player)
    end
  end,
  on_use = function (self, event, target, player, data)
    data.nullified = true
  end,
})

jinshou:addEffect(fk.TurnStart, {
  can_refresh = function (self, event, target, player, data)
    return target == player
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:setPlayerMark(player, "@@ofl__jinshou", 0)
  end,
})

return jinshou
