local dingyi = fk.CreateSkill {
  name = "ofl_shiji__dingyi",
}

Fk:loadTranslationTable{
  ["ofl_shiji__dingyi"] = "定仪",
  [":ofl_shiji__dingyi"] = "每轮开始时，你可以摸一张牌，然后将一张与“定仪”牌花色均不同的牌置于一名没有“定仪”牌的角色武将牌旁。"..
  "有“定仪”牌的角色根据花色获得对应效果：<br>"..
  "♠，手牌上限+4；<br>"..
  "<font color='red'>♥</font>，每回合首次脱离濒死状态时，回复2点体力；<br>"..
  "♣，使用牌无距离限制；<br>"..
  "<font color='red'>♦</font>，摸牌阶段多摸两张牌。",

  ["#ofl_shiji__dingyi-put"] = "定仪：将一张牌置为一名角色的“定仪”牌，根据花色其获得效果<br>♠ 手牌上限+4；<font color='red'>♥</font> "..
  "脱离濒死时回复体力<br>♣ 使用牌无距离限制；<font color='red'>♦</font> 摸牌阶段多摸两张牌",

  ["$ofl_shiji__dingyi1"] = "制礼以节官吏众庶，国祚方可安稳绵长。",
  ["$ofl_shiji__dingyi2"] = "礼行则国治，礼弛则国乱矣。", 
}

dingyi:addEffect(fk.RoundStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(dingyi.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(1, dingyi.name)
    if player.dead or player:isNude() then return end
    local targets, suits = {}, {"nosuit"}
    for _, p in ipairs(room.alive_players) do
      if #p:getPile(dingyi.name) > 0 then
        table.insert(suits, Fk:getCardById(p:getPile(dingyi.name)[1]):getSuitString())
      else
        table.insert(targets, p)
      end
    end
    if #targets == 0 or #suits == 5 then return false end
    local to, card = room:askToChooseCardsAndPlayers(player, {
      min_card_num = 1,
      max_card_num = 1,
      min_num = 1,
      max_num = 1,
      targets = targets,
      pattern = ".|.|^("..table.concat(suits,",")..")",
      skill_name = dingyi.name,
      prompt = "#ofl_shiji__dingyi-put",
      cancelable = true,
    })
    if #to > 0 and #card > 0 then
      to[1]:addToPile(dingyi.name, card, true, dingyi.name, player)
    end
  end,
})

dingyi:addEffect(fk.DrawNCards, {
  can_refresh = function(self, event, target, player, data)
    return target == player and #player:getPile(dingyi.name) > 0 and
      Fk:getCardById(player:getPile(dingyi.name)[1]).suit == Card.Diamond
  end,
  on_refresh = function(self, event, target, player, data)
    data.n = data.n + 2
  end,
})

dingyi:addEffect(fk.AfterDying, {
  anim_type = "support",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if target == player and #player:getPile(dingyi.name) > 0 then
      local dat = player.room.logic:getEventsOfScope(GameEvent.Dying, 1, function(e)
        return e.data.who == player
      end, Player.HistoryTurn)
      if Fk:getCardById(player:getPile(dingyi.name)[1]).suit == Card.Heart and player:isWounded() then
        return #dat > 0 and dat[1].data == data
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:recover({
      who = player,
      num = 2,
      recoverBy = player,
      skillName = dingyi.name,
    })
  end,
})

dingyi:addEffect("maxcards", {
  correct_func = function(self, player)
    if #player:getPile(dingyi.name) > 0 and Fk:getCardById(player:getPile(dingyi.name)[1]).suit == Card.Spade then
      return 4
    end
  end,
})

dingyi:addEffect("targetmod", {
  bypass_distances = function(self, player, skill, card)
    return card and #player:getPile(dingyi.name) > 0 and Fk:getCardById(player:getPile(dingyi.name)[1]).suit == Card.Club
  end,
})

return dingyi
