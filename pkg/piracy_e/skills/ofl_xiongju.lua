local xiongju = fk.CreateSkill({
  name = "ofl__xiongju",
  tags = { Skill.Lord },
})

Fk:loadTranslationTable{
  ["ofl__xiongju"] = "雄踞",
  [":ofl__xiongju"] = "主公技，与你势力相同的角色视为拥有技能〖马术〗。",
}

xiongju:addAcquireEffect(function (self, player)
  local room = player.room
  for _, p in ipairs(room.alive_players) do
    if p.kingdom == "qun" and not p:hasSkill("mashu", true) then
      room:setPlayerMark(p, xiongju.name, 1)
      room:handleAddLoseSkills(p, "mashu", nil, false, true)
    end
  end
end)

xiongju:addEffect(fk.AfterPropertyChange, {
  can_refresh = function(self, event, target, player, data)
    return target == player
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if player.kingdom == "qun" and table.find(room.alive_players, function (p)
      return p ~= player and p:hasSkill(xiongju.name, true)
    end) then
      if not player:hasSkill("mashu", true) then
        room:setPlayerMark(player, xiongju.name, 1)
        room:handleAddLoseSkills(player, "mashu", nil, false, true)
      end
    elseif player:getMark(xiongju.name) > 0 then
      room:setPlayerMark(player, xiongju.name, 0)
      room:handleAddLoseSkills(player, "-mashu", nil, false, true)
    end
  end,
})

return xiongju
