local kuizhul = fk.CreateSkill {
  name = "sgsh__kuizhul",
}

Fk:loadTranslationTable{
  ["sgsh__kuizhul"] = "馈珠",
  [":sgsh__kuizhul"] = "当一名其他角色造成伤害后，你可以交给其一张手牌，然后若其手牌数小于你，你摸一张牌。",

  ["#sgsh__kuizhul-invoke"] = "馈珠：你可以交给 %dest 一张手牌",

  ["$sgsh__kuizhul1"] = "宝珠万千，皆予将军一人。",
  ["$sgsh__kuizhul2"] = "馈珠还情，邀买人心。",
}

kuizhul:addEffect(fk.Damage, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(kuizhul.name) and target and target ~= player and
      not player:isKongcheng() and not target.dead
  end,
  on_cost = function(self, event, target, player, data)
    local card = player.room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = kuizhul.name,
      cancelable = true,
      prompt = "#sgsh__kuizhul-invoke::"..target.id,
    })
    if #card > 0 then
      event:setCostData(self, {tos = {target}, cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:moveCardTo(event:getCostData(self).cards, Card.PlayerHand, target, fk.ReasonGive, kuizhul.name, nil, false, player)
    if not player.dead and player:getHandcardNum() > target:getHandcardNum() then
      player:drawCards(1, kuizhul.name)
    end
  end,
})

return kuizhul
