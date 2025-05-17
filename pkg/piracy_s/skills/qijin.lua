local qijin = fk.CreateSkill {
  name = "ofl__qijin",
}

Fk:loadTranslationTable{
  ["ofl__qijin"] = "七进",
  [":ofl__qijin"] = "摸牌阶段，你可以改为亮出牌堆顶的七张牌，然后获得其中一种颜色的所有牌。",

  ["#ofl__qijin-ask"] = "七进：获得一种颜色的所有牌",
}

qijin:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(qijin.name) and player.phase == Player.Draw
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    data.phase_end = true

    local cids = room:getNCards(7)
    room:turnOverCardsFromDrawPile(player, cids, qijin.name)
    room:delay(2000)

    local cards, choices = {}, {}
    for _, id in ipairs(cids) do
      local card = Fk:getCardById(id)
      local cardType = card:getColorString()
      if not cards[cardType] then
        table.insert(choices, cardType)
      end
      cards[cardType] = cards[cardType] or {}
      table.insert(cards[cardType], id)
    end
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = qijin.name,
      prompt = "#ofl__qijin-ask",
    })
    room:obtainCard(player, cards[choice], true, fk.ReasonJustMove, player, qijin.name)
    room:cleanProcessingArea(cids)
  end,
})

return qijin
