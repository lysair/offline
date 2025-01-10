local extension = Package("shzj")
extension.extensionName = "offline"

Fk:loadTranslationTable{
  ["shzj"] = "线下-山河煮酒",
  ["shzj_xiangfan"] = "龙起襄樊",
  ["shzj_yiling"] = "桃园挽歌",
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
      not data.to.dead and player.room.logic:damageByCardEffect()
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
    return card and table.contains(card.skillNames, "juesui&")
  end,
}
local juesui = fk.CreateTriggerSkill{
  name = "juesui",
  anim_type = "support",
  events = {fk.EnterDying},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and not target.dead and not table.contains(player:getTableMark("juesui_used"), target.id) and
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
    room:addTableMark(player, "juesui_used", target.id)
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

local shzj_xiangfan__pangde = General(extension, "shzj_xiangfan__pangde", "wei", 4)
local taiguan = fk.CreateActiveSkill{
  name = "taiguan",
  anim_type = "offensive",
  card_num = 1,
  target_num = 1,
  prompt = "#taiguan",
  times = function(self)
    return Self.phase == Player.Play and math.max(Self:getLostHp(), 1) - Self:usedSkillTimes(self.name, Player.HistoryPhase) or -1
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) < math.max(player:getLostHp(), 1)
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and not Self:prohibitDiscard(Fk:getCardById(to_select))
  end,
  target_filter = function(self, to_select, selected)
    local target = Fk:currentRoom():getPlayerById(to_select)
    return #selected == 0 and not target:isNude() and Self:inMyAttackRange(target)
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:throwCard(effect.cards, self.name, player, player)
    if target.dead then return end
    local card = room:askForDiscard(target, 1, 1, true, self.name, false, nil, "#taiguan-discard:"..player.id)
    if #card > 0 then
      card = Fk:getCardById(card[1])
      if card.trueName ~= "slash" and target.hp >= player.hp and not player.dead and not target.dead then
        room:useVirtualCard("duel", nil, player, target, self.name)
      end
    end
  end,
}
shzj_xiangfan__pangde:addSkill(taiguan)
shzj_xiangfan__pangde:addSkill("mashu")
Fk:loadTranslationTable{
  ["shzj_xiangfan__pangde"] = "庞德",
  ["#shzj_xiangfan__pangde"] = "意怒气壮",
  ["illustrator:shzj_xiangfan__pangde"] = "鬼画府",

  ["taiguan"] = "抬棺",
  [":taiguan"] = "出牌阶段限X次，你可以弃置一张牌并令攻击范围内的一名其他角色弃置一张牌，若其弃置的不为【杀】且你的体力值不大于其，你视为对其"..
  "使用一张【决斗】（X为你已损失体力值，至少为1）。",
  ["#taiguan"] = "抬棺：弃置一张牌，令一名角色弃一张牌",
  ["#taiguan-discard"] = "抬棺：你需弃置一张牌，若不为【杀】且你体力值不小于 %src，视为其对你使用【决斗】",
}

