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
  anim_type = "switch",
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
      if not data.extraUse then
        player:addCardUseHistory(data.card.trueName, -1)
        data.extraUse = true
      end
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
    local targets = room:getOtherPlayers(player)
    room:doIndicate(player.id, table.map(targets, Util.IdMapper))

    for _, p in ipairs(targets) do
      if player.dead then break end
      if not p:isNude() then
        local ids = room:askForCard(p, 1, 1, true, self.name, true, ".", "#ofl_mou__yijue-give::" .. player.id)
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

local moujiangwei = General(extension, "ofl_mou__jiangwei", "shu", 4)
Fk:loadTranslationTable{
  ["ofl_mou__jiangwei"] = "谋姜维",
  ["#ofl_mou__jiangwei"] = "见危授命",
  ["illustrator:ofl_mou__jiangwei"] = "凝聚永恒",
  ["~ofl_mou__jiangwei"] = "这八阵天机，我也难以看破……",
}

local mouTiaoXin = fk.CreateActiveSkill{
  name = "ofl_mou__tiaoxin",
  anim_type = "control",
  prompt = "#ofl_mou__tiaoxin-active",
  min_target_num = 1,
  card_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and player.hp > 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    return #selected < Self.hp and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local targets = table.simpleClone(effect.tos)
    room:sortPlayersByAction(targets)
    for _, pId in ipairs(targets) do
      local to = room:getPlayerById(pId)
      if player:isAlive() and to:isAlive() then
        local slashHit
        local use = room:askForUseCard(
          to,
          "slash",
          "slash",
          "#ofl_mou__tiaoxin-slash::" .. player.id,
          true,
          { exclusive_targets = { player.id }, bypass_distances = true }
        )
        if use then
          room:useCard(use)
          slashHit = use.damageDealt
        end

        if player:isAlive() and to:isAlive() and not to:isNude() and not slashHit then
          local id = room:askForCardChosen(player, to, "he", self.name)
          room:obtainCard(player, id, false, fk.ReasonPrey, player.id, self.name)
        end
      end
    end
  end,
}
Fk:loadTranslationTable{
  ["ofl_mou__tiaoxin"] = "挑衅",
  [":ofl_mou__tiaoxin"] = "出牌阶段限一次，你可以令至多X名其他角色依次选择一项（X为你的体力值）：" ..
  "1.对你使用一张【杀】（无距离限制），然后若此【杀】未对你造成伤害，则你获得其一张牌；2.令你获得其一张牌。",
  ["#ofl_mou__tiaoxin-active"] = "挑衅：你可令多名其他角色选择是否对你出杀，若杀未造成伤害或未出杀，你获得其一张牌",
  ["#ofl_mou__tiaoxin-slash"] = "挑衅；你可对%dest出杀，若杀未造成伤害或你未出杀，则其获得你一张牌",

  ["$ofl_mou__tiaoxin1"] = "你就这点本领吗？哈哈哈哈哈~",
  ["$ofl_mou__tiaoxin2"] = "就你？不过如此！",
}

moujiangwei:addSkill(mouTiaoXin)

local mouZhiJi = fk.CreateTriggerSkill{
  name = "ofl_mou__zhiji",
  anim_type = "support",
  events = {fk.EnterDying},
  frequency = Skill.Wake,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  can_wake = function(self, event, target, player, data)
    return player.dying
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local diff = 2 - player.hp
    if diff > 0 then
      room:recover{
        who = player,
        num = diff,
        recoverBy = player,
        skillName = self.name,
      }
    end

    room:changeMaxHp(player, -1)
    if not player:isAlive() then
      return
    end

    room:handleAddLoseSkills(player, "ofl_mou__beifa")
    if not table.find(room.alive_players, function(p) return p:getHandcardNum() < player:getHandcardNum() end) then
      player:drawCards(2, self.name)
    end
  end,
}
Fk:loadTranslationTable{
  ["ofl_mou__zhiji"] = "志继",
  [":ofl_mou__zhiji"] = "觉醒技，当你进入濒死状态时，你将体力回复至2点，减1点体力上限并获得“北伐”，" ..
  "然后若你手牌数最少，则你摸两张牌。",
  ["#ofl_mou__tiaoxin-active"] = "挑衅：你可令多名其他角色选择是否对你出杀，若杀未造成伤害或未出杀，你获得其一张牌",
  ["#ofl_mou__tiaoxin-slash"] = "挑衅；你可对%dest出杀，若杀未造成伤害或你未出杀，则其获得你一张牌",

  ["$ofl_mou__zhiji1"] = "蜀汉大业，虽身小亦鼎力而为！",
  ["$ofl_mou__zhiji2"] = "丞相北伐大业未完，吾必尽力图之。",
}

