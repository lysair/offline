local daidi = fk.CreateSkill {
  name = "ofl__daidi",
}

Fk:loadTranslationTable{
  ["ofl__daidi"] = "待敌",
  [":ofl__daidi"] = "每回合限一次，当你成为其他角色使用牌的目标时，你可以进行一次判定，若颜色与此牌相同，你可以令一名角色获得此判定牌。",

  ["#ofl__daidi-choose"] = "待敌：你可以令一名角色获得此判定牌",
}

daidi:addEffect(fk.TargetConfirming, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(daidi.name) and
      data.from ~= player and player:usedSkillTimes(daidi.name, Player.HistoryTurn) == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local pattern = "."
    if data.card.color == Card.Red then
      pattern = ".|.|red"
    elseif data.card.color == Card.Black then
      pattern = ".|.|black"
    end
    local judge = {
      who = player,
      reason = daidi.name,
      pattern = pattern,
    }
    room:judge(judge)
    if not player.dead and judge:matchPattern() and
      room:getCardArea(judge.card) == Card.DiscardPile then
      local to = room:askToChoosePlayers(player, {
        min_num = 1,
        max_num = 1,
        targets = room.alive_players,
        skill_name = daidi.name,
        prompt = "#ofl__daidi-choose",
        cancelable = true,
      })
      if #to > 0 then
        room:moveCardTo(judge.card, Card.PlayerHand, to[1], fk.ReasonJustMove, daidi.name, nil, true, player)
      end
    end
  end,
})

return daidi