local lvchang = General(extension, "lvchang", "wei", 4)
local juwu = fk.CreateTriggerSkill{
  name = "juwu",
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  events = {fk.PreCardEffect},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and data.card.name == "slash" and data.to == player.id and data.from then
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
  name = "#shouxiang_delay",
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
    room:askForYiji(player, player:getCardIds("h"), room:getOtherPlayers(player, false), "shouxiang", 0, n, "#shouxiang-give:::"..n,
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
  [":juwu"] = "锁定技，若一名角色攻击范围内包含至少三名角色，该角色对你使用的普通【杀】无效。",
  ["shouxiang"] = "守襄",
  [":shouxiang"] = "摸牌阶段，你可以多摸X张牌，然后跳过你的出牌阶段。若如此做，此回合的弃牌阶段开始时，你可以交给至多X名角色各一张手牌"..
  "（X为攻击范围内含有你的角色数且至多为3）。",
  ["#shouxiang-invoke"] = "守襄：你可以多摸%arg张牌并跳过出牌阶段，弃牌阶段开始时可以将牌交给其他角色",
  ["#shouxiang_delay"] = "守襄",
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
    local discussion = U.Discussion(player, targets, self.name)
    if discussion.color == "red" then
      for _, p in ipairs(targets) do
        if not p.dead and discussion.results[p.id].opinion == "red" then
          room:setPlayerMark(p, "@@qingshil-round", 1)
        end
      end
    elseif discussion.color == "black" then
      if player.dead then return end
      local n = #table.filter(targets, function (p)
        return discussion.results[p.id].opinion == "black"
      end)
      player:drawCards(n, self.name)
      if player.dead or player:isNude() then return end
      targets = table.filter(targets, function (p)
        return discussion.results[p.id].opinion == "black" and not p.dead and p ~= player
      end)
      if #targets == 0 then return end
      room:askForYiji(player, player:getCardIds("he"), targets, self.name, 0, 999, "#qingshil-give", nil, false, 1)
    end
  end,

  refresh_events = {fk.GameStart},
  can_refresh = function(self, event, target, player, data)
    if player:hasSkill(self) then
      local cards = table.filter(U.prepareDeriveCards(player.room, {
        {"shzj__dragon_phoenix", Card.Spade, 2}
      }, self.name), function (id)
        return player.room:getCardArea(id) == Card.Void
      end)
      return #cards > 0 and player:hasEmptyEquipSlot(Card.SubtypeWeapon)
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local cards = table.filter(U.prepareDeriveCards(player.room, {
      {"shzj__dragon_phoenix", Card.Spade, 2}
    }, self.name), function (id)
      return player.room:getCardArea(id) == Card.Void
    end)
    room:moveCardIntoEquip(player, cards[1], self.name, false, player.id)
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
            not player.room:getPlayerById(move.to).dead and not table.contains(player:getTableMark("yilin-turn"), move.to) then
            for _, info in ipairs(move.moveInfo) do
              if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
                table.contains(player.room:getPlayerById(move.to):getCardIds("h"), info.cardId) then
                return true
              end
            end
          end
          if move.to == player.id and move.from and move.from ~= player.id and
            not table.contains(player:getTableMark("yilin-turn"), player.id) then
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
          not table.contains(player:getTableMark("yilin-turn"), move.to) then
          for _, info in ipairs(move.moveInfo) do
            if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
              table.contains(room:getPlayerById(move.to):getCardIds("h"), info.cardId) then
              table.insertIfNeed(targets, move.to)
              break
            end
          end
        end
        if move.to == player.id and move.from and move.from ~= player.id and
          not table.contains(player:getTableMark("yilin-turn"), player.id) then
          for _, info in ipairs(move.moveInfo) do
            if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
              table.contains(player:getCardIds("h"), info.cardId) then
              table.insertIfNeed(targets, player.id)
              break
            end
          end
        end
      end
    end
    room:sortPlayersByAction(targets)
    for _, id in ipairs(targets) do
      if not player:hasSkill(self) then break end
      local to = room:getPlayerById(id)
      if to and not to.dead and not table.contains(player:getTableMark("yilin-turn"), to.id) then
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
    room:addTableMark(player, "yilin-turn", target.id)
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
      table.find(player.room:getOtherPlayers(player, false), function (p)
        return p.kingdom == "shu"
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(table.filter(room:getOtherPlayers(player, false), function (p)
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
  [":qingshil"] = "准备阶段，你可以令至多你体力值数量的角色进行议事，若结果为：红色，直到本轮结束，意见为红色的角色与除其以外的角色互相"..
  "计算距离+1；黑色，你摸意见为黑色的角色数量的牌，然后你可以交给任意名意见为黑色的其他角色各一张牌。<br>"..
  "游戏开始时，将<a href=':shzj__dragon_phoenix'>【飞龙夺凤】</a>置入你的装备区。",
  ["yilin"] = "夷临",
  [":yilin"] = "每回合每名角色限一次，当你获得其他角色的牌后，或当其他角色获得你的牌后，你可以令获得牌的角色选择是否使用其中一张牌。",
  ["chengming"] = "承命",
  [":chengming"] = "主公技，限定技，当你进入濒死状态时，你可以令一名其他蜀势力角色获得你区域内的所有牌，你将体力值回复至1点，若其有锁定技，"..
  "其获得技能〖仁德〗。",
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
      if player.dead or target.dead or not table.contains(player:getCardIds("he"), card) then return end
      room:setPlayerMark(player, "@@qianshou-turn", 1)
      room:setPlayerMark(target, "@@qianshou-turn", 1)
      room:moveCardTo(card, Card.PlayerHand, target, fk.ReasonGive, self.name, nil, true, player.id)
    else
      local card = room:askForCard(target, 1, 1, true, self.name, false, nil, "#qianshou-give:"..player.id)
      local color = Fk:getCardById(card[1]).color
      target:showCards(card)
      if player.dead or target.dead or not table.contains(target:getCardIds("he"), card[1]) then return end
      room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonGive, self.name, nil, true, target.id)
      if not player.dead and color ~= Card.Black then
        room:loseHp(player, 1, self.name)
      end
    end
  end,

  refresh_events = {fk.GameStart},
  can_refresh = function(self, event, target, player, data)
    if player:hasSkill(self) then
      local cards = table.filter(U.prepareDeriveCards(player.room, {
        {"imperial_sword", Card.Spade, 5}
      }, self.name), function (id)
        return player.room:getCardArea(id) == Card.Void
      end)
      return #cards > 0 and player:hasEmptyEquipSlot(Card.SubtypeWeapon)
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local cards = table.filter(U.prepareDeriveCards(player.room, {
      {"imperial_sword", Card.Spade, 5}
    }, self.name), function (id)
      return player.room:getCardArea(id) == Card.Void
    end)
    room:moveCardIntoEquip(player, cards[1], self.name, false, player.id)
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
  "且你与其不能成为牌的目标；阴：你可以令其展示并交给你一张牌，若不为黑色，你失去1点体力。<br>"..
  "游戏开始时，将<a href=':imperial_sword'>【尚方宝剑】</a>置入你的装备区。",
  ["tanlong"] = "探龙",
  [":tanlong"] = "出牌阶段限X次，你可以与一名角色拼点，赢的角色可以获得没赢角色的拼点牌，然后其视为对自己使用【铁索连环】（X为横置角色数+1）。",
  ["xibei"] = "袭惫",
  [":xibei"] = "当其他角色从牌堆以外的区域获得牌后，你可以摸一张牌，若此时为你的出牌阶段，你可以展示一张锦囊牌，此牌视为"..
  "<a href=':shzj__burning_camps'>【火烧连营】</a>直到本回合结束或离开你的手牌。",
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

local shzj_yiling__wuban = General(extension, "shzj_yiling__wuban", "shu", 4)
local youjun = fk.CreateActiveSkill{
  name = "youjun",
  anim_type = "control",
  prompt = "#youjun",
  card_num = 0,
  target_num = 1,
  can_use = function (self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function (self, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= Self.id and not Fk:currentRoom():getPlayerById(to_select):isNude()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local card = room:askForCardChosen(player, target, "he", self.name, "#youjun-prey::"..target.id)
    room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonPrey, self.name, nil, true, player.id)
    if player.dead or target.dead then return end
    if room:askForSkillInvoke(target, self.name, nil, "#youjun-duel:"..player.id) then
      room:setPlayerMark(target, "@@youjun-turn", 1)
      room:useVirtualCard("duel", nil, target, player, self.name)
    end
  end,
}
local youjun_filter = fk.CreateFilterSkill{
  name = "#youjun_filter",
  card_filter = function(self, card, player)
    return player:getMark("@@youjun-turn") > 0 and table.contains(player.player_cards[Player.Hand], card.id)
  end,
  view_as = function(self, card)
    return Fk:cloneCard("slash", card.suit, card.number)
  end,
}
local jicheng = fk.CreateTriggerSkill{
  name = "jicheng",
  anim_type = "masochism",
  frequency = Skill.Limited,
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card and data.card.type == Card.TypeTrick and
      player.hp < 3 and player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choices = {"draw2"}
    if player:isWounded() then
      table.insert(choices, "recover")
    end
    local choice = room:askForChoice(player, choices, self.name)
    if choice == "draw2" then
      player:drawCards(2, self.name)
    else
      room:recover({
        who = player,
        num = 1,
        recoverBy = player,
        skillName = self.name,
      })
    end
  end,
}
youjun:addRelatedSkill(youjun_filter)
shzj_yiling__wuban:addSkill(youjun)
shzj_yiling__wuban:addSkill(jicheng)
Fk:loadTranslationTable{
  ["shzj_yiling__wuban"] = "吴班",
  ["#shzj_yiling__wuban"] = "奉命诱贼",
  ["illustrator:shzj_yiling__wuban"] = "吕金宝",

  ["youjun"] = "诱军",
  [":youjun"] = "出牌阶段限一次，你可以获得一名其他角色一张牌，然后其可以令其所有手牌视为【杀】直到回合结束，并视为对你使用【决斗】。",
  ["jicheng"] = "计成",
  [":jicheng"] = "限定技，当你受到普通锦囊牌的伤害后，若你的体力值不大于2，你可以回复1点体力或摸两张牌。",
  ["#youjun"] = "诱军：获得一名角色一张牌，其可以令其手牌视为【杀】直到回合结束并视为对你使用【决斗】",
  ["#youjun-prey"] = "诱军：获得 %dest 一张牌",
  ["#youjun-duel"] = "诱军：是否令你所有手牌视为【杀】直到回合结束，并视为对 %src 使用【决斗】？",
  ["@@youjun-turn"] = "诱军",
  ["#youjun_filter"] = "诱军",
}

local shzj_yiling__chenshi = General(extension, "shzj_yiling__chenshi", "shu", 4)
local zhuan = fk.CreateActiveSkill{
  name = "zhuan",
  anim_type = "control",
  prompt = "#zhuan",
  card_num = 1,
  target_num = 1,
  can_use = Util.TrueFunc,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).trueName == "slash" and not Self:prohibitDiscard(to_select)
  end,
  target_filter = function (self, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= Self.id and #Fk:currentRoom():getPlayerById(to_select):getCardIds("e") > 0
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:throwCard(effect.cards, self.name, player, player)
    if player.dead or target.dead or #target:getCardIds("e") == 0 then return end
    local card = room:askForCardChosen(player, target, "e", self.name, "#zhuan-prey::"..target.id)
    room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonPrey, self.name, nil, true, player.id)
  end,
}
local zhuan_trigger = fk.CreateTriggerSkill{
  name = "#zhuan_trigger",
  mute = true,
  main_skill = zhuan,
  events = {fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(zhuan) and data.card.type == Card.TypeEquip
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, "zhuan", nil, "#zhuan-draw")
  end,
  on_use = function(self, event, target, player, data)
    player:broadcastSkillInvoke("zhuan")
    player.room:notifySkillInvoked(player, "zhuan", "drawcard")
    player:drawCards(1, "zhuan")
  end,
}
zhuan:addRelatedSkill(zhuan_trigger)
shzj_yiling__chenshi:addSkill(zhuan)
Fk:loadTranslationTable{
  ["shzj_yiling__chenshi"] = "陈式",
  ["#shzj_yiling__chenshi"] = "夹岸屯军",
  ["illustrator:shzj_yiling__chenshi"] = "凡果",

  ["zhuan"] = "驻岸",
  [":zhuan"] = "出牌阶段，你可以弃置一张【杀】并获得一名其他角色装备区内一张牌。一名角色使用装备牌后，你可以摸一张牌。",
  ["#zhuan"] = "驻岸：你可以弃一张【杀】，获得一名其他角色装备区一张牌",
  ["#zhuan-prey"] = "驻岸：获得 %dest 装备区一张牌",
  ["#zhuan-draw"] = "驻岸：你可以摸一张牌",
}

local shzj_yiling__zhangnan = General(extension, "shzj_yiling__zhangnan", "shu", 4)
local fenwu = fk.CreateTriggerSkill{
  name = "fenwu",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Start
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local id = player:drawCards(1, self.name)[1]
    if player.dead or not table.contains(player:getCardIds("h"), id) then return end
    player:showCards(id)
    if player.dead or not table.contains(player:getCardIds("h"), id) then return end
    local n = Fk:translate(Fk:getCardById(id).trueName, "zh_CN"):len()
    local names = {}
    if n == 1 then
      names = U.getAllCardNames("b", false)
    end
    table.insert(names, "duel")
    room:setPlayerMark(player, "fenwu-tmp", {id, names})
    local success, dat = room:askForUseActiveSkill(player, "fenwu_viewas", "#fenwu-use", true,
      {bypass_times = true, extraUse = true})
    room:setPlayerMark(player, "fenwu-tmp", 0)
    if success then
      local card = Fk:cloneCard(dat.interaction)
      card.skillName = self.name
      card:addSubcard(id)
      room:useCard{
        from = player.id,
        tos = table.map(dat.targets, function(id) return {id} end),
        card = card,
        extraUse = true,
      }
    end
  end,
}
local fenwu_viewas = fk.CreateViewAsSkill{
  name = "fenwu_viewas",
  interaction = function()
    return UI.ComboBox {choices = Self:getMark("fenwu-tmp")[2] }
  end,
  card_filter = function(self, to_select, selected)
    return to_select == Self:getMark("fenwu-tmp")[1]
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = "fenwu"
    card:addSubcards(cards)
    return card
  end,
}
Fk:addSkill(fenwu_viewas)
shzj_yiling__zhangnan:addSkill(fenwu)
Fk:loadTranslationTable{
  ["shzj_yiling__zhangnan"] = "张南",
  ["#shzj_yiling__zhangnan"] = "澄辉的义烈",
  ["illustrator:shzj_yiling__zhangnan"] = "Aaron",

  ["fenwu"] = "奋武",
  [":fenwu"] = "准备阶段，你可以摸一张牌并展示之，然后你可以将此牌当【决斗】或牌名字数相同与此牌相同的基本牌使用。",
  ["fenwu_viewas"] = "奋武",
  ["#fenwu-use"] = "奋武：你可以将这张牌转化使用",
}

local shzj_yiling__fengxi = General(extension, "shzj_yiling__fengxi", "shu", 4)
local qingkou = fk.CreateTriggerSkill{
  name = "qingkou",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Finish
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local id = player:drawCards(1, self.name)[1]
    if player.dead or not table.contains(player:getCardIds("h"), id) then return end
    player:showCards(id)
    if player.dead or not table.contains(player:getCardIds("h"), id) then return end
    local names = {"slash"}
    for _, i in ipairs(Fk:getAllCardIds()) do
      local card = Fk:getCardById(i)
      if card:isCommonTrick() and Fk:translate(card.trueName, "zh_CN"):len() == player.hp and not card.is_derived then
        table.insertIfNeed(names, card.name)
      end
    end
    room:setPlayerMark(player, "qingkou-tmp", {id, names})
    local success, dat = room:askForUseActiveSkill(player, "qingkou_viewas", "#qingkou-use", true,
      {bypass_times = true, extraUse = true})
    room:setPlayerMark(player, "qingkou-tmp", 0)
    if success then
      local card = Fk:cloneCard(dat.interaction)
      card.skillName = self.name
      card:addSubcard(id)
      room:useCard{
        from = player.id,
        tos = table.map(dat.targets, function(id) return {id} end),
        card = card,
        extraUse = true,
      }
    end
  end,
}
local qingkou_viewas = fk.CreateViewAsSkill{
  name = "qingkou_viewas",
  interaction = function()
    return UI.ComboBox {choices = Self:getMark("qingkou-tmp")[2] }
  end,
  card_filter = function(self, to_select, selected)
    return to_select == Self:getMark("qingkou-tmp")[1]
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = "qingkou"
    card:addSubcards(cards)
    return card
  end,
}
Fk:addSkill(qingkou_viewas)
shzj_yiling__fengxi:addSkill(qingkou)
Fk:loadTranslationTable{
  ["shzj_yiling__fengxi"] = "冯习",
  ["#shzj_yiling__fengxi"] = "赤胆的忠魂",
  ["illustrator:shzj_yiling__fengxi"] = "陈鑫",

  ["qingkou"] = "轻寇",
  [":qingkou"] = "结束阶段，你可以摸一张牌并展示之，然后你可以将此牌当【杀】或牌名字数与你体力值相同的普通锦囊牌使用。",
  ["qingkou_viewas"] = "轻寇",
  ["#qingkou-use"] = "轻寇：你可以将这张牌转化使用",
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
      player:usedSkillTimes(self.name, Player.HistoryTurn) == 0 and
      target:canUse(data.card, {bypass_times = true})
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, data, "#yuantao-invoke::"..target.id..":"..data.card:toLogString())
  end,
  on_use = function(self, event, target, player, data)
    data.extra_data = data.extra_data or {}
    data.extra_data.yuantao = data.extra_data.yuantao or {}
    data.extra_data.yuantao = {
      from = target.id,
      tos = TargetGroup:getRealTargets(data.tos),
      times = (data.extra_data.yuantao.times or 0) + 1,
    }
  end,
}
local yuantao_delay = fk.CreateTriggerSkill{
  name = "#yuantao_delay",
  mute = true,
  events = {fk.CardUseFinished, fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    if event == fk.CardUseFinished then
      if data.extra_data and data.extra_data.yuantao then
        local room = player.room
        local from = room:getPlayerById(data.extra_data.yuantao.from)
        if from.dead or from:prohibitUse(data.card) then return end
        if table.find(data.extra_data.yuantao.tos, function (id)
          local p = room:getPlayerById(id)
          return not p.dead and from:canUseTo(data.card, p, {bypass_times = true})
        end) then
          self.cost_data = table.simpleClone(data.extra_data.yuantao)
          data.extra_data.yuantao = nil
          return true
        end
      end
    elseif event == fk.TurnEnd then
      return player:usedSkillTimes("yuantao", Player.HistoryTurn) > 0
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.CardUseFinished then
      local n = self.cost_data.times
      for i = 1, n, 1 do
        local from = room:getPlayerById(self.cost_data.from)
        if from.dead or from:prohibitUse(data.card) then return end
        local tos = table.filter(self.cost_data.tos, function (id)
          local p = room:getPlayerById(id)
          return not p.dead and from:canUseTo(data.card, p, {bypass_times = true})
        end)
        if #tos == 0 then return end
        local use = {
          from = from.id,
          tos = table.map(tos, function(id) return {id} end),
          card = data.card,
          extraUse = true,
        }
        room:useCard(use)
      end
    elseif event == fk.TurnEnd then
      player:broadcastSkillInvoke("yuantao")
      room:notifySkillInvoked(player, "yuantao", "negative")
      room:loseHp(player, player:usedSkillTimes("yuantao", Player.HistoryTurn), "yuantao")
    end
  end,
}
yuantao:addRelatedSkill(yuantao_delay)
zhaorong:addSkill(yuantao)
Fk:loadTranslationTable{
  ["zhaorong"] = "赵融",
  ["#zhaorong"] = "从龙别督",
  ["illustrator:zhaorong"] = "荆芥",

  ["yuantao"] = "援讨",
  [":yuantao"] = "每回合限一次，一名角色使用基本牌时，你可以令此牌结算后额外使用一次，当前回合结束时，你失去1点体力。",
  ["#yuantao-invoke"] = "援讨：%dest 使用了%arg，是否令此牌额外使用一次？回合结束你失去1点体力",
  ["#yuantao_delay"] = "援讨",
}

local tanxiong = General(extension, "tanxiong", "wu", 4)
local lengjian = fk.CreateTriggerSkill{
  name = "lengjian",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.DamageCaused, fk.CardUsing},
  can_trigger = function(self, event, target, player, data)
    if target and target == player and player:hasSkill(self) and data.card and data.card.trueName == "slash" and
      #player.room.logic:getEventsOfScope(GameEvent.UseCard, 2, function (e)
        return e.data[1].from == player.id and e.data[1].card.trueName == "slash"
      end, Player.HistoryTurn) == 1 then
      if event == fk.DamageCaused then
        return player:inMyAttackRange(data.to) and data.by_user
      else
        return table.find(TargetGroup:getRealTargets(data.tos), function (id)
          return not player:inMyAttackRange(player.room:getPlayerById(id))
        end)
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    if event == fk.DamageCaused then
      data.damage = data.damage + 1
    else
      data.disresponsiveList = data.disresponsiveList or {}
      for _, p in ipairs(player.room:getOtherPlayers(player, false)) do
        if not player:inMyAttackRange(p) then
          table.insertIfNeed(data.disresponsiveList, p.id)
        end
      end
    end
  end,

  refresh_events = {fk.AfterCardUseDeclared},
  can_refresh = function (self, event, target, player, data)
    return target == player and player:hasSkill(self, true) and data.card.trueName == "slash"
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:addPlayerMark(player, "lengjian-turn", 1)
  end,

  on_acquire = function (self, player, is_start)
    local room = player.room
    if #room.logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
      local use = e.data[1]
      return use.from == player.id and use.card.trueName == "slash"
    end, Player.HistoryTurn) > 0 then
      room:addPlayerMark(player, "lengjian-turn", 1)
    end
  end,
}
local lengjian_targetmod = fk.CreateTargetModSkill{
  name = "#lengjian_targetmod",
  frequency = Skill.Compulsory,
  main_skill = lengjian,
  bypass_distances = function(self, player, skill, card, to)
    return player:hasSkill(lengjian) and skill.trueName == "slash_skill" and
      player:getMark("lengjian-turn") == 0
  end,
}
local sheju = fk.CreateTriggerSkill{
  name = "sheju",
  anim_type = "control",
  events = {fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card.trueName == "slash" and
      table.find(TargetGroup:getRealTargets(data.tos), function (id)
        local p = player.room:getPlayerById(id)
        return not p.dead and not p:isNude()
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local targets = table.filter(TargetGroup:getRealTargets(data.tos), function (id)
      local p = player.room:getPlayerById(id)
      return not p.dead and not p:isNude()
    end)
    local to = player.room:askForChoosePlayers(player, targets, 1, 1, "#sheju-choose", self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    local card = room:askForCardChosen(player, to, "he", self.name, "#sheju-discard::"..to.id)
    local yes = not table.contains({Card.SubtypeOffensiveRide, Card.SubtypeDefensiveRide}, Fk:getCardById(card).sub_type)
    room:throwCard(card, self.name, to, player)
    if yes and not to.dead then
      room:addPlayerMark(to, "@sheju-turn", 1)
      if not player.dead and to:inMyAttackRange(player) then
        local use = room:askForUseCard(to, self.name, "slash", "#sheju-slash::"..player.id, true,
          {bypass_times = true, must_targets = {player.id}})
        if use then
          use.extraUse = true
          room:useCard(use)
        end
      end
    end
  end,
}
local sheju_attackrange = fk.CreateAttackRangeSkill{
  name = "#sheju_attackrange",
  correct_func = function (self, from, to)
    return from:getMark("@sheju-turn")
  end,
}
lengjian:addRelatedSkill(lengjian_targetmod)
sheju:addRelatedSkill(sheju_attackrange)
tanxiong:addSkill(lengjian)
tanxiong:addSkill(sheju)
Fk:loadTranslationTable{
  ["tanxiong"] = "谭雄",
  ["#tanxiong"] = "暗箭难防",
  ["illustrator:tanxiong"] = "荆芥",

  ["lengjian"] = "冷箭",
  [":lengjian"] = "锁定技，你每回合使用的第一张【杀】对攻击范围内的角色造成伤害+1，对攻击范围外的角色无距离限制且不能被响应。",
  ["sheju"] = "射驹",
  [":sheju"] = "当你使用【杀】结算后，你可以弃置其中一名目标角色一张牌，若不为坐骑牌，其本回合攻击范围+1，然后若其攻击范围内包含你，其可以"..
  "对你使用一张【杀】。",
  ["#sheju-choose"] = "射驹：你可以弃置其中一名角色一张牌，若不为坐骑牌，其本回合攻击范围+1，若攻击范围内包含你，其可以对你使用【杀】",
  ["#sheju-discard"] = "射驹：弃置 %dest 一张牌",
  ["@sheju-turn"] = "射驹",
  ["#sheju-slash"] = "射驹：你可以对 %dest 使用一张【杀】",
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

local shzj_yiling__shamoke = General(extension, "shzj_yiling__shamoke", "shu", 4)
local manyong = fk.CreateTriggerSkill{
  name = "manyong",
  events = {fk.TurnStart, fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) then
      local yes = table.find(player:getEquipments(Card.SubtypeWeapon), function(id)
        return Fk:getCardById(id).name == "iron_bud"
      end)
      if event == fk.TurnStart and not yes then
        local cards = table.filter(U.prepareDeriveCards(player.room, {{"iron_bud", Card.Spade, 5}}, self.name), function (id)
          return player.room:getCardArea(id) == Card.Void
        end)
        return #cards > 0 and not player:isProhibited(player, Fk:getCardById(cards[1]))
      elseif event == fk.TurnEnd then
        return yes
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    if event == fk.TurnStart then
      return player.room:askForSkillInvoke(player, self.name, nil, "#manyong-use")
    elseif event == fk.TurnEnd then
      return player.room:askForSkillInvoke(player, self.name, nil, "#manyong-discard")
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.TurnStart then
      local id = table.filter(U.prepareDeriveCards(room, {{"iron_bud", Card.Spade, 5}}, self.name), function (id)
        return room:getCardArea(id) == Card.Void
      end)[1]
      local card = Fk:getCardById(id)
      room:setCardMark(card, MarkEnum.DestructOutMyEquip, 1)
      room:useCard({
        from = player.id,
        tos = {{player.id}},
        card = card,
      })
    elseif event == fk.TurnEnd then
      local cards = table.filter(player:getEquipments(Card.SubtypeWeapon), function(id)
        return Fk:getCardById(id).name == "iron_bud"
      end)
      room:throwCard(cards, self.name, player, player)
    end
  end,
}
shzj_yiling__shamoke:addSkill("jilis")
shzj_yiling__shamoke:addSkill(manyong)
Fk:loadTranslationTable{
  ["shzj_yiling__shamoke"] = "沙摩柯",
  ["#shzj_yiling__shamoke"] = "狂喜胜战",
  ["illustrator:shzj_yiling__shamoke"] = "铁杵文化",

  ["manyong"] = "蛮勇",
  [":manyong"] = "回合开始时，若你的装备区内没有<a href=':iron_bud'>【铁蒺藜骨朵】</a>，你可以从游戏外使用之。回合结束时，"..
  "你可以弃置装备区内的【铁蒺藜骨朵】。【铁蒺藜骨朵】离开装备区后销毁。",
  ["#manyong-use"] = "蛮勇：是否从游戏外装备【铁蒺藜骨朵】？",
  ["#manyong-discard"] = "蛮勇：是否弃置装备区内的【铁蒺藜骨朵】？",
}

local shzj_yiling__godliubei = General(extension, "shzj_yiling__godliubei", "god", 6)
local shzj_yiling__longnu = fk.CreateViewAsSkill{
  name = "shzj_yiling__longnu",
  switch_skill_name = "shzj_yiling__longnu",  --用以显示图标
  anim_type = "offensive",
  pattern = "slash|.|.|.|fire__slash,thunder__slash",
  prompt = function ()
    if Self:getMark("shzj_yiling__longnu-phase") == "yang" then
      return "#shzj_yiling__longnu_yang"
    elseif Self:getMark("shzj_yiling__longnu-phase") == "yin" then
      return "#shzj_yiling__longnu_yin"
    end
  end,
  card_filter = function(self, to_select, selected)
    if #selected == 0 then
      if Self:getMark("shzj_yiling__longnu-phase") == "yang" then
        return Fk:getCardById(to_select).color == Card.Red
      elseif Self:getMark("shzj_yiling__longnu-phase") == "yin" then
        return Fk:getCardById(to_select).type == Card.TypeTrick
      end
    end
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard("slash")
    if Self:getMark("shzj_yiling__longnu-phase") == "yang" then
      card = Fk:cloneCard("fire__slash")
    elseif Self:getMark("shzj_yiling__longnu-phase") == "yin" then
      card = Fk:cloneCard("thunder__slash")
    end
    card:addSubcard(cards[1])
    card.skillName = self.name
    return card
  end,
  before_use = function (self, player, use)
    player.room:setPlayerMark(player, MarkEnum.SwithSkillPreName..self.name, player:getSwitchSkillState(self.name, true))
  end,
  enabled_at_play = function (self, player)
    return player:getMark("shzj_yiling__longnu-phase") ~= 0
  end,
  enabled_at_response = function (self, player)
    return player:getMark("shzj_yiling__longnu-phase") ~= 0
  end,
}
local shzj_yiling__longnu_trigger = fk.CreateTriggerSkill{
  name = "#shzj_yiling__longnu_trigger",
  events = {fk.EventPhaseStart},
  anim_type = "switch",
  switch_skill_name = "shzj_yiling__longnu",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Play
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, "shzj_yiling__longnu", nil,
      "#shzj_yiling__longnu_"..player:getSwitchSkillState("shzj_yiling__longnu", false, true).."-invoke")
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(1, "shzj_yiling__longnu")
    if player.dead then return end
    if player:getSwitchSkillState("shzj_yiling__longnu", true) == fk.SwitchYang then
      room:loseHp(player, 1, "shzj_yiling__longnu")
      if player.dead then return end
      room:setPlayerMark(player, "shzj_yiling__longnu-phase", "yang")
    else
      room:changeMaxHp(player, -1)
      if player.dead then return end
      room:setPlayerMark(player, "shzj_yiling__longnu-phase", "yin")
    end
  end,

  refresh_events = {fk.GameStart},
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(self)
  end,
  on_refresh = function(self, event, target, player, data)
    local switch_state = player.room:askForChoice(player,
      { "tymou_switch:::shzj_yiling__longnu:yang", "tymou_switch:::shzj_yiling__longnu:yin" },
      "shzj_yiling__longnu", "#tymou_switch-transer:::shzj_yiling__longnu") == "tymou_switch:::shzj_yiling__longnu:yin"
    if switch_state then
      player.room:setPlayerMark(player, MarkEnum.SwithSkillPreName.."shzj_yiling__longnu", fk.SwitchYin)
      player:setSkillUseHistory("shzj_yiling__longnu", 1, Player.HistoryGame)
    end
  end,
}
local shzj_yiling__longnu_targetmod = fk.CreateTargetModSkill{
  name = "#shzj_yiling__longnu_targetmod",
  bypass_distances =  function(self, player, skill, card, to)
    return player:getMark("shzj_yiling__longnu-phase") == "yang" and
      table.contains(card.skillNames, "shzj_yiling__longnu")
  end,
  bypass_times = function(self, player, skill, scope, card, to)
    return card and player:getMark("shzj_yiling__longnu-phase") == "yin" and scope == Player.HistoryPhase and
      table.contains(card.skillNames, "shzj_yiling__longnu")
  end,
}
local taoyuan = fk.CreateActiveSkill{
  name = "taoyuan",
  anim_type = "support",
  card_num = 2,
  target_num = 1,
  prompt = "#taoyuan",
  can_use = function(self, player)
    return player:getMark("taoyuan-phase") > 0 and player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, to_select, selected)
    return #selected < 2 and not Self:prohibitDiscard(Fk:getCardById(to_select))
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:throwCard(effect.cards, self.name, player, player)
    if target.dead then return end
    local cards = table.filter(U.prepareDeriveCards(player.room, {
      {"god_salvation", Card.Heart, 1},
      {"god_salvation", Card.Heart, 1},
      {"god_salvation", Card.Heart, 1},
    }, self.name), function (id)
      return room:getCardArea(id) == Card.Void
    end)
    if #cards == 0 then return end
    local card = Fk:getCardById(cards[1])
    room:setCardMark(card, MarkEnum.DestructIntoDiscard, 1)
    room:moveCardTo(card, Card.PlayerHand, target, fk.ReasonJustMove, self.name, nil, true, target.id)
  end,
}
local taoyuan_trigger = fk.CreateTriggerSkill{
  name = "#taoyuan_trigger",
  
  refresh_events = {fk.StartPlayCard},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(taoyuan) and player:usedSkillTimes(taoyuan.name, Player.HistoryPhase) == 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if #table.filter(U.prepareDeriveCards(player.room, {
      {"god_salvation", Card.Heart, 1},
      {"god_salvation", Card.Heart, 1},
      {"god_salvation", Card.Heart, 1},
    }, "taoyuan"), function (id)
      return room:getCardArea(id) == Card.Void
    end) > 0 then
      room:setPlayerMark(player, "taoyuan-phase", 1)
    end
  end,
}
taoyuan:addRelatedSkill(taoyuan_trigger)
shzj_yiling__longnu:addRelatedSkill(shzj_yiling__longnu_trigger)
shzj_yiling__longnu:addRelatedSkill(shzj_yiling__longnu_targetmod)
shzj_yiling__godliubei:addSkill(shzj_yiling__longnu)
shzj_yiling__godliubei:addSkill("jieying")
shzj_yiling__godliubei:addSkill(taoyuan)
Fk:loadTranslationTable{
  ["shzj_yiling__godliubei"] = "神刘备",
  ["#shzj_yiling__godliubei"] = "桃园挽歌",
  ["illustrator:shzj_yiling__godliubei"] = "点睛",

  ["shzj_yiling__longnu"] = "龙怒",
  [":shzj_yiling__longnu"] = "转换技，游戏开始时可自选阴阳状态；出牌阶段开始时，你可以摸一张牌，阳：失去1点体力，你此阶段可以将红色牌当"..
  "无距离限制的火【杀】使用或打出；阴：减1点体力上限，你此阶段可以将锦囊牌当无次数限制的雷【杀】使用或打出。",
  ["taoyuan"] = "桃园",
  [":taoyuan"] = "出牌阶段限一次，你可以弃置两张牌，令一名角色从游戏外获得一张【桃园结义】。（游戏外共有3张【桃园结义】，进入弃牌堆时销毁）",
  ["#shzj_yiling__longnu_trigger"] = "龙怒",
  ["#shzj_yiling__longnu_yang"] = "龙怒：你可以将红色牌当无距离限制的火【杀】使用或打出",
  ["#shzj_yiling__longnu_yin"] = "龙怒：你可以将锦囊牌当无次数限制的雷【杀】使用或打出",
  ["#shzj_yiling__longnu_yang-invoke"] = "龙怒：是否摸一张牌并失去1点体力，此阶段可以将红色牌当无距离限制的火【杀】使用或打出？",
  ["#shzj_yiling__longnu_yin-invoke"] = "龙怒：是否摸一张牌并减1点体力上限，此阶段可以将锦囊牌当无次数限制的雷【杀】使用或打出？",
  ["#taoyuan"] = "桃园：弃置两张牌，令一名角色从游戏外获得一张【桃园结义】",
}

