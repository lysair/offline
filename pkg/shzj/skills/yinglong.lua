local yinglong = fk.CreateSkill {
  name = "yinglong",
}

Fk:loadTranslationTable{
  ["yinglong"] = "应龙",
  [":yinglong"] = "每回合限一次，当一名角色使用虚拟牌或转化牌时，你可以选择一项，令其本回合：1.使用同类型的牌不能被响应；2.使用同颜色的牌无次数限制。",

  ["yinglong_type"] = "%dest本回合使用%arg不能被响应",
  ["yinglong_color"] = "%dest本回合使用%arg牌无次数限制",
  ["@yinglong_type-turn"] = "应龙",
  ["@yinglong_color-turn"] = "应龙",
}

yinglong:addEffect(fk.CardUsing, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(yinglong.name) and data.card:isVirtual() and
      not target.dead and player:usedSkillTimes(yinglong.name, Player.HistoryTurn) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local choices = {
      "yinglong_type::"..target.id..":"..data.card:getTypeString(),
      "Cancel",
    }
    if data.card.color ~= Card.NoColor then
      table.insert(choices, 2, "yinglong_color::"..target.id..":"..data.card:getColorString())
    end
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = yinglong.name,
    })
    if choice ~= "Cancel" then
      event:setCostData(self, {tos = {target}, choice = choice})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choice = event:getCostData(self).choice
    if choice:startsWith("yinglong_type") then
      room:addTableMarkIfNeed(target, "@yinglong_type-turn", data.card:getTypeString().."_char")
    else
      room:addTableMarkIfNeed(target, "@yinglong_color-turn", data.card:getColorString())
    end
  end,
})

yinglong:addEffect(fk.PreCardUse, {
  can_refresh = function (self, event, target, player, data)
    return target == player
  end,
  on_refresh = function (self, event, target, player, data)
    if table.contains(player:getTableMark("@yinglong_type-turn"), data.card:getTypeString().."_char") then
      data.disresponsiveList = table.simpleClone(player.room.players)
    end
    if table.contains(player:getTableMark("@yinglong_color-turn"), data.card:getColorString()) then
      data.extraUse = true
    end
  end,
})

yinglong:addEffect("targetmod", {
  bypass_times = function (self, player, skill, scope, card, to)
    return card and table.contains(player:getTableMark("@yinglong_color-turn"), card:getColorString())
  end,
})

return yinglong
