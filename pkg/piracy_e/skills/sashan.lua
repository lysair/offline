local sashan = fk.CreateSkill({
  name = "ofl__sashan",
  tags = { Skill.Compulsory },
})

Fk:loadTranslationTable{
  ["ofl__sashan"] = "萨珊",
  [":ofl__sashan"] = "锁定技，游戏开始时，你将场上所有角色势力改为西势力。",
}

sashan:addEffect(fk.GameStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(sashan.name)
  end,
  on_cost = function (self, event, target, player, data)
    event:setCostData(self, {tos = player.room:getAlivePlayers()})
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room:getAlivePlayers()) do
      if not p.dead and p.kingdom ~= "west" then
        room:changeKingdom(p, "west", true)
      end
    end
  end,
})

return sashan