local fanjiang = General(extension, "fanjiang", "wu", 4)
local bianzhua = fk.CreateTriggerSkill{
  name = "bianzhua",
  anim_type = "special",
  expand_pile = "$fanjiangzhangda_yuan",
  events = {fk.TargetConfirmed, fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) then
      if event == fk.TargetConfirmed then
        return data.card.is_damage_card and player:getMark("bianzhua-turn") == 0 and
          player.room:getCardArea(data.card) == Card.Processing
      else
        return player.phase == Player.Finish and #player:getPile("$fanjiangzhangda_yuan") > 0
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    if event == fk.TargetConfirmed then
      return player.room:askForSkillInvoke(player, self.name, nil, "#bianzhua-invoke:::"..data.card:toLogString())
    else
      local use = U.askForUseRealCard(player.room, player, {player:getPile("$fanjiangzhangda_yuan")[1]}, nil, self.name,
        "#bianzhua-use", {bypass_times = true, expand_pile = "$fanjiangzhangda_yuan"}, true, true)
      if use then
        self.cost_data = use
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.TargetConfirmed then
      room:setPlayerMark(player, "bianzhua-turn", 1)
      player:addToPile("$fanjiangzhangda_yuan", data.card, true, self.name, player.id)
    else
      local use = self.cost_data
      room:useCard(use)
      while not player.dead and #player:getPile("$fanjiangzhangda_yuan") > 0 do
        use = U.askForUseRealCard(player.room, player, {player:getPile("$fanjiangzhangda_yuan")[1]}, nil, self.name,
          "#bianzhua-use", {bypass_times = true, expand_pile = "$fanjiangzhangda_yuan"}, true, true)
        if use then
          room:useCard(use)
        else
          return
        end
      end
    end
  end,
}
local benxiang = fk.CreateTriggerSkill{
  name = "benxiang",
  anim_type = "support",
  events = {fk.Deathed},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and data.damage and data.damage.from == player and #player.room.alive_players > 1
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:askForChoosePlayers(player, table.map(room:getOtherPlayers(player, false), Util.IdMapper), 1, 1,
      "#benxiang-invoke", self.name, false)
    room:getPlayerById(to[1]):drawCards(3, self.name)
  end,
}
local xiezhan = fk.CreateTriggerSkill{
  name = "xiezhan",
  anim_type = "special",
  frequency = Skill.Compulsory,
  events = {fk.GameStart, fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      if event == fk.GameStart then
        return true
      else
        return target == player and player.phase == Player.Play
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local isDeputy = false
    if player.deputyGeneral == "fanjiang" or player.deputyGeneral == "zhangda" then
      isDeputy = true
    end
    local general
    if event == fk.GameStart then
      local result = room:askForCustomDialog(
        player, self.name,
        "packages/utility/qml/ChooseSkillFromGeneralBox.qml",
        { {"fanjiang", "zhangda"},
        {fanjiang:getSkillNameList(), Fk.generals["zhangda"]:getSkillNameList()},
        "#xiezhan-choose" }
      )
      if result == "" then
        return
      else
        result = json.decode(result)
      end
      general, _ = table.unpack(result)
    else
      if isDeputy then
        if player.deputyGeneral == "fanjiang" then
          general = "zhangda"
        else
          general = "fanjiang"
        end
      else
        if player.general == "fanjiang" then
          general = "zhangda"
        elseif player.general == "zhangda" then
          general = "fanjiang"
        else
          local result = room:askForCustomDialog(
            player, self.name,
            "packages/utility/qml/ChooseSkillFromGeneralBox.qml",
            { {"fanjiang", "zhangda"},
            {fanjiang:getSkillNameList(), Fk.generals["zhangda"]:getSkillNameList()},
            "#xiezhan-choose" }
          )
          if result == "" then
            result = {"fanjiang"}
          else
            result = json.decode(result)
          end
          general, _ = table.unpack(result)
        end
      end
    end
    if (isDeputy and player.deputyGeneral == general) or (not isDeputy and player.general == general) then return end
    room:changeHero(player, general, false, isDeputy, true, false, false)
  end,
}
fanjiang:addSkill(bianzhua)
fanjiang:addSkill(benxiang)
fanjiang:addSkill(xiezhan)
Fk:loadTranslationTable{
  ["fanjiang"] = "范疆",
  ["#fanjiang"] = "有死无生",
  ["illustrator:fanjiang"] = "Qiyi",

  ["bianzhua"] = "鞭挝",
  [":bianzhua"] = "每回合限一次，当你成为伤害类牌的目标后，你可以将之置于你的武将牌上，称为“怨”。结束阶段，你可以依次使用“怨”。",
  ["benxiang"] = "奔降",
  [":benxiang"] = "锁定技，当你杀死一名角色后，你令一名其他角色摸三张牌。",
  ["xiezhan"] = "协战",
  [":xiezhan"] = "锁定技，游戏开始时，你选择范疆或张达；出牌阶段开始时，你变更武将牌。",
  ["$fanjiangzhangda_yuan"] = "怨",
  ["#bianzhua-invoke"] = "鞭挝：是否将%arg置为“怨”？",
  ["#bianzhua-use"] = "鞭挝：你可以依次使用“怨”",
  ["#benxiang-invoke"] = "奔降：令一名其他角色摸三张牌",
  ["#xiezhan-choose"] = "协战：请选择变为范疆或张达",
}

local zhangda = General(extension, "zhangda", "wu", 4)
zhangda.hidden = true
local xingsha = fk.CreateActiveSkill{
  name = "xingsha",
  anim_type = "special",
  min_card_num = 1,
  max_card_num = 2,
  target_num = 0,
  prompt = "#xingsha",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function (self, to_select, selected)
    return #selected < 2
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    player:addToPile("$fanjiangzhangda_yuan", effect.cards, false, self.name, player.id)
  end,
}
local xingsha_trigger = fk.CreateTriggerSkill{
  name = "#xingsha_trigger",
  mute = true,
  main_skill = xingsha,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xingsha) and player.phase == Player.Finish and
      #player:getPile("$fanjiangzhangda_yuan") > 1
  end,
  on_cost = function(self, event, target, player, data)
    local success, dat = player.room:askForUseActiveSkill(player, "xingsha_active",
      "#xingsha-invoke", true, {bypass_times = true, bypass_distances = true})
    if success and dat then
      self.cost_data = dat
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("xingsha")
    room:notifySkillInvoked(player, "xingsha", "offensive")
    local card = Fk:cloneCard("slash")
    card:addSubcards(self.cost_data.cards)
    card.skillName = "xingsha"
    local use = {
      from = player.id,
      tos = table.map(self.cost_data.targets, function(id) return {id} end),
      card = card,
      extraUse = true,
    }
    room:useCard(use)
  end,
}
local xingsha_active = fk.CreateViewAsSkill{
  name = "xingsha_active",
  expand_pile = "$fanjiangzhangda_yuan",
  card_filter = function(self, to_select, selected)
    return #selected < 2 and table.contains(Self:getPile("$fanjiangzhangda_yuan"), to_select)
  end,
  view_as = function(self, cards)
    if #cards ~= 2 then return end
    local card = Fk:cloneCard("slash")
    card:addSubcards(cards)
    return card
  end,
}
local xianshouz = fk.CreateTriggerSkill{
  name = "xianshouz",
  anim_type = "support",
  events = {fk.Deathed},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and data.damage and data.damage.from == player and
      table.find(player.room:getOtherPlayers(player, false), function (p)
        return p:isWounded()
      end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player, false), function (p)
      return p:isWounded()
    end)
    local to = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 1,
      "#xianshouz-invoke", self.name, false)
    to = room:getPlayerById(to[1])
    room:recover({
      who = to,
      num = math.min(2, to:getLostHp()),
      recoverBy = player,
      skillName = self.name,
    })
  end,
}
Fk:addSkill(xingsha_active)
xingsha:addRelatedSkill(xingsha_trigger)
zhangda:addSkill(xingsha)
zhangda:addSkill(xianshouz)
zhangda:addSkill("xiezhan")
Fk:loadTranslationTable{
  ["zhangda"] = "张达",
  ["#zhangda"] = "有死无生",
  ["illustrator:zhangda"] = "Qiyi",

  ["xingsha"] = "刑杀",
  [":xingsha"] = "出牌阶段限一次，你可以将至多两张牌置于你的武将牌上，称为“怨”。结束阶段，你可以将两张“怨”当一张无距离限制的【杀】使用。",
  ["xianshouz"] = "献首",
  [":xianshouz"] = "锁定技，当你杀死一名角色后，你令一名其他角色回复2点体力。",
  ["#xingsha"] = "刑杀：将至多两张牌置为“怨”",
  ["xingsha_active"] = "刑杀",
  ["#xingsha-invoke"] = "刑杀：你可以将两张“怨”当一张无距离限制的【杀】使用",
  ["#xianshou-invoke"] = "献首：令一名其他角色回复2点体力",
}

