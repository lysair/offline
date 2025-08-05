local tanyong = fk.CreateSkill({
  name = "ofl__tanyong",
  tags = { Skill.Compulsory },
})

Fk:loadTranslationTable{
  ["ofl__tanyong"] = "贪勇",
  [":ofl__tanyong"] = "锁定技，你使用牌时，其他角色只能使用点数大于此牌的牌响应。",
}

tanyong:addEffect(fk.HandleAskForPlayCard, {
  can_refresh = function(self, event, target, player, data)
    if data.eventData and data.eventData.from == player then
      if not data.afterRequest then
        return player:hasSkill(tanyong.name)
      else
        return player.room:getBanner(tanyong.name) and player.room:getBanner(tanyong.name)[1] == player.id
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if not data.afterRequest then
      room:setBanner(tanyong.name, {player.id, data.eventData.card.number})
    else
      room:setBanner(tanyong.name, 0)
    end
  end,
})

tanyong:addEffect("prohibit", {
  prohibit_use = function(self, player, card)
    local room = Fk:currentRoom()
    local banner = room:getBanner(tanyong.name)
    if banner and player.id ~= banner[1] then
      return card.number <= banner[2]
    end
  end,
})

return tanyong
