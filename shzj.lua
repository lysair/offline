local extension = Package("shzj")
extension.extensionName = "offline"

Fk:loadTranslationTable{
  ["shzj"] = "线下-山河煮酒",
  ["shzj_xiangfan"] = "襄樊",
  ["shzj_yiling"] = "夷陵",
}

local U = require "packages/utility/utility"

local shzj_xiangfan__guanyu = General:new(extension, "shzj_xiangfan__guanyu", "shu", 4)
local chaojue = fk.CreateTriggerSkill{
  name = "chaojue",
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Start and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local card = room:askForDiscard(player, 1, 1, false, self.name, true, ".", "#chaojue-invoke", true)
    if #card > 0 then
      room:doIndicate(player.id, table.map(room:getOtherPlayers(player, false), Util.IdMapper))
      self.cost_data = card[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = Fk:getCardById(self.cost_data)
    room:throwCard(self.cost_data, self.name, player, player)
    if player.dead then return end
    local mark = player:getNextAlive():getMark("@chaojue-turn")
    if mark == 0 then mark = {} end
    if card.suit ~= Card.NoSuit then
      table.insertIfNeed(mark, card:getSuitString(true))
    end
    local targets = room:getOtherPlayers(player)
    for _, p in ipairs(targets) do
      room:setPlayerMark(p, "@chaojue-turn", mark)
    end
    for _, p in ipairs(targets) do
      if player.dead then return end
      local cards = room:askForCard(p, 1, 1, false, self.name, true,
      ".|.|"..card:getSuitString(), "#chaojue-cost::"..player.id..":"..card:getSuitString())
      if #cards > 0 then
        room:obtainCard(player, cards, true, fk.ReasonPrey, player.id)
      else
        room:addPlayerMark(p, "@@chaojue-turn")
        room:addPlayerMark(p, MarkEnum.UncompulsoryInvalidity .. "-turn")
      end
    end
  end,
}
local chaojuejue_prohibit = fk.CreateProhibitSkill{
  name = "#chaojuejue_prohibit",
  prohibit_use = function(self, player, card)
    return player:getMark("@chaojue-turn") ~= 0 and table.contains(player:getMark("@chaojue-turn"), card:getSuitString(true))
  end,
  prohibit_response = function(self, player, card)
    return player:getMark("@chaojue-turn") ~= 0 and table.contains(player:getMark("@chaojue-turn"), card:getSuitString(true))
  end,
}
local junshen = fk.CreateViewAsSkill{
  name = "junshen",
  anim_type = "offensive",
  pattern = "slash",
  prompt = "#junshen-viewas",
  card_filter = function(self, to_select, selected)
    if #selected == 1 then return false end
    return Fk:getCardById(to_select).color == Card.Red
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then
      return nil
    end
    local c = Fk:cloneCard("slash")
    c.skillName = self.name
    c:addSubcard(cards[1])
    return c
  end,
}
local junshen_targetmod = fk.CreateTargetModSkill{
  name = "#junshen_targetmod",
  bypass_distances = function (self, player, skill, card, to)
    return player:hasSkill(junshen) and skill.trueName == "slash_skill" and card.suit == Card.Diamond
  end,
}
local junshen_trigger = fk.CreateTriggerSkill{
  name = "#junshen_trigger",
  anim_type = "offensive",
  events = {fk.DamageCaused, fk.AfterCardTargetDeclared},
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(junshen) then return false end
    if event == fk.AfterCardTargetDeclared then
      if data.card.trueName ~= "slash" or data.card.suit ~= Card.Heart then return false end
      local current_targets = TargetGroup:getRealTargets(data.tos)
      for _, p in ipairs(player.room.alive_players) do
        if not table.contains(current_targets, p.id) and not player:isProhibited(p, data.card) and
            data.card.skill:modTargetFilter(p.id, current_targets, data.from, data.card, true) then
          return true
        end
      end
    elseif event == fk.DamageCaused then
      return data.card and data.card.trueName == "slash" and table.contains(data.card.skillNames, "junshen") and
      not data.to.dead and U.damageByCardEffect(player.room)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if event == fk.AfterCardTargetDeclared then
      local current_targets = TargetGroup:getRealTargets(data.tos)
      local targets = {}
      for _, p in ipairs(room.alive_players) do
        if not table.contains(current_targets, p.id) and not player:isProhibited(p, data.card) and
            data.card.skill:modTargetFilter(p.id, current_targets, data.from, data.card, true) then
          table.insert(targets, p.id)
        end
      end
      local tos = room:askForChoosePlayers(player, targets, 1, 1,
      "#junshen-choose:::"..data.card:toLogString(), "junshen", true)
      if #tos > 0 then
        self.cost_data = tos
        return true
      end
    else
      room:doIndicate(player.id, {data.to.id})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    if event == fk.AfterCardTargetDeclared then
      table.insertTable(data.tos, table.map(self.cost_data, function (p)
        return {p}
      end))
    else
      local room = player.room
      if #data.to:getCardIds("e") == 0 then
        data.damage = data.damage + 1
      else
        local choices = {"junshen_choice1", "junshen_choice2"}
        local choice = room:askForChoice(data.to, choices, "junshen", "#junshen-choice:" .. player.id)
        if choice == "junshen_choice1" then
          data.to:throwAllCards("e")
        elseif choice == "junshen_choice2" then
          data.damage = data.damage + 1
        end
      end
    end
  end,
}
junshen:addRelatedSkill(junshen_trigger)
junshen:addRelatedSkill(junshen_targetmod)
chaojue:addRelatedSkill(chaojuejue_prohibit)
shzj_xiangfan__guanyu:addSkill(chaojue)
shzj_xiangfan__guanyu:addSkill(junshen)
Fk:loadTranslationTable{
  ["shzj_xiangfan__guanyu"] = "关羽",
  ["#shzj_xiangfan__guanyu"] = "国士无双",
  ["illustrator:shzj_xiangfan__guanyu"] = "鬼画府",

  ["chaojue"] = "超绝",
  [":chaojue"] = "准备阶段，你可以弃置一张手牌，令所有其他角色本回合不能使用或打出与此牌花色相同的牌，"..
  "然后这些角色依次选择：1.展示并交给你一张相同花色的手牌; 2.其本回合内所有非锁定技失效。",
  ["@@chaojue-turn"] ="被超绝",
  ["@chaojue-turn"] = "超绝",
  ["#chaojue-invoke"] = "超绝：是否弃置一张手牌，令所有其他角色本回合不能使用或打出该花色的牌?",
  ["#chaojue-cost"] = "超绝：你需交给%dest一张%arg手牌，否则本回合你的非锁定技失效",
  ["junshen"] = "军神",
  ["#junshen_trigger"] = "军神",
  [":junshen"] = "你可以将一张红色牌当【杀】使用或打出。"..
  "当你以此法使用【杀】对一名角色造成伤害时，其选择：1.弃置装备区内的所有牌; 2.令伤害值+1。"..
  "你使用<font color='red'>♦</font>【杀】无距离限制、<font color='red'>♥</font>【杀】可以多选择一个目标。",
  ["#junshen-viewas"] = "军神：将一张红色牌当【杀】使用或打出",
  ["#junshen-choose"] = "军神：是否为使用的【%arg】额外指定1个目标",
  ["#junshen-choice"] = "军神：弃置装备区的所有牌或者令%src对你造成的伤害+1。",
  ["junshen_choice1"] = "弃置装备",
  ["junshen_choice2"] = "受伤+1",
}

local shzj_xiangfan__caoren = General(extension, "shzj_xiangfan__caoren", "wei", 4)
local lizhong_nullification = fk.CreateViewAsSkill{
  name = "lizhong&",
  anim_type = "defensive",
  pattern = "nullification",
  prompt = "#lizhong-viewas",
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:currentRoom():getCardArea(to_select) == Player.Equip
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then return end
    local c = Fk:cloneCard("nullification")
    c.skillName = self.name
    c:addSubcard(cards[1])
    return c
  end,
  enabled_at_play = Util.FalseFunc,
  enabled_at_response = function (self, player)
    return #player.player_cards[Player.Equip] > 0
  end,
}
local lizhong_active = fk.CreateActiveSkill{
  name = "lizhong_active",
  card_num = 1,
  target_num = 1,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).type == Card.TypeEquip
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and #selected_cards == 1 and
    U.canMoveCardIntoEquip(Fk:currentRoom():getPlayerById(to_select), selected_cards[1], false)
  end,
}
local lizhong = fk.CreateTriggerSkill{
  name = "lizhong",
  anim_type = "support",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player.phase == Player.Finish and player:hasSkill(self)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local lizhong_use = true
    while true do
      local success, dat = room:askForUseActiveSkill(player, "lizhong_active", "#lizhong-put")
      if success then
        room:moveCardTo(dat.cards[1], Card.PlayerEquip, room:getPlayerById(dat.targets[1]), fk.ReasonPut, self.name, "", true, player.id)
        lizhong_use = false
      else
        break
      end
      if player.dead then return false end
    end
    local _, ret = room:askForUseActiveSkill(player, "choose_players_skill", "#lizhong-choose", true, {
      targets = table.map(table.filter(room.alive_players, function (p)
        return #p.player_cards[Player.Equip] > 0
      end), Util.IdMapper),
      num = 998,
      min_num = 0,
      pattern = "",
      skillName = self.name
    }, false)
    if ret then
      local tos = ret.targets
      if #tos == 0 then
        table.insert(tos, player.id)
      else
        room:sortPlayersByAction(tos)
      end
      for _, pid in ipairs(tos) do
        local p = room:getPlayerById(pid)
        if not p.dead then
          p:drawCards(1, self.name)
          if not p.dead then
            if p:getMark("@@lizhong-round") == 0 then
              room:setPlayerMark(p, "@@lizhong-round", 1)
              room:addPlayerMark(p, "AddMaxCards-round", 2)
            end
            if not p:hasSkill("lizhong&") then
              room:handleAddLoseSkills(p, "lizhong&", nil, false, true)
              room.logic:getCurrentEvent():findParent(GameEvent.Round):addCleaner(function()
                room:handleAddLoseSkills(p, "-lizhong&", nil, false, true)
              end)
            end
          end
        end
      end
    end
    if lizhong_use then
      while true do
        local success, dat = room:askForUseActiveSkill(player, "lizhong_active", "#lizhong-put")
        if success then
          room:moveCardTo(dat.cards[1], Card.PlayerEquip, room:getPlayerById(dat.targets[1]), fk.ReasonPut, self.name, "", true, player.id)
        else
          break
        end
        if player.dead then return false end
      end
    end
  end,
}
local juesui_slash = fk.CreateViewAsSkill{
  name = "juesui&",
  anim_type = "offensive",
  pattern = "slash",
  prompt = "#juesui-viewas",
  card_filter = function(self, to_select, selected)
    if #selected == 0 then
      local card = Fk:getCardById(to_select)
      return card.color == Card.Black and card.type ~= Card.TypeBasic
    end
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard("slash")
    card.skillName = self.name
    card:addSubcard(cards[1])
    return card
  end,
}
local juesui_targetmod = fk.CreateTargetModSkill{
  name = "#juesui_targetmod",
  bypass_times = function(self, player, skill, scope, card)
    return table.contains(card.skillNames, "juesui&")
  end,
}
local juesui = fk.CreateTriggerSkill{
  name = "juesui",
  anim_type = "support",
  events = {fk.EnterDying},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and not target.dead and not table.contains(U.getMark(player, "juesui_used"), target.id) and
    #target:getAvailableEquipSlots() > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askForSkillInvoke(player, self.name, nil, "#juesui-invoke::"..target.id) then
      room:doIndicate(player.id, {target.id})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local mark = U.getMark(player, "juesui_used")
    table.insert(mark, target.id)
    room:setPlayerMark(player, "juesui_used", mark)
    if player ~= target and not room:askForSkillInvoke(target, self.name, nil, "#juesui-accept") then return false end
    room:recover({
      who = target,
      num = 1 - target.hp,
      recoverBy = player,
      skillName = self.name
    })
    if target.dead then return false end
    local eqipSlots = target:getAvailableEquipSlots()
    if #eqipSlots > 0 then
      room:abortPlayerArea(target, eqipSlots)
    end
    if target.dead then return false end
    room:setPlayerMark(target, "@@juesui", 1)
    room:handleAddLoseSkills(target, "juesui&", nil, false, true)
  end,
}
Fk:addSkill(lizhong_active)
Fk:addSkill(lizhong_nullification)
juesui_slash:addRelatedSkill(juesui_targetmod)
Fk:addSkill(juesui_slash)
shzj_xiangfan__caoren:addSkill(lizhong)
shzj_xiangfan__caoren:addSkill(juesui)

