local tunquan = fk.CreateSkill {
  name = "ofl__tunquan"
}

Fk:loadTranslationTable{
  ['ofl__tunquan'] = '屯犬',
  ['@ofl__tunquan'] = '屯犬',
  ['#ofl__tunquan_delay'] = '屯犬',
  [':ofl__tunquan'] = '锁定技，准备阶段，你令你本局游戏摸牌阶段的摸牌数，手牌上限和每回合首次受到的伤害+1，直到你发动〖迁军〗。',
}

-- Effect for phase start
tunquan:addEffect(fk.EventPhaseStart, {
  anim_type = "special",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player)
    return target == player and player:hasSkill(tunquan.name) and player.phase == Player.Start
  end,
  on_use = function(self, event, target, player)
    player.room:addPlayerMark(player, "@ofl__tunquan", 1)
  end
})

-- Effect for draw NCards and damage inflicted
tunquan:addEffect({fk.DrawNCards, fk.DamageInflicted}, {
  mute = true,
  frequency = Skill.Compulsory,
  can_trigger = function (self, event, target, player, data)
    if target == player and player:getMark("@ofl__tunquan") > 0 then
      if event == fk.DrawNCards then
        return true
      elseif event == fk.DamageInflicted then
        return #player.room.logic:getEventsOfScope(GameEvent.Damage, 2, function (e)
          return e.data[1].to == player
        end, Player.HistoryTurn) == 1
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(tunquan.name)
    if event == fk.DrawNCards then
      room:notifySkillInvoked(player, tunquan.name, "drawcard")
      data.n = data.n + player:getMark("@ofl__tunquan")
    elseif event == fk.DamageInflicted then
      room:notifySkillInvoked(player, tunquan.name, "negative")
      data.damage = data.damage + player:getMark("@ofl__tunquan")
    end
  end,
})

-- Effect for max cards skill
tunquan:addEffect('maxcards', {
  correct_func = function(self, player)
    return player:getMark("@ofl__tunquan")
  end,
})

return tunquan
