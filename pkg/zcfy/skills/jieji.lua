local jieji = fk.CreateSkill {
  name = "jieji",
}

Fk:loadTranslationTable{
  ["jieji"] = "劫击",
  [":jieji"] = "当你每回合使用的首张【杀】对一名其他角色造成伤害后，你可以获得其一张手牌，然后其视为对你使用一张无距离限制的【杀】。",

  ["#jieji-invoke"] = "劫击：你可以获得 %dest 一张手牌，其视为对你使用【杀】",
}

jieji:addEffect(fk.Damage, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(jieji.name) and
      data.card and data.card.trueName == "slash" and not data.to.dead and not data.to:isKongcheng() then
      local use_event = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
      if use_event then
        local use = use_event.data
        local use_events = player.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
          return e.data.from == player and e.data.card.trueName == "slash"
        end, Player.HistoryTurn)
        return #use_events == 1 and use_events[1].data == use
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = jieji.name,
      prompt = "#jieji-invoke::"..data.to.id,
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = room:askToChooseCard(player, {
      target = data.to,
      flag = "h",
      skill_name = jieji.name,
    })
    room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonPrey, jieji.name, nil, false, player)
    if player.dead or data.to.dead then return end
    room:useVirtualCard("slash", nil, data.to, player, jieji.name, true)
  end,
})

return jieji