Fk:loadTranslationTable{
  ["shzj_xiangfan__caoren"] = "曹仁",
  ["#shzj_xiangfan__caoren"] = "玉钤奉国",
  ["illustrator:shzj_xiangfan__caoren"] = "鬼画府",

  ["lizhong"] = "厉众",
  [":lizhong"] = "结束阶段，你可选择任意项：1.将任意张装备牌置入任意名角色的装备区；2.令你或任意名装备区里有牌的角色各摸一张牌，"..
  "以此法摸牌的角色本轮内手牌上限+2且可以将装备区里的牌当【无懈可击】使用。",
  ["juesui"] = "玦碎",
  [":juesui"] = "当一名角色进入濒死状态时，若你未对其发动过此技能，你可以令其选择是否回复体力至1点并废除所有装备栏。"..
  "若其如此做，其本局游戏内可以将黑色非基本牌当无次数限制的【杀】使用或打出。",
  ["lizhong_active"] = "厉众",
  ["#lizhong-put"] = "厉众：将装备牌置入一名角色的装备区",
  ["#lizhong-choose"] = "厉众：选择任意名装备区里有牌的角色各摸一张牌，若不选角色则为你",
  ["@@lizhong-round"] = "厉众",
  ["#juesui-invoke"] = "是否对 %dest 发动 玦碎，令其可以回复体力至1点并废除所有装备栏",
  ["#juesui-accept"] = "玦碎：是否将体力值回复体力至1点并废除所有装备栏",
  ["@@juesui"] = "玦碎",
  ["lizhong&"] = "厉众",
  [":lizhong&"] = "你本轮内可以将装备区里的牌当【无懈可击】使用。",
  ["juesui&"] = "玦碎",
  [":juesui&"] = "你可以将黑色非基本牌当无次数限制的【杀】使用或打出。",
  ["#lizhong-viewas"] = "发动 厉众，将装备区里的牌当【无懈可击】使用",
  ["#juesui-viewas"] = "发动 玦碎，将黑色非基本牌当无次数限制的【杀】使用或打出",
}

