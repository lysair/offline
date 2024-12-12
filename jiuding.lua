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

    local seats = to:getTableMark("@fengtu")
    table.insertIfNeed(seats, target.seat)
    room:setPlayerMark(to, "@fengtu", seats)
  end,

  refresh_events = {fk.EventTurnChanging},
  can_refresh = function (self, event, target, player, data)
    return table.contains(player:getTableMark("@fengtu"), data.to.seat)
  end,
  on_refresh = function (self, event, target, player, data)
    player:gainAnExtraTurn(false, "game_rule")
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
    return Self:getTableMark("ofl_mou__beifa_view")
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

      return #room.logic:getEventsByRule(GameEvent.MoveCards, 1, function (e)
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
    local targets = table.map(self.cost_data, Util.Id2PlayerMapper)
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

local fhyx_pile = {
  {"slash", Card.Club, 4},
  {"thunder__slash", Card.Spade, 4},
  {"fire__slash", Card.Heart, 4},
  {"jink", Card.Diamond, 2},
  {"peach", Card.Heart, 6},
  {"analeptic", Card.Spade, 9},
  {"ex_nihilo", Card.Heart, 8},
  {"amazing_grace", Card.Heart, 4},
  {"dismantlement", Card.Spade, 3},
  {"snatch", Card.Diamond, 3},
  {"fire_attack", Card.Diamond, 2},
  {"duel", Card.Diamond, 1},
  {"savage_assault", Card.Spade, 13},
  {"archery_attack", Card.Heart, 1},
  {"nullification", Card.Heart, 13},
  {"indulgence", Card.Heart, 6},
  {"supply_shortage", Card.Spade, 10},
  {"iron_chain", Card.Club, 12},
  {"lightning", Card.Heart, 12},
  {"collateral", Card.Club, 13},
  {"god_salvation", Card.Heart, 1},
  {"eight_diagram", Card.Spade, 2},
  {"nioh_shield", Card.Club, 2},
  {"vine", Card.Spade, 2},
  {"silver_lion", Card.Club, 1},
  {"dilu", Card.Club, 5},
  {"chitu", Card.Heart, 5},
  {"dayuan", Card.Spade, 13},
  {"zixing", Card.Diamond, 13},
  {"hualiu", Card.Diamond, 13},
  {"zhuahuangfeidian", Card.Heart, 13},
  {"jueying", Card.Spade, 5},
  {"crossbow", Card.Diamond, 1},
  {"qinggang_sword", Card.Spade, 6},
  {"guding_blade", Card.Spade, 1},
  {"ice_sword", Card.Spade, 2},
  {"double_swords", Card.Spade, 2},
  {"blade", Card.Spade, 5},
  {"spear", Card.Spade, 12},
  {"axe", Card.Diamond, 5},
  {"fan", Card.Diamond, 1},
  {"halberd", Card.Diamond, 12},
  {"kylin_bow", Card.Heart, 5},
  {"role__wooden_ox", Card.Diamond, 5},
}
local function PrepareExtraPile(room)
  if room.tag["fhyx_extra_pile"] then return end
  local all_names = {}
  for _, card in ipairs(Fk.cards) do
    if not table.contains(room.disabled_packs, card.package.name) and not card.is_derived then
      table.insertIfNeed(all_names, card.name)
    end
  end
  local cards = {}
  for _, name in ipairs(all_names) do
    local c = table.filter(fhyx_pile, function(card)
      return card[1] == name
    end)
    if #c > 0 then
      table.insert(cards, c[1])
    else
      table.insert(cards, {name, math.random(1, 4), math.random(1, 13)})
    end
  end
  U.prepareDeriveCards(room, cards, "fhyx_extra_pile")
  room:setBanner("@$fhyx_extra_pile", table.simpleClone(room.tag["fhyx_extra_pile"]))
end
local function SetFhyxExtraPileBanner(room)
  local ids = table.filter(room.tag["fhyx_extra_pile"], function(id)
    return room:getCardArea(id) == Card.Void
  end)
  room:setBanner("@$fhyx_extra_pile", ids)
