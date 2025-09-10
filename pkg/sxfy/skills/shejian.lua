local shejian = fk.CreateSkill {
  name = "sxfy__shejian",
}

Fk:loadTranslationTable{
  ["sxfy__shejian"] = "舌剑",
  [":sxfy__shejian"] = "当你成为其他角色使用牌的唯一目标后，你可以弃置两张手牌，本回合结束时你对其造成1点伤害。",

  ["#sxfy__shejian-invoke"] = "舌剑：弃置两张手牌，本回合结束时对 %dest 造成1点伤害",
}

shejian:addEffect(fk.TargetConfirmed, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(shejian.name) and
      data.from ~= player and data:isOnlyTarget(player) and player:getHandcardNum() > 1
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cards = room:askToDiscard(player, {
      min_num = 2,
      max_num = 2,
      include_equip = false,
      skill_name = shejian.name,
      cancelable = true,
      prompt = "#sxfy__shejian-invoke::"..data.from.id,
      skip = true,
    })
    if #cards > 1 then
      event:setCostData(self, {tos = {data.from}, cards = cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(event:getCostData(self).cards, shejian.name, player, player)
    if not data.from.dead then
      room:addTableMark(data.from, "sxfy__shejian-turn", player)
    end
  end,
})

shejian:addEffect(fk.TurnEnd, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return player:getMark("sxfy__shejian-turn") ~= 0
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(player:getMark("sxfy__shejian-turn")) do
      if player.dead then return end
      room:doIndicate(p, {player})
      room:damage{
        from = p,
        to = player,
        damage = 1,
        skillName = shejian.name,
      }
    end
  end,
})

return shejian