local lvchang = General(extension, "lvchang", "wei", 4)
local juwu = fk.CreateTriggerSkill{
  name = "juwu",
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  events = {fk.PreCardEffect},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and (data.card.name == "slash" or data.card.name == "stab__slash") and
      player.id == data.to and data.from then
      local from = player.room:getPlayerById(data.from)
      return not from.dead and #table.filter(player.room.alive_players, function(p)
        return from:inMyAttackRange(p)
      end) > 2
    end
  end,
  on_use = Util.TrueFunc,
}
local shouxiang = fk.CreateTriggerSkill{
  name = "shouxiang",
  anim_type = "drawcard",
  events = {fk.DrawNCards},
  on_cost = function(self, event, target, player, data)
    local n = #table.filter(player.room.alive_players, function(p)
      return p:inMyAttackRange(player)
    end)
    return player.room:askForSkillInvoke(player, self.name, nil, "#shouxiang-invoke:::"..n)
  end,
  on_use = function(self, event, target, player, data)
    local n = #table.filter(player.room.alive_players, function(p)
      return p:inMyAttackRange(player)
    end)
    data.n = data.n + math.min(n, 3)
    player:skip(Player.Play)
  end,
}
local shouxiang_delay = fk.CreateTriggerSkill{
  name = "#shouxiang",
  mute = true,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player.phase == Player.Discard and player:usedSkillTimes("shouxiang", Player.HistoryTurn) > 0 and
      not player:isKongcheng() and
      #table.filter(player.room.alive_players, function(p)
        return p:inMyAttackRange(player)
      end) > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = #table.filter(player.room.alive_players, function(p)
      return p:inMyAttackRange(player)
    end)
    n = math.min(n, 3)
    U.askForDistribution(player, player:getCardIds("h"), room:getOtherPlayers(player), self.name, 0, n, "#shouxiang-give:::"..n,
      "", false, 1)
  end,
}
shouxiang:addRelatedSkill(shouxiang_delay)
lvchang:addSkill(juwu)
lvchang:addSkill(shouxiang)
Fk:loadTranslationTable{
  ["lvchang"] = "吕常",
  ["#lvchang"] = "险守襄阳",
  ["illustrator:lvchang"] = "戚屹",

  ["juwu"] = "拒武",
  [":juwu"] = "锁定技，若一名角色攻击范围内包含至少三名角色，该角色对你使用的无属性【杀】无效。",
  ["shouxiang"] = "守襄",
  [":shouxiang"] = "摸牌阶段，你可以多摸X张牌，然后跳过你的出牌阶段。若如此做，此回合的弃牌阶段开始时，你可以交给至多X名角色各一张手牌"..
  "（X为攻击范围内含有你的角色数且至多为3）。",
  ["#shouxiang-invoke"] = "守襄：你可以多摸%arg张牌并跳过出牌阶段，弃牌阶段开始时可以将牌交给其他角色",
  ["#shouxiang-give"] = "守襄：你可以交给%arg名角色各一张手牌",
}

