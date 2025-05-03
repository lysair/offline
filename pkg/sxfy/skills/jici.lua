local jici = fk.CreateSkill {
  name = "sxfy__jici",
}

Fk:loadTranslationTable{
  ["sxfy__jici"] = "激词",
  [":sxfy__jici"] = "当你亮出拼点牌时，你可以失去1点体力，令你的拼点牌的点数视为K。",

  ["#sxfy__jici_win-invoke"] = "激词：你和 %dest 拼点赢了，是否要失去1点体力让点数视为K？",
  ["#sxfy__jici_draw-invoke"] = "激词：你和 %dest 拼点平了，是否要失去1点体力让点数视为K？",
  ["#sxfy__jici_lose-invoke"] = "激词：你和 %dest 拼点输了，是否要失去1点体力让点数视为K？",
}

jici:addEffect(fk.PindianCardsDisplayed, {
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(jici.name) and (player == data.from or data.results[player])
  end,
  on_cost = function (self, event, target, player, data)
    local prompt, to = "win", nil
    if player == data.from then
      for p, _ in pairs(data.results) do
        to = p
        if data.fromCard.number < data.results[p].toCard.number then
          prompt = "lose"
        elseif data.fromCard.number == data.results[p].toCard.number then
          prompt = "draw"
        end
      end
    elseif data.results[player] then
      to = data.from
      if data.results[player].toCard.number < data.fromCard.number then
        prompt = "lose"
      elseif data.results[player].toCard.number == data.fromCard.number then
        prompt = "draw"
      end
    end
    if to then
      return player.room:askToSkillInvoke(player, {
        skill_name = jici.name,
        prompt = "#sxfy__jici_"..prompt.."-invoke::"..to.id,
      })
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changePindianNumber(data, player, 13, jici.name)
    room:loseHp(player, 1, jici.name)
  end,
})

return jici
