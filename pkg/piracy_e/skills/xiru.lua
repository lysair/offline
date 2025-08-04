local xiru = fk.CreateSkill({
  name = "ofl__xiru",
  tags = { Skill.Compulsory },
})

Fk:loadTranslationTable{
  ["ofl__xiru"] = "西入",
  [":ofl__xiru"] = "锁定技，摸牌阶段，你的摸牌数+X（X为场上坐骑牌数的一半，向上取整）。",
}

xiru:addEffect(fk.DrawNCards, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xiru.name) and
      table.find(player.room.alive_players, function (p)
        return #p:getEquipments(Card.SubtypeDefensiveRide) > 0 or #p:getEquipments(Card.SubtypeOffensiveRide) > 0
      end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = 0
    for _, p in ipairs(room:getAlivePlayers()) do
      n = n + #p:getEquipments(Card.SubtypeDefensiveRide) + #p:getEquipments(Card.SubtypeOffensiveRide)
    end
    data.n = data.n + (n + 1) // 2
  end,
})

return xiru