local shzj_yiling__liubei = General(extension, "shzj_yiling__liubei", "shu", 4)
local qingshil = fk.CreateTriggerSkill{
  name = "qingshil",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Start and
      table.find(player.room.alive_players, function(p) return not p:isKongcheng() end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(table.filter(room.alive_players, function(p)
      return not p:isKongcheng()
    end), Util.IdMapper)
    local tos = room:askForChoosePlayers(player, targets, 1, player.hp, "#qingshil-choose:::"..player.hp, self.name, true)
    if #tos > 0 then
      self.cost_data = tos
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:sortPlayersByAction(self.cost_data)
    local targets = table.map(self.cost_data, Util.Id2PlayerMapper)
    local discussion = U.Discussion{
      reason = self.name,
      from = player,
      tos = targets,
      results = {},
    }
    if discussion.color == "red" then
      for _, p in ipairs(targets) do
        if not p.dead and discussion.results[p.id].opinion == Card.Red then
          room:setPlayerMark(p, "@@qingshil-round", 1)
        end
      end
    elseif discussion.color == "black" then
      if player.dead then return end
      local n = #table.filter(targets, function (p)
        return discussion.results[p.id].opinion == Card.Black
      end)
      player:drawCards(n, self.name)
      if player.dead or player:isNude() then return end
      targets = table.filter(targets, function (p)
        return discussion.results[p.id].opinion == Card.Black and not p.dead and p ~= player
      end)
      if #targets == 0 then return end
      U.askForDistribution(player, player:getCardIds("he"), targets, self.name, 0, 999, "#qingshil-give", nil, false, 1)
    end
  end,
}
local qingshil_distance = fk.CreateDistanceSkill{
  name = "#qingshil_distance",
  correct_func = function(self, from, to)
    local ret = 0
    if from:getMark("@@qingshil-round") > 0 then
      ret = ret + 1
    end
    if to:getMark("@@qingshil-round") > 0 then
      ret = ret + 1
    end
    return ret
  end,
}
local yilin = fk.CreateTriggerSkill{
  name = "yilin",
  anim_type = "support",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      for _, move in ipairs(data) do
        if move.toArea == Card.PlayerHand then
          if move.from == player.id and move.to ~= player.id and
            not player.room:getPlayerById(move.to).dead and not table.contains(U.getMark(player, "yilin-turn"), move.to) then
            for _, info in ipairs(move.moveInfo) do
              if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
                table.contains(player.room:getPlayerById(move.to):getCardIds("h"), info.cardId) then
                return true
              end
            end
          end
          if move.to == player.id and move.from and move.from ~= player.id and
            not table.contains(U.getMark(player, "yilin-turn"), player.id) then
            for _, info in ipairs(move.moveInfo) do
              if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
                table.contains(player:getCardIds("h"), info.cardId) then
                return true
              end
            end
          end
        end
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    local room = player.room
    local targets = {}
    for _, move in ipairs(data) do
      if move.toArea == Card.PlayerHand then
        if move.from == player.id and move.to ~= player.id and
          not table.contains(U.getMark(player, "yilin-turn"), move.to) then
          for _, info in ipairs(move.moveInfo) do
            if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
              table.contains(room:getPlayerById(move.to):getCardIds("h"), info.cardId) then
              table.insertIfNeed(targets, move.to)
            end
          end
        end
        if move.to == player.id and move.from and move.from ~= player.id and
          not table.contains(U.getMark(player, "yilin-turn"), player.id) then
          for _, info in ipairs(move.moveInfo) do
            if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
              table.contains(player:getCardIds("h"), info.cardId) then
                table.insertIfNeed(targets, player.id)
            end
          end
        end
      end
    end
    room:sortPlayersByAction(targets)
    for _, id in ipairs(targets) do
      if not player:hasSkill(self) then break end
      local to = room:getPlayerById(id)
      if to and not to.dead and not table.contains(U.getMark(player, "yilin-turn"), to.id) then
        self:doCost(event, to, player, data)
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#yilin-invoke::"..target.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    local mark = U.getMark(player, "yilin-turn")
    table.insert(mark, target.id)
    room:setPlayerMark(player, "yilin-turn", mark)
    local cards = {}
    if target == player then
      for _, move in ipairs(data) do
        if move.toArea == Card.PlayerHand and move.to == player.id and move.from and move.from ~= player.id then
          for _, info in ipairs(move.moveInfo) do
            if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
              table.contains(player:getCardIds("h"), info.cardId) then
              table.insertIfNeed(cards, info.cardId)
            end
          end
        end
      end
    else
      for _, move in ipairs(data) do
        if move.toArea == Card.PlayerHand and move.from == player.id and move.to == target.id then
          for _, info in ipairs(move.moveInfo) do
            if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
              table.contains(target:getCardIds("h"), info.cardId) then
              table.insertIfNeed(cards, info.cardId)
            end
          end
        end
      end
    end
    cards = U.moveCardsHoldingAreaCheck(room, cards)
    if #cards > 0 then
      local use = U.askForUseRealCard(room, target, cards, nil, self.name, "#yilin-use", {bypass_times = true}, true)
      if use then
        use.extraUse = true
        room:useCard(use)
      end
    end
  end,
}
local chengming = fk.CreateTriggerSkill{
  name = "chengming$",
  anim_type = "defensive",
  frequency = Skill.Limited,
  events = {fk.EnterDying},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryGame) == 0 and
      table.find(player.room:getOtherPlayers(player), function (p)
        return p.kingdom == "shu"
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(table.filter(room:getOtherPlayers(player), function (p)
      return p.kingdom == "shu"
    end), Util.IdMapper)
    local to = room:askForChoosePlayers(player, targets, 1, 1, "#chengming-choose", self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    if not player:isAllNude() then
      room:moveCardTo(player:getCardIds("hej"), Card.PlayerHand, to, fk.ReasonPrey, self.name, nil, false, to.id)
    end
    if player.hp < 1 and player:isWounded() and not player.dead then
      room:recover{
        who = player,
        num = 1 - player.hp,
        recoverBy = player,
        skillName = self.name,
      }
    end
    if not to.dead and table.find(to.player_skills, function (s)
      return s:isPlayerSkill(player) and s.visible and s.frequency == Skill.Compulsory
    end) and not to:hasSkill("ex__rende", true) then
      room:handleAddLoseSkills(to, "ex__rende", nil, true, false)
    end
  end,
}
qingshil:addRelatedSkill(qingshil_distance)
shzj_yiling__liubei:addSkill(qingshil)
shzj_yiling__liubei:addSkill(yilin)
shzj_yiling__liubei:addSkill(chengming)
shzj_yiling__liubei:addRelatedSkill("ex__rende")
Fk:loadTranslationTable{
  ["shzj_yiling__liubei"] = "刘备",
  ["#shzj_yiling__liubei"] = "见龙渊献",
  ["illustrator:shzj_yiling__liubei"] = "鬼画府",

  ["qingshil"] = "倾师",
  [":qingshil"] = "准备阶段，你可以令至多你体力值数量的角色进行议事，若结果为：红色，直到本轮结束，意见为红色的角色与除其以外的角色互相计算距离"..
  "+1；黑色，你摸意见为黑色的角色数量的牌，然后你可以交给任意名意见为黑色的其他角色各一张牌。",
  ["yilin"] = "夷临",
  [":yilin"] = "每回合每名角色限一次，当你获得其他角色的牌后，或当其他角色获得你的牌后，你可以令获得牌的角色选择是否使用其中一张牌。",
  ["chengming"] = "承命",
  [":chengming"] = "主公技，限定技，当你进入濒死状态时，你可以令一名其他蜀势力角色获得你区域内的所有牌，你将体力值回复至1点，若其有锁定技，其"..
  "获得技能〖仁德〗。",
  ["#qingshil-choose"] = "倾师：你可以令至多%arg名角色议事",
  ["#qingshil-give"] = "倾师：你可以交给其中任意名角色各一张牌",
  ["@@qingshil-round"] = "倾师",
  ["#yilin-invoke"] = "夷临：你可以令 %dest 可以使用其中一张牌",
  ["#yilin-use"] = "夷临：你可以使用其中一张牌",
  ["#chengming-choose"] = "承命：你可以令一名蜀势力角色获得你区域内所有牌，你回复体力至1点，若其有锁定技，其获得“仁德”",
}

local shzj_yiling__luxun = General(extension, "shzj_yiling__luxun", "wu", 3)
local qianshou = fk.CreateTriggerSkill{
  name = "qianshou",
  anim_type = "switch",
  switch_skill_name = "qianshou",
  events = {fk.TurnStart},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and target ~= player and (target.hp > player.hp or not target.chained) and not target.dead then
      if player:getSwitchSkillState(self.name, false) == fk.SwitchYang then
        return not player:isNude()
      else
        return not target:isNude()
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    if player:getSwitchSkillState(self.name, false) == fk.SwitchYang then
      local card = player.room:askForCard(player, 1, 1, true, self.name, true, ".|.|heart,diamond", "#qianshou-yang::"..target.id)
      if #card > 0 then
        self.cost_data = card[1]
        return true
      end
    else
      return player.room:askForSkillInvoke(player, self.name, nil, "#qianshou-yin::"..target.id)
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    if player:getSwitchSkillState(self.name, true) == fk.SwitchYang then
      local card = self.cost_data
      player:showCards(card)
      if player.dead or target.dead or not table.contains(player:getCardIds("h"), card) then return end
      room:setPlayerMark(player, "@@qianshou-turn", 1)
      room:setPlayerMark(target, "@@qianshou-turn", 1)
      room:moveCardTo(card, Card.PlayerHand, target, fk.ReasonGive, self.name, nil, true, player.id)
    else
      local card = room:askForCard(target, 1, 1, true, self.name, false, nil, "#qianshou-give:"..player.id)
      local color = Fk:getCardById(card[1]).color
      target:showCards(card)
      if player.dead or target.dead or not table.contains(target:getCardIds("h"), card[1]) then return end
      room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonGive, self.name, nil, true, target.id)
      if not player.dead and color ~= Card.Black then
        room:loseHp(player, 1, self.name)
      end
    end
  end,
}
local qianshou_prohibit = fk.CreateProhibitSkill{
  name = "#qianshou_prohibit",
  prohibit_use = function (self, player, card)
    if player:getMark("@@qianshou-turn") > 0 and player:usedSkillTimes("qianshou", Player.HistoryTurn) > 0 then
      local subcards = card:isVirtual() and card.subcards or {card.id}
      return #subcards > 0 and table.every(subcards, function(id)
        return table.contains(player:getCardIds("h"), id)
      end)
    end
  end,
  is_prohibited = function(self, from, to, card)
    return to:getMark("@@qianshou-turn") > 0
  end,
}
local tanlong = fk.CreateActiveSkill{
  name = "tanlong",
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  prompt = "#tanlong",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) <= Self:getMark("tanlong-phase")
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and Self:canPindian(Fk:currentRoom():getPlayerById(to_select))
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local pindian = player:pindian({target}, self.name)
    local winner, card = nil, nil
    if pindian.results[target.id].winner == player then
      winner = player
      card = pindian.results[target.id].toCard
    elseif pindian.results[target.id].winner == target then
      winner = target
      card = pindian.fromCard
    end
    if winner ~= nil and not winner.dead then
      if room:getCardArea(card) == Card.DiscardPile and room:askForSkillInvoke(winner, self.name, nil, "#tanlong-prey") then
        room:moveCardTo(card, Card.PlayerHand, winner, fk.ReasonJustMove, self.name, nil, true, winner.id)
      end
      if not winner.dead then
        room:useVirtualCard("iron_chain", nil, winner, winner, self.name)
      end
    end
  end,
}
local tanlong_trigger = fk.CreateTriggerSkill{
  name = "#tanlong_trigger",

  refresh_events = {fk.StartPlayCard},
  can_refresh = function (self, event, target, player, data)
    return target == player and player:hasSkill(tanlong, true)
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    local n = #table.filter(room.alive_players, function (p)
      return p.chained
    end)
    room:setPlayerMark(player, "tanlong-phase", n)
  end,
}
local xibei = fk.CreateTriggerSkill{
  name = "xibei",
  anim_type = "drawcard",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      for _, move in ipairs(data) do
        if move.to and move.to ~= player.id and move.toArea == Player.Hand then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea ~= Card.DrawPile then
              return true
            end
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(1, self.name)
    if player.phase == Player.Play and not player.dead and not player:isKongcheng() then
      local card = room:askForCard(player, 1, 1, false, self.name, true, ".|.|.|.|.|trick", "#xibei-show")
      if #card > 0 then
        player:showCards(card)
        if not player.dead and table.contains(player:getCardIds("h"), card[1]) then
          room:setCardMark(Fk:getCardById(card[1]), "@@xibei-inhand", 1)
        end
      end
    end
  end,

  refresh_events = {fk.AfterTurnEnd},
  can_refresh = function(self, event, target, player, data)
    return table.find(player:getCardIds("h"), function (id)
      return Fk:getCardById(id):getMark("@@xibei-inhand") > 0
    end)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    for _, id in ipairs(player:getCardIds("h")) do
      room:setCardMark(Fk:getCardById(id), "@@xibei-inhand", 0)
    end
  end,
}
local xibei_filter = fk.CreateFilterSkill{
  name = "#xibei_filter",
  anim_type = "offensive",
  card_filter = function(self, card, player)
    return card:getMark("@@xibei-inhand") > 0 and table.contains(player:getCardIds("h"), card.id)
  end,
  view_as = function(self, card)
    return Fk:cloneCard("shzj__burning_camps", card.suit, card.number)
  end,
}
qianshou:addRelatedSkill(qianshou_prohibit)
tanlong:addRelatedSkill(tanlong_trigger)
xibei:addRelatedSkill(xibei_filter)
shzj_yiling__luxun:addSkill(qianshou)
shzj_yiling__luxun:addSkill(tanlong)
shzj_yiling__luxun:addSkill(xibei)
Fk:loadTranslationTable{
  ["shzj_yiling__luxun"] = "陆逊",
  ["#shzj_yiling__luxun"] = "社稷心膂",
  ["illustrator:shzj_yiling__luxun"] = "鬼画府",

  ["qianshou"] = "谦守",
  [":qianshou"] = "转换技，其他角色回合开始时，若其体力值大于你，或其未处于横置状态，阳：你可以展示并交给其一张红色牌，本回合你不能使用手牌"..
  "且你与其不能成为牌的目标；阴：你可以令其展示并交给你一张牌，若不为黑色，你失去1点体力。",
  ["tanlong"] = "探龙",
  [":tanlong"] = "出牌阶段限X次，你可以与一名角色拼点，赢的角色可以获得没赢角色的拼点牌，然后其视为对自己使用【铁索连环】（X为横置角色数+1）。",
  ["xibei"] = "袭惫",
  [":xibei"] = "当其他角色从牌堆以外的区域获得牌后，你可以摸一张牌，若此时为你的出牌阶段，你可以展示一张锦囊牌，此牌视为【火烧连营】直到"..
  "本回合结束或离开你的手牌。<br>"..
  "<font color='grey'><small>【火烧连营】出牌阶段，对一名有牌的角色使用，你展示目标角色的一张牌，然后你可以弃置一张与展示牌花色相同的手牌，"..
  "若如此做，你弃置展示的牌并对其造成1点火焰伤害，然后若其处于横置状态，你获得弃牌堆中其展示的牌。</small></font>",
  ["#qianshou-yang"] = "谦守：是否交给 %dest 一张红色牌，令你本回合不能使用手牌、你与其不能成为牌的目标？",
  ["#qianshou-yin"] = "谦守：是否令 %dest 交给你一张牌？若不为黑色，你失去1点体力",
  ["#qianshou-give"] = "谦守：请交给 %src 一张牌，若不为黑色，其失去1点体力",
  ["@@qianshou-turn"] = "谦守",
  ["#tanlong"] = "探龙：与一名角色拼点，赢的角色获得没赢角色的拼点牌并视为对自己使用【铁索连环】",
  ["#tanlong-prey"] = "探龙：是否获得对方的拼点牌？",
  ["#xibei-show"] = "袭惫：你可以展示一张锦囊牌，将之视为【火烧连营】直到回合结束",
  ["@@xibei-inhand"] = "袭惫",
  ["#xibei_filter"] = "袭惫",
}

