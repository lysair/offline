local jianbing = fk.CreateSkill {
  name = "ofl__jianbing",
}

Fk:loadTranslationTable{
  ["ofl__jianbing"] = "谏兵",
  [":ofl__jianbing"] = "当一名其他角色受到【杀】造成的伤害时，你可以获得其一张牌，若为<font color='red'>♥</font>，其回复1点体力。",

  ["#ofl__jianbing-invoke"] = "谏兵：你可以获得 %dest 一张牌，若为<font color='red'>♥</font>其回复1点体力",
}

jianbing:addEffect(fk.DamageInflicted, {
  anim_type = "control",
  can_trigger = function (self, event, target, player, data)
    return target ~= player and player:hasSkill(jianbing.name) and
      data.card and data.card.trueName == "slash" and not target:isNude()
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = jianbing.name,
      prompt = "#ofl__jianbing-invoke::"..target.id,
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local card = room:askToChooseCard(player, {
      target = target,
      flag = "he",
      skill_name = jianbing.name,
    })
    local yes = Fk:getCardById(card).suit == Card.Heart
    room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonPrey, jianbing.name, nil, false, player)
    if yes and not target.dead then
      room:recover{
        who = target,
        num = 1,
        recoverBy = player,
        skillName = jianbing.name,
      }
    end
  end,
})

return jianbing