local jiwei = fk.CreateSkill {
  name = "ofl__jiwei",
  tags = { Skill.Wake },
}

Fk:loadTranslationTable{
  ["ofl__jiwei"] = "继魏",
  [":ofl__jiwei"] = "觉醒技，每个回合结束时，若你本轮发动〖技新〗次数不小于一号位当前体力值，你加1点体力上限，回复体力至体力上限，"..
  "选择获得5个魏势力武将的主公技。",

  ["#ofl__jiwei-choice"] = "继魏：获得5个魏势力主公技",
}

jiwei:addEffect(fk.TurnEnd, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(jiwei.name) and
      player:usedSkillTimes(jiwei.name, Player.HistoryGame) == 0
  end,
  can_wake = function (self, event, target, player, data)
    return player:usedSkillTimes("ofl__jixin", Player.HistoryRound) >= player.room:getPlayerBySeat(1).hp
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, 1)
    if player.dead then return end
    if player:isWounded() then
      room:recover{
        who = player,
        num = player.maxHp - player.hp,
        recoverBy = player,
        skillName = jiwei.name,
      }
      if player.dead then return end
    end
    local skills, generals = {}, {}
    for _, g in ipairs(Fk:getAllGenerals()) do
      if g.kingdom == "wei" or g.subkingdom == "wei" then
        for _, sname in ipairs(g:getSkillNameList(true)) do
          local s = Fk.skills[sname]
          if s and s:hasTag(Skill.Lord) and not player:hasSkill(s, true) and table.insertIfNeed(skills, sname) then
            table.insert(generals, g.name)
          end
        end
      end
    end
    if #skills == 0 then return end
    if #skills > 5 then
      local result = room:askToCustomDialog(player, {
        skill_name = "qyt__guixin",
        qml_path = "packages/utility/qml/ChooseSkillBox.qml",
        extra_data = {
          skills, 5, 5, "#ofl__jiwei-choice", generals
        },
      })
      if result ~= "" then
        skills = json.decode(result)
      else
        skills = table.random(skills, 5)
      end
    end
    room:handleAddLoseSkills(player, skills)
  end,
})

return jiwei
