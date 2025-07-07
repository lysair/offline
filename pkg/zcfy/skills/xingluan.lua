local xingluan = fk.CreateSkill {
  name = "sxfy__xingluan",
}

Fk:loadTranslationTable{
  ["sxfy__xingluan"] = "兴乱",
  [":sxfy__xingluan"] = "每阶段限一次，当你于你出牌阶段使用一张仅指定一名目标角色的牌结算结束后，你可以亮出牌堆顶六张牌，"..
  "获得其中一张牌。",

  ["#sxfy__xingluan-prey"] = "兴乱：获得其中一张牌",
}

xingluan:addEffect(fk.CardUseFinished, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xingluan.name) and player.phase == Player.Play and
      #data.tos == 1 and player:usedSkillTimes(xingluan.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = room:getNCards(6)
    local card = room:askToChooseCard(player, {
      target = player,
      flag = { card_data = {{ "Top", cards }} },
      skill_name = xingluan.name,
      prompt = "#sxfy__xingluan-prey",
    })
    room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonJustMove, xingluan.name, nil, false, player)
    room:cleanProcessingArea(cards)
  end,
})

return xingluan
