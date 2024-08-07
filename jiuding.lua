local extension = Package("jiuding")
extension.extensionName = "offline"

local U = require "packages/utility/utility"

Fk:loadTranslationTable{
  ["jiuding"] = "线下-九鼎",
}

local simayan = General(extension, "simayan", "jin", 3)
Fk:loadTranslationTable{
  ["simayan"] = "司马炎",
  ["#simayan"] = "晋武帝",
  -- ["illustrator:simayan"] = "",
  -- ["~simayan"] = "",
}

local juqi = fk.CreateTriggerSkill{
  name = "juqi",
  events = {fk.EventPhaseStart},
  anim_type = "support",
  switch_skill_name = "juqi",
  can_trigger = function(self, event, target, player, data)
    return
      player:hasSkill(self) and
      target.phase == Player.Start and
      not (
        target ~= player and
        target:isKongcheng()
      )
  end,
  on_cost = function(self, event, target, player, data)
    if target ~= player then
      local room = player.room
      local suits = player:getSwitchSkillState(self.name) == fk.SwitchYin and "diamond,heart" or "club,spade"
      local ids = room:askForCard(target, 1, 1, false, self.name, true, ".|.|" .. suits, "#juqi-give::" .. player.id)
      if #ids == 0 then
        return false
      end

      self.cost_data = ids
    end

    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if target ~= player then
      target:showCards(self.cost_data)
      room:obtainCard(player, self.cost_data, true, fk.ReasonGive, target.id, self.name)
    else
      if player:getSwitchSkillState(self.name, true) == fk.SwitchYin then
        room:setPlayerMark(player, "@@juqi-turn", 1)
      else
        player:drawCards(3, self.name)
      end
    end
  end,
}
local juqiOffensive = fk.CreateTriggerSkill{
  name = "#juqi_offensive",
  events = {fk.DamageCaused},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@@juqi-turn") > 0 and data.card
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage + 1
  end,
}
local juqiBuff = fk.CreateTargetModSkill{
  name = "#juqi_buff",
  bypass_times = function(self, player, skill, scope, card, to)
    return player:getMark("@@juqi-turn") > 0
  end,
}
Fk:loadTranslationTable{
  ["juqi"] = "举棋",
  [":juqi"] = "转换技，阳：准备阶段开始时，你摸三张牌/其他角色的准备阶段开始时，其可以展示并交给你一张黑色手牌；" ..
  "阴：准备阶段开始时，令你本回合使用牌无次数限制且造成的伤害+1/其他角色的准备阶段开始时，其可以展示并交给你一张红色手牌。",
  ["#juqi_offensive"] = "举棋",
  ["@@juqi-turn"] = "举棋 进攻",
  ["#juqi-give"] = "举棋：你可以交给%dest一张对应颜色的手牌，切换其“举棋”状态",
}

juqi:addRelatedSkill(juqiOffensive)
juqi:addRelatedSkill(juqiBuff)
simayan:addSkill(juqi)

local fengtu = fk.CreateTriggerSkill{
  name = "fengtu",
  events = {fk.Deathed},
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return
      target ~= player and
      player:hasSkill(self) and
      target.rest == 0 and
      table.find(player.room.alive_players, function(p) return p:getMark("fengtu_lost") == 0 end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function(p) return p:getMark("fengtu_lost") == 0 end)
    local tos = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 1, "#fengtu-choose:::" .. target.seat, self.name)
    if #tos > 0 then
      self.cost_data = tos[1]
      return true
    end

    return false
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    if not to:isAlive() then
      return false
    end

    local effected = room:changeMaxHp(to, -1)
    if effected then
      room:setPlayerMark(to, "fengtu_lost", 1)
    end

    local seats = U.getMark(to, "@fengtu")
    table.insertIfNeed(seats, target.seat)
    room:setPlayerMark(to, "@fengtu", seats)
  end,

  refresh_events = {fk.EventTurnChanging},
  can_refresh = function (self, event, target, player, data)
    local room = player.room
    if player ~= room.players[1] then
      return false
    end

    if room:getTag("fengtuTurn") then
      return true
    end

    local current = data.from
    repeat
      local next = current.next
      if not next.dead then
        break
      end

      if table.find(room.alive_players, function(p) return table.contains(U.getMark(p, "@fengtu"), next.seat) end) then
        return true
      end

      current = next
    until current == data.to

    return false
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    if room:getTag("fengtuTurn") then
      local realSeat = room:getTag("fengtuTurn")
      local realTurnOwner = table.find(room.players, function(p) return p.seat == realSeat end)
      room:removeTag("fengtuTurn")
      if realTurnOwner then
        local current = realTurnOwner
        repeat
          local next = current.next
          if not next.dead then
            break
          end
    
          local newNextCurrent = table.find(room.alive_players, function(p) return table.contains(U.getMark(p, "@fengtu"), next.seat) end)
          if newNextCurrent then
            data.to = newNextCurrent
            data.skipRoundPlus = realSeat < next.seat
            room:setTag("fengtuTurn", next.seat)
            return false
          end
  
          current = next
        until current == data.to

        local nextPlayer = realTurnOwner:getNextAlive(true, nil, true)
        data.to = nextPlayer
        data.skipRoundPlus = realSeat < nextPlayer.seat
      end
    else
      local current = data.from
      repeat
        local next = current.next
        if not next.dead then
          break
        end
  
        local newNextCurrent = table.find(room.alive_players, function(p) return table.contains(U.getMark(p, "@fengtu"), next.seat) end)
        if newNextCurrent then
          data.to = newNextCurrent
          data.skipRoundPlus = data.from.seat < next.seat
          room:setTag("fengtuTurn", next.seat)
          break
        end

        current = next
      until current == data.to
    end
  end,
}
Fk:loadTranslationTable{
  ["fengtu"] = "封土",
  [":fengtu"] = "当其他角色死亡后，若其未处于休整状态，则你可以令一名未以此法扣减过体力上限的角色减1点体力上限，" ..
  "然后其获得死亡角色座次每轮的额定回合。",
  ["@fengtu"] = "封土",
  ["#fengtu-choose"] = "封土：你可令其中一名角色减1体力上限并获得%arg号位的额定回合",
}

simayan:addSkill(fengtu)

local taishi = fk.CreateTriggerSkill{
  name = "taishi$",
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
  [":taishi"] = "主公技，一名角色的回合开始前，你可以令所有隐匿角色依次登场。",
}

simayan:addSkill(taishi)

return extension
