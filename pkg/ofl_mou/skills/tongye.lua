local tongye = fk.CreateSkill {
  name = "ofl_mou__tongye",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_mou__tongye"] = "统业",
  [":ofl_mou__tongye"] = "锁定技，若本局游戏牌堆未洗过牌，则你视为拥有〖英姿〗和〖固政〗。",
}

tongye:addEffect(fk.AfterDrawPileShuffle, {
  can_refresh = function (self, event, target, player, data)
    return not player.room:getBanner(tongye.name)
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    room:setBanner(tongye.name, 1)
    if player:getMark(tongye.name) ~= 0 then
      room:handleAddLoseSkills(player, "-"..table.concat(player:getTableMark(tongye.name), "|-"), nil, false, true)
      room:setPlayerMark(player, tongye.name, 0)
    end
  end,
})

tongye:addAcquireEffect(function (self, player, is_start)
  local room = player.room
  if not room:getBanner(tongye.name) then
    local skills = table.filter({"mou__yingzi", "guzheng"}, function (s)
      return not player:hasSkill(s, true)
    end)
    if #skills > 0 then
      room:setPlayerMark(player, tongye.name, skills)
      room:handleAddLoseSkills(player, table.concat(skills, "|"), nil, false, true)
    end
  end
end)

tongye:addLoseEffect(function (self, player, is_death)
  local room = player.room
  if player:getMark(tongye.name) ~= 0 then
    room:handleAddLoseSkills(player, "-"..table.concat(player:getTableMark(tongye.name), "|-"), nil, false, true)
    room:setPlayerMark(player, tongye.name, 0)
  end
end)

return tongye