moujiangwei:addSkill(mouZhiJi)

local mouBeiFa = fk.CreateActiveSkill{
  name = "ofl_mou__beifa",
  anim_type = "offensive",
  prompt = "#ofl_mou__beifa-active",
  target_num = 1,
  min_card_num = 1,
  can_use = function(self, player)
    return not player:isKongcheng() and player:usedSkillTimes(self.name, Player.HistoryPhase) < 20
  end,
  card_filter = function (self, to_select, selected)
    return not Self:prohibitDiscard(to_select) and Fk:currentRoom():getCardArea(to_select) == Card.PlayerHand
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and not Fk:currentRoom():getPlayerById(to_select):isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local to = room:getPlayerById(effect.tos[1])
    local toThrow = effect.cards
    room:throwCard(toThrow, self.name, player, player)

    local names = {}
    for _, id in ipairs(toThrow) do
      table.insertIfNeed(names, Fk:getCardById(id).trueName)
    end

    if not to:isKongcheng() then
      local ids
      if to:getHandcardNum() > #toThrow then
        ids = room:askForCard(to, #toThrow, #toThrow, false, self.name, false, ".", "#ofl_mou__beifa-display:" .. player.id)
      else
        ids = to:getCardIds("h")
      end

      to:showCards(ids)

      local sameNames = table.filter(
        ids,
        function(id)
          return
            table.contains(names, Fk:getCardById(id).trueName) and
            room:getCardArea(id) == Card.PlayerHand and
            room:getCardOwner(id) == to
        end
      )
      while #sameNames > 0 do
        if not (player:isAlive() and to:isAlive()) then
          break
        end

        if to ~= player then
          room:setPlayerMark(player, "ofl_mou__beifa_view", sameNames)
        end
    
        local extra_data = {bypass_times = true}
        local availableCards = {}
        for _, id in ipairs(sameNames) do
          local card = Fk:cloneCard("slash")
          card:addSubcard(id)
          if not player:prohibitUse(card) and player:canUse(card, extra_data) then
            table.insertIfNeed(availableCards, id)
          end
        end

        room:setPlayerMark(player, "ofl_mou__beifa_cards", availableCards)
        local success, dat = room:askForUseActiveSkill(
          player,
          "ofl_mou__beifa_viewas",
          "#ofl_mou__beifa-use",
          true,
          extra_data
        )
        room:setPlayerMark(player, "ofl_mou__beifa_view", 0)
        room:setPlayerMark(player, "ofl_mou__beifa_cards", 0)

        if not (success and dat) then
          break
        end

        local card = Fk.skills["ofl_mou__beifa_viewas"]:viewAs(dat.cards)
        room:useCard{
          from = player.id,
          tos = table.map(dat.targets, function(id) return { id } end),
          card = card,
          extraUse = true,
        }

        table.removeOne(sameNames, dat.cards[1])
        sameNames = table.filter(
          sameNames,
          function(id)
            return
              room:getCardArea(id) == Card.PlayerHand and
              room:getCardOwner(id) == to
          end
        )
      end
    end
  end,
}
local mouBeiFaViewas = fk.CreateViewAsSkill{
  name = "ofl_mou__beifa_viewas",
  expand_pile = function (self)
    return U.getMark(Self, "ofl_mou__beifa_view")
  end,
  card_filter = function(self, to_select, selected)
    if #selected == 0 then
      local ids = Self:getMark("ofl_mou__beifa_cards")
      return type(ids) == "table" and table.contains(ids, to_select)
    end
  end,
  view_as = function(self, cards)
    if #cards == 1 then
      local card = Fk:cloneCard("slash")
      card:addSubcards(cards)
      card.skillName = "ofl_mou__beifa"
      return card
    end
  end,
}
Fk:loadTranslationTable{
  ["ofl_mou__beifa"] = "北伐",
  [":ofl_mou__beifa"] = "出牌阶段，你可以弃置至少一张手牌，并令一名角色展示等量手牌，" ..
  "你可将展示牌中一张你本次弃置过的牌名的牌（须本流程中未以此法转化过且仍处于其手牌中）当无次数限制的【杀】使用，然后你可重复此转化流程。",
  ["#ofl_mou__beifa-active"] = "北伐：你可弃置任意手牌并令一名角色展示等量手牌，你可将其中弃置与展示同名的牌当【杀】使用",
  ["#ofl_mou__beifa-display"] = "北伐：你须展示等量牌，%src可将其中与其弃置的同名牌依次当【杀】使用",
  ["#ofl_mou__beifa-use"] = "北伐；你可将其中一张牌当无次数限制的【杀】使用",
  ["ofl_mou__beifa_viewas"] = "北伐",
  ["ofl_mou__beifa_view"] = "北伐",

  ["$ofl_mou__beifa1"] = "",
  ["$ofl_mou__beifa2"] = "",
}

Fk:addSkill(mouBeiFaViewas)
moujiangwei:addRelatedSkill(mouBeiFa)

local moumenghuo = General(extension, "ofl_mou__menghuo", "shu", 4)
Fk:loadTranslationTable{
  ["ofl_mou__menghuo"] = "谋孟获",
  ["#ofl_mou__menghuo"] = "南蛮王",
  ["illustrator:ofl_mou__menghuo"] = "石琨",
  ["~ofl_mou__menghuo"] = "南中子弟，有死无降！",
}

local mouHuoShou = fk.CreateTriggerSkill{
  name = "ofl_mou__huoshou",
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  events = {fk.PreCardEffect, fk.TargetSpecified, fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    if event == fk.PreCardEffect then
      return player.id == data.to and player:hasSkill(self) and data.card.trueName == "savage_assault"
    elseif event == fk.TargetSpecified then
      return target ~= player and data.firstTarget and player:hasSkill(self) and data.card.trueName == "savage_assault"
    end

    return player == target and player:hasSkill(self) and player.phase == Player.Play
  end,
  on_use = function(self, event, target, player, data)
    if event == fk.PreCardEffect then
      return true
    elseif event == fk.TargetSpecified then
      data.extra_data = data.extra_data or {}
      data.extra_data.oflMouHuoShou = player.id
    else
      local room = player.room
      room:throwCard(player:getCardIds("h"), self.name, player, player)
      room:useCard{
        from = player.id,
        card = Fk:cloneCard("savage_assault"),
      }
    end
  end,

  refresh_events = {fk.PreDamage},
  can_refresh = function(self, event, target, player, data)
    if data.card and data.card.trueName == "savage_assault" then
      local e = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
      if e then
        local use = e.data[1]
        return use.extra_data and use.extra_data.oflMouHuoShou
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local e = room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
    if e then
      local use = e.data[1]
      data.from = room:getPlayerById(use.extra_data.oflMouHuoShou)
    end
  end,
}
Fk:loadTranslationTable{
  ["ofl_mou__huoshou"] = "祸首",
  [":ofl_mou__huoshou"] = "锁定技，【南蛮入侵】对你无效；当其他角色使用【南蛮入侵】指定第一个目标后，你代替其成为伤害来源；" ..
  "出牌阶段结束时，你弃置所有手牌，视为使用一张【南蛮入侵】。",

  ["$ofl_mou__huoshou1"] = "蛮人世居两川之地，岂会屈居汉人之下！",
  ["$ofl_mou__huoshou2"] = "吾等，定要守护这南中乐土！",
}

moumenghuo:addSkill(mouHuoShou)

local mouZaiQi = fk.CreateTriggerSkill{
  name = "ofl_mou__zaiqi",
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and player.phase == Player.Discard then
      local room = player.room
      local turn_event = room.logic:getCurrentEvent():findParent(GameEvent.Turn)
      if turn_event == nil then return false end

      return #U.getEventsByRule(room, GameEvent.MoveCards, 1, function (e)
        for _, move in ipairs(e.data) do
          if move.toArea == Card.DiscardPile and move.moveReason == fk.ReasonDiscard and move.proposer == player.id then
            return true
          end
        end
        return false
      end, turn_event.id) > 0
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room

    local ids = {}
    room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
      for _, move in ipairs(e.data) do
        if move.toArea == Card.DiscardPile and move.moveReason == fk.ReasonDiscard and move.proposer == player.id then
          for _, info in ipairs(move.moveInfo) do
            table.insertIfNeed(ids, info.cardId)
          end
        end
      end
      return false
    end, Player.HistoryTurn)

    local x = #ids
    local result = room:askForChoosePlayers(
      player,
      table.map(room.alive_players, Util.IdMapper),
      1,
      x,
      "#ofl_mou__zaiqi-choose:::" .. x,
      self.name,
      true
    )
    if #result > 0 then
      self.cost_data = result
      return true
    end

    return false
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:sortPlayersByAction(self.cost_data)
    local targets = table.map(self.cost_data, function(id) return room:getPlayerById(id) end)
    for _, p in ipairs(targets) do
      if not player:isAlive() then
        break
      end

      if p:isAlive() then
        local recover = false
        if player:isWounded() and not p:isNude() then
          local ids = room:askForDiscard(p, 1, 1, true, self.name, true, ".", "#ofl_mou__zaiqi-discard:" .. player.id)
          if #ids > 0 then
            room:recover({
              who = player,
              num = 1,
              recoverBy = p,
              skillName = self.name
            })
          end
        end

        if not recover then
          player:drawCards(1, self.name)
        end
      end
    end
  end,
}
Fk:loadTranslationTable{
  ["ofl_mou__zaiqi"] = "再起",
  [":ofl_mou__zaiqi"] = "弃牌阶段结束时，你可以令至多X名角色依次选择一项（X为你本回合弃置过的牌数）：" ..
  "1.令你摸一张牌；2.弃置一张牌并令你回复1点体力。",
  ["#ofl_mou__zaiqi-choose"] = "再起：你可选择至多%arg名角色，令他们选择令你摸牌或弃牌令你回血",
  ["#ofl_mou__zaiqi-discard"] = "再起：你可弃置一张牌令%src回复1点体力，否则其摸一张牌",

  ["$ofl_mou__zaiqi1"] = "山辟路窄，误遭汝手，如何肯服？",
  ["$ofl_mou__zaiqi2"] = "待我重整兵马，来日一决雌雄！",
}

