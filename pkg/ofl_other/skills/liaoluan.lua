local liaoluan = fk.CreateSkill {
  name = "liaoluan"
}

Fk:loadTranslationTable{
  ['liaoluan'] = '缭乱',
  ['#liaoluan'] = '缭乱：你可以翻面，对攻击范围内一名非起义军角色造成1点伤害（每局游戏限一次！）',
  ['liaoluan&'] = '缭乱',
  [':liaoluan'] = '每名起义军限一次，出牌阶段，其可以翻面，对攻击范围内一名非起义军角色造成1点伤害。',
}

liaoluan:addEffect('active', {
  anim_type = "offensive",
  card_num = 0,
  target_num = 1,
  prompt = "#liaoluan",
  can_use = function (self, player, card, extra_data)
    return IsInsurrectionary(player) and
      player:usedSkillTimes(liaoluan.name, Player.HistoryGame) + player:usedSkillTimes("liaoluan&", Player.HistoryGame) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    local target = Fk:currentRoom():getPlayerById(to_select)
    return not IsInsurrectionary(target) and player:inMyAttackRange(target)
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    player:turnOver()
    if not target.dead then
      room:damage{
        from = player,
        to = target,
        damage = 1,
        skillName = liaoluan.name,
      }
    end
  end,
})

liaoluan:addEffect("fk.JoinInsurrectionary", {
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(liaoluan.name, true) and not (target:hasSkill(liaoluan.name, true) or target:hasSkill("liaoluan&", true))
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if IsInsurrectionary(target) then
      room:handleAddLoseSkills(target, "liaoluan&", nil, false, true)
    end
  end,
})

liaoluan:addEffect("fk.QuitInsurrectionary", {
  can_refresh = function(self, event, target, player, data)
    return target:hasSkill("liaoluan&", true)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if not IsInsurrectionary(target) then
      room:handleAddLoseSkills(target, "-liaoluan&", nil, false, true)
    end
  end,
})

liaoluan:addEffect(fk.EventAcquireSkill, {
  can_refresh = function(self, event, target, player, data)
    return target == player and data == liaoluan and
      not table.find(player.room:getOtherPlayers(player, false), function(p)
        return p:hasSkill(liaoluan.name, true)
      end)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room:getOtherPlayers(player, false)) do
      if IsInsurrectionary(p) then
        room:handleAddLoseSkills(p, "liaoluan&", nil, false, true)
      end
    end
  end,
})

liaoluan:addEffect(fk.EventLoseSkill, {
  can_refresh = function(self, event, target, player, data)
    return target == player and data == liaoluan and
      not table.find(player.room:getOtherPlayers(player, false), function(p)
        return p:hasSkill(liaoluan.name, true)
      end)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room:getOtherPlayers(player, true, true)) do
      room:handleAddLoseSkills(p, "-liaoluan&", nil, false, true)
    end
  end,
})

liaoluan:addEffect(fk.Deathed, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(liaoluan.name, true, true) and
      not table.find(player.room:getOtherPlayers(player, false), function(p)
        return p:hasSkill(liaoluan.name, true)
      end)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room:getOtherPlayers(player, true, true)) do
      room:handleAddLoseSkills(p, "-liaoluan&", nil, false, true)
    end
  end,
})

return liaoluan