local shzj_yiling__guanyu = General(extension, "shzj_yiling__guanyu", "shu", 5)
local shzj_yiling__wusheng = fk.CreateViewAsSkill{
  name = "shzj_yiling__wusheng",
  anim_type = "offensive",
  pattern = "slash",
  prompt = "#shzj_yiling__wusheng",
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).color == Card.Red
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard("slash")
    card.skillName = self.name
    card:addSubcards(cards)
    return card
  end,
}
local shzj_yiling__wusheng_trigger = fk.CreateTriggerSkill{
  name = "#shzj_yiling__wusheng_trigger",
  mute = true,
  events = {fk.PreCardEffect},
  can_trigger = function(self, event, target, player, data)
    return target == player and data.card.name == "jink" and data.responseToEvent and data.responseToEvent.card and
      table.contains(data.responseToEvent.card.skillNames, "shzj_yiling__wusheng") and
      (data.card.suit == Card.NoSuit or data.card.suit ~= data.responseToEvent.card.suit)
  end,
  on_cost = Util.TrueFunc,
  on_use = Util.TrueFunc,

  refresh_events = {fk.HandleAskForPlayCard},
  can_refresh = function(self, event, target, player, data)
    return data.eventData and data.eventData.from == player.id and
      table.contains(data.eventData.card.skillNames, "shzj_yiling__wusheng")
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if not data.afterRequest then
      room:setBanner("shzj_yiling__wusheng", data.eventData.card.suit)
    else
      room:setBanner("shzj_yiling__wusheng", 0)
    end
  end,
}
local shzj_yiling__wusheng_prohibit = fk.CreateProhibitSkill{
  name = "#shzj_yiling__wusheng_prohibit",
  prohibit_use = function(self, player, card)
    local room = Fk:currentRoom()
    local suit = room:getBanner("shzj_yiling__wusheng")
    if suit then
      if suit == Card.NoSuit then
        return true
      else
        if card:isVirtual() then
          if #card.subcards == 1 then
            return Fk:getCardById(card.subcards[1]).suit ~= suit
          else
            return true
          end
        else
          return card.suit ~= suit
        end
      end
    end
  end,
}
local chengshig = fk.CreateTriggerSkill{
  name = "chengshig",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.Damage},
  can_trigger = function(self, event, target, player, data)
    if target and target == player and player:hasSkill(self) and data.card and data.card.trueName == "slash" and
      data.card.color == Card.Red and player:usedSkillTimes(self.name, Player.HistoryTurn) == 0 then
      if player.phase ~= Player.NotActive then
        local use_event = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
        if use_event ~= nil then
          local use = use_event.data[1]
          return not use.extraUse
        end
      else
        return not data.to.dead
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if player.phase ~= Player.NotActive then
      player:addCardUseHistory(data.card.trueName, -1)
      local use_event = room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
      if use_event ~= nil then
        local use = use_event.data[1]
        use.extraUse = true
      end
    else
      room:doIndicate(player.id, {data.to.id})
      local mark = data.to:getTableMark("chengshig-turn")
      table.insert(mark, player.id)
      room:setPlayerMark(data.to, "chengshig-turn", mark)
    end
  end,
}
local chengshig_prohibit = fk.CreateProhibitSkill{
  name = "#chengshig_prohibit",
  is_prohibited = function(self, from, to, card)
    return from:getMark("chengshig-turn") ~= 0 and card and not table.contains(from:getTableMark("chengshig-turn"), to.id) and
      card.is_damage_card
  end,
}
local fuwei = fk.CreateTriggerSkill{
  name = "fuwei",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and
      (target.seat == 1 or target.general:endsWith("liubei") or target.deputyGeneral:endsWith("liubei")) and
      not player:isNude() and player:usedSkillTimes(self.name, Player.HistoryTurn) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local prompt
    if data.from and not data.from.dead and data.from ~= player then
      if target == player then
        return player.room:askForSkillInvoke(player, self.name)
      end
      prompt = "#fuwei1-give:"..data.from.id..":"..target.id..":"..data.damage
    else
      if target == player then
        return false
      end
      prompt = "#fuwei2-give::"..target.id..":"..data.damage
    end
    local cards = player.room:askForCard(player, 1, data.damage, true, self.name, true, nil, prompt)
    if #cards > 0 then
      self.cost_data = cards
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if target ~= player then
      room:moveCardTo(self.cost_data, Card.PlayerHand, target, fk.ReasonGive, self.name, nil, false, player.id)
    end
    if data.from and data.from ~= player then
      local n = data.damage
      for i = 1, n, 1 do
        if player.dead or data.from.dead then return end
        local use = room:askForUseCard(player, self.name, "slash", "#fuwei-slash::"..data.from.id..":"..i..":"..n, true,
          {bypass_times = true, bypass_distances = true, must_targets = {data.from.id}})
        if use then
          use.extraUse = true
          room:useCard(use)
        else
          return
        end
      end
    end
  end,
}
shzj_yiling__wusheng:addRelatedSkill(shzj_yiling__wusheng_trigger)
shzj_yiling__wusheng:addRelatedSkill(shzj_yiling__wusheng_prohibit)
chengshig:addRelatedSkill(chengshig_prohibit)
shzj_yiling__guanyu:addSkill(shzj_yiling__wusheng)
shzj_yiling__guanyu:addSkill(chengshig)
shzj_yiling__guanyu:addSkill(fuwei)
Fk:loadTranslationTable{
  ["shzj_yiling__guanyu"] = "神秘将军",
  ["#shzj_yiling__guanyu"] = "卷土重来",
  ["illustrator:shzj_yiling__guanyu"] = "MUMU",

  ["shzj_yiling__wusheng"] = "武圣",
  [":shzj_yiling__wusheng"] = "你可以将一张红色牌当【杀】使用或打出，你以此法使用的【杀】只能被花色相同的【闪】抵消。",
  ["chengshig"] = "乘势",
  [":chengshig"] = "锁定技，每回合限一次：当你于回合内使用红色【杀】造成伤害后，此【杀】不计入次数限制；当你于回合外使用红色【杀】"..
  "造成伤害后，受伤角色本回合不能使用伤害类牌指定除你以外的角色为目标。",
  ["fuwei"] = "扶危",
  [":fuwei"] = "每回合限一次，当一号位角色或刘备受到伤害后，你可以交给其至多X张牌，然后你可以对伤害来源依次使用至多X张【杀】（X为伤害值）。",
  ["#shzj_yiling__wusheng"] = "武圣：将一张红色牌当【杀】使用或打出，此【杀】只能被相同花色【闪】抵消",
  ["#fuwei1-give"] = "扶危：你可以交给 %dest 至多%arg张牌，然后可以对 %src 使用至多%arg张【杀】",
  ["#fuwei2-give"] = "扶危：你可以交给 %dest 至多%arg张牌",
  ["#fuwei-slash"] = "扶危：你可以对 %dest 使用【杀】（第%arg张，共%arg2张）",
}

