local majiang = fk.CreateSkill {
  name = "ofl_tx__majiang",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_tx__majiang"] = "马将",
  [":ofl_tx__majiang"] = "锁定技，每名其他角色的结束阶段，若其计算与你的距离与回合开始时相比："..
  "增加，你回复2X点体力；减少，你摸2X张牌（X为计算距离变化值）。",
}

majiang:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    return target ~= player and player:hasSkill(majiang.name) and target.phase == Player.Finish and
      not target:isRemoved() and (target.dead or player:getTableMark("ofl_tx__majiang-turn")[target] ~= target:distanceTo(player))
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local n = target:distanceTo(player) - player:getTableMark("ofl_tx__majiang-turn")[target]
    if n > 0 then
      room:recover{
        who = player,
        num = 2 * n,
        recoverBy = player,
        skillName = majiang.name,
      }
    else
      player:drawCards(-2 * n, majiang.name)
    end
  end,
})

majiang:addEffect(fk.TurnStart, {
  can_refresh = function (self, event, target, player, data)
    return target ~= player
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    local mark = {}
    for _, p in ipairs(room:getOtherPlayers(player, false)) do
      mark[p] = p:distanceTo(player)
    end
    room:setPlayerMark(player, "ofl_tx__majiang-turn", mark)
  end,
})

majiang:addAcquireEffect(function (self, player, is_start)
  if not is_start and player:getMark("ofl_tx__majiang-turn") == 0 then
    local room = player.room
    local mark = {}
    for _, p in ipairs(room:getOtherPlayers(player, false)) do
      mark[p] = p:distanceTo(player)
    end
    room:setPlayerMark(player, "ofl_tx__majiang-turn", mark)
  end
end)

return majiang
