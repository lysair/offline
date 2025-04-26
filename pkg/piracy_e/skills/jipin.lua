local jipin = fk.CreateSkill {
  name = "ofl__jipin",
}

Fk:loadTranslationTable{
  ["ofl__jipin"] = "济贫",
  [":ofl__jipin"] = "当你对手牌数大于你的角色造成伤害后，你可以获得其一张手牌，然后可以将之交给一名其他角色。",

  ["#ofl__jipin-invoke"] = "济贫：是否获得 %dest 一张手牌？",
  ["#ofl__jipin-prey"] = "济贫：获得 %dest 一张手牌",
  ["#ofl__jipin-give"] = "济贫：你可以将这张%arg交给一名其他角色",
}

jipin:addEffect(fk.Damage, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jipin.name) and
      player:getHandcardNum() < data.to:getHandcardNum() and not data.to.dead
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askToSkillInvoke(target, {
      skill_name = jipin.name,
      prompt = "#ofl__jipin-invoke::" .. data.to.id,
    }) then
      event:setCostData(self, {tos = {data.to}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = room:askToChooseCard(target, {
      target = data.to,
      flag = "h",
      skill_name = jipin.name,
      prompt = "#ofl__jipin-prey::" .. data.to.id,
    })
    room:moveCardTo(card, Card.PlayerHand, target, fk.ReasonPrey, jipin.name, nil, false, target)
    if player.dead or not table.contains(player:getCardIds("h"), card) or #room:getOtherPlayers(player, false) == 0 then return end
    local to = room:askToChoosePlayers(player, {
      targets = room:getOtherPlayers(player, false),
      min_num = 1,
      max_num = 1,
      prompt = "#ofl__jipin-give:::" .. Fk:getCardById(card):toLogString(),
      skill_name = jipin.name,
    })
    if #to > 0 then
      room:moveCardTo(card, Card.PlayerHand, to[1], fk.ReasonGive, jipin.name, nil, false, target)
    end
  end,
})

return jipin
