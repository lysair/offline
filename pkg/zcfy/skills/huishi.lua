local huishi = fk.CreateSkill {
  name = "sxfy__huishi",
}

Fk:loadTranslationTable{
  ["sxfy__huishi"] = "慧识",
  [":sxfy__huishi"] = "出牌阶段限一次，你可以进行判定，若结果的颜色与本阶段以此法进行判定的结果均不同，你可以重复此流程。"..
  "然后你可以将所有生效的判定牌交给一名角色。",

  ["#sxfy__huishi"] = "慧识：连续判定直到出现相同颜色，然后将判定牌交给一名角色",
  ["#sxfy__huishi-ask"] = "慧识：是否继续判定？",
  ["#sxfy__huishi-choose"] = "慧识：你可以令一名角色获得这些判定牌",
}

huishi:addEffect("active", {
  anim_type = "drawcard",
  prompt = "#sxfy__huishi",
  can_use = function(self, player)
    return player:usedSkillTimes(huishi.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from

    local cards = {}
    local pattern = "."
    while not player.dead do
      local judge = {
        who = player,
        reason = huishi.name,
        pattern = pattern,
        skipDrop = true,
      }
      room:judge(judge)
      if judge.card then
        table.insert(cards, judge.card)
        if judge.card.color == Card.Black then
          pattern = ".|.|spade,club"
        elseif judge.card.color == Card.Red then
          pattern = ".|.|heart,diamond"
        end
      end
      if not table.every(cards, function(card)
          return card == judge.card or judge.card:compareColorWith(card, true)
        end) or
        player.dead or
        not room:askToSkillInvoke(player, {
          skill_name = huishi.name,
          prompt = "#sxfy__huishi-ask",
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
      room:cleanProcessingArea(cards)
      return
    end

    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room.alive_players,
      skill_name = huishi.name,
      prompt = "#sxfy__huishi-choose",
      cancelable = true,
    })
    if #to > 0 then
      to = to[1]
      room:moveCardTo(cards, Card.PlayerHand, to, fk.ReasonGive, huishi.name, nil, true, player)
    else
      room:cleanProcessingArea(cards)
    end
  end,
})

return huishi
