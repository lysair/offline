local ofl_shiji__dingyi = fk.CreateSkill {
  name = "ofl_shiji__dingyi"
}

Fk:loadTranslationTable{
  ['ofl_shiji__dingyi'] = '定仪',
  ['#ofl_shiji__dingyi-use'] = '定仪：将一张“定仪”牌置于一名角色武将牌旁，根据花色其获得效果<br>♠ 手牌上限+4；<font color=>♥</font> 脱离濒死时回复体力<br>♣ 使用牌无距离限制；<font color=>♦</font> 摸牌阶段多摸两张牌',
  ['#ofl_shiji__dingyi_delay'] = '定仪',
  [':ofl_shiji__dingyi'] = '每轮开始时，你可以摸一张牌，然后将一张与“定仪”牌花色均不同的牌置于一名没有“定仪”牌的角色武将牌旁。有“定仪”牌的角色根据花色获得对应效果：<br>♠，手牌上限+4；<br><font color=>♥</font>，每回合首次脱离濒死状态时，回复2点体力；<br>♣，使用牌无距离限制；<br><font color=>♦</font>，摸牌阶段多摸两张牌。',
  ['$ofl_shiji__dingyi1'] = '制礼以节官吏众庶，国祚方可安稳绵长。',
  ['$ofl_shiji__dingyi2'] = '礼行则国治，礼弛则国乱矣。',
}

-- 主技能
ofl_shiji__dingyi:addEffect(fk.RoundStart, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(ofl_shiji__dingyi.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(1, ofl_shiji__dingyi.name)
    if player.dead or player:isNude() then return end
    local targets, suits = {}, {"nosuit"}
    for _, p in ipairs(room.alive_players) do
      if #p:getPile(ofl_shiji__dingyi.name) > 0 then
        table.insert(suits, Fk:getCardById(p:getPile(ofl_shiji__dingyi.name)[1]):getSuitString())
      else
        table.insert(targets, p.id)
      end
    end
    if #targets == 0 or #suits == 5 then return false end
    local tos, cardId = room:askToChooseCardsAndPlayers(player, {
      min_card_num = 1,
      max_card_num = 1,
      targets = targets,
      pattern = ".|.|^("..table.concat(suits,",")..")",
      prompt = "#ofl_shiji__dingyi-use",
      skill_name = ofl_shiji__dingyi.name,
      cancelable = true
    })
    if #tos > 0 and cardId then
      local to = room:getPlayerById(tos[1])
      to:addToPile(ofl_shiji__dingyi.name, cardId, true, ofl_shiji__dingyi.name)
      room:broadcastProperty(to, "MaxCards")
    end
  end,
})

-- 延迟技能
ofl_shiji__dingyi:addEffect(fk.DrawNCards, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target == player and #player:getPile(ofl_shiji__dingyi.name) > 0 then
      return Fk:getCardById(player:getPile(ofl_shiji__dingyi.name)[1]).suit == Card.Diamond
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.n = data.n + 2
  end,
})

-- 延迟技能（濒死）
ofl_shiji__dingyi:addEffect(fk.AfterDying, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target == player and #player:getPile(ofl_shiji__dingyi.name) > 0 then
      local dat = player.room.logic:getEventsOfScope(GameEvent.Dying, 1, function(e)
        return e.data[1].who == player.id
      end, Player.HistoryTurn)
      if Fk:getCardById(player:getPile(ofl_shiji__dingyi.name)[1]).suit == Card.Heart and player:isWounded() then
        return #dat > 0 and dat[1].data[1] == data
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:recover({
      who = player,
      num = math.min(player:getLostHp(), 2),
      recoverBy = player,
      skillName = ofl_shiji__dingyi.name,
    })
  end,
})

-- 手牌上限
ofl_shiji__dingyi:addEffect('maxcards', {
  correct_func = function(self, player)
    if #player:getPile(ofl_shiji__dingyi.name) > 0 and Fk:getCardById(player:getPile(ofl_shiji__dingyi.name)[1]).suit == Card.Spade then
      return 4
    end
  end,
})

-- 目标修正技能
ofl_shiji__dingyi:addEffect('targetmod', {
  bypass_distances = function(self, player)
    return #player:getPile(ofl_shiji__dingyi.name) > 0 and Fk:getCardById(player:getPile(ofl_shiji__dingyi.name)[1]).suit == Card.Club
  end,
})

return ofl_shiji__dingyi
