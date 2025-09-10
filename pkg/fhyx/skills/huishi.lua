local huishi = fk.CreateSkill {
  name = "ofl_shiji__huishi",
}

Fk:loadTranslationTable{
  ["ofl_shiji__huishi"] = "慧识",
  [":ofl_shiji__huishi"] = "出牌阶段限一次，你可以进行判定，若结果的花色与本阶段以此法进行判定的结果均不同，你可以重复此流程。"..
  "然后你可以将所有生效的判定牌交给一名角色。",

  ["#ofl_shiji__huishi"] = "慧识：连续判定直到出现相同花色，然后将判定牌交给一名角色",
  ["#ofl_shiji__huishi-ask"] = "慧识：是否继续判定？",
  ["#ofl_shiji__huishi-choose"] = "慧识：你可以令一名角色获得这些判定牌",

  ["$ofl_shiji__huishi1"] = "察才识贤，以翊公之事。",
  ["$ofl_shiji__huishi2"] = "观滴水而知沧海，窥一举而察人心。",
}

huishi:addEffect("active", {
  anim_type = "drawcard",
  prompt = "#ofl_shiji__huishi",
  can_use = function(self, player)
    return player:usedSkillTimes(huishi.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from

    local cards = {}
    while not player.dead do
      local parsePattern = table.concat(table.map(cards, function(card)
        return card:getSuitString()
      end), ",")

      local judge = {
        who = player,
        reason = huishi.name,
        pattern = ".|.|" .. (parsePattern == "" and "." or "^(" .. parsePattern .. ")"),
        skipDrop = true,
      }
      room:judge(judge)
      table.insert(cards, judge.card)
      if not table.every(cards, function(card)
          return card == judge.card or judge.card:compareSuitWith(card, true)
        end) or
        player.dead or
        not room:askToSkillInvoke(player, {
          skill_name = huishi.name,
          prompt = "#ofl_shiji__huishi-ask",
        })
      then
        break
      end
    end

    cards = table.filter(cards, function(card)
      return room:getCardArea(card) == Card.Processing
    end)
    if #cards == 0 then
      return
    elseif player.dead then
      room:moveCardTo(cards, Card.DiscardPile, nil, fk.ReasonJudge)
      return
    end

    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room.alive_players,
      skill_name = huishi.name,
      prompt = "#ofl_shiji__huishi-choose",
      cancelable = true,
    })
    if #to > 0 then
      to = to[1]
      room:moveCardTo(cards, Card.PlayerHand, to, fk.ReasonGive, huishi.name, nil, true, player)
    else
      room:moveCardTo(cards, Card.DiscardPile, nil, fk.ReasonJudge)
    end
  end,
})

return huishi
