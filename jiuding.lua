local extension = Package("jiuding")
extension.extensionName = "offline"

local U = require "packages/utility/utility"

Fk:loadTranslationTable{
  ["jiuding"] = "线下-九鼎",
  ["ofl_mou"] = "线下谋攻篇",
}

local simayan = General(extension, "simayan", "jin", 3)
Fk:loadTranslationTable{
  ["simayan"] = "司马炎",
  ["#simayan"] = "晋武帝",
  ["illustrator:simayan"] = "鬼画府",
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
  [":taishi"] = "主公技，限定技，一名角色的回合开始前，你可以令所有隐匿角色依次登场。",
}

simayan:addSkill(taishi)

local mouguanyu = General(extension, "ofl_mou__guanyu", "shu", 4)
Fk:loadTranslationTable{
  ["ofl_mou__guanyu"] = "谋关羽",
  ["#ofl_mou__guanyu"] = "关圣帝君",
  ["illustrator:ofl_mou__guanyu"] = "鬼画府",
  ["~ofl_mou__guanyu"] = "大哥知遇之恩，云长来世再报了……",
}

local mouWuSheng = fk.CreateViewAsSkill{
  name = "ofl_mou__wusheng",
  pattern = "slash",
  card_num = 1,
  card_filter = function(self, to_select, selected)
    if #selected == 1 or Fk:currentRoom():getCardArea(to_select) ~= Player.Hand then return false end
    local c = Fk:cloneCard("slash")
    return (Fk.currentResponsePattern == nil and Self:canUse(c)) or
      (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(c))
  end,
  interaction = function(self)
    local allCardNames = {}
    for _, id in ipairs(Fk:getAllCardIds()) do
      local card = Fk:getCardById(id)
      if
        not table.contains(allCardNames, card.name) and
        card.trueName == "slash" and
        (
          (Fk.currentResponsePattern == nil and Self:canUse(card)) or
          (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(card))
        ) and
        not Self:prohibitUse(card) then
        table.insert(allCardNames, card.name)
      end
    end
    return UI.ComboBox { choices = allCardNames }
  end,
  view_as = function(self, cards)
    local choice = self.interaction.data
    if not choice or #cards ~= 1 then return end
    local c = Fk:cloneCard(choice)
    c:addSubcards(cards)
    c.skillName = self.name
    return c
  end,
  enabled_at_play = function(self, player)
    return player:canUse(Fk:cloneCard("slash"))
  end,
  enabled_at_response = function(self, player)
    return Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(Fk:cloneCard("slash"))
  end,
}
local mouWuShengTrigger = fk.CreateTriggerSkill{
  name = "#ofl_mou__wusheng_trigger",
  anim_type = "offensive",
  main_skill = mouWuSheng,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    local room = player.room

    return
      target == player and
      player:hasSkill("ofl_mou__wusheng") and
      player.phase == Player.Play and
      table.find(room.alive_players, function(p) return not p:isKongcheng() end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player), function(p)
      return not p:isKongcheng()
    end)

    if #targets then
      local tos = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 1, "#ofl_mou__wusheng-choose", self.name)
      if #tos > 0 then
        self.cost_data = tos[1]
        player:broadcastSkillInvoke("ofl_mou__wusheng")
        return true
      end
    end

    return false
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)

    to:showCards(to:getCardIds("h"))

    local reds = table.filter(to:getCardIds("h"), function(id) return Fk:getCardById(id).color == Card.Red end)
    if #reds == 0 then
      return false
    end

    room:setPlayerMark(to, "@ofl_mou__wusheng-phase", #reds)
    room:setPlayerMark(player, "ofl_mou__wusheng_from-phase", 1)
  end,
}
local mouWuShengTargetMod = fk.CreateTargetModSkill{
  name = "#ofl_mou__wusheng_targetmod",
  bypass_times = function(self, player, skill, scope, card, to)
    return
      card and
      card.trueName == "slash" and
      player:getMark("ofl_mou__wusheng_from-phase") > 0 and
      to and
      to:getMark("@ofl_mou__wusheng-phase") ~= 0
  end,
  bypass_distances = function(self, player, skill, card, to)
    return
      card and
      card.trueName == "slash" and
      player:getMark("ofl_mou__wusheng_from-phase") > 0 and
      to and
      to:getMark("@ofl_mou__wusheng-phase") ~= 0
  end,
}
local mouWuShengBuff = fk.CreateTriggerSkill{
  name = "#ofl_mou__wusheng_buff",
  mute = true,
  events = {fk.CardUsing, fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    if event == fk.CardUsing then
      return
        target == player and
        data.card.trueName == "slash" and
        table.find(
          TargetGroup:getRealTargets(data.tos),
          function(pId)
            local to = player.room:getPlayerById(pId)
            return to:isAlive() and to:getMark("@ofl_mou__wusheng-phase") > 0
          end
        )
    end

    return data.card.trueName == "slash" and (data.extra_data or {}).oflMouWuShengUser == player.id
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.CardUsing then
      local targets = table.filter(
        TargetGroup:getRealTargets(data.tos),
        function(pId)
          local to = player.room:getPlayerById(pId)
          return to:isAlive() and to:getMark("@ofl_mou__wusheng-phase") > 0
        end
      )

      for _, pId in ipairs(targets) do
        room:removePlayerMark(room:getPlayerById(pId), "@ofl_mou__wusheng-phase")
      end

      player:addCardUseHistory(data.card.trueName, -1)
      data.extra_data = data.extra_data or {}
      data.extra_data.oflMouWuShengUser = player.id
    else
      player:drawCards(1, self.name)
    end
  end,
}
Fk:loadTranslationTable{
  ["ofl_mou__wusheng"] = "武圣",
  [":ofl_mou__wusheng"] = "你可以将一张手牌当任意【杀】使用或打出；出牌阶段开始时，你可以令一名其他角色展示所有手牌，" ..
  "然后你此阶段对其使用前X张【杀】无距离次数限制且结算结束后摸一张牌（X为其以此法展示牌中的红色牌数）。",
  ["#ofl_mou__wusheng_trigger"] = "武圣",
  ["#ofl_mou__wusheng-choose"] = "武圣：你可令一名其他角色展示手牌，根据其中红色牌数此阶段为你前等量张【杀】提供增益",
  ["@ofl_mou__wusheng-phase"] = "武圣",

  ["$ofl_mou__wusheng1"] = "敌酋虽勇，亦非关某一合之将！",
  ["$ofl_mou__wusheng2"] = "酒且斟下，关某片刻便归。",
  ["$ofl_mou__wusheng3"] = "煮酒待温方适饮！",
}

mouWuSheng:addRelatedSkill(mouWuShengTrigger)
mouWuSheng:addRelatedSkill(mouWuShengTargetMod)
mouWuSheng:addRelatedSkill(mouWuShengBuff)
mouguanyu:addSkill(mouWuSheng)

local mouYiJue = fk.CreateTriggerSkill{
  name = "ofl_mou__yijue",
  anim_type = "control",
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return
      target == player and
      player.phase == Player.Start and
      player:hasSkill(self) and
      table.find(player.room.alive_players, function(p) return player ~= p and not p:isNude() end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function(p) return player ~= p and not p:isNude() end)
    room:doIndicate(player.id, table.map(targets, Util.IdMapper))

    for _, p in ipairs(targets) do
      if not p:isKongcheng() then
        local ids = room:askForCard(p, 1, 1, false, self.name, true, ".", "#ofl_mou__yijue-give::" .. player.id)
        if #ids > 0 then
          room:setPlayerMark(p, "@@ofl_mou__yijue-turn", player.id)
          room:obtainCard(player, ids, false, fk.ReasonGive, p.id, self.name)
        end
      end
    end
  end,
}
local mouYiJueDebuff = fk.CreateTriggerSkill{
  name = "#ofl_mou__yijue_debuff",
  anim_type = "negative",
  events = {fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    local yijueUser = target:getMark("@@ofl_mou__yijue-turn")
    return
      yijueUser ~= 0 and
      data.from == player and
      player.id == yijueUser and
      data.card and
      data.card.trueName == "slash"
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("ofl_mou__yijue")
    room:setPlayerMark(target, "@@ofl_mou__yijue-turn", 0)
    return true
  end,
}
Fk:loadTranslationTable{
  ["ofl_mou__yijue"] = "义绝",
  [":ofl_mou__yijue"] = "锁定技，准备阶段开始时，你令所有其他角色依次选择是否交给你一张牌，" ..
  "以此法交给你牌的角色本回合首次受到你【杀】造成的伤害时，你防止此伤害。",
  ["#ofl_mou__yijue_debuff"] = "义绝",
  ["#ofl_mou__yijue-give"] = "义绝；你可交给%dest一张牌，防止其本回合使用【杀】对你造成的首次伤害",
  ["@@ofl_mou__yijue-turn"] = "义绝",

  ["$ofl_mou__yijue1"] = "大丈夫处事，只以忠义为先。",
  ["$ofl_mou__yijue2"] = "马行忠魂路，刀斩不义敌！",
}

mouYiJue:addRelatedSkill(mouYiJueDebuff)
mouguanyu:addSkill(mouYiJue)

return extension
