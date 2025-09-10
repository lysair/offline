local yingzhen = fk.CreateSkill {
  name = "yingzhen",
}

Fk:loadTranslationTable{
  ["yingzhen"] = "应阵",
  [":yingzhen"] = "游戏开始时，你选择一名其他角色，你与其上家或下家交换座次，然后你与其依次执行一个额外回合。",

  ["yingzhen-choose"] = "应阵：选择一名角色，你与其上家或下家交换座次，然后你与其依次执行一个额外回合",
  ["yingzhen_last"] = "与%dest交换座次",
  ["yingzhen_next"] = "与%dest交换座次",

  ["$yingzhen1"] = "将军真壮士也！吾可助之！",
  ["$yingzhen2"] = "今日，定要活捉那孙策！",
}

yingzhen:addEffect(fk.GameStart, {
  priority = 0.001,
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(yingzhen.name) and #player.room:getOtherPlayers(player, false) > 0
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room:getOtherPlayers(player, false),
      skill_name = yingzhen.name,
      prompt = "yingzhen-choose",
      cancelable = false,
    })
    event:setCostData(self, {tos = to})
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    if to:getLastAlive() ~= to:getNextAlive() then
      local choices = {"yingzhen_last::"..to:getLastAlive().id, "yingzhen_next::"..to:getNextAlive().id}
      local choice = room:askToChoice(player, {
        choices = choices,
        skill_name = yingzhen.name,
      })
      local p = to:getLastAlive()
      if choice:startsWith("yingzhen_next") then
        p = to:getNextAlive()
      end
      if p ~= player then
        room:swapSeat(player, p)
      end
    end
    to:gainAnExtraTurn(true, yingzhen.name)
    player:gainAnExtraTurn(true, yingzhen.name)
  end,
})

return yingzhen
