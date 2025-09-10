local jiaoying = fk.CreateSkill {
  name = "sxfy__jiaoying",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["sxfy__jiaoying"] = "醮影",
  [":sxfy__jiaoying"] = "锁定技，你的回合内，手牌数多于本回合开始时的角色不能使用红色牌且受到的伤害+1。",
}

jiaoying:addEffect(fk.DamageInflicted, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(jiaoying.name) and player.room.current == player and
      data.to:getHandcardNum() > data.to:getMark("sxfy__jiaoying-turn")
  end,
  on_cost = function (self, event, target, player, data)
    event:setCostData(self, {tos = {target}})
    return true
  end,
  on_use = function(self, event, target, player, data)
    data:changeDamage(1)
  end,
})

jiaoying:addEffect(fk.TurnStart, {
  can_refresh = function (self, event, target, player, data)
    return target == player and player:hasSkill(jiaoying.name, true)
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room.alive_players) do
      room:setPlayerMark(p, "sxfy__jiaoying-turn", p:getHandcardNum())
    end
  end,
})

jiaoying:addEffect("prohibit", {
  prohibit_use = function(self, player, card)
    return Fk:currentRoom().current:hasSkill(jiaoying.name) and card and
      player:getHandcardNum() > player:getMark("sxfy__jiaoying-turn") and card.color == Card.Red
  end,
})

jiaoying:addAcquireEffect(function (self, player, is_start)
  if not is_start and player.room.current == player then
    local room = player.room
    for _, p in ipairs(room.alive_players) do
      room:setPlayerMark(p, "sxfy__jiaoying-turn", p:getHandcardNum())
    end
  end
end)

return jiaoying