Fk:loadTranslationTable{
  ["shzj_yiling__wuban"] = "吴班",
  ["#shzj_yiling__wuban"] = "奉命诱贼",
  ["illustrator:shzj_yiling__wuban"] = "",

  ["youjun"] = "诱军",
  [":youjun"] = "出牌阶段限一次，你可以获得一名其他角色一张牌，然后其可以令其所有手牌视为【杀】直到回合结束，并视为对你使用【决斗】。",
  ["jicheng"] = "计成",
  [":jicheng"] = "限定技，当你受到普通锦囊牌的伤害后，若你的体力值不大于2，你可以回复1点体力或摸两张牌。",
}

Fk:loadTranslationTable{
  ["shzj_yiling__chenshi"] = "陈式",
  ["#shzj_yiling__chenshi"] = "夹岸屯军",
  ["illustrator:shzj_yiling__chenshi"] = "",

  ["zhuan"] = "驻岸",
  [":zhuan"] = "出牌阶段，你可以弃置一张【杀】并获得一名其他角色装备区内一张牌。一名角色使用装备牌后，你可以摸一张牌。",
}

Fk:loadTranslationTable{
  ["shzj_yiling__zhangnan"] = "张南",
  ["#shzj_yiling__zhangnan"] = "澄辉的义烈",
  ["illustrator:shzj_yiling__zhangnan"] = "",

  ["fenwu"] = "奋武",
  [":fenwu"] = "准备阶段，你可以摸一张牌并展示之，然后你可以将此牌当牌名字数与之相同的基本牌或【决斗】使用。",
}

Fk:loadTranslationTable{
  ["shzj_yiling__fengxi"] = "冯习",
  ["#shzj_yiling__fengxi"] = "赤胆的忠魂",
  ["illustrator:shzj_yiling__fengxi"] = "",

  ["qingkou"] = "轻寇",
  [":qingkou"] = "结束阶段，你可以摸一张牌并展示之，然后你可以将此牌当牌名字数与你的体力值相同的普通锦囊牌牌或【杀】使用。",
}