moumenghuo:addSkill(mouZaiQi)

local mousunquan = General(extension, "ofl_mou__sunquan", "wu", 4)
Fk:loadTranslationTable{
  ["ofl_mou__sunquan"] = "谋孙权",
  ["#ofl_mou__sunquan"] = "江东大帝",
  ["illustrator:ofl_mou__sunquan"] = "陈层",
  ["~ofl_mou__sunquan"] = "天下一统，吾终不可得乎……",
}

local mouZhiHeng = fk.CreateActiveSkill{
  name = "ofl_mou__zhiheng",
  anim_type = "drawcard",
  prompt = "#ofl_mou__zhiheng-active",
  target_num = 0,
  min_card_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function (self, to_select, selected)
    return not Self:prohibitDiscard(to_select)
  end,
  target_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local drawNum = #effect.cards
    if table.find(player:getCardIds("e"), function(id) return table.contains(effect.cards, id) end) then
      drawNum = drawNum + 1
    end

    room:throwCard(effect.cards, self.name, player, player)
    player:drawCards(drawNum, self.name)
  end,
}
Fk:loadTranslationTable{
  ["ofl_mou__zhiheng"] = "制衡",
  [":ofl_mou__zhiheng"] = "出牌阶段限一次，你可以弃置至少一张牌，然后摸等量的牌，若你以此法弃置了装备区里的牌，则你多摸一张牌。",
  ["#ofl_mou__zhiheng-active"] = "制衡：你可弃置任意牌并摸等量牌，若你弃置装备区里的牌，则多摸一张",

  ["$ofl_mou__zhiheng1"] = "权者万变，非制衡不可取之。",
  ["$ofl_mou__zhiheng2"] = "内制朝臣乱政，外衡天下时局。",
}