local ansha_active = fk.CreateViewAsSkill{
  name = "ansha_active",
  card_filter = function(self, to_select, selected)
    return #selected == 0
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard("stab__slash")
    card:addSubcards(cards)
    return card
  end,
}
Fk:addSkill(ansha_active)

local yanque = General(extension, "yanque", "qun", 4)
local siji = fk.CreateTriggerSkill{
  name = "siji",
  anim_type = "offensive",
  events = {fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target ~= player and not target.dead and not player:isNude() and
    #player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
      for _, move in ipairs(e.data) do
        if move.from == target.id and move.moveReason ~= fk.ReasonUse and move.moveReason ~= fk.ReasonResonpse then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
              return true
            end
          end
        end
      end
    end, Player.HistoryTurn) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local success, dat = player.room:askForUseActiveSkill(player, "ansha_active",
      "#siji-invoke::"..target.id, true, {bypass_times = true, bypass_distances = true, must_targets = {target.id}})
    if success and dat then
      self.cost_data = dat
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = Fk:cloneCard("stab__slash")
    card:addSubcards(self.cost_data.cards)
    card.skillName = self.name
    local use = {
      from = player.id,
      tos = table.map(self.cost_data.targets, function(id) return {id} end),
      card = card,
      extraUse = true,
    }
    room:useCard(use)
  end,
}
local cangshen = fk.CreateDistanceSkill{
  name = "cangshen",
  frequency = Skill.Compulsory,
  correct_func = function(self, from, to)
    if to:hasSkill(self) then
      return 1
    end
    return 0
  end,
}
local cangshen_trigger = fk.CreateTriggerSkill{
  name = "#cangshen_trigger",

  refresh_events = {fk.CardUseFinished},
  can_refresh = function (self, event, target, player, data)
    return target == player and player:hasSkill(cangshen) and data.card.trueName == "slash"
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:invalidateSkill(player, "cangshen", "-round")
  end,
}
cangshen:addRelatedSkill(cangshen_trigger)
yanque:addSkill(siji)
yanque:addSkill(cangshen)
Fk:loadTranslationTable{
  ["yanque"] = "阎鹊",
  ["#yanque"] = "神出鬼没",
  ["illustrator:yanque"] = "紫芒小侠",

  ["siji"] = "伺机",
  [":siji"] = "其他角色回合结束时，若其本回合不因使用和打出失去过牌，你可以将一张牌当无距离限制的刺【杀】对其使用。",
  ["cangshen"] = "藏身",
  [":cangshen"] = "锁定技，其他角色计算与你距离+1；当你使用【杀】后，〖藏身〗本轮失效。",
  ["ansha_active"] = "",
  ["#siji-invoke"] = "伺机：你可以将一张牌当无距离限制的刺【杀】对 %dest 使用",
}

