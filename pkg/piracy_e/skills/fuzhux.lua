local fuzhux = fk.CreateSkill {
  name = "fuzhux",
}

Fk:loadTranslationTable{
  ["fuzhux"] = "辅主",
  [":fuzhux"] = "蜀势力技，每回合限一次，当一名角色使用转化牌结算后，你可以将一张牌置于牌堆顶，然后亮出牌堆顶四张牌，其获得这些牌中"..
  "所有锦囊牌，你将其余牌以任意顺序置于牌堆顶或牌堆底。",

  ["#fuzhux-invoke"] = "辅主：你可以将一张牌置于牌堆顶，令 %dest 亮出牌堆顶四张牌并获得其中的锦囊牌",
}

fuzhux:addEffect(fk.CardUseFinished, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(fuzhux.name) and data.card:isVirtual() and #data.card.subcards > 0 and
      player:usedSkillTimes(fuzhux.name, Player.HistoryTurn) == 0 and not player:isNude()
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local card = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = fuzhux.name,
      prompt = "#fuzhux-invoke::" .. target.id,
    })
    if #card > 0 then
      event:setCostData(self, {tos = {target}, cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:moveCards({
      ids = event:getCostData(self).cards,
      from = player,
      toArea = Card.DrawPile,
      moveReason = fk.ReasonPut,
      skillName = fuzhux.name,
      drawPilePosition = 1,
      moveVisible = true,
    })
    local cards = room:getNCards(4)
    room:showCards(cards)
    room:delay(1000)
    if not target.dead then
      local ids = table.filter(cards, function (id)
        return Fk:getCardById(id).type == Card.TypeTrick
      end)
      if #ids > 0 then
        room:moveCardTo(ids, Card.PlayerHand, target, fk.ReasonJustMove, fuzhux.name, nil, true, target)
      end
    end
    cards = table.filter(cards, function (id)
      return table.contains(room.draw_pile, id)
    end)
    if #cards > 0 and not player.dead then
      room:askToGuanxing(player, {
        cards = cards,
        skill_name = fuzhux.name,
      })
    end
  end,
})

return fuzhux
