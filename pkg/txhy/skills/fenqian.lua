local fenqian = fk.CreateSkill {
  name = "ofl_tx__fenqian",
}

Fk:loadTranslationTable{
  ["ofl_tx__fenqian"] = "焚迁",
  [":ofl_tx__fenqian"] = "每回合限一次，当你进入濒死状态时，你将体力回复至1点，直到回合结束：其他角色计算与你的距离+2X（X为存活角色数），"..
  "你受到的伤害减半（向上取整）。",

  ["@@ofl_tx__fenqian-turn"] = "焚迁",
}

fenqian:addEffect(fk.EnterDying, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(fenqian.name) and
      player.hp < 1 and player:usedSkillTimes(fenqian.name, Player.HistoryTurn) == 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@@ofl_tx__fenqian-turn", 1)
    room:recover{
      who = player,
      num = 1 - player.hp,
      recoverBy = player,
      skillName = fenqian.name,
    }
  end,
})

fenqian:addEffect(fk.DamageInflicted, {
  anim_type = "defensive",
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and player:getMark("@@ofl_tx__fenqian-turn") > 0
  end,
  on_use = function (self, event, target, player, data)
    data:changeDamage(-math.floor((data.damage + 1) // 2))
  end,
})

fenqian:addEffect("distance", {
  correct_func = function(self, from, to)
    if to:getMark("@@ofl_tx__fenqian-turn") > 0 then
      return 2 * #Fk:currentRoom().alive_players
    end
  end,
})

return fenqian
