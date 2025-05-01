local xihun = fk.CreateSkill {
  name = "xihun",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["xihun"] = "吸魂",
  [":xihun"] = "锁定技，每轮结束时，所有其他角色依次选择弃置两张手牌或失去1点体力，然后你弃置任意个“魂”并回复等量体力。",

  ["#xihun-discard"] = "吸魂：弃置两张手牌，否则失去1点体力",
  ["#xihun-choose"] = "吸魂：弃置任意个“魂”，然后回复等量体力",
}

xihun:addEffect(fk.RoundEnd, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(xihun.name)
  end,
  on_cost = function(self, event, target, player, data)
    event:setCostData(self, {tos = player.room:getOtherPlayers(player)})
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if not p.dead then
        if #p:getCardIds("h") < 2 or
        #room:askToDiscard(player, {
          min_num = 2,
          max_num = 2,
          include_equip = false,
          skill_name = xihun.name,
          prompt = "#xihun-discard",
          cancelable = true,
        }) < 2 then
          room:loseHp(p, 1, xihun.name)
        end
      end
    end
    if not player.dead and player:getMark("@anying_soul") > 0 then
      local n = room:askToNumber(player, {
        skill_name = xihun.name,
        prompt = "#xihun-choice",
        min = 1,
        max = player:getMark("@anying_soul"),
        cancelable = true,
      })
      if n then
        room:removePlayerMark(player, "@anying_soul", n)
        room:recover{
          who = player,
          num = n,
          recoverBy = player,
          skillName = xihun.name,
        }
      end
    end
  end,
})

return xihun
