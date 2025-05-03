local jujing = fk.CreateSkill {
  name = "sxfy__jujing",
  tags = { Skill.Lord },
}

Fk:loadTranslationTable{
  ["sxfy__jujing"] = "踞荆",
  [":sxfy__jujing"] = "主公技，当你受到其他群势力角色造成的伤害后，你可以弃置两张牌，然后回复1点体力。",

  ["#sxfy__jujing-invoke"] = "踞荆：你可以弃置两张牌，回复1点体力",
}

jujing:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jujing.name) and
      data.from and data.from.kingdom == "qun" and data.from ~= player and
      player:isWounded() and #player:getCardIds("he") > 1
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cards = room:askToDiscard(player, {
      min_num = 2,
      max_num = 2,
      include_equip = true,
      skill_name = jujing.name,
      cancelable = true,
      prompt = "#sxfy__jujing-invoke",
    })
    if #cards == 2 then
      event:setCostData(self, {cards = cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(event:getCostData(self).cards, jujing.name, player, player)
    if not player.dead and player:isWounded() then
      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = jujing.name,
      }
    end
  end,
})

return jujing
