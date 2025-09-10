local bishi = fk.CreateSkill {
  name = "ofl__bishi",
}

Fk:loadTranslationTable{
  ["ofl__bishi"] = "避世",
  [":ofl__bishi"] = "当你成为其他角色使用【杀】的目标后，你可以令其摸一张牌，令此【杀】无效。",

  ["#ofl__bishi-invoke"] = "避世：是否令 %dest 摸一张牌，其使用的%arg无效？",
}

bishi:addEffect(fk.TargetConfirmed, {
  anim_type = "defensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(bishi.name) and
      data.card.trueName == "slash" and data.from ~= player and not data.from.dead
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = bishi.name,
      prompt = "#ofl__bishi-invoke::"..data.from.id..":"..data.card:toLogString(),
    }) then
      event:setCostData(self, {tos = {data.from}})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    data.from:drawCards(1, bishi.name)
    data.use.nullifiedTargets = table.simpleClone(player.room.players)
  end,
})

return bishi