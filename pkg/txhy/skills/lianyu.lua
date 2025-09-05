local lianyu = fk.CreateSkill {
  name = "ofl_tx__lianyu",
}

Fk:loadTranslationTable{
  ["ofl_tx__lianyu"] = "炼狱",
  [":ofl_tx__lianyu"] = "结束阶段，你可以对所有敌方角色各造成1点火焰伤害。",

  ["#ofl_tx__lianyu-invoke"] = "炼狱：是否对所有敌方角色各造成1点火焰伤害？",
}

lianyu:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(lianyu.name) and player.phase == Player.Finish and
      #player:getEnemies() > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = lianyu.name,
      prompt = "#ofl_tx__lianyu-invoke",
    }) then
      local tos = player:getEnemies()
      room:sortByAction(tos)
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if p:isEnemy(player) and not p.dead then
        room:damage{
          from = player,
          to = p,
          damage = 1,
          damageType = fk.FireDamage,
          skillName = lianyu.name,
        }
      end
    end
  end,
})

return lianyu
