local nagong = fk.CreateSkill({
  name = "ofl__nagong",
})

Fk:loadTranslationTable{
  ["ofl__nagong"] = "纳贡",
  [":ofl__nagong"] = "其他角色的准备阶段，其可以交给你一张牌，直到其下回合开始，其将势力改为群。",

  ["#ofl__nagong-invoke"] = "纳贡：你可以交给 %src 一张牌，直到你下回合开始你势力改为群",
}

nagong:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function (self, event, target, player, data)
    return target ~= player and player:hasSkill(nagong.name) and target.phase == Player.Start and
      not target:isNude()
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local cards = room:askToCards(target, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = nagong.name,
      prompt = "#ofl__nagong-invoke:"..player.id,
      cancelable = true,
    })
    if #cards > 0 then
      event:setCostData(self, {cards = cards})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:moveCardTo(event:getCostData(self).cards, Card.PlayerHand, player, fk.ReasonGive, nagong.name, nil, false, target)
    if not target.dead and target.kingdom ~= "qun" then
      room:setPlayerMark(player, nagong.name, player.kingdom)
      room:changeKingdom(player, "qun", true)
    end
  end,
})

nagong:addEffect(fk.TurnStart, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and player:getMark(nagong.name) ~= 0
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local kingdom = player:getMark(nagong.name)
    room:setPlayerMark(player, nagong.name, 0)
    room:changeKingdom(player, kingdom, true)
  end,
})

return nagong
