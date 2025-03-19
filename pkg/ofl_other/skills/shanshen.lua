local shanshen = fk.CreateSkill {
  name = "ofl__shanshen"
}

Fk:loadTranslationTable{
  ['ofl__shanshen'] = '善身',
  [':ofl__shanshen'] = '当有角色死亡时，你可令〖隅泣〗中的一个数字+2（单项不能超过3）。然后若你没有对死亡角色造成过伤害，你回复1点体力。',
  ['$ofl__shanshen1'] = '人家只想做安安静静的小淑女。',
  ['$ofl__shanshen2'] = '雪花纷飞，独存寒冬。',
}

shanshen:addEffect(fk.Death, {
  can_trigger = function(self, event, target, player)
    return player:hasSkill(shanshen.name) and target ~= player and not player.dead
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    AddYuqi(player, shanshen.name, 2)
    if player:isWounded() and #room.logic:getActualDamageEvents(1, function(e)
      local damage = e.data[1]
      if damage.from == player and damage.to == target then
        return true
      end
    end, nil, 0) == 0 then
      room:recover{
        who = player,
        num = 1,
        skillName = shanshen.name,
      }
    end
  end,
})

return shanshen