local wuque = General(extension, "wuque", "qun", 4)
local ansha = fk.CreateTriggerSkill{
  name = "ansha",
  anim_type = "offensive",
  events = {fk.TurnStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target ~= player and not target.dead and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local success, dat = player.room:askForUseActiveSkill(player, "ansha_active",
      "#ansha-invoke::"..target.id, true, {bypass_times = true, must_targets = {target.id}})
    if success and dat then
      self.cost_data = dat
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = Fk:cloneCard("stab__slash")
    card:addSubcards(self.cost_data.cards)
    card.skillName = self.name
    local use = {
      from = player.id,
      tos = table.map(self.cost_data.targets, function(id) return {id} end),
      card = card,
      extraUse = true,
    }
    room:useCard(use)
    if target.dead then return end
    room:addTableMark(player, "ansha-round", target.id)
  end,
}
local ansha_distance = fk.CreateDistanceSkill{
  name = "#ansha_distance",
  correct_func = function(self, from, to) return 0 end,
  fixed_func = function(self, from, to)
    local mark = to:getTableMark("ansha-round")
    if table.contains(mark, from.id) then
      return 1
    end
  end,
}
local xiongren = fk.CreateTriggerSkill{
  name = "xiongren",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.DamageCaused},
  can_trigger = function(self, event, target, player, data)
    return target and target == player and player:hasSkill(self) and data.to:distanceTo(player) > 1
    and data.card and data.card.trueName == "slash"
  end,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage + 1
  end,
}
local xiongren_targetmod = fk.CreateTargetModSkill{
  name = "#xiongren_targetmod",
  frequency = Skill.Compulsory,
  main_skill = xiongren,
  bypass_times = function(self, player, skill, scope, card, to)
    return player:hasSkill(xiongren) and skill.trueName == "slash_skill" and scope == Player.HistoryPhase and
      to:distanceTo(player) <= 1
  end,
  bypass_distances = function(self, player, skill, card, to)
    return player:hasSkill(xiongren) and skill.trueName == "slash_skill" and
      to:distanceTo(player) <= 1
  end,
}
ansha:addRelatedSkill(ansha_distance)
xiongren:addRelatedSkill(xiongren_targetmod)
wuque:addSkill(ansha)
wuque:addSkill("cangshen")
wuque:addSkill(xiongren)
Fk:loadTranslationTable{
  ["wuque"] = "乌鹊",
  ["#wuque"] = "密执生死",
  ["illustrator:wuque"] = "Mr_Sleeping",

  ["ansha"] = "暗杀",
  [":ansha"] = "其他角色回合开始时，你可以将一张牌当刺【杀】对其使用，此牌结算后，其计算与你距离视为1直到本轮结束。",
  ["xiongren"] = "凶刃",
  [":xiongren"] = "锁定技，你对与你距离大于1的角色使用【杀】造成伤害+1；你对与你距离不大于1的角色使用【杀】无距离次数限制。",
  ["#ansha-invoke"] = "暗杀：你可以将一张牌当刺【杀】对 %dest 使用，本轮其计算与你距离距离视为1",
}

local wangque = General(extension, "wangque", "qun", 3)
local daifa = fk.CreateTriggerSkill{
  name = "daifa",
  anim_type = "offensive",
  events = {fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target ~= player and not target.dead and not player:isNude() and
    #player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
      for _, move in ipairs(e.data) do
        if move.to == target.id and move.from and move.from ~= move.to then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
              return true
            end
          end
        end
      end
    end, Player.HistoryTurn) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local success, dat = player.room:askForUseActiveSkill(player, "ansha_active",
      "#daifa-invoke::"..target.id, true, {bypass_times = true, bypass_distances = true, must_targets = {target.id}})
    if success and dat then
      self.cost_data = dat
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = Fk:cloneCard("stab__slash")
    card:addSubcards(self.cost_data.cards)
    card.skillName = self.name
    local use = {
      from = player.id,
      tos = table.map(self.cost_data.targets, function(id) return {id} end),
      card = card,
      extraUse = true,
    }
    room:useCard(use)
  end,
}
wangque:addSkill(daifa)
wangque:addSkill("cangshen")
Fk:loadTranslationTable{
  ["wangque"] = "亡鹊",
  ["#wangque"] = "神鬼莫测",
  ["illustrator:wangque"] = "黑羽",

  ["daifa"] = "待发",
  [":daifa"] = "其他角色回合结束时，若其本回合获得过除其以外角色的牌，你可以将一张牌当无距离限制的刺【杀】对其使用。",
  ["#daifa-invoke"] = "待发：你可以将一张牌当无距离限制的刺【杀】对 %dest 使用",
}

