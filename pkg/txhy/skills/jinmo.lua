local jinmo = fk.CreateSkill {
  name = "ofl_tx__jinmo",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_tx__jinmo"] = "浸魔",
  [":ofl_tx__jinmo"] = "锁定技，当你受到伤害时，你令此伤害-1并获得一枚“魔”标记。"..
  "弃牌阶段结束时，你受到X点无来源伤害（X为“魔”标记数），然后从牌堆获得Y张伤害类牌（Y为你本次受到的伤害值）。"..
  "回合结束时，你移去所有“魔”标记。",

  ["@ofl_tx__jinmo"] = "魔",
}

jinmo:addEffect(fk.DamageInflicted, {
  anim_type = "defensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(jinmo.name)
  end,
  on_use = function (self, event, target, player, data)
    player.room:addPlayerMark(player, "@ofl_tx__jinmo", 1)
    data:changeDamage(-1)
  end,
})

jinmo:addEffect(fk.EventPhaseEnd, {
  anim_type = "negative",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(jinmo.name) and player.phase == Player.Discard and
      player:getMark("@ofl_tx__jinmo") > 0
  end,
  on_use = function (self, event, target, player, data)
    player.room:damage{
      to = player,
      damage = player:getMark("@ofl_tx__jinmo"),
      skillName = jinmo.name,
    }
  end,
})

jinmo:addEffect(fk.Damaged, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and not player.dead and data.skillName == jinmo.name
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local cards = table.filter(room.draw_pile, function (id)
      return Fk:getCardById(id).is_damage_card
    end)
    if #cards > 0 then
      room:moveCardTo(table.random(cards, data.damage), Card.PlayerHand, player, fk.ReasonJustMove, jinmo.name, nil, false, player)
    end
  end,
})

jinmo:addEffect(fk.TurnEnd, {
  mute = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(jinmo.name) and
      player:getMark("@ofl_tx__jinmo") > 0
  end,
  on_use = function (self, event, target, player, data)
    player.room:setPlayerMark(player, "@ofl_tx__jinmo", 0)
  end,
})

return jinmo
