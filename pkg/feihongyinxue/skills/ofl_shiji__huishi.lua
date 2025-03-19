local ofl_shiji__huishi = fk.CreateSkill {
  name = "ofl_shiji__huishi"
}

Fk:loadTranslationTable{
  ['ofl_shiji__huishi'] = '慧识',
  ['#ofl_shiji__huishi'] = '慧识：你可以重复判定，将不同花色的判定牌交给一名角色',
  ['#ofl_shiji__huishi-invoke'] = '慧识：是否继续判定？',
  ['#ofl_shiji__huishi-give'] = '慧识：你可以令一名角色获得这些判定牌',
  [':ofl_shiji__huishi'] = '出牌阶段限一次，你可以进行判定，若结果的花色与本阶段以此法进行判定的结果均不同，你可以重复此流程。然后你可以将所有生效的判定牌交给一名角色。',
}

ofl_shiji__huishi:addEffect('active', {
  anim_type = "drawcard",
  card_num = 0,
  target_num = 0,
  prompt = "#ofl_shiji__huishi",
  can_use = function(self, player)
    return player:usedSkillTimes(ofl_shiji__huishi.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local cards = {}
    while true do
      if player.dead then return end
      local pattern = table.concat(table.map(cards, function(card) return card:getSuitString() end), ",")
      local judge = {
        who = player,
        reason = ofl_shiji__huishi.name,
        pattern = ".|.|" .. (pattern == "" and "." or "^(" .. pattern .. ")"),
        skipDrop = true,
      }
      room:judge(judge)
      table.insert(cards, judge.card)
      if not table.every(cards, function(card) return card == judge.card or judge.card:compareSuitWith(card, true) end) or
        not room:askToSkillInvoke(player, {
          skill_name = ofl_shiji__huishi.name,
          prompt = "#ofl_shiji__huishi-invoke"
        })
      then
        break
      end
    end
    local targets = table.map(room.alive_players, function(p) return p.id end)
    cards = table.filter(cards, function(card) return room:getCardArea(card.id) == Card.Processing end)
    if #cards == 0 then return end
    local to = room:askToChoosePlayers(player, {
      targets = room:getOtherPlayers(player),
      min_num = 1,
      max_num = 1,
      prompt = "#ofl_shiji__huishi-give",
      skill_name = ofl_shiji__huishi.name,
      cancelable = true
    })
    if #to > 0 then
      room:obtainCard(to[1], cards, true, fk.ReasonGive)
    else
      room:moveCards({
        ids = table.map(cards, function(card) return card:getEffectiveId() end),
        toArea = Card.DiscardPile,
        moveReason = fk.ReasonPutIntoDiscardPile,
        skillName = ofl_shiji__huishi.name,
      })
    end
  end,
})

return ofl_shiji__huishi