end
local huangyueying = General(extension, "ofl_mou__huangyueying", "shu", 3, 3, General.Female)
local jizhi = fk.CreateTriggerSkill{
  name = "ofl_mou__jizhi",
  anim_type = "drawcard",
  events = {fk.CardUsing},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card:isCommonTrick() and not data.card:isVirtual()
  end,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(player, MarkEnum.AddMaxCardsInTurn, 1)
    player:drawCards(1, self.name)
  end,
}
local qicai = fk.CreateActiveSkill{
  name = "ofl_mou__qicai",
  prompt = "#ofl_mou__qicai",
  anim_type = "control",
  card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function (self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).type == Card.TypeEquip
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    if table.contains(player:getCardIds("h"), effect.cards[1]) then
      player:showCards(effect.cards)
      if player.dead or target.dead or not table.contains(player:getCardIds("h"), effect.cards[1]) then return end
    end
    room:moveCardTo(effect.cards, Card.PlayerHand, target, fk.ReasonGive, self.name, nil, true, player.id)
    if player.dead or target.dead then return end
    local cards = table.filter(target:getCardIds("h"), function (id)
      return Fk:getCardById(id).type ~= Card.TypeEquip
    end)
    local cards2 = table.filter(room:getBanner("@$fhyx_extra_pile"), function(id)
      return Fk:getCardById(id):isCommonTrick()
    end)
    if #cards > 0 then
      local cancelable = true
      if #cards2 == 0 then
        cancelable = false
      end
      cards = room:askForCard(target, 2, 2, false, self.name, cancelable, ".|.|.|.|.|^equip", "#ofl_mou__qicai-give:"..player.id)
      if #cards > 0 then
        target:showCards(cards)
        if player.dead or target.dead then return end
        cards = table.filter(cards, function (id)
          return table.contains(target:getCardIds("h"), id)
        end)
        if #cards == 0 then return end
        room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonGive, self.name, nil, true, target.id)
      else
        room:moveCardTo(table.random(cards2, 2), Card.PlayerHand, player, fk.ReasonJustMove, self.name, nil, true,
          player.id, MarkEnum.DestructIntoDiscard)
      end
    elseif #cards2 > 0 then
      room:moveCardTo(table.random(cards2, 2), Card.PlayerHand, player, fk.ReasonJustMove, self.name, nil, true,
        player.id, MarkEnum.DestructIntoDiscard)
    end
  end,
}
local qicai_trigger = fk.CreateTriggerSkill{
  name = "#ofl_mou__qicai_trigger",

  refresh_events = {fk.EventAcquireSkill, fk.AfterCardsMove},
  can_refresh = function(self, event, target, player, data)
    if event == fk.EventAcquireSkill then
      return target == player and data == self
    elseif player.seat == 1 and player.room.tag["fhyx_extra_pile"] then
      for _, move in ipairs(data) do
        for _, info in ipairs(move.moveInfo) do
          if table.contains(player.room.tag["fhyx_extra_pile"], info.cardId) then
            return true
          end
        end
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    if event == fk.EventAcquireSkill then
      PrepareExtraPile(player.room)
    else
      SetFhyxExtraPileBanner(player.room)
    end
  end,
}
local qicai_targetmod = fk.CreateTargetModSkill{
  name = "#ofl_mou__qicai_targetmod",
  main_skill = qicai,
  bypass_distances = function(self, player, skill, card)
    return player:hasSkill(qicai) and card and card.type == Card.TypeTrick
  end,
}
qicai:addRelatedSkill(qicai_trigger)
qicai:addRelatedSkill(qicai_targetmod)
huangyueying:addSkill(jizhi)
huangyueying:addSkill(qicai)
Fk:loadTranslationTable{
  ["ofl_mou__huangyueying"] = "谋黄月英",
  ["#ofl_mou__huangyueying"] = "足智多谋",
  ["illustrator:ofl_mou__huangyueying"] = "光域",

  ["ofl_mou__jizhi"] = "集智",
  [":ofl_mou__jizhi"] = "锁定技，当你使用非转化的普通锦囊牌时，你摸一张牌，本回合手牌上限+1。",
  ["ofl_mou__qicai"] = "奇才",
  [":ofl_mou__qicai"] = "你使用锦囊牌无距离限制。出牌阶段限一次，你可以将一张装备牌展示并交给一名其他角色，然后其选择一项：1.展示并交给你"..
  "两张非装备牌；2.你从额外牌堆随机获得两张普通锦囊牌。",
  ["#ofl_mou__qicai"] = "奇才：将一张装备牌交给一名角色，其选择交给你两张非装备牌或令你从额外牌堆获得两张普通锦囊牌",
  ["#ofl_mou__qicai-give"] = "奇才：交给 %src 两张非装备牌，或点“取消”令其从额外牌堆获得两张普通锦囊牌",

  ["$ofl_mou__jizhi1"] = "奇思机上巧，妙想晦下明。",
  ["$ofl_mou__jizhi2"] = "愚，固曾有，智，从未绝。",
  ["$ofl_mou__qicai1"] = "奇巧之器，当出于奇巧之人。",
  ["$ofl_mou__qicai2"] = "尽奇思，毕全才。",
  ["~ofl_mou__huangyueying"] = "夫君尽忠节，妾身亦如是……",
}

