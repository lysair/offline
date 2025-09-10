local linze = fk.CreateSkill {
  name = "linze",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["linze"] = "麟择",
  [":linze"] = "锁定技，若你的体力值减已损失体力值：不小于0，你视为拥有〖挑衅〗；不大于0，你视为拥有〖困奋〗。",

  ["$linze1"] = "",
  ["$linze2"] = "",
}

local spec = {
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(linze.name, true)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local skills = ""
    if player.hp - player:getLostHp() >= 0 then
      if not player:hasSkill("m_ex__tiaoxin", true) then
        skills = "m_ex__tiaoxin"
      end
    else
      if player:hasSkill("m_ex__tiaoxin", true) then
        skills = "-m_ex__tiaoxin"
      end
    end
    if player.hp - player:getLostHp() <= 0 then
      if not player:hasSkill("kunfenEx", true) then
        if skills == "" then
          skills = "kunfenEx"
        else
          skills = skills.."|kunfenEx"
        end
      end
    else
      if player:hasSkill("kunfenEx", true) then
        if skills == "" then
          skills = "-kunfenEx"
        else
          skills = skills.."|-kunfenEx"
        end
      end
    end
    if skills ~= "" then
      player:broadcastSkillInvoke(linze.name)
      room:handleAddLoseSkills(player, skills, nil, false, true)
    end
  end,
}

linze:addEffect(fk.HpChanged, spec)
linze:addEffect(fk.MaxHpChanged, spec)

linze:addAcquireEffect(function (self, player, is_death)
  local room = player.room
  local skills = ""
  if player.hp - player:getLostHp() >= 0 and not player:hasSkill("m_ex__tiaoxin", true) then
    skills = "m_ex__tiaoxin"
  end
  if player.hp - player:getLostHp() <= 0 and not player:hasSkill("kunfenEx", true) then
    skills = skills.."|kunfenEx"
  end
  if skills ~= "" then
    player:broadcastSkillInvoke(linze.name)
    room:handleAddLoseSkills(player, skills, nil, false, true)
  end
end)

linze:addLoseEffect(function (self, player, is_death)
  player.room:handleAddLoseSkills(player, "-m_ex__tiaoxin|-kunfenEx")
end)

return linze
