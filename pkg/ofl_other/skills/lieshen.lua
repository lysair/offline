local lieshen = fk.CreateSkill {
  name = "lieshen"
}

Fk:loadTranslationTable{
  ['lieshen'] = '列神',
  ['#lieshen'] = '列神：令一名角色将体力值和手牌数调整至游戏开始时！',
  [':lieshen'] = '限定技，出牌阶段，你可以令一名角色将体力值和手牌数调整至游戏开始时。',
}

-- 主动技能部分
lieshen:addEffect('active', {
  anim_type = "support",
  frequency = Skill.Limited,
  card_num = 0,
  target_num = 1,
  prompt = "#lieshen",
  can_use = function(self, player)
    return player:usedSkillTimes(lieshen.name, Player.HistoryGame) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0
  end,
  on_use = function(self, room, effect)
    local target = room:getPlayerById(effect.tos[1])
    local n1, n2 = Fk.generals[target.general].hp, 4
    if target:getMark(lieshen.name) ~= 0 then
      local mark = target:getMark(lieshen.name)
      n1, n2 = mark[1], mark[2]
    end
    target.hp = math.min(n1, target.maxHp)
    room:broadcastProperty(target, "hp")
    local n = target:getHandcardNum() - n2
    if n > 0 then
      room:askToDiscard(target, {
        min_num = n2,
        max_num = n2,
        include_equip = false,
        skill_name = lieshen.name,
        cancelable = false,
      })
    elseif n < 0 then
      target:drawCards(-n, lieshen.name)
    end
  end,
})

-- 触发技能部分
lieshen:addEffect(fk.RoundStart, {
  can_refresh = function(self, event, player)
    return player.room:getBanner("RoundCount") == 1 and player.seat == 1
  end,
  on_refresh = function(self, event, player)
    local room = player.room
    for _, p in ipairs(room.alive_players) do
      room:setPlayerMark(p, lieshen.name, {p.hp, p:getHandcardNum()})
    end
  end,
})

return lieshen
