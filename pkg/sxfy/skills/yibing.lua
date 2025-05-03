local yibing = fk.CreateSkill {
  name = "sxfy__yibing",
}

Fk:loadTranslationTable{
  ["sxfy__yibing"] = "益兵",
  [":sxfy__yibing"] = "一名其他角色进入濒死状态时，你可以获得其一张手牌。",

  ["#sxfy__yibing-invoke"] = "益兵：是否获得 %dest 一张手牌？",
}

yibing:addEffect(fk.EnterDying, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(yibing.name) and not target:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = self.name,
      prompt = "#sxfy__yibing-invoke::"..target.id,
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = room:askToChooseCard(player, {
      target = target,
      flag = "h",
      skill_name = yibing.name,
    })
    room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonPrey, yibing.name, nil, false, player)
  end,
})

return yibing
