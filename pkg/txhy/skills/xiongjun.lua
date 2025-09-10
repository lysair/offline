local xiongjun = fk.CreateSkill {
  name = "ofl_tx__xiongjun",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_tx__xiongjun"] = "凶军",
  [":ofl_tx__xiongjun"] = "锁定技，当你造成伤害后，拥有〖凶军〗的角色各摸一张牌。",

  ["$ofl_tx__xiongjun1"] = "凶兵愤戾，尽诛长安之民！",
  ["$ofl_tx__xiongjun2"] = "继董公之命，逞凶戾之兵。",
}

xiongjun:addEffect(fk.Damage, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xiongjun.name)
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room:getAlivePlayers()) do
      if p:hasSkill(xiongjun.name, true) and not p.dead then
        p:drawCards(1, xiongjun.name)
      end
    end
  end,
})

return xiongjun
