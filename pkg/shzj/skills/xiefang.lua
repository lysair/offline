local xiefang = fk.CreateSkill{
  name = "shzj_guansuo__xiefang",
}

Fk:loadTranslationTable{
  ["shzj_guansuo__xiefang"] = "撷芳",
  [":shzj_guansuo__xiefang"] = "你计算与其他角色距离-X；你使用基本牌和普通锦囊牌可以额外指定至多X个目标（X为场上女性角色数且至少为1）。",

  ["#shzj_guansuo__xiefang-choose"] = "撷芳：你可以为此%arg额外指定至多%arg2个目标",
}

xiefang:addEffect(fk.AfterCardTargetDeclared, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xiefang.name) and
      (data.card.type == Card.TypeBasic or data.card:isCommonTrick()) and #data:getExtraTargets() > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local n = #table.filter(room.alive_players, function (p)
      return p:isFemale()
    end)
    n = math.min(n, 1)
    local tos = room:askToChoosePlayers(player, {
      targets = data:getExtraTargets(),
      min_num = 1,
      max_num = n,
      prompt = "#shzj_guansuo__xiefang-choose:::" .. data.card:toLogString()..":"..n,
      skill_name = xiefang.name,
      cancelable = true,
    })
    if #tos > 0 then
      room:sortByAction(tos)
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    for _, p in ipairs(event:getCostData(self).tos) do
      data:addTarget(p)
    end
  end,
})

xiefang:addEffect("distance", {
  correct_func = function(self, from, to)
    if from:hasSkill(xiefang.name) then
      local n = #table.filter(Fk:currentRoom().alive_players, function (p)
        return p:isFemale()
      end)
      return -math.min(n, 1)
    end
  end,
})

return xiefang