mousunquan:addSkill(mouZhiHeng)

local mouTongYe = fk.CreateTriggerSkill{
  name = "ofl_mou__tongye",
  frequency = Skill.Compulsory,
  refresh_events = {fk.AfterDrawPileShuffle, fk.EventAcquireSkill, fk.EventLoseSkill},
  can_refresh = function(self, event, target, player, data)
    if event == fk.AfterDrawPileShuffle then
      return player:hasSkill(self, true)
    end

    return
      target == player and
      data == self and
      not (fk.EventAcquireSkill and player:getMark("ofl_mou__tongye_shuffled") > 0)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.AfterDrawPileShuffle then
      room:setPlayerMark(player, "ofl_mou__tongye_shuffled", 1)
      room:handleAddLoseSkills(player, "-mou__yingzi|-guzheng")
    elseif event == fk.EventAcquireSkill then
      room:handleAddLoseSkills(player, "mou__yingzi|guzheng")
    else
      room:handleAddLoseSkills(player, "-mou__yingzi|-guzheng")
    end
  end,
}
Fk:loadTranslationTable{
  ["ofl_mou__tongye"] = "统业",
  [":ofl_mou__tongye"] = "锁定技，若本局游戏牌堆未洗过牌，则你视为拥有“英姿”和“固政”。",
}