local sunshangxiang = General(extension, "ofl_mou__sunshangxiang", "shu", 4, 4, General.Female)
local jieyin = fk.CreateTriggerSkill{
  name = "ofl_mou__jieyin",
  anim_type = "control",
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Play
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function (p)
      return p:getHandcardNum() <= player:getHandcardNum()
    end)
    local to = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 1,
      "#ofl_mou__jieyin-choose", self.name, false)
    to = room:getPlayerById(to[1])
    if #player:getPile("mou__liangzhu_dowry") == 0 then
      if to:isKongcheng() then
        if player:isWounded() then
          room:recover({
            who = player,
            num = 1,
            recoverBy = player,
            skillName = self.name,
          })
        end
      else
        if to == player then
          room:changeShield(to, 1)
          return
        else
          local cards = room:askForCard(to, math.min(2, to:getHandcardNum()), 2, false, self.name, false, nil, "#ofl_mou__jieyin-give:"..player.id)
          room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonGive, self.name, nil, false, to.id)
          if not to.dead then
            room:changeShield(to, 1)
          end
        end
      end
    else
      local cards = {}
      if not to:isKongcheng() then
        cards = room:askForCard(to, math.min(2, to:getHandcardNum()), 2, false, self.name, true, nil,
          "#ofl_mou__jieyin-choice:"..player.id)
      end
      if #cards > 0 then
        if to == player then
          room:changeShield(to, 1)
          return
        else
          room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonGive, self.name, nil, false, to.id)
          if not to.dead then
            room:changeShield(to, 1)
          end
        end
      else
        if player:isWounded() then
          room:recover({
            who = player,
            num = 1,
            recoverBy = player,
            skillName = self.name,
          })
        end
        if player.dead then return end
        if #player:getPile("mou__liangzhu_dowry") > 0 then
          room:moveCardTo(player:getPile("mou__liangzhu_dowry"), Card.PlayerHand, player, fk.ReasonJustMove, self.name, nil, true,
            player.id)
        end
        if player.dead then return end
        room:changeMaxHp(player, -1)
        if player.dead then return end
        if player.kingdom ~= "wu" then
          room:changeKingdom(player, "wu", true)
          room:handleAddLoseSkills(player, "mou__xiaoji", nil, true, false)  --FIXME: 权宜之计
        end
      end
    end
  end,
}
local liangzhu = fk.CreateActiveSkill{
  name = "ofl_mou__liangzhu",
  anim_type = "control",
  prompt = "#ofl_mou__liangzhu",
  card_num = 0,
  target_num = 1,
  derived_piles = "mou__liangzhu_dowry",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= Self.id and #Fk:currentRoom():getPlayerById(to_select):getCardIds("e") > 0
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local card = room:askForCardChosen(player, target, "e", self.name)
    player:addToPile("mou__liangzhu_dowry", card, true, self.name)
    if player.dead then return end
    local targets = table.filter(room:getOtherPlayers(player), function (p)
      return p:isWounded()
    end)
    if #targets == 0 then return end
    local to = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 1,
      "#ofl_mou__liangzhu-recover", self.name, false)
    room:recover({
      who = room:getPlayerById(to[1]),
      num = 1,
      recoverBy = player,
      skillName = self.name,
    })
  end,
}
liangzhu:addAttachedKingdom("shu")
sunshangxiang:addSkill(jieyin)
sunshangxiang:addSkill(liangzhu)
sunshangxiang:addSkill("mou__xiaoji")
Fk:loadTranslationTable{
  ["ofl_mou__sunshangxiang"] = "谋孙尚香",
  ["#ofl_mou__sunshangxiang"] = "骄豪明俏",
  ["illustrator:ofl_mou__sunshangxiang"] = "光域",

  ["ofl_mou__jieyin"] = "结姻",
  [":ofl_mou__jieyin"] = "锁定技，出牌阶段开始时，你令一名手牌数不大于你的角色选择一项：1.若其有手牌，其交给你两张手牌（不足则全给），"..
  "然后其获得1点护甲；2.你回复1点体力并获得所有“妆”，然后减1点体力上限，变更势力为吴。",
  ["ofl_mou__liangzhu"] = "良助",
  [":ofl_mou__liangzhu"] = "蜀势力技，出牌阶段限一次，你可以将一名其他角色装备区内一张牌置于你的武将牌上，称为“妆”，然后你令一名其他角色"..
  "回复1点体力。",
  ["#ofl_mou__jieyin-give"] = "结姻：请交给 %src 两张手牌，你获得1点护甲",
  ["#ofl_mou__jieyin-choice"] = "结姻：交给 %src 两张手牌（不足则全给），你获得1点护甲；或其变更为吴势力",
  ["#ofl_mou__jieyin-choose"] = "结姻：令一名角色选择一项",
  ["#ofl_mou__liangzhu"] = "良助：将一名角色装备区内一张牌置为“妆”，然后令一名其他角色回复1点体力",
  ["#ofl_mou__liangzhu-recover"] = "良助：令一名其他角色回复1点体力",

  ["$ofl_mou__jieyin1"] = "窈窕之姿，可配夫君之勇？",
  ["$ofl_mou__jieyin2"] = "君既反目生嫌，妾又何需隐忍！",
  ["$ofl_mou__liangzhu1"] = "既为使君妇，当助使君归。",
  ["$ofl_mou__liangzhu2"] = "愿随夫君，成一方枭雄之业！",
  ["$mou__xiaoji_ofl_mou__sunshangxiang1"] = "吾之所通，何止十八般兵刃！",
  ["$mou__xiaoji_ofl_mou__sunshangxiang2"] = "既如此，就让尔等见识一番！",
  ["~ofl_mou__sunshangxiang"] = "今夫君已亡，复能……独生乎！",
}

