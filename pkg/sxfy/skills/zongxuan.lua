local zongxuan = fk.CreateSkill {
  name = "sxfy__zongxuan",
}

Fk:loadTranslationTable{
  ["sxfy__zongxuan"] = "纵玄",
  [":sxfy__zongxuan"] = "当你的手牌因弃置而进入弃牌堆后，你可以弃置场上的一张牌。",

  ["#sxfy__zongxuan-choose"] = "纵玄：你可以弃置场上的一张牌",
}

zongxuan:addEffect(fk.AfterCardsMove, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(zongxuan.name) and
      table.find(player.room.alive_players, function (p)
        return #p:getCardIds("ej") > 0
      end) then
      for _, move in ipairs(data) do
        if move.from == player and move.moveReason == fk.ReasonDiscard and move.toArea == Card.DiscardPile then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand then
              return true
            end
          end
        end
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function (p)
      return #p:getCardIds("ej") > 0
    end)
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = zongxuan.name,
      prompt = "#sxfy__zongxuan-choose",
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local card = room:askToChooseCard(player, {
      target = to,
      flag = "ej",
      skill_name = zongxuan.name,
    })
    room:throwCard(card, zongxuan.name, to, player)
  end,
})

return zongxuan