mousunquan:addSkill(mouTongYe)
mousunquan:addRelatedSkill("mou__yingzi")
mousunquan:addRelatedSkill("guzheng")

local mouJiuYuan = fk.CreateActiveSkill{
  name = "ofl_mou__jiuyuan$",
  anim_type = "control",
  prompt = "#ofl_mou__jiuyuan-active",
  target_num = 1,
  card_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function (self, to_select, selected)
    if #selected > 0 or Self.id == to_select then
      return false
    end
    local to = Fk:currentRoom():getPlayerById(to_select)
    return to.kingdom == "wu" and #to:getCardIds("e") > 0
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:obtainCard(player, room:getPlayerById(effect.tos[1]):getCardIds("e"), true, fk.ReasonPrey, player.id, self.name)
    room:recover{
      who = player,
      num = 1,
      recoverBy = player,
      skillName = self.name,
    }
  end,
}
Fk:loadTranslationTable{
  ["ofl_mou__jiuyuan"] = "救援",
  [":ofl_mou__jiuyuan"] = "主公技，出牌阶段限一次，你可以获得一名其他吴势力角色装备区里的所有牌，然后你回复1点体力。",
  ["#ofl_mou__jiuyuan-active"] = "救援：你可以获得一名其他吴势力角色装备区里的所有牌，然后你回复1点体力",

  ["$ofl_mou__jiuyuan1"] = "援军何在？诸将速速回转！",
  ["$ofl_mou__jiuyuan2"] = "若无将军舍命，吾安可无伤而返。",
}

mousunquan:addSkill(mouJiuYuan)

return extension
