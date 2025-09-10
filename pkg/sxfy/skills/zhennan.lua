local zhennan = fk.CreateSkill {
  name = "sxfy__zhennan",
}

Fk:loadTranslationTable {
  ["sxfy__zhennan"] = "镇南",
  [":sxfy__zhennan"] = "其他角色的准备阶段，你可以弃置一张手牌，然后其本回合使用下一张牌时，若为红色，其获得之。",

  ["#sxfy__zhennan-invoke"] = "镇南：弃一张手牌，若 %dest 使用的下一张牌是红色，其将之收回",
  ["@@sxfy__zhennan-turn"] = "镇南",
}

zhennan:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(zhennan.name) and target.phase == Player.Start and not target.dead and
      not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local card = room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = zhennan.name,
      prompt = "#sxfy__zhennan-invoke::"..target.id,
      cancelable = true,
      skip = true,
    })
    if #card > 0 then
      event:setCostData(self, {tos = {target}, cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(event:getCostData(self).cards, zhennan.name, player, player)
    if target.dead then return false end
    room:setPlayerMark(target, "@@sxfy__zhennan-turn", 1)
  end,
})

zhennan:addEffect(fk.CardUsing, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and player:getMark("@@sxfy__zhennan-turn") > 0 and data.card.color == Card.Red and
      player.room:getCardArea(data.card) == Card.Processing and not target.dead
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@@sxfy__zhennan-turn", 0)
    room:obtainCard(player, data.card, true, fk.ReasonJustMove, player, zhennan.name)
  end,
})

return zhennan