local shzj_yiling__guanxings = General(extension, "shzj_yiling__guanxings", "shu", 4)
local conglong = fk.CreateTriggerSkill{
  name = "conglong",
  anim_type = "support",
  events = {fk.CardUsing, fk.DamageCaused, fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      if event == fk.CardUsing then
        return data.card.trueName == "slash" and data.card.color == Card.Red and not player:isKongcheng()
      elseif event == fk.DamageCaused then
        return data.card and data.card.trueName == "slash" and data.card.color == Card.Red and not player:isNude()
      elseif event == fk.TurnEnd then
        local x = 0
        local logic = player.room.logic
        logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
          for _, move in ipairs(e.data) do
            if move.from == player.id and move.moveReason == fk.ReasonDiscard then
              x = x + #move.moveInfo
              if x > 1 then return true end
            end
          end
          return false
        end, Player.HistoryTurn)
        return x > 1
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    if event == fk.TurnEnd then
      return player.room:askForSkillInvoke(player, self.name, nil, "#conglong3-invoke")
    else
      local pattern, prompt = ".|.|.|.|.|trick", "#conglong1-invoke::"..target.id..":"..data.card:toLogString()
      if event == fk.DamageCaused then
        pattern, prompt = ".|.|.|.|.|equip", "#conglong2-invoke::"..data.to.id..":"..data.card:toLogString()
      end
      local card = player.room:askForDiscard(player, 1, 1, true, self.name, true, pattern, prompt, true)
      if #card > 0 then
        self.cost_data = card
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.TurnEnd then
      player:drawCards(1, self.name)
    else
      room:throwCard(self.cost_data, self.name, player, player)
      if event == fk.CardUsing then
        data.disresponsiveList = table.map(room.alive_players, Util.IdMapper)
      elseif event == fk.DamageCaused then
        data.damage = data.damage + 1
      end
    end
  end,
}
local xianwu = fk.CreateViewAsSkill{
  name = "xianwu",
  anim_type = "offensive",
  pattern = "slash",
  prompt = "#xianwu",
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).color == Card.Red
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard("slash")
    card:addSubcard(cards[1])
    card.skillName = self.name
    return card
  end,
  enabled_at_play = function(self, player)
    return player:getMark("xianwu-round") ~= 0
  end,
  enabled_at_response = function(self, player, response)
    return not response and player:getMark("xianwu-round") ~= 0
  end,
}
local xianwu_trigger = fk.CreateTriggerSkill{
  name = "#xianwu_trigger",
  mute = true,
  main_skill = xianwu,
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xianwu) and data.from and data.from ~= player and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local card = player.room:askForDiscard(player, 1, 1, true, "xianwu", true, nil, "#xianwu-discard::"..data.from.id, true)
    if #card > 0 then
      self.cost_data = card
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("xianwu")
    room:notifySkillInvoked(player, "xianwu", "masochism")
    if not data.from.dead then
      room:doIndicate(player.id, {data.from.id})
      room:setPlayerMark(data.from, "@@xianwu-round", 1)
      room:addTableMark(player, "xianwu-round", data.from.id)
    end
    room:throwCard(self.cost_data, "xianwu", player, player)
  end,
}
local xianwu_prohibit = fk.CreateProhibitSkill{
  name = "#xianwu_prohibit",
  is_prohibited = function(self, from, to, card)
    return from:getMark("xianwu-round") ~= 0 and card and table.contains(card.skillNames, "xianwu") and
      not table.contains(from:getTableMark("xianwu-round"), to.id)
  end,
}
local xianwu_targetmod = fk.CreateTargetModSkill{
  name = "#xianwu_targetmod",
  bypass_distances = function(self, player, skill, card, to)
    return player:getMark("xianwu-round") ~= 0 and table.contains(player:getTableMark("xianwu-round"), to.id)
  end,
}
xianwu:addRelatedSkill(xianwu_trigger)
xianwu:addRelatedSkill(xianwu_prohibit)
xianwu:addRelatedSkill(xianwu_targetmod)
shzj_yiling__guanxings:addSkill(conglong)
shzj_yiling__guanxings:addSkill(xianwu)
Fk:loadTranslationTable{
  ["shzj_yiling__guanxings"] = "关兴",
  ["#shzj_yiling__guanxings"] = "少有令问",
  ["illustrator:shzj_yiling__guanxings"] = "君桓文化",

  ["conglong"] = "从龙",
  [":conglong"] = "当一名角色使用红色【杀】时，你可以弃置一张锦囊牌，令此【杀】不能被响应。当红色【杀】对一名角色造成伤害时，你可以弃置一张"..
  "装备牌，令此伤害+1。每回合结束时，若你本回合弃置过至少两张牌，你可以摸一张牌。",
  ["xianwu"] = "显武",
  [":xianwu"] = "当你受到其他角色造成的伤害后，你可以弃置一张牌，直到本轮结束，你可以将一张红色牌当【杀】对其使用，且你对其使用牌无距离限制。",
  ["#conglong1-invoke"] = "从龙：你可以弃置一张锦囊牌，令 %dest 使用的%arg不能被响应",
  ["#conglong2-invoke"] = "从龙：你可以弃置一张装备牌，%arg对 %dest 造成的伤害+1",
  ["#conglong3-invoke"] = "从龙：是否摸一张牌？",
  ["#xianwu_trigger"] = "显武",
  ["#xianwu-discard"] = "显武：你可以弃一张牌，令你本轮可以将红色牌当【杀】对 %dest 使用且对其使用牌无距离限制",
  ["@@xianwu-round"] = "显武",
  ["#xianwu"] = "显武：你可以将一张红色牌当【杀】对“显武”目标使用",
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
                break
              end
            end
          end
          if move.from == player.id and move.to ~= player.id then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.PlayerHand then
                table.insert(dat, {move.to, 2})
                break
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
    if player:getMark(self.name) == 0 then
      room:setPlayerMark(player, self.name, U.getUniversalCards(room, "bt"))
    end
    cards = table.filter(player:getMark(self.name), function (id)
      return table.find(effect.cards, function (c)
        return Fk:getCardById(c).name == Fk:getCardById(id).name
      end)
    end)
    if #cards > 0 then
      local use = U.askForUseRealCard(room, player, cards, nil, self.name,
        "#chende-use", {expand_pile = cards, bypass_times = true}, true, false)
      if use then
        local card = Fk:cloneCard(use.card.name)
        card.skillName = self.name
        room:useCard{
          card = card,
          from = player.id,
          tos = use.tos,
          extraUse = true,
        }
      end
    end
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
        return data.card:isVirtual() and #data.card.subcards == 0 and table.find(player.room.alive_players, function (p)
          return #p.sealedSlots > 0 and table.find(p.sealedSlots, function (slot)
            return slot ~= Player.JudgeSlot
          end)
        end)
      elseif event == fk.PreDamage then
        return data.card and data.card:isVirtual() and #data.card.subcards == 0
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
  ["#chende-use"] = "臣德：你可以视为使用其中一张牌",
}

local shzj_yiling__ganning = General(extension, "shzj_yiling__ganning", "wu", 4)
local qixi = fk.CreateViewAsSkill{
  name = "shzj_yiling__qixi",
  anim_type = "control",
  pattern = "dismantlement",
  prompt = "#shzj_yiling__qixi",
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).color == Card.Black
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then return end
    local c = Fk:cloneCard("dismantlement")
    c.skillName = self.name
    c:addSubcard(cards[1])
    return c
  end,
  before_use = function (self, player, use)
    if Fk:getCardById(use.card.subcards[1]).type ~= Card.TypeBasic then
      use.disresponsiveList = table.map(player.room.players, Util.IdMapper)
    end
  end,
  enabled_at_response = function (self, player, response)
    return not response
  end
}
local fenwei = fk.CreateTriggerSkill{
  name = "shzj_yiling__fenwei",
  anim_type = "defensive",
  events = {fk.TargetSpecified},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and data.card.type == Card.TypeTrick and #AimGroup:getAllTargets(data.tos) > 1 and data.firstTarget
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local success, dat = room:askForUseActiveSkill(player, "shzj_yiling__fenwei_active",
      "#shzj_yiling__fenwei-choose:::"..data.card:toLogString(), true, {exclusive_targets = AimGroup:getAllTargets(data.tos)})
    if success and dat then
      self.cost_data = {tos = dat.targets, choice = dat.interaction}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    table.insertTable(data.nullifiedTargets, self.cost_data.tos)
    if self.cost_data.choice == "shzj_yiling__fenwei2" then
      room:handleAddLoseSkills(player, "-"..self.name, nil, true, false)
    else
      room:loseHp(player, math.max(player:usedSkillTimes(self.name, Player.HistoryGame) - 1, 1), self.name)
    end
  end,
}
local fenwei_active = fk.CreateActiveSkill{
  name = "shzj_yiling__fenwei_active",
  card_num = 0,
  min_target_num = 1,
  interaction = function ()
    local n = math.max(Self:usedSkillTimes("shzj_yiling__fenwei", Player.HistoryGame), 1)
    return UI.ComboBox { choices = {"shzj_yiling__fenwei1:::"..n, "shzj_yiling__fenwei2"} }
  end,
  card_filter = Util.FalseFunc,
  target_filter = function (self, to_select, selected, selected_cards, card, extra_data)
    return table.contains(extra_data.exclusive_targets, to_select)
  end,
}
Fk:addSkill(fenwei_active)
shzj_yiling__ganning:addSkill(qixi)
shzj_yiling__ganning:addSkill(fenwei)
Fk:loadTranslationTable{
  ["shzj_yiling__ganning"] = "甘宁",
  ["#shzj_yiling__ganning"] = "锦帆英豪",
  ["illustrator:shzj_yiling__ganning"] = "鬼画府",

  ["shzj_yiling__qixi"] = "奇袭",
  [":shzj_yiling__qixi"] = "你可以将一张黑色牌当【过河拆桥】使用；你以此法用非基本牌转化的【过河拆桥】不能被响应。",
  ["shzj_yiling__fenwei"] = "奋威",
  [":shzj_yiling__fenwei"] = "当一张锦囊牌指定至少两个目标后，你可以失去X点体力或〖奋威〗，令此牌对其中任意名目标角色无效（X为你发动"..
  "〖奋威〗次数，至少为1）。",
  ["#shzj_yiling__qixi"] = "奇袭：将一张黑色牌当【过河拆桥】使用，用非基本牌转化的不能被响应",
  ["shzj_yiling__fenwei_active"] = "奋威",
  ["#shzj_yiling__fenwei-choose"] = "奋威：你可以执行一项，令此%arg对任意个目标无效",
  ["shzj_yiling__fenwei1"] = "失去%arg点体力",
  ["shzj_yiling__fenwei2"] = "失去“奋威”",
}

local shzj_yiling__buzhi = General(extension, "shzj_yiling__buzhi", "wu", 3)
local hongde = fk.CreateTriggerSkill{
  name = "shzj_yiling__hongde",
  anim_type = "control",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      for _, move in ipairs(data) do
        if #move.moveInfo > 1 and ((move.from == player.id and move.to ~= player.id) or
          (move.to == player.id and move.toArea == Card.PlayerHand)) then
          return true
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local success, dat = room:askForUseActiveSkill(player, "shzj_yiling__hongde_active", "#shzj_yiling__hongde-choose", true)
    if success and dat then
      self.cost_data = {tos = dat.targets, choice = dat.interaction}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data.tos[1])
    if self.cost_data.choice == "draw1" then
      to:drawCards(1, self.name)
    else
      room:askForDiscard(to, 1, 1, true, self.name, false)
    end
  end,
}
local hongde_active = fk.CreateActiveSkill{
  name = "shzj_yiling__hongde_active",
  card_num = 0,
  target_num = 1,
  interaction = function ()
    return UI.ComboBox { choices = {"draw1", "shzj_yiling__hongde_discard"} }
  end,
  card_filter = Util.FalseFunc,
  target_filter = function (self, to_select, selected, selected_cards)
    if #selected == 0 then
      if self.interaction.data == "draw1" then
        return true
      else
        if to_select == Self.id then
          return table.find(Self:getCardIds("he"), function (id)
            return not Self:prohibitDiscard(id)
          end)
        else
          return not Fk:currentRoom():getPlayerById(to_select):isNude()
        end
      end
    end
  end,
}
local dingpan = fk.CreateActiveSkill{
  name = "shzj_yiling__dingpan",
  anim_type = "offensive",
  card_num = 0,
  target_num = 1,
  prompt = "#shzj_yiling__dingpan",
  times = function(self)
    return Self.phase == Player.Play and
      #Self:getTableMark("shzj_yiling__dingpan-turn") - Self:usedSkillTimes(self.name, Player.HistoryPhase) or -1
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) < #player:getTableMark("shzj_yiling__dingpan-turn")
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and #Fk:currentRoom():getPlayerById(to_select):getCardIds("e") > 0
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    target:drawCards(1, self.name)
    if player.dead or target.dead then return end
    local choice = room:askForChoice(target, {"shzj_yiling__dingpan_discard:"..player.id, "dingpan_damage:"..player.id}, self.name)
    if choice:startsWith("shzj_yiling__dingpan_discard") then
      if target == player then
        room:askForDiscard(player, 2, 2, true, self.name, false, nil, "#shzj_yiling__dingpan-discard::"..target.id)
      else
        local n = math.min(#target:getCardIds("he"), 2)
        local cards = room:askForCardsChosen(player, target, n, n, "he", self.name, "#shzj_yiling__dingpan-discard::"..target.id)
        room:throwCard(cards, self.name, target, player)
      end
    else
      room:moveCardTo(target:getCardIds("e"), Card.PlayerHand, target, fk.ReasonJustMove, self.name, nil, true, target.id)
      if not target.dead then
        room:damage{
          from = player,
          to = target,
          damage = 1,
          skillName = self.name,
        }
      end
    end
  end,

  on_acquire = function (self, player, is_start)
    local room = player.room
    if player.phase == Player.Play then
      local types = {}
      room.logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
        local use = e.data[1]
        if use.from == player.id then
          table.insertIfNeed(types, use.card.type)
        end
      end, Player.HistoryTurn)
      room:setPlayerMark(player, "shzj_yiling__dingpan-turn", types)
    end
  end,
}
local dingpan_trigger = fk.CreateTriggerSkill{
  name = "#shzj_yiling__dingpan_trigger",

  refresh_events = {fk.AfterCardUseDeclared},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill("shzj_yiling__dingpan", true) and player.phase == Player.Play
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:addTableMarkIfNeed(player, "shzj_yiling__dingpan-turn", data.card.type)
  end,
}
dingpan:addRelatedSkill(dingpan_trigger)
Fk:addSkill(hongde_active)
shzj_yiling__buzhi:addSkill(hongde)
shzj_yiling__buzhi:addSkill(dingpan)
Fk:loadTranslationTable{
  ["shzj_yiling__buzhi"] = "步骘",
  ["#shzj_yiling__buzhi"] = "积跬靖边",
  ["illustrator:shzj_yiling__buzhi"] = "匠人绘",

  ["shzj_yiling__hongde"] = "弘德",
  [":shzj_yiling__hongde"] = "当你一次获得或失去至少两张牌后，你可以令一名角色摸一张牌或弃一张牌。",
  ["shzj_yiling__dingpan"] = "定叛",
  [":shzj_yiling__dingpan"] = "出牌阶段限X次，你可以令一名装备区里有牌的角色摸一张牌，然后其选择一项：1.令你弃置其两张牌；"..
  "2.获得其装备区里的所有牌，你对其造成1点伤害（X为你本回合使用过牌的类别数）。",
  ["shzj_yiling__hongde_active"] = "弘德",
  ["#shzj_yiling__hongde-choose"] = "弘德：你可以令一名角色摸一张牌或弃一张牌",
  ["#shzj_yiling__dingpan"] = "定叛：令一名装备区里有牌的角色摸一张牌，然后其选择你弃置其两张牌或收回装备并受到伤害",
  ["shzj_yiling__hongde_discard"] = "弃一张牌",
  ["shzj_yiling__dingpan_discard"] = "%src弃置你两张牌",
  ["#shzj_yiling__dingpan-discard"] = "定叛：弃置 %dest 两张牌",
}

