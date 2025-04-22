local ofl__shouli = fk.CreateSkill {
  name = "ofl__shouli"
}

Fk:loadTranslationTable{
  ['ofl__shouli'] = '狩骊',
  ['#ofl__shouli-promot'] = '狩骊：移动一名其他角色的所有“骏”/“骊”，视为使用或打出【杀】/【闪】',
  ['@ofl__jun'] = '骏',
  ['@ofl__li'] = '骊',
  ['#ofl__shouli-horse'] = '狩骊：选择一名有 %arg 标记的其他角色',
  ['ofl__shouli_next'] = '下家:%src',
  ['ofl__shouli_last'] = '上家:%src',
  ['#ofl__shouli-move'] = '狩骊：将 %dest 所有 %arg 标记移动至其上家或下家',
  ['#ofl__shouli_trigger'] = '狩骊',
  ['@@ofl__shouli_tieji-turn'] = '狩骊封技',
  [':ofl__shouli'] = '①游戏开始时，所有其他角色随机获得1枚“狩骊”标记。<br>②每回合各限一次，你可以选择一项：1.移动一名其他角色的所有“骏”至其上家或下家，并视为使用或打出一张无距离和次数限制的【杀】；2.移动一名其他角色的所有“骊”至其上家或下家，并视为使用或打出一张【闪】。<br>③“狩骊”标记包括4枚“骊”和3枚“骏”，获得“骏”/“骊”时废除装备区的进攻/防御坐骑栏，失去所有“骏”/“骊”时恢复之。<br>④若你的“骏”数量大于0，你与其他角色的距离-1；大于1，摸牌阶段，你多摸一张牌；大于2，当你使用【杀】指定目标后，该角色本回合非锁定技失效。<br>⑤若你的“骊”数量大于0，其他角色与你的距离+1；大于1，摸牌阶段，你多摸一张牌；大于2，你造成或受到的伤害均视为雷电伤害；大于3，你造成或受到的伤害+1。<br>⑥当你受到属性伤害或【南蛮入侵】、【万箭齐发】造成的伤害后，你的所有“骏”移动至你上家，所有“骊”移动至你下家。',
  ['$ofl__shouli1'] = '饲骊胡肉，饮骥虏血，一骑可定万里江山！',
  ['$ofl__shouli2'] = '折兵为弭，纫甲为服，此箭可狩在野之龙！',
}

-- ViewAsSkill
ofl__shouli:addEffect('viewas', {
  pattern = "slash,jink",
  prompt = "#ofl__shouli-promot",
  interaction = function(self, player)
    local names = {}
    local pat = Fk.currentResponsePattern
    if ((pat == nil and not player:prohibitUse(Fk:cloneCard("slash"))) or (pat and Exppattern:Parse(pat):matchExp("slash")))
      and player:getMark("ofl__shouli_slash-turn") == 0
      and table.find(Fk:currentRoom().alive_players, function(p) return p ~= player and p:getMark("@ofl__jun") > 0 end)
    then
      table.insert(names, "slash")
    end
    if pat and Exppattern:Parse(pat):matchExp("jink")
      and player:getMark("ofl__shouli_jink-turn") == 0
      and table.find(Fk:currentRoom().alive_players, function(p) return p ~= player and p:getMark("@ofl__li") > 0 end)
    then
      table.insert(names, "jink")
    end
    if #names == 0 then return end
    return UI.ComboBox {choices = names}
  end,
  view_as = function(self, player)
    if skill.interaction.data == nil then return end
    local card = Fk:cloneCard(skill.interaction.data)
    card.skillName = ofl__shouli.name
    return card
  end,
  before_use = function(self, player, use)
    local room = player.room
    use.extraUse = true
    local mark = (use.card.trueName == "slash") and "@ofl__jun" or "@ofl__li"
    room:addPlayerMark(player, "ofl__shouli_"..use.card.trueName.."-turn")
    local targets = table.filter(room:getOtherPlayers(player, false), function(p)
      return p:getMark(mark) > 0
    end)
    if #targets > 0 then
      local tos = room:askToChoosePlayers(player, {
        targets = targets,
        min_num = 1,
        max_num = 1,
        prompt = "#ofl__shouli-horse:::" .. mark,
        skill_name = ofl__shouli.name,
        no_indicate = true
      })
      if #tos > 0 then
        local to = room:getPlayerById(tos[1])
        local next = to:getNextAlive()
        local last = to:getLastAlive()
        local choice = room:askToChoice(player, {
          choices = {"ofl__shouli_next:"..next.id, "ofl__shouli_last:"..last.id},
          skill_name = ofl__shouli.name,
          prompt = "#ofl__shouli-move::"..to.id..":"..mark
        })
        local receiver = choice:startsWith("ofl__shouli_next") and next or last
        local n = to:getMark(mark)
        loseAllHorse (room, to, mark)
        getHorse (room, receiver, mark, n)
      end
    end
  end,
  enabled_at_play = function(self, player)
    return player:hasSkill(ofl__shouli) and table.find(Fk:currentRoom().alive_players, function(p)
      return p ~= player and p:getMark("@ofl__jun") > 0
    end)
  end,
  enabled_at_response = function(self, player)
    local pat = Fk.currentResponsePattern
    if not pat then return end
    if Exppattern:Parse(pat):matchExp("slash") and player:getMark("ofl__shouli_slash-turn") == 0 then
      return table.find(Fk:currentRoom().alive_players, function(p)
        return p ~= player and p:getMark("@ofl__jun") > 0
      end)
    end
    if Exppattern:Parse(pat):matchExp("jink") and player:getMark("ofl__shouli_jink-turn") == 0 then
      return table.find(Fk:currentRoom().alive_players, function(p)
        return p ~= player and p:getMark("@ofl__li") > 0
      end)
    end
  end,
})

