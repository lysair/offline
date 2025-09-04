local juedou = fk.CreateSkill {
  name = "ofl_tx__juedou",
}

Fk:loadTranslationTable{
  ["ofl_tx__juedou"] = "角斗",
  [":ofl_tx__juedou"] = "准备阶段，你可以令所有角色本回合攻击范围+X（X为此时存活角色数）。",
}

juedou:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(juedou.name) and player.phase == Player.Start
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = juedou.name,
    }) then
      event:setCostData(self, {tos = room:getAlivePlayers()})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room.alive_players) do
      room:addPlayerMark(p, "ofl_tx__juedou-turn", #room.alive_players)
    end
  end,
})

juedou:addEffect("atkrange", {
  correct_func = function(self, from, to)
    return from:getMark("ofl_tx__juedou-turn")
  end,
})

return juedou
