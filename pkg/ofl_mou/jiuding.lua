
local taishi = fk.CreateTriggerSkill{
  name = "taishi",
  priority = 2,
  events = {fk.TurnStart},
  frequency = Skill.Limited,
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return
      player:hasSkill(self) and
      player:usedSkillTimes(self.name, Player.HistoryGame) == 0 and
      table.find(
        player.room.alive_players,
        function(p) return p:getMark("__hidden_general") ~= 0 or p:getMark("__hidden_deputy") ~= 0 end
      )
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room:getAlivePlayers()) do
      if p:getMark("__hidden_general") ~= 0 or p:getMark("__hidden_deputy") ~= 0 then
        room:handleAddLoseSkills(p, "-hidden_skill&", nil, false, true)
        if Fk.generals[p:getMark("__hidden_general")] then
          p.general = p:getMark("__hidden_general")
        end
        if Fk.generals[p:getMark("__hidden_deputy")] then
          p.deputyGeneral = p:getMark("__hidden_deputy")
        end
        room:setPlayerMark(p, "__hidden_general", 0)
        room:setPlayerMark(p, "__hidden_deputy", 0)
        local general = Fk.generals[p.general]
        local deputy = Fk.generals[p.deputyGeneral]
        p.gender = general.gender
        p.kingdom = general.kingdom
        room:broadcastProperty(p, "gender")
        room:broadcastProperty(p, "general")
        room:broadcastProperty(p, "deputyGeneral")
        room:askForChooseKingdom({p})
        room:broadcastProperty(p, "kingdom")
        
        p.maxHp = p:getGeneralMaxHp()
        p.hp = deputy and math.floor((deputy.hp + general.hp) / 2) or general.hp
        p.shield = math.min(general.shield + (deputy and deputy.shield or 0), 5)
        local changer = Fk.game_modes[room.settings.gameMode]:getAdjustedProperty(p)
        if changer then
          for key, value in pairs(changer) do
            p[key] = value
          end
        end
        room:broadcastProperty(p, "maxHp")
        room:broadcastProperty(p, "hp")
        room:broadcastProperty(p, "shield")

        local lordBuff = p.role == "lord" and p.role_shown == true and #room.players > 4
        local skills = general:getSkillNameList(lordBuff)
        if deputy then
          table.insertTable(skills, deputy:getSkillNameList(lordBuff))
        end
        skills = table.filter(skills, function (s)
          local skill = Fk.skills[s]
          return skill and (#skill.attachedKingdom == 0 or table.contains(skill.attachedKingdom, p.kingdom))
        end)
        if #skills > 0 then
          room:handleAddLoseSkills(p, table.concat(skills, "|"), nil, false)
        end

        room:sendLog{ type = "#RevealGeneral", from = p.id, arg =  "mainGeneral", arg2 = general.name }
        local event_data = {["m"] = general}
        if deputy then
          room:sendLog{ type = "#RevealGeneral", from = p.id, arg =  "deputyGeneral", arg2 = deputy.name }
          event_data["d"] = deputy.name
        end
        room.logic:trigger("fk.GeneralAppeared", p, event_data)
      end
    end
  end,
}
Fk:loadTranslationTable{
  ["taishi"] = "泰始",
  [":taishi"] = "主公技，限定技，一名角色的回合开始前，你可以令所有隐匿角色依次登场。",
}

Fk:loadTranslationTable{
  ["ofl_wende__huaxin"] = "华歆",
  ["#ofl_wende__huaxin"] = "渊清玉洁",
  ["illustrator:ofl_wende__huaxin"] = "",

  ["ofl_wende__caozhao"] = "草诏",
  [":ofl_wende__caozhao"] = "每轮限一次，体力值不大于你的其他角色出牌阶段开始时，你可以展示其一张手牌并声明一种未以此法声明过的基本牌或"..
  "普通锦囊牌，令其选择选择一项：1.将此牌当你声明的牌使用；2.失去1点体力。",
}

Fk:loadTranslationTable{
  ["fhyx__hanlong"] = "韩龙",
  ["#fhyx__hanlong"] = "碧落玄鹄",
  ["designer:fhyx__hanlong"] = "雾燎鸟",
  ["illustrator:fhyx__hanlong"] = "",

  ["ofl__cibei"] = "刺北",
  [":ofl__cibei"] = "当【杀】使用结算结束后，若此【杀】造成过伤害，你可以将此【杀】与一张不为【杀】的“刺”交换，然后弃置一名角色区域内的一张牌。"..
  "一名角色的回合结束时，若所有“刺”均为【杀】，你获得所有“刺”，然后本局游戏你获得以下效果：你使用【杀】无距离次数限制；每回合结束时，你获得"..
  "弃牌堆中你本回合被弃置的所有【杀】。",
}