local anying = General(extension, "anying", "qun", 3)
local liupo = fk.CreateTriggerSkill{
  name = "liupo",
  switch_skill_name = "liupo",
  anim_type = "switch",
  events = {fk.TurnStart},
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local isYang = player:getSwitchSkillState(self.name) == fk.SwitchYang
    local room = player.room
    if not isYang then
      room:setPlayerMark(player, "@liupo_buff-round", "liupo_prihibit_use")
    else
      room:setPlayerMark(player, "@liupo_buff-round", "liupo_lose_hp")
    end
  end,
}
local liupo_prhibit = fk.CreateProhibitSkill{
  name = "#liupo_prohibit",
  prohibit_use = function(self, player, card)
    return table.find(Fk:currentRoom().alive_players, function(p)
      return p:getMark("@liupo_buff-round") == "liupo_prihibit_use"
    end) and (card or {}).name == "peach"
  end,
}
local liupo_trigger = fk.CreateTriggerSkill{
  name = "#liupo_trigger",
  mute = true,
  events = {fk.PreDamage},
  can_trigger = function(self, event, target, player, data)
    return player:getMark("@liupo_buff-round") == "liupo_lose_hp"
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:loseHp(data.to, data.damage, self.name)
    return true
  end,
}
local zhuiling = fk.CreateTriggerSkill{
  name = "zhuiling",
  anim_type = "special",
  frequency = Skill.Compulsory,
  events = {fk.HpLost},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and (data.num or 0) > 0 and player:getMark("@anying_soul") < 3
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local num = math.min(3 - player:getMark("@anying_soul"), data.num)
    room:addPlayerMark(player, "@anying_soul", num)
  end,
}
local zhuiling_targetmod = fk.CreateTargetModSkill{
  name = "#zhuiling_targetmod",
  bypass_times = function(self, player, skill, scope, card, to)
    return card and player:hasSkill(self) and to:isKongcheng()
  end,
  bypass_distances =  function(self, player, skill, card, to)
    return card and player:hasSkill(self) and to:isKongcheng()
  end,
}
local xihun = fk.CreateTriggerSkill{
  name = "xihun",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.RoundEnd},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(room:getOtherPlayers(player, false), Util.IdMapper)
    room:sortPlayersByAction(targets)
    room:doIndicate(player.id, targets)
    for _, id in ipairs(targets) do
      local p = room:getPlayerById(id)
      if not p.dead then
        if #p:getCardIds("h") > 1 then
          local cids = room:askForDiscard(p, 2, 2, false, self.name, true, ".", "#xihun-discard")
          if #cids == 0 then
            room:loseHp(p, 1)
          end
        else
          room:loseHp(p, 1)
        end
      end
    end
    if not player.dead and player:getMark("@anying_soul") > 0 then
      local choices = {}
      for i = 1, player:getMark("@anying_soul") do
        table.insert(choices, tostring(i))
      end
      local choice = room:askForChoice(player, choices, self.name, "#xihun-choose")
      if choice and player:isWounded() then
        local n = tonumber(choice)
        local num = math.min(n, player.maxHp - player.hp)
        room:removePlayerMark(player, "@anying_soul", math.min(n, 1))
        room:recover{
          who = player,
          num = num,
          recoverBy = player,
          skillName = self.name,
        }
      end
    end
  end,
}
local xianqi = fk.CreateTriggerSkill{
  name = "xianqi",
  attached_skill_name = "xianqi_other&",
}
local xianqi_other = fk.CreateActiveSkill{
  name = "xianqi_other&",
  anim_type = "support",
  prompt = "#xianqi_other-active",
  mute = true,
  max_card_num = 2,
  target_num = 0,
  card_filter = function(self, to_select, selected)
    return #selected < 2 and table.contains(Self:getCardIds("h"), to_select)
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local cards = effect.cards
    local target = table.filter(room:getOtherPlayers(player), function(p)
      return p:hasSkill("xianqi")
    end)
    if #target > 0 then
      target = target[1]
      if #cards == 2 then
        room:throwCard(cards, self.name, player, player)
      else
        room:damage{
          from = player,
          to = player,
          damage = 1,
          skillName = self.name,
        }
      end
      if not target.dead then
        room:damage{
          from = nil,
          to = target,
          damage = 1,
          skillName = self.name,
        }
      end
    end
  end,
}
local fansheng = fk.CreateTriggerSkill{
  name = "fansheng",
  anim_type = "special",
  frequency = Skill.Compulsory,
  events = {fk.EnterDying},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self, true) and target == player and player:getMark("fansheng_used") == 0 then
      player.room:setPlayerMark(player, "fansheng_used", 1)
      return player:hasSkill(self)
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local num = 1 - player.hp
    room:recover{
      who = player,
      num = num,
      recoverBy = player,
      skillName = self.name
    }
    local targets = table.map(room:getOtherPlayers(player, false), Util.IdMapper)
    room:sortPlayersByAction(targets)
    room:doIndicate(player.id, targets)
    for _, id in ipairs(targets) do
      local p = room:getPlayerById(id)
      if not p.dead and #p:getCardIds("he") > 0 then
        local choices = {}
        if #p:getCardIds("h") > 0 then
          table.insert(choices, "#xihun-handcards")
        end
        if #p:getCardIds("e") > 0 then
          table.insert(choices, "#xihun-equipcards")
        end
        if #choices < 2 then
          room:throwCard(p:getCardIds("he"), self.name, p, p)
        else
          local choice = room:askForChoice(p, choices, self.name, "#fansheng-choose", nil, {"#xihun-handcards", "#xihun-equipcards"})
          if choice == "#xihun-handcards" then
            room:throwCard(p:getCardIds("h"), self.name, p, p)
          else
            room:throwCard(p:getCardIds("e"), self.name, p, p)
          end
        end
      end
    end
  end,
}
Fk:addSkill(xianqi_other)
liupo:addRelatedSkill(liupo_prhibit)
liupo:addRelatedSkill(liupo_trigger)
zhuiling:addRelatedSkill(zhuiling_targetmod)
anying:addSkill(liupo)
anying:addSkill(zhuiling)
anying:addSkill(xihun)
anying:addSkill(xianqi)
anying:addSkill(fansheng)
Fk:loadTranslationTable{
  ["anying"] = "暗影",
  ["#anying"] = "黑影笼罩",
  ["illustrator:anying"] = "黑白画谱",

  ["liupo"] = "流魄",
  [":liupo"] = "转换技，回合开始时，你令本轮：阳：所有角色不能使用【桃】；阴：所有即将造成的伤害均视为体力流失。",
  ["#liupo_prohibit"] = "流魄",
  ["#liupo_trigger"] = "流魄",
  ["@liupo_buff-round"] = "流魄",
  ["liupo_prihibit_use"] = "禁止用桃",
  ["liupo_lose_hp"] = "失去体力",
  ["zhuiling"] = "追灵",
  [":zhuiling"] = "锁定技，一名角色失去体力后，你获得等量的“魂”（“魂”至多为3）。你对没有手牌的角色使用牌无距离和次数限制。",
  ["@anying_soul"] = "魂",
  ["xihun"] = "吸魂",
  [":xihun"] = "锁定技，每轮结束时，所有其他角色依次选择弃置两张手牌或失去1点体力，然后你弃置任意个“魂”并回复等量体力。",
  ["#xihun-discard"] = "吸魂：你须弃置两张手牌，或点击取消，然后你失去1点体力",
  ["#xihun-choose"] = "吸魂：弃置任意个“魂”，然后回复等量体力",
  ["xianqi"] = "献气",
  [":xianqi"] = "其他角色出牌阶段限一次，其可以对其造成1点伤害或弃置两张手牌，然后你受到1点无来源伤害。",
  ["xianqi_other&"] = "献气",
  [":xianqi_other&"] = "出牌阶段限一次，你可以对你自身造成1点伤害或弃置两张手牌，然后令暗影受到1点无来源伤害。",
  ["#xianqi_other-active"] = "献气：选择两张手牌弃置，若选择数不为2，则改为对自己造成1点伤害，然后拥有“献气”的角色受到1点伤害",
  ["fansheng"] = "反生",
  [":fansheng"] = "锁定技，当你第一次进入濒死时，你将体力回复至1点，然后令所有其他角色依次选择弃置其所有手牌或弃置其装备区里的所有牌。",
  ["#fansheng-choose"] = "反生：你须选择一项",
  ["#xihun-handcards"] = "弃置所有手牌",
  ["#xihun-equipcards"] = "弃置装备区的所有牌",
}

return extension