local chengji = General(extension, "chengji", "shu", 3)
local zhongen = fk.CreateTriggerSkill{
  name = "zhongen",
  mute = true,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target.phase == Player.Finish and
      #player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
        for _, move in ipairs(e.data) do
          if move.to == player.id and move.toArea == Card.PlayerHand then
            return true
          end
          if move.from == player.id then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.PlayerHand then
                return true
              end
            end
          end
        end
      end, Player.HistoryTurn) > 0
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local all_choices = {"zhongen_ex_nihilo::"..target.id, "zhongen_slash", "Cancel"}
    local choices = table.simpleClone(all_choices)
    if target.dead then
      table.remove(choices, 1)
    end
    local choice = ""
    while choice ~= "Cancel" do
      choice = room:askForChoice(player, choices, self.name, nil, false, all_choices)
      if choice == "zhongen_ex_nihilo::"..target.id then
        room:setPlayerMark(player, "zhongen-tmp", target.id)
        local success, dat = room:askForUseActiveSkill(player, "zhongen_active", "#zhongen-use::"..target.id, true)
        room:setPlayerMark(player, "zhongen-tmp", 0)
        if success and dat then
          self.cost_data = {dat.cards, 1}
          return true
        end
      elseif choice == "zhongen_slash" then
        local use = room:askForUseCard(player, self.name, "slash", "#zhongen-slash",
          true, {bypass_times = true, bypass_distances = true})
        if use then
          self.cost_data = {use, 2}
          return true
        end
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(self.name)
    if self.cost_data[2] == 1 then
      room:notifySkillInvoked(player, self.name, "support")
      room:useVirtualCard("ex_nihilo", self.cost_data[1], player, target, self.name)
    elseif self.cost_data[2] == 2 then
      room:notifySkillInvoked(player, self.name, "offensive")
      local use = self.cost_data[1]
      use.extraUse = true
      room:useCard(use)
    end
  end,
}
local zhongen_active = fk.CreateActiveSkill{
  name = "zhongen_active",
  card_num = 1,
  card_filter = function(self, to_select, selected)
    if #selected == 0 then
      local target = Fk:currentRoom():getPlayerById(Self:getMark("zhongen-tmp"))
      local card = Fk:cloneCard("ex_nihilo")
      card.skillName = "zhongen"
      card:addSubcard(to_select)
      return Fk:getCardById(to_select).trueName == "slash" and not Self:isProhibited(target, card)
    end
  end,
}
local liebao = fk.CreateTriggerSkill{
  name = "liebao",
  anim_type = "support",
  events = {fk.TargetConfirmed, fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    if data.card.trueName == "slash" then
      if event == fk.TargetConfirmed then
        return player:hasSkill(self) and data.from ~= player.id and
          table.every(player.room.alive_players, function (p)
          return p:getHandcardNum() >= target:getHandcardNum()
        end)
      elseif data.card and data.extra_data and data.extra_data.liebao and data.extra_data.liebao[1] == player.id then
        return not data.damageDealt or not data.damageDealt[player.id]
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    if event == fk.TargetConfirmed then
      local prompt = (target == player) and "#liebao-self" or "#liebao-invoke::"..target.id
      return player.room:askForSkillInvoke(player, self.name, nil, prompt)
    else
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.TargetConfirmed then
      AimGroup:cancelTarget(data, data.to)
      data.extra_data = data.extra_data or {}
      data.extra_data.liebao = {player.id, target.id}
      if not room:getPlayerById(data.from):isProhibited(player, data.card) then
        room:doIndicate(data.from, {player.id})
        AimGroup:addTargets(room, data, player.id)
      end
      player:drawCards(1, self.name)
    elseif event == fk.CardUseFinished then
      local to = room:getPlayerById(data.extra_data.liebao[2])
      room:doIndicate(player.id, {to.id})
      if to:isWounded() and not to.dead then
        room:recover({
          who = to,
          num = 1,
          recoverBy = player,
          skillName = self.name,
        })
      end
    end
  end,
}
Fk:addSkill(zhongen_active)
chengji:addSkill(zhongen)
chengji:addSkill(liebao)
Fk:loadTranslationTable{
  ["chengji"] = "程畿",
  ["#chengji"] = "大义之诚",
  ["illustrator:chengji"] = "荆芥",

  ["zhongen"] = "忠恩",
  [":zhongen"] = "一名角色结束阶段，若你本回合失去或获得过手牌，你可以将一张【杀】当【无中生有】对其使用，或使用一张无距离限制的【杀】。",
  ["liebao"] = "烈报",
  [":liebao"] = "一名角色成为【杀】的目标后，若其手牌数最少，你可以摸一张牌，代替其成为目标，若此【杀】未对你造成伤害，其回复1点体力。",
  ["zhongen_active"] = "忠恩",
  ["zhongen_ex_nihilo"] = "将一张【杀】当【无中生有】对%dest使用",
  ["zhongen_slash"] = "使用一张无距离限制的【杀】",
  ["#zhongen-use"] = "忠恩：将一张【杀】当【无中生有】对 %dest 使用",
  ["#zhongen-slash"] = "忠恩：使用一张无距离限制的【杀】",
  ["#liebao-self"] = "烈报：你可以摸一张牌，若此【杀】未对你造成伤害，你回复1点体力",
  ["#liebao-invoke"] = "烈报：你可以摸一张牌，代替 %dest 成为此【杀】目标，若未对你造成伤害，其回复1点体力",
}

local zhaorong = General(extension, "zhaorong", "shu", 4)
local yuantao = fk.CreateTriggerSkill{
  name = "yuantao",
  anim_type = "support",
  events = {fk.CardUsing},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and data.card.type == Card.TypeBasic and
      player:usedSkillTimes(self.name, Player.HistoryTurn) == 0
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, data, "#yuantao-invoke::"..target.id..":"..data.card:toLogString())
  end,
  on_use = function(self, event, target, player, data)
    data.additionalEffect = (data.additionalEffect or 0) + 1
  end,
}
local yuantao_delay = fk.CreateTriggerSkill{
  name = "#yuantao_delay",
  mute = true,
  events = {fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    return player:usedSkillTimes("yuantao", Player.HistoryTurn) > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("yuantao")
    room:notifySkillInvoked(player, "yuantao", "negative")
    room:loseHp(player, player:usedSkillTimes("yuantao", Player.HistoryTurn), "yuantao")
  end,
}
yuantao:addRelatedSkill(yuantao_delay)
zhaorong:addSkill(yuantao)
Fk:loadTranslationTable{
  ["zhaorong"] = "赵融",
  ["#zhaorong"] = "从龙别督",
  ["illustrator:zhaorong"] = "荆芥",

  ["yuantao"] = "援讨",
  [":yuantao"] = "每回合限一次，一名角色使用基本牌时，你可以令此牌额外结算一次，当前回合结束时，你失去1点体力。",
  ["#yuantao-invoke"] = "援讨：%dest 使用了%arg，是否令此牌额外结算一次？回合结束你失去1点体力",
  ["#yuantao_delay"] = "援讨",
}

Fk:loadTranslationTable{
  ["tanxiong"] = "谭雄",
  ["#tanxiong"] = "暗箭难防",
  ["illustrator:tanxiong"] = "荆芥",

  ["lengjian"] = "冷箭",
  [":lengjian"] = "锁定技，你每回合使用的第一张【杀】对攻击范围内的角色造成伤害+1，对攻击范围外的角色无距离限制且不能被响应。",
  ["sheju"] = "射驹",
  [":sheju"] = "当你使用【杀】结算后，你可以弃置其中一名目标角色一张牌，若不为坐骑牌，其本回合攻击范围+1，然后若其攻击范围内包含你，其可以对你"..
  "使用一张【杀】。",
}

local liue = General(extension, "liue", "wu", 5)
local xiyu = fk.CreateTriggerSkill{
  name = "xiyu",
  anim_type = "drawcard",
  events = {fk.TargetSpecified},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and data.card:isVirtual()-- and data.firstTarget
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
  end,
}
liue:addSkill(xiyu)
Fk:loadTranslationTable{
  ["liue"] = "刘阿",
  ["#liue"] = "西抵怒龙",
  ["illustrator:liue"] = "荆芥",

  ["xiyu"] = "西御",
  [":xiyu"] = "一名角色使用转化牌或虚拟牌指定目标后，你可以摸一张牌。",
}

Fk:loadTranslationTable{
  ["fanjiang"] = "范疆",
  ["#fanjiang"] = "有死无生",
  ["illustrator:fanjiang"] = "Qiyi",

  ["bianzhua"] = "鞭挝",
  [":bianzhua"] = "每回合限一次，当你成为伤害类牌的目标后，你可以将之置于你的武将牌上，称为“怨”。结束阶段，你可以依次将“怨”使用或置入弃牌堆。",
  ["benxiang"] = "奔降",
  [":benxiang"] = "锁定技，当你杀死一名角色后，你令一名其他角色摸三张牌。",
  ["xiezhan"] = "协战",
  [":xiezhan"] = "锁定技，游戏开始时，你选择范疆或张达；出牌阶段开始时，你变更武将牌。",
}

Fk:loadTranslationTable{
  ["zhangda"] = "张达",
  ["#zhangda"] = "有死无生",
  ["illustrator:zhangda"] = "Qiyi",

  ["xingsha"] = "刑杀",
  [":xingsha"] = "出牌阶段限一次，你可以将至多两张牌置于你的武将牌上，称为“怨”。结束阶段，你可以将两张“怨”当一张无距离限制的【杀】使用。",
  ["xianshou"] = "献首",
  [":xianshou"] = "锁定技，当你杀死一名角色后，你令一名其他角色回复2点体力。",
}

Fk:loadTranslationTable{
  ["shzj_yiling__guanyu"] = "神秘将军",
  ["#shzj_yiling__guanyu"] = "卷土重来",
  ["illustrator:shzj_yiling__guanyu"] = "MUMU",

  ["shzj_yiling__wusheng"] = "武圣",
  [":shzj_yiling__wusheng"] = "你可以将一张红色牌当【杀】使用或打出，你以此法使用的【杀】只能被花色相同的【闪】抵消。",
  ["chengshig"] = "乘势",
  [":chengshig"] = "锁定技，每回合限一次，当你于回合内使用红色【杀】造成伤害后，此【杀】不计入次数限制；当你于回合外使用红色【杀】造成伤害后，"..
  "受伤角色本回合不能使用伤害类牌指定除你以外的角色为目标。",
  ["fuwei"] = "扶危",
  [":fuwei"] = "每回合限一次，当一号位角色或刘备受到伤害后，你可以交给其至多X张牌，然后你可以对伤害来源依次使用至多X张【杀】（X为此伤害值）。",
}

Fk:loadTranslationTable{
  ["yanque"] = "阎鹊",--4
  ["#yanque"] = "神出鬼没",
  --["designer:yanque"] = "",
  ["illustrator:yanque"] = "",

  ["siji"] = "伺机",
  [":siji"] = "其他角色回合结束时，若其本回合不因使用和打出失去过牌，你可以将一张牌当无距离限制的刺【杀】对其使用。",
  ["cangshen"] = "藏身",
  [":cangshen"] = "锁定技，其他角色计算与你距离+1；当你使用【杀】后，〖藏身〗本轮失效。",
}

Fk:loadTranslationTable{
  ["wuque"] = "乌鹊",--4
  ["#wuque"] = "密执生死",
  --["designer:wuque"] = "",
  ["illustrator:wuque"] = "",

  ["ansha"] = "暗杀",
  [":ansha"] = "其他角色回合开始时，你可以将一张牌当刺【杀】对其使用，然后其计算与你距离视为1直到本轮结束。",
  --"藏身",
  ["xiongren"] = "凶刃",
  [":xiongren"] = "锁定技，你对与你距离大于1的角色使用【杀】造成伤害+1；你对与你距离不大于1的角色使用【杀】无距离次数限制。",
}

Fk:loadTranslationTable{
  ["wangque"] = "亡鹊",--3
  ["#wangque"] = "密执生死",
  --["designer:wangque"] = "",
  ["illustrator:wangque"] = "",

  ["daifa"] = "待发",
  [":daifa"] = "其他角色回合结束时，若其本回合获得过除其以外角色的牌，你可以将一张牌当无距离限制的刺【杀】对其使用。",
  --"藏身",
}

Fk:loadTranslationTable{
  ["shzj_yiling__guanxing"] = "关兴",
  ["#shzj_yiling__guanxing"] = "少有令问",
  --["designer:shzj_yiling__guanxing"] = "",
  ["illustrator:shzj_yiling__guanxing"] = "君桓文化",

  ["conglong"] = "从龙",
  [":conglong"] = "当一名角色使用红色【杀】时，你可以弃置一张锦囊牌，令此【杀】不能被响应。当红色【杀】对一名角色造成伤害时，你可以弃置一张"..
  "装备牌，令此伤害+1。每回合结束时，若你本回合弃置过至少两张牌，你可以摸一张牌。",
  ["xianwu"] = "显武",
  [":xianwu"] = "当你受到其他角色造成的伤害后，你可以弃置一张牌，直到本轮结束，你可以将一张红色牌当【杀】对其使用，且你对其使用牌无距离限制。",
}

local shzj_yiling__sunquan = General(extension, "shzj_yiling__sunquan", "shu", 3)
local fuhans = fk.CreateTriggerSkill{
  name = "fuhans",
  mute = true,
  events = {fk.AfterCardsMove, fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      if event == fk.AfterCardsMove then
        for _, move in ipairs(data) do
          if move.toArea == Card.PlayerHand then
            if move.to == player.id and move.from and move.from ~= player.id and
              #player:getAvailableEquipSlots() > 0 and not player.room:getPlayerById(move.from).dead then
              for _, info in ipairs(move.moveInfo) do
                if info.fromArea == Card.PlayerHand then
                  return true
                end
              end
            end
            if move.from == player.id and move.to ~= player.id and
              #player.sealedSlots > 0 and table.find(player.sealedSlots, function (slot)
                return slot ~= Player.JudgeSlot
              end) and not player.room:getPlayerById(move.to).dead then
              for _, info in ipairs(move.moveInfo) do
                if info.fromArea == Card.PlayerHand then
                  return true
                end
              end
            end
          end
        end
      else
        return player:usedSkillTimes(self.name, Player.HistoryTurn) > 0 and not target.dead and target:getHandcardNum() < target.maxHp
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    if event == fk.AfterCardsMove then
      local room = player.room
      local dat = {}
      for _, move in ipairs(data) do
        if move.toArea == Card.PlayerHand then
          if move.to == player.id and move.from and move.from ~= player.id then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.PlayerHand then
                table.insert(dat, {move.from, 1})
              end
            end
          end
          if move.from == player.id and move.to ~= player.id then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.PlayerHand then
                table.insert(dat, {move.to, 2})
              end
            end
          end
        end
      end
      for _, info in ipairs(dat) do
        if not player:hasSkill(self) then break end
        local to = room:getPlayerById(info[1])
        if to and not to.dead then
          if info[2] == 1 and #player:getAvailableEquipSlots() > 0 then
            self:doCost(event, to, player, 1)
          end
          if info[2] == 2 and #player.sealedSlots > 0 and table.find(player.sealedSlots, function (slot)
            return slot ~= Player.JudgeSlot
          end) then
            self:doCost(event, to, player, 2)
          end
        end
      end
    else
      self:doCost(event, target, player, data)
    end
  end,
  on_cost = function(self, event, target, player, data)
    if event == fk.AfterCardsMove then
      local slot = "Cancel"
      if data == 1 then
        local slots = table.simpleClone(player:getAvailableEquipSlots())
        table.insert(slots, "Cancel")
        slot = player.room:askForChoice(target, slots, self.name, "#fuhans1-invoke:"..player.id)
      else
        local slots = table.simpleClone(player.sealedSlots)
        table.removeOne(slots, Player.JudgeSlot)
        table.insert(slots, "Cancel")
        slot = player.room:askForChoice(target, slots, self.name, "#fuhans2-invoke:"..player.id)
      end
      if slot ~= "Cancel" then
        self.cost_data = slot
        return true
      end
    else
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(self.name)
    if event == fk.AfterCardsMove then
      if data == 1 then
        room:notifySkillInvoked(player, self.name, "negative")
        room:abortPlayerArea(player, self.cost_data)
      else
        room:notifySkillInvoked(player, self.name, "support")
        room:resumePlayerArea(player, {self.cost_data})
      end
    else
      room:doIndicate(player.id, {target.id})
      room:notifySkillInvoked(player, self.name, "support")
      target:drawCards(target.maxHp - target:getHandcardNum(), self.name)
    end
  end,
}
local chende = fk.CreateActiveSkill{
  name = "chende",
  anim_type = "support",
  min_card_num = 2,
  target_num = 1,
  prompt = "#chende",
  can_use = function(self, player)
    return not player:isKongcheng()
  end,
  card_filter = function (self, to_select, selected)
    return table.contains(Self:getCardIds("h"), to_select)
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    player:showCards(effect.cards)
    if player.dead or target.dead then return end
    local cards = table.filter(effect.cards, function (id)
      return table.contains(player:getCardIds("h"), id)
    end)
    if #cards == 0 then return end
    room:moveCardTo(cards, Card.PlayerHand, target, fk.ReasonGive, self.name, nil, true, player.id)
    if player.dead then return end
    cards = table.filter(U.getUniversalCards(room, "bt", true), function (id)
      return table.find(effect.cards, function (c)
        return Fk:getCardById(c).name == Fk:getCardById(id).name
      end)
    end)
    room:setPlayerMark(player, "chende-tmp", cards)
    local success, dat = room:askForUseActiveSkill(player, "chende_viewas", "#chende-use", true)
    room:setPlayerMark(player, "chende-tmp", 0)
    if success then
      local card = Fk.skills["chende_viewas"]:viewAs(dat.cards)
      local use = {
        from = player.id,
        tos = table.map(dat.targets, function(id) return {id} end),
        card = card,
        extraUse = true,
      }
      room:useCard(use)
    end
  end,
}
local chende_viewas = fk.CreateViewAsSkill{
  name = "chende_viewas",
  expand_pile = function(self)
    return U.getMark(Self, "chende-tmp")
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and table.contains(U.getMark(Self, "chende-tmp"), to_select) and
      Self:canUse(Fk:getCardById(to_select), {bypass_times = true})
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard(Fk:getCardById(cards[1]).name)
    card.skillName = "chende"
    return card
  end,
}
local wansu = fk.CreateTriggerSkill{
  name = "wansu",
  anim_type = "special",
  events = {fk.CardUsing, fk.PreDamage},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      if event == fk.CardUsing then
        return data.card:isVirtual() and table.find(player.room.alive_players, function (p)
          return #p.sealedSlots > 0 and table.find(p.sealedSlots, function (slot)
            return slot ~= Player.JudgeSlot
          end)
        end)
      elseif event == fk.PreDamage then
        return data.card and data.card:isVirtual()
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    if event == fk.CardUsing then
      local targets = table.filter(player.room.alive_players, function (p)
        return #p.sealedSlots > 0 and table.find(p.sealedSlots, function (slot)
          return slot ~= Player.JudgeSlot
        end)
      end)
      if #targets > 0 then
        data.disresponsiveList = data.disresponsiveList or {}
        for _, p in ipairs(targets) do
          table.insertIfNeed(data.disresponsiveList, p.id)
        end
      end
    elseif event == fk.PreDamage then
      player.room:loseHp(data.to, data.damage, self.name)
      return true
    end
  end,
}
Fk:addSkill(chende_viewas)
shzj_yiling__sunquan:addSkill(fuhans)
shzj_yiling__sunquan:addSkill(chende)
shzj_yiling__sunquan:addSkill(wansu)
Fk:loadTranslationTable{
  ["shzj_yiling__sunquan"] = "孙权",
  ["#shzj_yiling__sunquan"] = "<font color='green'>大汉吴王</font>",
  --["designer:shzj_yiling__sunquan"] = "",
  ["illustrator:shzj_yiling__sunquan"] = "荆芥",

  ["fuhans"] = "辅汉",
  [":fuhans"] = "当你获得其他角色的手牌后，其可以废除你一个装备栏；当其他角色获得你的手牌后，其可以恢复你一个装备栏。每个回合结束时，若你"..
  "本回合发动过此技能，你令当前回合角色将手牌摸至体力上限。",
  ["chende"] = "臣德",
  [":chende"] = "出牌阶段，你可以展示并交给其他角色至少两张手牌，然后你可以视为使用其中一张基本牌或普通锦囊牌。",
  ["wansu"] = "完夙",
  [":wansu"] = "锁定技，有装备栏被废除的角色不能响应虚拟牌；虚拟牌造成的伤害均改为失去体力。",
  ["#fuhans1-invoke"] = "辅汉：是否废除 %src 一个装备栏？回合结束时当前回合角色将手牌摸至体力上限",
  ["#fuhans2-invoke"] = "辅汉：是否恢复 %src 一个装备栏？回合结束时当前回合角色将手牌摸至体力上限",
  ["#chende"] = "臣德：交给一名角色至少两张手牌，然后你可以视为使用其中一张牌",
  ["chende_viewas"] = "臣德",
  ["#chende-use"] = "臣德：你可以视为使用其中一张牌",
}

return extension
