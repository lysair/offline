local yingyou = fk.CreateSkill {
  name = "yingyou",
}

Fk:loadTranslationTable{
  ["yingyou"] = "英猷",
  [":yingyou"] = "出牌阶段开始时，你可以明置一张“志”，然后摸X张牌（X为你明置的“志”数）。当你失去与明置的“志”花色相同的牌后，你摸一张牌。",

  ["#yingyou-invoke"] = "英猷：你可以明置一张“志”，摸明置数的牌",
}

yingyou:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yingyou.name) and player.phase == Player.Play and
      table.find(player:getPile("$yingtian_ambition"), function (id)
        return not table.contains(player:getTableMark("yingtian_ambition_shown"), id)
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cards = table.filter(player:getPile("$yingtian_ambition"), function (id)
      return not table.contains(player:getTableMark("yingtian_ambition_shown"), id)
    end)
    local card = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = yingyou.name,
      cancelable = true,
      pattern = tostring(Exppattern{ id = cards }),
      prompt = "#yingyou-invoke",
      expand_pile = player:getPile("$yingtian_ambition"),
    })
    if #card > 0 then
      event:setCostData(self, {cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:addTableMark(player, "yingtian_ambition_shown", event:getCostData(self).cards[1])
    local n = #table.filter(player:getPile("$yingtian_ambition"), function (id)
      return table.contains(player:getTableMark("yingtian_ambition_shown"), id)
    end)
    player:drawCards(n, yingyou.name)
  end,
})

yingyou:addLoseEffect(function (self, player, is_death)
  if not player:hasSkill("jilin", true) then
    local room = player.room
    room:setPlayerMark(player, "yingtian_ambition_shown", 0)
    room:moveCards({
      ids = player:getPile("$yingtian_ambition"),
      from = player,
      toArea = Card.DiscardPile,
      moveReason = fk.ReasonPutIntoDiscardPile,
    })
  end
end)

yingyou:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(yingyou.name) and #player:getPile("$yingtian_ambition") > 0 and
      player:getMark("yingtian_ambition_shown") ~= 0 then
      for _, move in ipairs(data) do
        if move.from == player then
          for _, info in ipairs(move.moveInfo) do
            if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
              table.find(player:getPile("$yingtian_ambition"), function (id)
                return table.contains(player:getTableMark("yingtian_ambition_shown"), id) and
                  Fk:getCardById(id):compareSuitWith(Fk:getCardById(info.cardId))
              end) then
              return true
            end
          end
        end
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, yingyou.name)
  end,
})

return yingyou