local ganning = General(extension, "ofl_mou__ganning", "wu", 4)
local qixi = fk.CreateActiveSkill{
  name = "ofl_mou__qixi",
  anim_type = "control",
  prompt = "#ofl_mou__qixi",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_num = 1,
  target_num = 1,
  card_filter = function (self, to_select, selected)
    return #selected == 0 and table.contains(Self:getCardIds("h"), to_select)
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local suits = {"log_spade", "log_heart", "log_club", "log_diamond"}
    local num = 0
    while #suits > 0 do
      local choice = room:askForChoice(target, suits, self.name, "#ofl_mou__qixi-choice:"..player.id)
      num = num + 1
      room:sendLog{
        type = "#Choice",
        from = target.id,
        arg = choice,
        toast = true,
      }
      if Fk:getCardById(effect.cards[1]):getSuitString(true) ~= choice then
        table.removeOne(suits, choice)
      else
        room:throwCard(effect.cards, self.name, player, player)
        break
      end
    end
    local throw_num = math.min(#target:getCardIds("hej"), num - 1)
    if player.dead or target.dead or throw_num == 0 then return end
    local throw = room:askForCardsChosen(player, target, throw_num, throw_num, "hej", self.name)
    room:throwCard(throw, self.name, target, player)
  end
}
local fenwei = fk.CreateTriggerSkill{
  name = "ofl_mou__fenwei",
  anim_type = "defensive",
  frequency = Skill.Limited,
  events = {fk.TargetSpecified},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and data.card.type == Card.TypeTrick and #AimGroup:getAllTargets(data.tos) > 1 and data.firstTarget and
      player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local tos = player.room:askForChoosePlayers(player, AimGroup:getAllTargets(data.tos), 1, 999,
      "#ofl_mou__fenwei-choose:::"..data.card:toLogString(), self.name, true)
    if #tos > 0 then
      self.cost_data = tos
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    table.insertTable(data.nullifiedTargets, self.cost_data)
    if table.contains(self.cost_data, player.id) then
      player.room:setPlayerMark(player, "ofl_mou__fenwei-turn", 1)
    end
  end,
}
local fenwei_delay = fk.CreateTriggerSkill{
  name = "#ofl_mou__fenwei_delay",
  mute = true,
  events = {fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    return player:getMark("ofl_mou__fenwei-turn") > 0 and not player:isKongcheng() and
      table.find(player.room:getOtherPlayers(player), function (p)
        return not p:isAllNude()
      end)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:askForUseActiveSkill(player, "ofl_mou__qixi", "#ofl_mou__qixi", true)
  end,
}
fenwei:addRelatedSkill(fenwei_delay)
ganning:addSkill(qixi)
ganning:addSkill(fenwei)
Fk:loadTranslationTable{
  ["ofl_mou__ganning"] = "谋甘宁",
  ["#ofl_mou__ganning"] = "兴王定霸",
  ["illustrator:ofl_mou__ganning"] = "铁杵",

  ["ofl_mou__qixi"] = "奇袭",
  [":ofl_mou__qixi"] = "出牌阶段限一次，你可以选择一张手牌并选择一名其他角色，令其猜测此牌的花色。若猜错，该角色从未猜测过的花色中再次猜测；"..
  "若猜对，你弃置此牌，然后你弃置其区域内X-1张牌（X为该角色猜测的次数，不足则全弃）。",
  ["ofl_mou__fenwei"] = "奋威",
  [":ofl_mou__fenwei"] = "限定技，当一张锦囊牌指定多个目标后，你可以令此牌对其中任意个目标无效，若包含你，本回合结束时你可以发动一次〖奇袭〗。",
  ["#ofl_mou__qixi"] = "奇袭：选择一张手牌，令一名角色猜测此牌花色，你弃置此牌并弃置其猜测次数-1的牌",
  ["#ofl_mou__qixi-choice"] = "奇袭：请猜测 %src 选择的手牌的花色",
  ["#ofl_mou__fenwei-choose"] = "奋威：你可以令此%arg对任意个目标无效，若包含你则本回合结束时可以发动“奇袭”",
  ["#ofl_mou__fenwei_delay"] = "奋威",

  ["$ofl_mou__qixi1"] = "百甲倾袭出，片刻得胜归！",
  ["$ofl_mou__qixi2"] = "奇袭中军帐，誓斩曹孟德！",
  ["$ofl_mou__fenwei1"] = "浪淘英雄泪，血染将军魂！",
  ["$ofl_mou__fenwei2"] = "立功护英主，奋威破敌酋！",
  ["~ofl_mou__ganning"] = "折冲御侮半生世，忽忆当年锦帆时……",
}

local daqiao = General(extension, "ofl_mou__daqiao", "wu", 3, 3, General.Female)
local guose = fk.CreateActiveSkill{
  name = "ofl_mou__guose",
  anim_type = "control",
  min_card_num = 0,
  max_card_num = 1,
  min_target_num = 1,
  max_target_num = 1,
  prompt = function (self)
    return "#"..self.interaction.data
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  interaction = function()
    return UI.ComboBox {choices = {"ofl_mou__guose_use", "ofl_mou__guose_move"}}
  end,
  card_filter = function(self, to_select, selected)
    if self.interaction.data == "ofl_mou__guose_use" then
      if #selected > 0 or Fk:getCardById(to_select).suit ~= Card.Diamond then return end
      local card = Fk:cloneCard("indulgence")
      card:addSubcard(to_select)
      return Self:canUse(card) and not Self:prohibitUse(card)
    else
      return false
    end
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    local target = Fk:currentRoom():getPlayerById(to_select)
    if self.interaction.data == "ofl_mou__guose_use" and #selected_cards == 1 then
      local card = Fk:cloneCard("indulgence")
      card:addSubcard(selected_cards[1])
      return to_select ~= Self.id and not Self:isProhibited(target, card)
    elseif self.interaction.data == "ofl_mou__guose_move" then
      if #selected == 0 then
        return target:hasDelayedTrick("indulgence")
      elseif #selected == 1 then
        local target1 = Fk:currentRoom():getPlayerById(selected[1])
        for _, id in ipairs(target1:getCardIds("j")) do
          local card = target1:getVirualEquip(id)
          if not card then card = Fk:getCardById(id) end
          if card.name == "indulgence" and target1:canMoveCardInBoardTo(target, id) and
            not target:isProhibited(target, card) then
            return true
          end
        end
      end
    end
  end,
  feasible = function (self, selected, selected_cards)
    if self.interaction.data == "ofl_mou__guose_use" then
      return #selected == 1 and #selected_cards == 1
    else
      if #selected == 2 and #selected_cards == 0 then
        local target1 = Fk:currentRoom():getPlayerById(selected[1])
        local target2 = Fk:currentRoom():getPlayerById(selected[2])
        for _, id in ipairs(target1:getCardIds("j")) do
          local card = target1:getVirualEquip(id)
          if not card then card = Fk:getCardById(id) end
          if card.name == "indulgence" and target1:canMoveCardInBoardTo(target2, id) and
            not target2:isProhibited(target2, card) then
            return true
          end
        end
      end
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    if self.interaction.data == "ofl_mou__guose_use" then
      local target = room:getPlayerById(effect.tos[1])
      room:useVirtualCard("indulgence", effect.cards, player, target, self.name)
    elseif self.interaction.data == "ofl_mou__guose_move" then
      local targets = table.map(effect.tos, Util.Id2PlayerMapper)
      local excludeIds = {}
      for _, id in ipairs(targets[1]:getCardIds("j")) do
        local card = targets[1]:getVirualEquip(id)
        if not card then card = Fk:getCardById(id) end
        if card.name == "indulgence" and targets[1]:canMoveCardInBoardTo(targets[2], id) and
          not targets[2]:isProhibited(targets[2], card) then
        else
          table.insert(excludeIds, id)
        end
      end
      room:askForMoveCardInBoard(player, targets[1], targets[2], self.name, "j", targets[1], excludeIds)
    end
  end,
}
local liuli = fk.CreateTriggerSkill{
  name = "ofl_mou__liuli",
  anim_type = "defensive",
  events = {fk.TargetConfirming},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card.trueName == "slash" and not player:isNude() and
      table.find(player.room.alive_players, function (p)
        return player:inMyAttackRange(p) and p.id ~= data.from and not player.room:getPlayerById(data.from):isProhibited(p, data.card)
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function (p)
      return player:inMyAttackRange(p) and p.id ~= data.from and not room:getPlayerById(data.from):isProhibited(p, data.card)
    end)
    local cards = table.filter(player:getCardIds("he"), function (id)
      return not player:prohibitDiscard(id)
    end)
    local to, id = room:askForChooseCardAndPlayers(player, table.map(targets, Util.IdMapper), 1, 1,
      tostring(Exppattern{ id = cards }), "#ofl_mou__liuli-choose:::"..data.card:toLogString(), self.name, true)
    if #to > 0 and id then
      self.cost_data = {tos = to, cards = {id}}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data.tos[1])
    room:throwCard(self.cost_data.cards, self.name, player, player)
    AimGroup:cancelTarget(data, player.id)
    AimGroup:addTargets(room, data, to.id)
    if not to.dead then
      for _, p in ipairs(room.alive_players) do
        room:setPlayerMark(p, "@@liuli_dangxian", 0)
      end
      room:setPlayerMark(to, "@@liuli_dangxian", 1)
    end
    return true
  end,
}
local liuli_delay = fk.CreateTriggerSkill{
  name = "#ofl_mou__liuli_delay",

  refresh_events = {fk.EventPhaseChanging},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@@liuli_dangxian") ~= 0 and data.to == Player.Start
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@liuli_dangxian", 0)
    player:gainAnExtraPhase(Player.Play)
  end,
}
liuli:addRelatedSkill(liuli_delay)
daqiao:addSkill(guose)
daqiao:addSkill(liuli)
Fk:loadTranslationTable{
  ["ofl_mou__daqiao"] = "谋大乔",
  ["#ofl_mou__daqiao"] = "国色芳华",
  ["illustrator:ofl_mou__daqiao"] = "凡果",

  ["ofl_mou__guose"] = "国色",
  [":ofl_mou__guose"] = "出牌阶段限一次，你可以将一张<font color='red'>♦</font>牌当【乐不思蜀】使用，或移动场上一张【乐不思蜀】。",
  ["ofl_mou__liuli"] = "流离",
  [":ofl_mou__liuli"] = "当你成为【杀】的目标时，你可以弃置一张牌，将目标转移给你攻击范围内除使用者以外的一名角色，令其获得“流离”标记"..
  "（若场上已有则转移给其）。有“流离”标记的角色回合开始时，移去“流离”标记并执行一个额外的出牌阶段。",
  ["ofl_mou__guose_use"] = "使用【乐不思蜀】",
  ["ofl_mou__guose_move"] = "移动【乐不思蜀】",
  ["#ofl_mou__guose_use"] = "国色：将一张<font color='red'>♦</font>牌当【乐不思蜀】使用",
  ["#ofl_mou__guose_move"] = "国色：移动场上一张【乐不思蜀】",
  ["#ofl_mou__liuli-choose"] = "流离：你可以弃置一张牌，将此%arg转移给一名其他角色",
  ["@@liuli_dangxian"] = "流离",

  ["$ofl_mou__guose1"] = "逢郎欲语含羞笑，还走香囊投君怀。",
  ["$ofl_mou__guose2"] = "凝眸望君浅笑，换君片刻停留。",
  ["$ofl_mou__liuli1"] = "战火频仍，坐困此间。",
  ["$ofl_mou__liuli2"] = "飘零复一载，何处是归程。",
  ["~ofl_mou__daqiao"] = "瞻彼日月，悠悠我思……",
}

local xiaoqiao = General(extension, "ofl_mou__xiaoqiao", "wu", 3, 3, General.Female)
local tianxiang = fk.CreateTriggerSkill{
  name = "ofl_mou__tianxiang",
  anim_type = "defensive",
  events = {fk.DamageInflicted},
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:getHandcardNum() > 1 and #player.room:getOtherPlayers(player) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to, cards = room:askForChooseCardsAndPlayers(player, 2, 2, table.map(room:getOtherPlayers(player), Util.IdMapper), 1, 1,
    ".|.|.|hand", "#ofl_mou__tianxiang-choose", self.name, true)
    if #to > 0 and #cards == 2 then
      self.cost_data = {tos = to, cards = cards}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data.tos[1])
    player:showCards(self.cost_data.cards)
    local cards = U.askforChooseCardsAndChoice(to, self.cost_data.cards, {"OK"}, self.name, "#ofl_mou__tianxiang-prey:"..player.id)
    local yes = Fk:getCardById(cards[1]).suit == Card.Heart
    local type = Fk:getCardById(cards[1]):getTypeString()
    room:moveCardTo(cards, Card.PlayerHand, to, fk.ReasonPrey, self.name, nil, true, to.id)
    if yes then
      if not to.dead then
        room:damage{
          from = data.from,
          to = to,
          damage = data.damage,
          damageType = data.damageType,
          skillName = data.skillName,
          chain = data.chain,
          card = data.card,
        }
      end
      return true
    elseif not to.dead then
      room:addTableMark(to, "@ofl_mou__tianxiang-turn", type.."_char")
    end
  end,
}
local tianxiang_prohibit = fk.CreateProhibitSkill{
  name = "#ofl_mou__tianxiang_prohibit",
  prohibit_use = function(self, player, card)
    local mark = player:getMark("@ofl_mou__tianxiang-turn")
    if type(mark) == "table" and table.contains(mark, card:getTypeString() .. "_char") then
      local subcards = card:isVirtual() and card.subcards or {card.id}
      return #subcards > 0 and table.every(subcards, function(id)
        return table.contains(player:getCardIds(Player.Hand), id)
      end)
    end
  end,
}
local hongyan = fk.CreateFilterSkill{
  name = "ofl_mou__hongyan",
  card_filter = function(self, to_select, player, isJudgeEvent)
    return to_select.suit == Card.Spade and player:hasSkill(self) and
      (table.contains(player:getCardIds("he"), to_select.id) or isJudgeEvent)
  end,
  view_as = function(self, to_select)
    return Fk:cloneCard(to_select.name, Card.Heart, to_select.number)
  end,
}
local hongyan_trigger = fk.CreateTriggerSkill {
  name = "#ofl_mou__hongyan_trigger",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(hongyan) and player:usedSkillTimes(self.name, Player.HistoryTurn) == 0 then
      for _, move in ipairs(data) do
        if move.from == player.id then
          for _, info in ipairs(move.moveInfo) do
            if info.extra_data and info.extra_data.ofl_mou__hongyan then
              return true
            end
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, "ofl_mou__hongyan")
  end,

  refresh_events = {fk.BeforeCardsMove},
  can_refresh = function (self, event, target, player, data)
    if player:hasSkill(hongyan, true) then
      for _, move in ipairs(data) do
        if move.from == player.id then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
              return true
            end
          end
        end
      end
    end
  end,
  on_refresh = function (self, event, target, player, data)
    for _, move in ipairs(data) do
      if move.from == player.id then
        for _, info in ipairs(move.moveInfo) do
          if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
            Fk:getCardById(info.cardId, false).suit == Card.Heart then
            info.extra_data = info.extra_data or {}
            info.extra_data.ofl_mou__hongyan = true
          end
        end
      end
    end
  end,
}
hongyan:addRelatedSkill(hongyan_trigger)
tianxiang:addRelatedSkill(tianxiang_prohibit)
xiaoqiao:addSkill(tianxiang)
xiaoqiao:addSkill(hongyan)
Fk:loadTranslationTable{
  ["ofl_mou__xiaoqiao"] = "谋小乔",
  ["#ofl_mou__xiaoqiao"] = "矫情之花",
  ["illustrator:ofl_mou__xiaoqiao"] = "黯荧岛",

  ["ofl_mou__tianxiang"] = "天香",
  [":ofl_mou__tianxiang"] = "当你受到伤害时，你可以展示两张手牌，令一名其他角色选择获得其中一张牌，若此牌：为<font color='red'>♥</font>，"..
  "你将此伤害转移给其；不为<font color='red'>♥</font>，其本回合不能使用与此牌类别相同的手牌。",
  ["ofl_mou__hongyan"] = "红颜",
  [":ofl_mou__hongyan"] = "锁定技，你的♠牌或你的♠判定牌视为<font color='red'>♥</font>。当你每回合首次失去<font color='red'>♥</font>牌后，"..
  "你摸一张牌。",
  ["#ofl_mou__tianxiang-choose"] = "天香：展示两张牌手牌，令一名角色获得一张，若为<font color='red'>♥</font>则伤害转移给其，否则其本回合"..
  "不能使用此类别的手牌",
  ["#ofl_mou__tianxiang-prey"] = "天香：获得其中一张牌",
  ["#ofl_mou__hongyan_trigger"] = "红颜",
  ["@ofl_mou__tianxiang-turn"] = "天香",

  ["$ofl_mou__tianxiang1"] = "江东明珠，可不是汝掌中之物！",
  ["$ofl_mou__tianxiang2"] = "容冠国色，华茂天香。",
  ["~ofl_mou__xiaoqiao"] = "红颜易逝，天香难湮……",
}

