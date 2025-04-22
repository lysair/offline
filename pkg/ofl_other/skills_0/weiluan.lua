local weiluan = fk.CreateSkill {
  name = "ofl__weiluan"
}

Fk:loadTranslationTable{
  ['ofl__weiluan'] = '为乱',
  ['@ofl__weiluan'] = '为乱',
  [':ofl__weiluan'] = '锁定技，准备阶段/摸牌阶段/出牌阶段开始时，你进行判定，若结果为♠，你的攻击范围/摸牌阶段摸牌数/使用【杀】次数上限+1。',
}

weiluan:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skill.name) and
      table.contains({Player.Start, Player.Draw, Player.Play}, player.phase)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local judge = {
      who = player,
      reason = skill.name,
      pattern = ".|.|spade",
    }
    room:judge(judge)
    if judge.card.suit == Card.Spade and not player.dead then
      local mark = player:getMark("@ofl__weiluan")
      if player.phase == Player.Start then
        mark[1] = mark[1] + 1
      elseif player.phase == Player.Draw then
        mark[2] = mark[2] + 1
      elseif player.phase == Player.Play then
        mark[3] = mark[3] + 1
      end
      room:setPlayerMark(player, "@ofl__weiluan", mark)
    end
  end,
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@ofl__weiluan") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    data.n = data.n + player:getMark("@ofl__weiluan")[2]
  end,
  on_acquire = function(self, player, is_start)
    player.room:setPlayerMark(player, "@ofl__weiluan", {0, 0, 0})
  end
})

weiluan:addEffect('atkrange', {
  correct_func = function (self, from, to)
    if from:getMark("@ofl__weiluan") ~= 0 then
      return from:getMark("@ofl__weiluan")[1]
    end
  end,
})

weiluan:addEffect('targetmod', {
  name = "#ofl__weiluan_targetmod",
  residue_func = function(self, player, skill, scope)
    if skill.trueName == "slash_skill" and player:getMark("@ofl__weiluan") ~= 0 and scope == Player.HistoryPhase then
      return player:getMark("@ofl__weiluan")[3]
    end
  end,
})

return weiluan
