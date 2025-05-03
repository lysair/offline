local jiexun = fk.CreateSkill {
  name = "sxfy__jiexun",
}

Fk:loadTranslationTable{
  ["sxfy__jiexun"] = "诫训",
  [":sxfy__jiexun"] = "结束阶段，你可以令一名角色弃置一张手牌，然后若此牌为<font color='red'>♦</font>牌，其摸两张牌",

  ["#sxfy__jiexun-choose"] = "诫训：令一名角色弃一张手牌，若为<font color='red'>♦</font>牌，其摸两张牌",
  ["#sxfy__jiexun-discard"] = "诫训：请弃置一张手牌，若为<font color='red'>♦</font>牌，你摸两张牌",
}

jiexun:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jiexun.name) and player.phase == Player.Finish and
      table.find(player.room.alive_players, function (p)
        return not p:isKongcheng()
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function (p)
      return not p:isKongcheng()
    end)
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = jiexun.name,
      prompt = "#sxfy__jiexun-choose",
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
    local card = room:askToDiscard(to, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = jiexun.name,
      cancelable = false,
      prompt = "#sxfy__jiexun-discard",
    })
    if #card == 1 and Fk:getCardById(card[1]).suit == Card.Diamond and not to.dead then
      to:drawCards(2, jiexun.name)
    end
  end,
})

return jiexun
