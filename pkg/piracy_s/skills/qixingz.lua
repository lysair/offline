local qixing = fk.CreateSkill {
  name = "ofl__qixingz",
}

Fk:loadTranslationTable{
  ["ofl__qixingz"] = "祈星",
  [":ofl__qixingz"] = "出牌阶段开始时，你可以将手牌摸至七张，若如此做，本回合结束时，你弃置所有手牌；本回合当你连续使用两张相同类别的牌时，"..
  "你失去1点体力。",

  ["#ofl__qixingz-invoke"] = "祈星：你可以将手牌摸至七张，本回合连续使用相同类别牌时失去体力，回合结束时弃置所有手牌",
}

qixing:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(qixing.name) and player.phase == Player.Play and
      player:getHandcardNum() < 7
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = qixing.name,
      prompt = "#ofl__qixingz-invoke",
    })
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    player:drawCards(7 - player:getHandcardNum(), qixing.name)
    if not player.dead and player:getMark("ofl__qixingz-turn") == 0 then
      room:setPlayerMark(player, "ofl__qixingz-turn", room.logic:getCurrentEvent().id)
    end
  end,
})

qixing:addEffect(fk.CardUsing, {
  anim_type = "negative",
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    if target == player and not player.dead and player:getMark("ofl__qixingz-turn") ~= 0 then
      local use_events = player.room.logic:getEventsByRule(GameEvent.UseCard, 1, function (e)
        if e.id < player.room.logic:getCurrentEvent().id then
          return e.data.from == player
        end
      end, player:getMark("ofl__qixingz-turn"))
      return #use_events == 1 and use_events[1].data.card.type == data.card.type
    end
  end,
  on_use = function (self, event, target, player, data)
    player.room:loseHp(player, 1, qixing.name)
  end,
})

qixing:addEffect(fk.TurnEnd, {
  anim_type = "negative",
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and not player.dead and player:getMark("ofl__qixingz-turn") ~= 0
  end,
  on_use = function (self, event, target, player, data)
    player:throwAllCards("h", qixing.name)
  end,
})

return qixing
