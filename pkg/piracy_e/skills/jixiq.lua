local jixiq = fk.CreateSkill {
  name = "ofl__jixiq",
}

Fk:loadTranslationTable{
  ["ofl__jixiq"] = "疾袭",
  [":ofl__jixiq"] = "当你使用【杀】指定目标后，若其装备区内牌数不小于你，你可以选择一项：1.获得其一张牌；2.摸一张牌，此【杀】不可被响应。",

  ["ofl__jixiq_prey"] = "获得其一张牌",
  ["ofl__jixiq_draw"] = "摸一张牌，此【杀】不可被响应",
}

jixiq:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jixiq.name) and
      data.card.trueName == "slash" and
      #data.to:getCardIds("e") >= #player:getCardIds("e")
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local choices = { "ofl__jixiq_draw", "Cancel" }
    if not data.to:isNude() then
      table.insert(choices, 1, "ofl__jixiq_prey")
    end
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = jixiq.name,
      all_choices = { "ofl__jixiq_prey", "ofl__jixiq_draw", "Cancel" },
    })
    if choice ~= "Cancel" then
      event:setCostData(self, {tos = {data.to}, choice = choice})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choice = event:getCostData(self).choice
    if choice == "ofl__jixiq_prey" then
      local card = room:askToChooseCard(player, {
        target = data.to,
        flag = "he",
        skill_name = jixiq.name,
      })
      room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonPrey, jixiq.name, nil, false, player)
    else
      data.disresponsive = true
      player:drawCards(1, jixiq.name)
    end
  end,
})

return jixiq
