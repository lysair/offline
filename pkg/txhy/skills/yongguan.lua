local yongguan = fk.CreateSkill({
  name = "ofl_tx__yongguan",
  tags = { Skill.Compulsory },
})

Fk:loadTranslationTable{
  ["ofl_tx__yongguan"] = "勇冠",
  [":ofl_tx__yongguan"] = "锁定技，当你受到伤害时，防止此伤害，你获得等量的“勇”标记。"..
  "每个回合结束时，你弃置“勇”标记数的手牌并移去所有“勇”标记，每少弃置一张你失去1点体力。",

  ["@ofl_tx__yongguan"] = "勇",
}

yongguan:addEffect(fk.DetermineDamageInflicted, {
  anim_type = "defensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(yongguan.name)
  end,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "@ofl_tx__yongguan", data.damage)
    data:preventDamage()
  end,
})

yongguan:addEffect(fk.TurnEnd, {
  anim_type = "negative",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(yongguan.name) and player:getMark("@ofl_tx__yongguan") > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = player:getMark("@ofl_tx__yongguan")
    room:setPlayerMark(player, "@ofl_tx__yongguan", 0)
    local cards = room:askToDiscard(player, {
      min_num = n,
      max_num = n,
      include_equip = false,
      skill_name = yongguan.name,
      cancelable = false,
    })
    if not player.dead and #cards < n then
      room:loseHp(player, n - #cards, yongguan.name)
    end
  end,
})

return yongguan