-- TriggerSkill
ofl__shouli:addEffect(fk.GameStart, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(ofl__shouli)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(ofl__shouli.name)
    room:notifySkillInvoked(player, ofl__shouli.name)
    local horse = {"@ofl__jun", "@ofl__jun", "@ofl__jun", "@ofl__li", "@ofl__li", "@ofl__li", "@ofl__li"}
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if not player.dead and not p.dead and #horse > 0 then
        local mark = table.remove(horse, math.random(1, #horse))
        getHorse (room, p, mark, 1)
      end
    end
  end,
})

ofl__shouli:addEffect(fk.DrawNCards, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(ofl__shouli) and target == player and (player:getMark("@ofl__jun") > 1 or player:getMark("@ofl__li") > 1)
  end,
  on_use = function(self, event, target, player, data)
    local n = 0
    if player:getMark("@ofl__jun") > 1 then n = n + 1 end
    if player:getMark("@ofl__li") > 1 then n = n + 1 end
    data.n = data.n + n
  end,
})

ofl__shouli:addEffect(fk.TargetSpecified, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(ofl__shouli) and data.card.trueName == "slash" and player:getMark("@ofl__jun") > 2
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(data.to)
    room:addPlayerMark(to, MarkEnum.UncompulsoryInvalidity .. "-turn")
    room:addPlayerMark(to, "@@ofl__shouli_tieji-turn")
  end,
})

ofl__shouli:addEffect(fk.Damaged, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(ofl__shouli) and target == player and (data.damageType ~= fk.NormalDamage
      or (data.card and (data.card.name == "savage_assault" or data.card.name == "archery_attack")))
      and (player:getMark("@ofl__jun") > 0 or player:getMark("@ofl__li") > 0) and player:getNextAlive() ~= player
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local jun = player:getMark("@ofl__jun")
    if jun > 0 then
      loseAllHorse (room, player, "@ofl__jun")
      getHorse (room, player:getLastAlive(), "@ofl__jun", jun)
    end
    local li = player:getMark("@ofl__li")
    if li > 0 then
      loseAllHorse (room, player, "@ofl__li")
      getHorse (room, player:getNextAlive(), "@ofl__li", li)
    end
  end,
})

ofl__shouli:addEffect(fk.DamageInflicted + fk.DamageCaused, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(ofl__shouli) and target == player and player:getMark("@ofl__li") > 2
  end,
  on_use = function(self, event, target, player, data)
    local n = player:getMark("@ofl__li")
    if n > 2 then
      data.damageType = fk.ThunderDamage
    end
    if n > 3 then
      data.damage = data.damage + 1
    end
  end,
})

-- DistanceSkill
ofl__shouli:addEffect('distance', {
  correct_func = function(self, from, to)
    if from:hasSkill(ofl__shouli) and from:getMark("@ofl__jun") > 0 then
      return -1
    end
    if to:hasSkill(ofl__shouli) and to:getMark("@ofl__li") > 0 then
      return 1
    end
  end,
})

-- TargetModSkill
ofl__shouli:addEffect('targetmod', {
  bypass_times = function(self, player, skill, scope, card)
    return card and table.contains(card.skillNames, "ofl__shouli")
  end,
  bypass_distances = function(self, player, skill, card)
    return card and table.contains(card.skillNames, "ofl__shouli")
  end,
})

return ofl__shouli