local yuanshao = General(extension, "ofl_mou__yuanshao", "qun", 4)
local luanji = fk.CreateViewAsSkill{
  name = "ofl_mou__luanji",
  anim_type = "offensive",
  pattern = "archery_attack",
  prompt = "#ofl_mou__luanji",
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, to_select, selected)
    return #selected < 2 and Fk:currentRoom():getCardArea(to_select) ~= Player.Equip
  end,
  view_as = function(self, cards)
    if #cards == 2 then
      local archery_attack = Fk:cloneCard("archery_attack")
      archery_attack:addSubcards(cards)
      return archery_attack
    end
  end,
}
local luanji_trigger = fk.CreateTriggerSkill{
  name = "#ofl_mou__luanji_trigger",
  anim_type = "drawcard",
  events = {fk.CardResponding},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(luanji) and target ~= player and data.card.name == "jink" and
      data.responseToEvent and data.responseToEvent.from == player.id and
      data.responseToEvent.card.trueName =="archery_attack" and
      player:getHandcardNum() < player.hp and player:getHandcardNum() < target:getHandcardNum()
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player:broadcastSkillInvoke("ofl_mou__luanji")
    player:drawCards(1, "ofl_mou__luanji")
  end,
}
local xueyi = fk.CreateTriggerSkill{
  name = "ofl_mou__xueyi$",
  anim_type = "offensive",
  events = {fk.CardUseFinished},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.tos and
      data.extra_data and data.extra_data.ofl_mou__xueyi and
      table.find(data.extra_data.ofl_mou__xueyi, function (id)
        local p = player.room:getPlayerById(id)
        return not p.dead and p.kingdom == "qun"
      end) and
      player.room.logic:getCurrentEvent():findParent(GameEvent.Phase, true)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, id in ipairs(data.extra_data.ofl_mou__xueyi) do
      room:setPlayerMark(room:getPlayerById(id), "@@ofl_mou__xueyi-phase", 1)
    end
  end,

  refresh_events = {fk.AfterAskForCardUse, fk.AfterAskForCardResponse, fk.AfterAskForNullification},
  can_refresh = function(self, event, target, player, data)
    if data.eventData then
      if event == fk.AfterAskForCardUse then
        return target == player and data.result and data.result.from == player.id
      elseif event == fk.AfterAskForCardResponse then
        return target == player and data.result
      elseif event == fk.AfterAskForNullification then
        return data.result and data.result.from == player.id
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local use_event = room.logic:getCurrentEvent():findParent(GameEvent.UseCard, true)
    if use_event == nil then return end
    local use = use_event.data[1]
    use.extra_data = use.extra_data or {}
    use.extra_data.ofl_mou__xueyi = use.extra_data.ofl_mou__xueyi or {}
    table.insertIfNeed(use.extra_data.ofl_mou__xueyi, player.id)
  end,
}
local xueyi_maxcards = fk.CreateMaxCardsSkill{
  name = "#ofl_mou__xueyi_maxcards",
  correct_func = function(self, player)
    if player:hasSkill(xueyi) then
      local hmax = 0
      for _, p in ipairs(Fk:currentRoom().alive_players) do
        if p ~= player and p.kingdom == "qun" then
          hmax = hmax + 1
        end
      end
      return hmax *2
    else
      return 0
    end
  end,
}
local xueyi_prohibit = fk.CreateProhibitSkill{
  name = "#ofl_mou__xueyi_prohibit",
  prohibit_use = function(self, player, card)
    if player:getMark("@@ofl_mou__xueyi-phase") > 0 then
      local subcards = card:isVirtual() and card.subcards or {card.id}
      return #subcards > 0 and table.every(subcards, function(id)
        return table.contains(player:getCardIds(Player.Hand), id)
      end)
    end
  end,
  prohibit_response = function (self, player, card)
    if player:getMark("@@ofl_mou__xueyi-phase") > 0 then
      local subcards = card:isVirtual() and card.subcards or {card.id}
      return #subcards > 0 and table.every(subcards, function(id)
        return table.contains(player:getCardIds(Player.Hand), id)
      end)
    end
  end,
}
luanji:addRelatedSkill(luanji_trigger)
xueyi:addRelatedSkill(xueyi_maxcards)
xueyi:addRelatedSkill(xueyi_prohibit)
yuanshao:addSkill(luanji)
yuanshao:addSkill(xueyi)
Fk:loadTranslationTable{
  ["ofl_mou__yuanshao"] = "谋袁绍",
  ["#ofl_mou__yuanshao"] = "高贵的名门",
  ["illustrator:ofl_mou__yuanshao"] = "荧光笔",

  ["ofl_mou__luanji"] = "乱击",
  [":ofl_mou__luanji"] = "出牌阶段限一次，你可以将两张手牌当【万箭齐发】使用。当其他角色打出【闪】响应你使用的【万箭齐发】时，"..
  "若你的手牌数小于体力值且小于其手牌数，你摸一张牌。",
  ["ofl_mou__xueyi"] = "血裔",
  [":ofl_mou__xueyi"] = "主公技，锁定技，你的手牌上限+2X（X为其他群势力角色数）。当你使用牌结算后，你令响应过此牌的其他群势力角色"..
  "本阶段不能使用或打出手牌。",
  ["#ofl_mou__luanji"] = "乱击：你可以将两张手牌当【万箭齐发】使用",
  ["#ofl_mou__luanji_trigger"] = "乱击",
  ["@@ofl_mou__xueyi-phase"] = "禁止使用打出手牌",

  ["$ofl_mou__luanji1"] = "翦公孙，平夷患，起高橹，靖四州！",
  ["$ofl_mou__luanji2"] = "乱箭之下，尽显吾袁门之威！",
  ["$ofl_mou__xueyi1"] = "天下诸公，皆是我袁门故吏！",
  ["$ofl_mou__xueyi2"] = "累四世功名，今朝定声震寰宇！",
  ["~ofl_mou__yuanshao"] = "天命竟最终站在了……他那边……",
  --帐下贤才多如江鲫，欲取天下岂非易事？
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

return extension
