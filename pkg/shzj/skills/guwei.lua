local guwei = fk.CreateSkill {
  name = "guwei",
}

Fk:loadTranslationTable{
  ["guwei"] = "固围",
  [":guwei"] = "当你成为其他角色使用【杀】或锦囊牌的目标后，你可以摸一张牌，此牌结算结束后，若未造成伤害，你可以弃置使用者一张手牌。",

  ["#guwei-invoke"] = "固围：是否弃置 %dest 一张手牌？",
}

guwei:addEffect(fk.TargetConfirmed, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(guwei.name) and
      data.from ~= player and (data.card.trueName == "slash" or data.card.type == Card.TypeTrick)
  end,
  on_use = function(self, event, target, player, data)
    data.extra_data = data.extra_data or {}
    data.extra_data.guwei = data.extra_data.guwei or {}
    table.insert(data.extra_data.guwei, player)
    player:drawCards(1, guwei.name)
  end,
})

guwei:addEffect(fk.CardUseFinished, {
  anim_type = "control",
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return data.extra_data and data.extra_data.guwei and
      table.contains(data.extra_data.guwei, player) and not data.damageDealt and
      not player.dead and not data.from:isKongcheng()
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = guwei.name,
      prompt = "#guwei-invoke::"..target.id,
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local card = room:askToChooseCard(player, {
      target = target,
      flag = "h",
      skill_name = guwei.name,
    })
    room:throwCard(card, guwei.name, target, player)
  end,
})

return guwei
