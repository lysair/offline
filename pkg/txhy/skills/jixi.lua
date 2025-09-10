local jixi = fk.CreateSkill {
  name = "ofl_tx__jixi",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_tx__jixi"] = "疾袭",
  [":ofl_tx__jixi"] = "锁定技，出牌阶段开始时，你选择失去1~2点体力，本回合你使用的下X张伤害类牌不能被响应（X为你选择失去的体力值）。",

  ["#ofl_tx__jixi-choice"] = "疾袭：失去1~2点体力，本回合下等量张伤害牌不能被响应",
  ["@ofl_tx__jixi-turn"] = "疾袭",
}

jixi:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jixi.name) and player.phase == Player.Play
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = room:askToNumber(player, {
      skill_name = jixi.name,
      prompt = "#ofl_tx__jixi-choice",
      min = 1,
      max = 2,
    })
    room:setPlayerMark(player, "@ofl_tx__jixi-turn", n)
    room:loseHp(player, n, jixi.name)
  end,
})

jixi:addEffect(fk.PreCardUse, {
  can_refresh = function (self, event, target, player, data)
    return target == player and player:getMark("@ofl_tx__jixi-turn") > 0 and data.card.is_damage_card
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    room:removePlayerMark(player, "@ofl_tx__jixi-turn", 1)
    data.disresponsiveList = table.simpleClone(room.players)
  end,
})

return jixi
