local gaiming = fk.CreateSkill {
  name = "ofl__gaiming",
}

Fk:loadTranslationTable{
  ["ofl__gaiming"] = "改命",
  [":ofl__gaiming"] = "每回合限一次，当你的判定牌生效前，若结果不为♠，你可以亮出牌堆顶的一张牌代替之。",

  ["#ofl__gaiming-invoke"] = "贞烈：是否亮出牌堆顶一张牌修改你的“%arg”判定？",
}

gaiming:addEffect(fk.AskForRetrial, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(gaiming.name) and
      (not data.card or data.card.suit ~= Card.Spade) and
      player:usedSkillTimes(gaiming.name, Player.HistoryTurn) == 0
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = gaiming.name,
      prompt = "#ofl__gaiming-invoke:::"..data.reason,
    })
  end,
  on_use = function(self, event, target, player, data)
    player.room:changeJudge{
      card = Fk:getCardById(player.room:getNCards(1)[1]),
      player = player,
      data = data,
      skillName = gaiming.name,
      response = false,
    }
  end,
})

return gaiming
