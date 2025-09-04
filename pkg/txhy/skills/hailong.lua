
local hailong = fk.CreateSkill {
  name = "ofl_tx__hailong",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_tx__hailong"] = "骸龙",
  [":ofl_tx__hailong"] = "锁定技，回合开始时，你令所有其他角色各减1点体力上限，然后你增加等量的体力上限并回复等量体力。",
}

hailong:addEffect(fk.TurnStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(hailong.name) and
      #player.room:getOtherPlayers(player, false) > 0
  end,
  on_cost = function (self,event, target, player, data)
    event:setCostData(self, {tos = player.room:getOtherPlayers(player)})
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = 0
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if not p.dead then
        n = n + 1
        room:changeMaxHp(p, -1)
      end
    end
    if player.dead then return end
    room:changeMaxHp(player, n)
    if player.dead then return end
    room:recover{
      who = player,
      num = n,
      recoverBy = player,
      skillName = hailong.name,
    }
  end,
})

return hailong
