local shefu = fk.CreateSkill {
  name = "sxfy__shefu",
  derived_piles = "$sxfy__shefu",
}

Fk:loadTranslationTable{
  ["sxfy__shefu"] = "设伏",
  [":sxfy__shefu"] = "结束阶段，你可以将一张手牌扣置于武将牌上；当一名角色使用牌时，你可以移去你武将牌上的一张同名牌令之无效。",

  ["$sxfy__shefu"] = "设伏",
  ["#sxfy__shefu-put"] = "设伏：你可以将一张手牌扣置为“设伏”牌",
  ["#sxfy__shefu-invoke"] = "设伏：是否移去同名“设伏”牌，令 %dest 使用的%arg无效？",
}

shefu:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(shefu.name) and player.phase == Player.Finish and
      not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cards = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = shefu.name,
      prompt = "#sxfy__shefu-put",
      cancelable = true,
    })
    if #cards > 0 then
      event:setCostData(self, {cards = cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player:addToPile("$sxfy__shefu", event:getCostData(self).cards, false, shefu.name, player)
  end,
})

shefu:addEffect(fk.CardUsing, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(shefu.name) and
      table.find(player:getPile("$sxfy__shefu"), function (id)
        return Fk:getCardById(id).trueName == data.card.trueName
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cards = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = shefu.name,
      pattern = data.card.trueName.."|.|.|$sxfy__shefu",
      prompt = "#sxfy__shefu-invoke::"..target.id..":"..data.card:toLogString(),
      cancelable = true,
      expand_pile = "$sxfy__shefu",
    })
    if #cards > 0 then
      event:setCostData(self, {tos = {target}, cards = cards})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:moveCardTo(event:getCostData(self).cards, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, shefu.name, nil, true, player)
    data.toCard = nil
    data:removeAllTargets()
  end,
})

return shefu
