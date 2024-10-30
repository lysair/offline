local extension = Package("feihongyinxue")
extension.extensionName = "offline"

Fk:loadTranslationTable{
  ["feihongyinxue"] = "线下-飞鸿映雪",
  ["fhyx"] = "线下",
  ["fhyx_ex"] = "线下界",
  ["ofl_shiji"] = "线下始计篇",
}

local U = require "packages/utility/utility"

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
Fk:loadTranslationTable{
  ["@$fhyx_extra_pile"] = "额外牌堆",
}

local yanliangwenchou = General(extension, "fhyx_ex__yanliangwenchou", "qun", 4)
local fhyx_ex__shuangxiong = fk.CreateViewAsSkill{
  name = "fhyx_ex__shuangxiong",
  anim_type = "offensive",
  pattern = "duel",
  prompt = function ()
    local color = "red"
    if Self:getMark("@fhyx_ex__shuangxiong-phase") == "red" then
      color = "black"
    end
    return "#fhyx_ex__shuangxiong:::"..color
  end,
  card_filter = function(self, to_select, selected)
    if #selected == 1 then return false end
    local color = Fk:getCardById(to_select):getColorString()
    if color == "red" then
      color = "black"
    elseif color == "black" then
      color = "red"
    else
      return false
    end
    return table.contains(Self:getHandlyIds(true), to_select) and Self:getMark("@fhyx_ex__shuangxiong-phase") == color
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then return end
    local c = Fk:cloneCard("duel")
    c:addSubcard(cards[1])
    c.skillName = self.name
    return c
  end,
  enabled_at_play = function(self, player)
    return player:getMark("@fhyx_ex__shuangxiong-phase") ~= 0
  end,
  enabled_at_response = function(self, player)
    return player:getMark("@fhyx_ex__shuangxiong-phase") ~= 0
  end,
}
local fhyx_ex__shuangxiong_trigger = fk.CreateTriggerSkill{
  name = "#fhyx_ex__shuangxiong_trigger",
  mute = true,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Play and
      table.find(player.room.alive_players, function(p)
        return not p:isNude()
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(player.room.alive_players, function(p)
      return not p:isNude()
    end)
    local to = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 1,
      "#fhyx_ex__shuangxiong-choose", self.name, true)
    if #to > 0 then
      self.cost_data = {tos = to}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("fhyx_ex__shuangxiong")
    room:notifySkillInvoked(player, "fhyx_ex__shuangxiong", "control")
    player:revealBySkillName("fhyx_ex__shuangxiong")
    local to = room:getPlayerById(self.cost_data.tos[1])
    local card = room:askForDiscard(to, 1, 1, true, self.name, false, nil, "#fhyx_ex__shuangxiong-discard:"..player.id)
    if #card > 0 and not player.dead then
      local color = Fk:getCardById(card[1]):getColorString()
      if color ~= "nocolor" then
        room:setPlayerMark(player, "@fhyx_ex__shuangxiong-phase", color)
      end
    end
  end,
}
local fhyx_ex__xiayong = fk.CreateTriggerSkill{
  name = "fhyx_ex__xiayong",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and player.phase == Player.Finish then
      local yes, n = true, 0
      player.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
        local use = e.data[1]
        if use.from == player.id and (use.card.trueName == "slash" or use.card.trueName == "duel") then
          if use.damageDealt then
            local tmp = n
            for _, id in ipairs(TargetGroup:getRealTargets(use.tos)) do
              if use.damageDealt[id] then
                n = n + use.damageDealt[id]
              end
            end
            if n == tmp then
              yes = false
              return true
            end
          else
            yes = false
            return true
          end
        end
      end, Player.HistoryTurn)
      if yes and n > 0 then
        self.cost_data = n
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(self.cost_data, self.name)
  end,
}
fhyx_ex__shuangxiong:addRelatedSkill(fhyx_ex__shuangxiong_trigger)
yanliangwenchou:addSkill(fhyx_ex__shuangxiong)
yanliangwenchou:addSkill(fhyx_ex__xiayong)
Fk:loadTranslationTable{
  ["fhyx_ex__yanliangwenchou"] = "界颜良文丑",
  ["#fhyx_ex__yanliangwenchou"] = "虎狼兄弟",
  ["illustrator:fhyx_ex__yanliangwenchou"] = "鬼画府",

  ["fhyx_ex__shuangxiong"] = "双雄",
  [":fhyx_ex__shuangxiong"] = "出牌阶段开始时，你可以令一名角色弃置一张牌，若如此做，此阶段你可以将与此牌颜色不同的手牌当【决斗】使用。",
  ["fhyx_ex__xiayong"] = "狭勇",
  [":fhyx_ex__xiayong"] = "结束阶段，若你本回合使用的【杀】和【决斗】均对目标角色造成了伤害，你可以摸等同于这些伤害值的牌。",
  ["#fhyx_ex__shuangxiong_trigger"] = "双雄",
  ["#fhyx_ex__shuangxiong-choose"] = "双雄：令一名角色弃置一张牌，此阶段你可以将与之颜色不同的手牌当【决斗】使用",
  ["#fhyx_ex__shuangxiong-discard"] = "双雄：请弃置一张牌，此阶段 %src 可以将与之颜色不同的手牌当【决斗】使用",
  ["@fhyx_ex__shuangxiong-phase"] = "双雄",
  ["#fhyx_ex__shuangxiong"] = "双雄：你可以将一张%arg手牌当【决斗】使用",
}

local guanqiujian = General(extension, "fhyx__guanqiujian", "wei", 4)
local fhyx__zhengrong = fk.CreateTriggerSkill{
  name = "fhyx__zhengrong",
  anim_type = "switch",
  switch_skill_name = "fhyx__zhengrong",
  derived_piles = "$fhyx__glory",
  frequency = Skill.Compulsory,
  events = {fk.GameStart, fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      if event == fk.GameStart then
        return true
      elseif event ==  fk.CardUseFinished then
        if target == player and player.phase == Player.Play and data.tos and
          table.find(TargetGroup:getRealTargets(data.tos), function (id)
            return id ~= player.id
          end) then
          if player:getSwitchSkillState(self.name, false) == fk.SwitchYang then
            return not player:isKongcheng()
          else
            return table.find(player.room:getOtherPlayers(player), function (p)
              return not p:isNude()
            end)
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.GameStart then
      player:addToPile("$fhyx__glory", room.draw_pile[1], false, self.name, player.id)
    elseif event ==  fk.CardUseFinished then
      if player:getSwitchSkillState(self.name, true) == fk.SwitchYang then
        local cards = room:askForArrangeCards(player, self.name,
          {player:getPile("$fhyx__glory"), player:getCardIds("h"), "$fhyx__glory", "$Hand"}, "#fhyx__zhengrong-exchange", true)
        U.swapCardsWithPile(player, cards[1], cards[2], self.name, "$fhyx__glory")
      else
        local targets = table.filter(room:getOtherPlayers(player), function (p)
          return not p:isNude()
        end)
        local to = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 1,
          "#fhyx__zhengrong-choose", self.name, false)
        to = room:getPlayerById(to[1])
        local card = room:askForCardChosen(player, to, "he", self.name)
        player:addToPile("$fhyx__glory", card, false, self.name, player.id)
      end
    end
  end,
}
local fhyx__hongju = fk.CreateTriggerSkill{
  name = "fhyx__hongju",
  frequency = Skill.Wake,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
      player.phase == Player.Start and
      player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  can_wake = function(self, event, target, player, data)
    return #player:getPile("$fhyx__glory") > 2
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(#player:getPile("$fhyx__glory"), self.name)
    if player.dead then return end
    room:changeMaxHp(player, -1)
    if player.dead then return end
    room:handleAddLoseSkills(player, "fhyx__qingce", nil, true, false)
  end,
}
local fhyx__qingce = fk.CreateActiveSkill{
  name = "fhyx__qingce",
  anim_type = "control",
  target_num = 1,
  card_num = 1,
  prompt = "#fhyx__qingce",
  expand_pile = "$fhyx__glory",
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Self:getPileNameOfId(to_select) == "$fhyx__glory"
  end,
  target_filter = function(self, to_select, selected)
    return #Fk:currentRoom():getPlayerById(to_select):getCardIds("ej") > 0
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:moveCardTo(effect.cards, Card.DiscardPile, player, fk.ReasonPutIntoDiscardPile, self.name, "$fhyx__glory")
    if player.dead or target.dead or #target:getCardIds("ej") == 0 then return end
    local card = room:askForCardChosen(player, target, "ej", self.name)
    room:throwCard(card, self.name, target, player)
  end,
}
guanqiujian:addSkill(fhyx__zhengrong)
guanqiujian:addSkill(fhyx__hongju)
guanqiujian:addRelatedSkill(fhyx__qingce)
Fk:loadTranslationTable{
  ["fhyx__guanqiujian"] = "毌丘俭",
  ["#fhyx__guanqiujian"] = "镌功铭征荣",
  ["illustrator:fhyx__guanqiujian"] = "鬼画府",

  ["fhyx__zhengrong"] = "征荣",
  [":fhyx__zhengrong"] = "转换技，锁定技，游戏开始时，你将牌堆顶一张牌置于武将牌上，称为“荣”。当你于出牌阶段对其他角色使用牌结算后，"..
  "阳：你选择任意张手牌替换等量的“荣”；阴：你将一名其他角色的一张牌置为“荣”。",
  ["fhyx__hongju"] = "鸿举",
  [":fhyx__hongju"] = "觉醒技，准备阶段，若“荣”数不小于3，你摸等同于“荣”数的牌，然后减1点体力上限，获得〖清侧〗。",
  ["fhyx__qingce"] = "清侧",
  [":fhyx__qingce"] = "出牌阶段，你可以移去一张“荣”，然后弃置场上的一张牌。",
  ["$fhyx__glory"] = "荣",
  ["#fhyx__zhengrong-exchange"] = "征荣：选择任意张手牌替换等量的“荣”",
  ["#fhyx__zhengrong-choose"] = "征荣：将一名其他角色的一张牌置为“荣”",
  ["#fhyx__qingce"] = "清侧：你可以移去一张“荣”，弃置场上的一张牌",
}

local liyan = General(extension, "fhyx__liyans", "shu", 3)
local fhyx__duliang = fk.CreateActiveSkill{
  name = "fhyx__duliang",
  anim_type = "support",
  card_num = 0,
  target_num = 1,
  prompt = "#fhyx__duliang",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= Self.id and not Fk:currentRoom():getPlayerById(to_select):isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local n = math.max(target:getLostHp(), 1)
    local cards = room:askForCardsChosen(player, target, 1, n, "h", self.name, "#fhyx__duliang-prey::"..target.id..":"..n)
    n = #cards
    room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonPrey, self.name, nil, false, player.id)
    if player.dead or target.dead then return end
    local choice = room:askForChoice(player, {"fhyx__duliang_view:::"..(2*n), "fhyx__duliang_draw:::"..n}, self.name,
      "#fhyx__duliang-choice::"..target.id)
    if choice[15] == "v" then
      local all_cards = room:getNCards(2*n)
      cards = table.filter(cards, function (id)
        return Fk:getCardById(id).type == Card.TypeBasic
      end)
      cards = U.askforChooseCardsAndChoice(target, cards, {"OK"}, self.name, "#fhyx__duliang-get", nil, 0, #cards, all_cards)
      if #cards > 0 then
        room:moveCardTo(cards, Card.PlayerHand, target, fk.ReasonJustMove, self.name, nil, false, target.id)
      end
    else
      room:addPlayerMark(target, "@duliang", n)
    end
  end,
}
local fhyx__duliang_trigger = fk.CreateTriggerSkill{
  name = "#fhyx__duliang_trigger",

  refresh_events = {fk.DrawNCards},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@duliang") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    data.n = data.n + player:getMark("@duliang")
    player.room:setPlayerMark(player, "@duliang", 0)
  end,
}
local fhyx__fulin = fk.CreateTriggerSkill{
  name = "fhyx__fulin",
  anim_type = "control",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and player.phase ~= Player.NotActive and not player:isKongcheng() then
      local cards = {}
      for _, move in ipairs(data) do
        if move.to == player.id and move.toArea == Card.PlayerHand then
          for _, info in ipairs(move.moveInfo) do
            if table.contains(player:getCardIds("h"), info.cardId) then
              table.insertIfNeed(cards, info.cardId)
            end
          end
        end
      end
      U.moveCardsHoldingAreaCheck(player.room, cards)
      if #cards > 0 then
        self.cost_data = cards
        return true
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local cards = player.room:askForCard(player, 1, 999, false, self.name, true, ".|.|.|.|.|.|"..table.concat(self.cost_data, ","),
      "#fhyx__fulin-invoke")
    if #cards > 0 then
      self.cost_data = {cards = cards}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(player, "@fhyx__fulin-turn", #self.cost_data.cards)
    if #self.cost_data.cards == 1 then
      room:moveCards({
        ids = self.cost_data.cards,
        from = player.id,
        toArea = Card.DrawPile,
        moveReason = fk.ReasonPut,
        skillName = self.name,
        proposer = player.id,
      })
    else
      local result = room:askForGuanxing(player, self.cost_data.cards, nil, {0, 0}, self.name, true)
      room:moveCards({
        ids = table.reverse(result.top),
        from = player.id,
        toArea = Card.DrawPile,
        moveReason = fk.ReasonPut,
        skillName = self.name,
        proposer = player.id,
      })
    end
  end,
}
local fhyx__fulin_delay = fk.CreateTriggerSkill{
  name = "#fhyx__fulin_delay",
  mute = true,
  events = {fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@fhyx__fulin-turn") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player:broadcastSkillInvoke("fhyx__fulin")
    player.room:notifySkillInvoked(player, "fhyx__fulin", "drawcard")
    player:drawCards(player:getMark("@fhyx__fulin-turn"), "fhyx__fulin")
  end,
}
fhyx__duliang:addRelatedSkill(fhyx__duliang_trigger)
fhyx__fulin:addRelatedSkill(fhyx__fulin_delay)
liyan:addSkill(fhyx__duliang)
liyan:addSkill(fhyx__fulin)
Fk:loadTranslationTable{
  ["fhyx__liyans"] = "李严",
  ["#fhyx__liyans"] = "矜风流务",
  ["illustrator:fhyx__liyans"] = "梦回唐朝",

  ["fhyx__duliang"] = "督粮",
  [":fhyx__duliang"] = "出牌阶段限一次，你可以获得一名其他角色至多X张手牌（X为其已损失体力值且至少为1），然后选择一项："..
  "1.其观看牌堆顶的两倍的牌，获得其中任意张基本牌；2.其下个摸牌阶段多摸等量的牌。",
  ["fhyx__fulin"] = "腹鳞",
  [":fhyx__fulin"] = "当你于回合内获得牌后，你可以将其中任意张牌以任意顺序置于牌堆顶；回合结束时，你摸X张牌（X为本回合你以此法失去的牌数）。",
  ["#fhyx__duliang"] = "督粮：获得一名角色其已损失体力值张手牌（至少一张），然后令其获得基本牌或其下个摸牌阶段多摸牌",
  ["#fhyx__duliang-prey"] = "督粮：获得 %dest 至多%arg张手牌",
  ["#fhyx__duliang-choice"] = "督粮：选择令 %dest 执行的一项",
  ["fhyx__duliang_view"] = "其观看牌堆顶%arg张牌，获得其中的基本牌",
  ["fhyx__duliang_draw"] = "其下个摸牌阶段额外摸%arg张牌",
  ["#fhyx__duliang-get"] = "督粮：你可以获得其中任意张基本牌",
  ["#fhyx__fulin-invoke"] = "腹鳞：你可以将其中任意张牌以任意顺序置于牌堆顶，回合结束时摸等量的牌",
  ["@fhyx__fulin-turn"] = "腹鳞",
  ["#fhyx__fulin_delay"] = "腹鳞",

  ["$fhyx__duliang1"] = "积粮囤草，以备战时之用。",
  ["$fhyx__duliang2"] = "粮食充裕，怎可撤军。",
  ["$fhyx__fulin1"] = "我的才学，蜀中何人能比？",
  ["$fhyx__fulin2"] = "生此乱世，腹中鳞甲可保我周全。",
  ["~fhyx__liyans"] = "老臣，有愧圣恩……",
}

local caojie = General(extension, "fhyx__caojie", "qun", 3, 3, General.Female)
local fhyx__shouxi = fk.CreateTriggerSkill{
  name = "fhyx__shouxi",
  anim_type = "defensive",
  events = {fk.TargetConfirmed},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and (data.card.trueName == "slash" or data.card:isCommonTrick()) and
      data.from ~= player.id
  end,
  on_cost = function (self, event, target, player, data)
    local choice = player.room:askForChoice(player, {"basic", "trick", "equip", "Cancel"}, self.name,
      "#fhyx__shouxi-invoke::"..data.from..":"..data.card:toLogString())
    if choice ~= "Cancel" then
      self.cost_data = {choice = choice}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local from = room:getPlayerById(data.from)
    if #room:askForDiscard(from, 1, 1, false, self.name, true, ".|.|.|.|.|"..self.cost_data.choice,
      "#fhyx__shouxi-discard:"..player.id.."::"..data.card:toLogString()) == 0 then
      table.insertIfNeed(data.nullifiedTargets, player.id)
    elseif not player:isKongcheng() and not player.dead and not from.dead then
      local card = room:askForCardChosen(from, player, "h", self.name)
      room:moveCardTo(card, Card.PlayerHand, from, fk.ReasonPrey, self.name, nil, false, from.id)
    end
  end,
}
local fhyx__huimin = fk.CreateTriggerSkill{
  name = "fhyx__huimin",
  anim_type = "support",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Finish and
      table.find(player.room.alive_players, function (p)
        return p:getHandcardNum() < p.hp
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(table.filter(room.alive_players, function (p)
      return p:getHandcardNum() < p.hp
    end), Util.IdMapper)
    local tos = room:askForChoosePlayers(player, targets, 1, 10, "#fhyx__huimin-choose", self.name, true)
    if #tos > 0 then
      self.cost_data = {tos = tos}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(#self.cost_data.tos, self.name)
    if player.dead or player:isKongcheng() then return end
    local targets = table.filter(self.cost_data.tos, function (id)
      return not room:getPlayerById(id).dead
    end)
    if #targets == 0 then return end
    local n = math.min(player:getHandcardNum(), #targets)
    room:askForYiji(player, player:getCardIds("h"), table.map(targets, Util.Id2PlayerMapper), self.name, n, n,
      "#fhyx__huimin-give", nil, false, 1)
  end,
}
caojie:addSkill(fhyx__shouxi)
caojie:addSkill(fhyx__huimin)
Fk:loadTranslationTable{
  ["fhyx__caojie"] = "曹节",
  ["#fhyx__caojie"] = "悬壶济世",
  ["illustrator:fhyx__caojie"] = "匠人绘·空山",

  ["fhyx__shouxi"] = "守玺",
  [":fhyx__shouxi"] = "当你成为其他角色使用【杀】或普通锦囊牌的目标后，你可声明一种牌的类别，令使用者选择一项：1.弃置一张此类别的牌，"..
  "然后其可以获得你的一张手牌；2.此牌对你无效。",
  ["fhyx__huimin"] = "惠民",
  [":fhyx__huimin"] = "结束阶段，你可以选择任意名手牌数小于体力值的角色，你摸等量的牌，然后交给这些角色各一张手牌。",
  ["#fhyx__shouxi-invoke"] = "守玺：你可以声明类别，%dest 需弃置一张此类别牌并获得你一张手牌，否则%arg对你无效",
  ["#fhyx__shouxi-discard"] = "守玺：弃置一张%arg并获得 %src 一张手牌，否则%arg对其无效",
  ["#fhyx__huimin-choose"] = "惠民：选择任意名手牌数小于体力值的角色，你摸等量牌，然后交给这些角色各一张手牌",
  ["#fhyx__huimin-give"] = "惠民：请交给这些角色各一张手牌",
}

local caiyong = General(extension, "fhyx_ex__caiyong", "qun", 3)
local fhyx__tongbo = fk.CreateTriggerSkill{
  name = "fhyx__tongbo",
  anim_type = "special",
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Draw and
      #player:getPile("caiyong_book") > 0 and (not player:isNude() or #player:getPile("caiyong_book") > 3)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local piles = room:askForArrangeCards(player, self.name,
      {"caiyong_book", player:getPile("caiyong_book"), player.general, player:getCardIds("he")})
    U.swapCardsWithPile(player, piles[1], piles[2], self.name, "caiyong_book")
    if player.dead or #player:getPile("caiyong_book") < 4 or #room.alive_players < 2 then return end
    if room:askForSkillInvoke(player, self.name, nil, "#fhyx__tongbo-give") then
      local result = room:askForYiji(player, player:getPile("caiyong_book"), room:getOtherPlayers(player), self.name, 4, 4,
        "#fhyx__tongbo-distribute", "caiyong_book", false, 4)
      if player.dead then return end
      local suits = {}
      for _, cards in pairs(result) do
        table.insertTableIfNeed(suits, table.map(cards, function (id)
          return Fk:getCardById(id).suit
        end))
      end
      table.removeOne(suits, Card.NoSuit)
      if #suits == 4 then
        if player:getMark("pizhuan_extra") < #room.players then
          room:addPlayerMark(player, "pizhuan_extra", 1)
        end
        if player:isWounded() then
          room:recover{
            who = player,
            num = 1,
            recoverBy = player,
            skillName = self.name,
          }
        end
      end
    end
  end,
}
caiyong:addSkill("pizhuan")
caiyong:addSkill(fhyx__tongbo)
Fk:loadTranslationTable{
  ["fhyx_ex__caiyong"] = "界蔡邕",
  ["#fhyx_ex__caiyong"] = "大鸿儒",
  ["illustrator:fhyx_ex__caiyong"] = "凝聚永恒",

  ["fhyx__tongbo"] = "通博",
  [":fhyx__tongbo"] = "摸牌阶段结束时，你可以用任意张牌替换等量的“书”，然后你可以将四张“书”任意分配给其他角色，若花色各不相同，"..
  "你回复1点体力，“书”的数量上限+1（至多增加等同于角色数的上限）。",
  ["#fhyx__tongbo-give"] = "通博：是否将四张“书”任意分配给其他角色？若花色各不相同，你回复1点体力，“书”的数量上限+1",
  ["#fhyx__tongbo-distribute"] = "通博：请将四张“书”任意分配给其他角色",
}

local bianfuren = General(extension, "ofl_shiji__bianfuren", "wei", 3, 3, General.Female)
local ofl_shiji__fuding = fk.CreateTriggerSkill{
  name = "ofl_shiji__fuding",
  anim_type = "support",
  events = {fk.EnterDying, fk.AfterDying},
  can_trigger = function(self, event, target, player, data)
    if event == fk.EnterDying then
      return player:hasSkill(self) and target ~= player and not player:isNude() and
        player:usedSkillTimes(self.name, Player.HistoryRound) == 0
    else
      return not target.dead and data.extra_data and
        data.extra_data.ofl_shiji__fuding and data.extra_data.ofl_shiji__fuding[1] == player.id and
        not player.dead
    end
  end,
  on_cost = function(self, event, target, player, data)
    if event == fk.EnterDying then
      local cards = player.room:askForCard(player, 1, 5, true, self.name, true, ".", "#ofl_shiji__fuding-invoke::"..target.id)
      if #cards > 0 then
        self.cost_data = cards
        return true
      end
    else
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.EnterDying then
      room:moveCardTo(self.cost_data, Card.PlayerHand, target, fk.ReasonGive, self.name)
      data.extra_data = data.extra_data or {}
      data.extra_data.ofl_shiji__fuding = {player.id, #self.cost_data}
    else
      player:drawCards(data.extra_data.ofl_shiji__fuding[2], self.name)
      if player:isWounded() and not player.dead then
        room:recover{
          who = player,
          num = 1,
          recoverBy = player,
          skillName = self.name,
        }
      end
    end
  end,
}
local ofl_shiji__yuejian = fk.CreateViewAsSkill{
  name = "ofl_shiji__yuejian",
  pattern = ".|.|.|.|.|basic",
  prompt = "#ofl_shiji__yuejian",
  interaction = function()
    local names = {}
    for _, id in ipairs(Fk:getAllCardIds()) do
      local card = Fk:getCardById(id)
      if card.type == Card.TypeBasic and not card.is_derived then
        local to_use = Fk:cloneCard(card.name)
        if ((Fk.currentResponsePattern == nil and Self:canUse(to_use) and not Self:prohibitUse(to_use)) or
        (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(to_use))) then
          table.insertIfNeed(names, card.name)
        end
      end
    end
    return UI.ComboBox { choices = names }
  end,
  card_filter = function(self, to_select, selected)
    return false
  end,
  view_as = function(self, cards)
    if not self.interaction.data then return nil end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = self.name
    return card
  end,
  enabled_at_play = function(self, player)
    return player:getMark("ofl_shiji__yuejian-round") == 0
  end,
  enabled_at_response = function(self, player, response)
    return not response and player:getMark("ofl_shiji__yuejian-round") == 0
  end,
}
local ofl_shiji__yuejian_record = fk.CreateTriggerSkill{
  name = "#ofl_shiji__yuejian_record",

  refresh_events = {fk.AfterCardUseDeclared, fk.EventAcquireSkill},
  can_refresh = function(self, event, target, player, data)
    if event == fk.AfterCardUseDeclared then
      return target == player and data.card.type == Card.TypeBasic and player:getMark("ofl_shiji__yuejian-round") == 0
    else
      return target == player and data == self and
        player:getMark("ofl_shiji__yuejian-round") == 0 and player.room:getTag("RoundCount") and
        #player.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function(e)
        local use = e.data[1]
          return use.from == player.id and use.card.type == Card.TypeBasic
        end, Player.HistoryRound) > 0
    end
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "ofl_shiji__yuejian-round", 1)
  end,
}
local ofl_shiji__yuejian_maxcards = fk.CreateMaxCardsSkill{
  name = "#ofl_shiji__yuejian_maxcards",
  correct_func = function(self, player)
    if player:hasSkill("ofl_shiji__yuejian") then
      return player.maxHp
    else
      return 0
    end
  end,
}
ofl_shiji__yuejian:addRelatedSkill(ofl_shiji__yuejian_record)
ofl_shiji__yuejian:addRelatedSkill(ofl_shiji__yuejian_maxcards)
bianfuren:addSkill(ofl_shiji__fuding)
bianfuren:addSkill(ofl_shiji__yuejian)
Fk:loadTranslationTable{
  ["ofl_shiji__bianfuren"] = "卞夫人",
  ["#ofl_shiji__bianfuren"] = "内助贤后",
  ["illustrator:ofl_shiji__bianfuren"] = "云涯", -- 史诗皮肤 蝶恋琵琶

  ["ofl_shiji__fuding"] = "抚定",
  [":ofl_shiji__fuding"] = "每轮限一次，当一名其他角色进入濒死状态时，你可以交给其至多五张牌，若如此做，当其脱离濒死状态时，"..
  "你摸等量的牌并回复1点体力。",
  ["ofl_shiji__yuejian"] = "约俭",
  [":ofl_shiji__yuejian"] = "你的手牌上限+X（X为你的体力上限）。当你需使用一张基本牌时，若你本轮未使用过基本牌，你可以视为使用之。",
  ["#ofl_shiji__fuding-invoke"] = "抚定：你可以交给 %dest 至多五张牌，其脱离濒死状态后你摸等量牌并回复1点体力",
  ["#ofl_shiji__yuejian"] = "约俭：你可以视为使用一张基本牌",
}

local chenzhen = General(extension, "ofl_shiji__chenzhen", "shu", 3)
local ofl_shiji__shameng = fk.CreateActiveSkill{
  name = "ofl_shiji__shameng",
  anim_type = "drawcard",
  min_card_num = 1,
  max_card_num = 2,
  target_num = 1,
  prompt = "#ofl_shiji__shameng",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  card_filter = function(self, to_select, selected)
    return #selected < 2 and table.contains(Self:getCardIds("h"), to_select)
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= Self.id and not Fk:currentRoom():getPlayerById(to_select):isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local suits = {}
    local types = {}
    for _, id in ipairs(effect.cards) do
      local card = Fk:getCardById(id)
      if card.suit ~= Card.NoSuit then
        table.insertIfNeed(suits, card.suit)
      end
      table.insertIfNeed(types, card.type)
    end
    player:showCards(effect.cards)
    if player.dead or target.dead or target:isKongcheng() then return end
    local cards = room:askForCard(target, 1, 2, false, self.name, false, ".", "#ofl_shiji__shameng-show:"..player.id)
    for _, id in ipairs(cards) do
      local card = Fk:getCardById(id)
      if card.suit ~= Card.NoSuit then
        table.insertIfNeed(suits, card.suit)
      end
      table.insertIfNeed(types, card.type)
    end
    target:showCards(cards)
    if player.dead then return end
    if room:askForSkillInvoke(player, self.name, nil, "#ofl_shiji__shameng-discard::"..target.id..":"..#suits..":"..#types) then
      local move1 = {
        ids = table.filter(effect.cards, function(id)
          return room:getCardOwner(id) == player and table.contains(player:getCardIds("h"), id) and not player:prohibitDiscard(id)
        end),
        from = player.id,
        toArea = Card.DiscardPile,
        moveReason = fk.ReasonDiscard,
        proposer = player.id,
        skillName = self.name,
      }
      local move2 = {
        ids = table.filter(cards, function(id)
          return room:getCardOwner(id) == target and table.contains(target:getCardIds("h"), id)
        end),
        from = target.id,
        toArea = Card.DiscardPile,
        moveReason = fk.ReasonDiscard,
        proposer = player.id,
        skillName = self.name,
      }
      room:moveCards(move1, move2)
      if not player.dead then
        player:drawCards(#suits, self.name)
      end
      if not target.dead then
        target:drawCards(#types, self.name)
      end
    end
  end,
}
chenzhen:addSkill(ofl_shiji__shameng)
Fk:loadTranslationTable{
  ["ofl_shiji__chenzhen"] = "陈震",
  ["#ofl_shiji__chenzhen"] = "歃盟使节",
  ["illustrator:ofl_shiji__chenzhen"] = "君桓文化",

  ["ofl_shiji__shameng"] = "歃盟",
  [":ofl_shiji__shameng"] = "出牌阶段限一次，你可以展示一至两张手牌，然后令一名其他角色展示一至两张手牌，若如此做，你可以弃置这些牌，"..
  "你摸等同于其中花色数的牌，令该角色摸等同于其中类别数的牌。",
  ["#ofl_shiji__shameng"] = "歃盟：你可以展示至多两张手牌，令一名角色展示至多两张手牌，你可以弃置这些牌令双方摸牌",
  ["#ofl_shiji__shameng-show"] = "歃盟：请展示一至两张手牌，%src 可以弃置这些牌令双方摸牌",
  ["#ofl_shiji__shameng-discard"] = "歃盟：是否弃置这些牌令双方摸牌？你摸%arg张，%dest摸%arg2张",
}

local luotong = General(extension, "ofl_shiji__luotong", "wu", 4)
local ofl_shiji__minshi = fk.CreateActiveSkill{
  name = "ofl_shiji__minshi",
  anim_type = "support",
  card_num = 0,
  target_num = 0,
  prompt = function(self, card)
    return "#ofl_shiji__minshi-active"
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and
      table.find(Fk:currentRoom().alive_players, function(p)
        return p:getHandcardNum() < p.hp
      end) and
      table.find(Fk:currentRoom():getBanner("@$fhyx_extra_pile"), function(id)
        return Fk:getCardById(id).type == Card.TypeBasic
      end)
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local targets = table.filter(room:getAlivePlayers(), function(p)
      return p:getHandcardNum() < p.hp end)
    if #targets == 0 then return end
    room:doIndicate(player.id, table.map(targets, Util.IdMapper))
    local cards = table.filter(room:getBanner("@$fhyx_extra_pile"), function(id)
      return Fk:getCardById(id).type == Card.TypeBasic
    end)
    cards = table.random(cards, 3)
    if #cards == 0 then return end
    for _, id in ipairs(cards) do
      room:setCardMark(Fk:getCardById(id), MarkEnum.DestructIntoDiscard, 1)
    end
    local result = room:askForYiji(player, cards, targets, self.name, 1, #cards, "#ofl_shiji__minshi-give", cards, false)
    local n = #table.filter(targets, function(p)
      return #result[tostring(p.id)] == 0
    end)
    if n > 0 and not player.dead then
      room:loseHp(player, n, self.name)
    end
  end,
}
local ofl_shiji__minshi_trigger = fk.CreateTriggerSkill{
  name = "#ofl_shiji__minshi_trigger",

  refresh_events = {fk.EventAcquireSkill, fk.AfterCardsMove},
  can_refresh = function(self, event, target, player, data)
    if event == fk.EventAcquireSkill then
      return target == player and data == self
    elseif player.seat == 1 then
      for _, move in ipairs(data) do
        for _, info in ipairs(move.moveInfo) do
          if player.room.tag["fhyx_extra_pile"] and
            table.contains(player.room.tag["fhyx_extra_pile"], info.cardId) then
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
local ofl_shiji__xianming = fk.CreateTriggerSkill{
  name = "ofl_shiji__xianming",
  anim_type = "drawcard",
  events = {fk.BeforeCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryTurn) == 0 and
      player.room.tag["fhyx_extra_pile"] then
      local ids = {}
      for _, move in ipairs(data) do
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.Void and player.room:getBanner("@$fhyx_extra_pile") and
            table.contains(player.room:getBanner("@$fhyx_extra_pile"), info.cardId) then
            table.insertIfNeed(ids, info.cardId)
          end
        end
      end
      return #table.filter(player.room:getBanner("@$fhyx_extra_pile"), function(id)
        return Fk:getCardById(id).type == Card.TypeBasic
      end) == #ids
    end
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(2, self.name)
    if player:isWounded() and not player.dead then
      player.room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = self.name,
      }
    end
  end,
}
ofl_shiji__minshi:addRelatedSkill(ofl_shiji__minshi_trigger)
luotong:addSkill(ofl_shiji__minshi)
luotong:addSkill(ofl_shiji__xianming)
Fk:loadTranslationTable{
  ["ofl_shiji__luotong"] = "骆统",
  ["#ofl_shiji__luotong"] = "辨如悬河",
  ["illustrator:ofl_shiji__luotong"] = "凡果",

  ["ofl_shiji__minshi"] = "悯施",
  [":ofl_shiji__minshi"] = "出牌阶段限一次，你可以选择所有手牌数少于体力值的角色并观看额外牌堆中至多三张基本牌，然后你可以依次将其中"..
  "任意张牌交给任意角色。然后你选择的角色中每有一名未获得牌的角色，你失去1点体力。",
  ["ofl_shiji__xianming"] = "显名",
  [":ofl_shiji__xianming"] = "每回合限一次，当额外牌堆中失去最后一张基本牌时，你可以摸两张牌并回复1点体力。",  --移动牌时移动牌神将
  ["#ofl_shiji__minshi-active"] = "悯施：观看额外牌堆的三张基本牌，任意交给手牌数小于体力值的角色",
  ["#ofl_shiji__minshi-give"] = "悯施：分配这些牌，每有一名没获得牌的目标角色，你失去1点体力",
}

local sunshao = General:new(extension, "ofl_shiji__sunshao", "wu", 3)
local ofl_shiji__dingyi = fk.CreateTriggerSkill{
  name = "ofl_shiji__dingyi",
  events = {fk.RoundStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self)
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    player:drawCards(1, self.name)
    if player.dead or player:isNude() then return end
    local targets, suits = {}, {"nosuit"}
    for _, p in ipairs(room.alive_players) do
      if #p:getPile(self.name) > 0 then
        table.insert(suits, Fk:getCardById(p:getPile(self.name)[1]):getSuitString())
      else
        table.insert(targets, p.id)
      end
    end
    if #targets == 0 or #suits == 5 then return false end
    local tos, cardId = room:askForChooseCardAndPlayers(player, targets, 1, 1, ".|.|^("..table.concat(suits,",")..")",
      "#ofl_shiji__dingyi-use", self.name, true)
    if #tos > 0 and cardId then
      local to = room:getPlayerById(tos[1])
      to:addToPile(self.name, cardId, true, self.name)
      room:broadcastProperty(to, "MaxCards")
    end
  end,
}
local ofl_shiji__dingyi_delay = fk.CreateTriggerSkill{
  name = "#ofl_shiji__dingyi_delay",
  mute = true,
  events = {fk.DrawNCards, fk.AfterDying},
  can_trigger = function(self, event, target, player, data)
    if target == player and #player:getPile("ofl_shiji__dingyi") > 0 then
      if event == fk.DrawNCards then
        return Fk:getCardById(player:getPile("ofl_shiji__dingyi")[1]).suit == Card.Diamond
      elseif Fk:getCardById(player:getPile("ofl_shiji__dingyi")[1]).suit == Card.Heart and player:isWounded() then
        local dat = player.room.logic:getEventsOfScope(GameEvent.Dying, 1, function(e)
          return e.data[1].who == player.id
        end, Player.HistoryTurn)
        return #dat > 0 and dat[1].data[1] == data
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    if event == fk.DrawNCards then
      data.n = data.n + 2
    else
      player.room:recover({
        who = player,
        num = math.min(player:getLostHp(), 2),
        recoverBy = player,
        skillName = "ofl_shiji__dingyi",
      })
    end
  end,
}
local ofl_shiji__dingyi_maxcards = fk.CreateMaxCardsSkill{
  name = "#ofl_shiji__dingyi_maxcards",
  correct_func = function(self, player)
    if #player:getPile("ofl_shiji__dingyi") > 0 and Fk:getCardById(player:getPile("ofl_shiji__dingyi")[1]).suit == Card.Spade then
      return 4
    end
  end,
}
local ofl_shiji__dingyi_targetmod = fk.CreateTargetModSkill{
  name = "#ofl_shiji__dingyi_targetmod",
  bypass_distances = function(self, player)
    return #player:getPile("ofl_shiji__dingyi") > 0 and Fk:getCardById(player:getPile("ofl_shiji__dingyi")[1]).suit == Card.Club
  end,
}
local ofl_shiji__zuici = fk.CreateTriggerSkill{
  name = "ofl_shiji__zuici",
  anim_type = "masochism",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
      table.find(player.room.alive_players, function(p)
        return #p:getPile("ofl_shiji__dingyi") > 0
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local targets = table.map(table.filter(player.room.alive_players, function(p)
      return #p:getPile("ofl_shiji__dingyi") > 0
    end),
    Util.IdMapper)
    local to = player.room:askForChoosePlayers(player, targets, 1, 1, "#ofl_shiji__zuici-choose", self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    room:moveCardTo(to:getPile("ofl_shiji__dingyi"), Card.PlayerHand, player, fk.ReasonJustMove, self.name, "", true, player.id)
    if player.dead or to.dead then return end
    local cards = table.filter(player.room:getBanner("@$fhyx_extra_pile"), function(id)
      return table.contains({"ex_nihilo", "dismantlement", "nullification"}, Fk:getCardById(id).name)
    end)
    if #cards == 0 then return end
    local card = room:askForCard(player, 1, 1, false, self.name, false, ".|.|.|.|.|.|"..table.concat(cards, ","),
      "#ofl_shiji__zuici-give::"..to.id, cards)
    room:moveCardTo(card, Card.PlayerHand, to, fk.ReasonJustMove, self.name, "", true, player.id, MarkEnum.DestructIntoDiscard)
  end,

  refresh_events = {fk.EventAcquireSkill, fk.AfterCardsMove},
  can_refresh = function(self, event, target, player, data)
    if event == fk.EventAcquireSkill then
      return target == player and data == self
    elseif player.seat == 1 then
      for _, move in ipairs(data) do
        for _, info in ipairs(move.moveInfo) do
          if player.room.tag["fhyx_extra_pile"] and
            table.contains(player.room.tag["fhyx_extra_pile"], info.cardId) then
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
ofl_shiji__dingyi:addRelatedSkill(ofl_shiji__dingyi_delay)
ofl_shiji__dingyi:addRelatedSkill(ofl_shiji__dingyi_maxcards)
ofl_shiji__dingyi:addRelatedSkill(ofl_shiji__dingyi_targetmod)
sunshao:addSkill(ofl_shiji__dingyi)
sunshao:addSkill(ofl_shiji__zuici)
Fk:loadTranslationTable{
  ["ofl_shiji__sunshao"] = "孙邵",
  ["#ofl_shiji__sunshao"] = "清庙之器",
  ["illustrator:ofl_shiji__sunshao"] = "枭瞳",

  ["ofl_shiji__dingyi"] = "定仪",
  [":ofl_shiji__dingyi"] = "每轮开始时，你可以摸一张牌，然后将一张与“定仪”牌花色均不同的牌置于一名没有“定仪”牌的角色武将牌旁。"..
  "有“定仪”牌的角色根据花色获得对应效果：<br>♠，手牌上限+4；<br><font color='red'>♥</font>，每回合首次脱离濒死状态时，回复2点体力；<br>"..
  "♣，使用牌无距离限制；<br><font color='red'>♦</font>，摸牌阶段多摸两张牌。",
  ["ofl_shiji__zuici"] = "罪辞",
  [":ofl_shiji__zuici"] = "当你受到伤害后，你可以获得一名角色的“定仪”牌，然后你从额外牌堆选择一张智囊牌令其获得。",
  ["#ofl_shiji__dingyi-use"] = "定仪：将一张“定仪”牌置于一名角色武将牌旁，根据花色其获得效果<br>♠ 手牌上限+4；<font color='red'>♥</font> "..
  "脱离濒死时回复体力<br>♣ 使用牌无距离限制；<font color='red'>♦</font> 摸牌阶段多摸两张牌",
  ["#ofl_shiji__dingyi_delay"] = "定仪",
  ["#ofl_shiji__zuici-choose"] = "罪辞：你可以获得一名角色的“定仪”牌，然后从额外牌堆选择一张智囊牌令其获得",
  ["#ofl_shiji__zuici-give"] = "罪辞：选择一张智囊牌令 %dest 获得",

  ["$ofl_shiji__dingyi1"] = "制礼以节官吏众庶，国祚方可安稳绵长。",
  ["$ofl_shiji__dingyi2"] = "礼行则国治，礼弛则国乱矣。",
  ["$ofl_shiji__zuici1"] = "无争权柄之事，只望臣宰一心。",
  ["$ofl_shiji__zuici2"] = "折堕己名而得朝臣向主，邵无怨也。",
  ["~ofl_shiji__sunshao"] = "若得望朝野清明，邵死亦无憾……",
}

local duyu = General(extension, "ofl_shiji__duyu", "qun", 4)
duyu.subkingdom = "jin"
local ofl_shiji__wuku = fk.CreateTriggerSkill{
  name = "ofl_shiji__wuku",
  frequency = Skill.Compulsory,
  events = {fk.CardUsing, fk.BeforeCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and player:getMark("@wuku") < 3 then
      if event == fk.CardUsing then
        return target == player and data.card.type == Card.TypeEquip
      else
        for _, move in ipairs(data) do
          if move.from ~= player.id then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.PlayerEquip then
                return true
              end
            end
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.CardUsing then
      room:addPlayerMark(player, "@wuku", 1)
    else
      if player:getMark("@wuku") == 2 then
        room:addPlayerMark(player, "@wuku", 1)
      else
        local n = 0
        for _, move in ipairs(data) do
          if move.from ~= player.id then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.PlayerEquip then
                n = n + 1
              end
            end
          end
        end
        room:addPlayerMark(player, "@wuku", math.min(n, 3 - player:getMark("@wuku")))
      end
    end
  end,
}
local ofl_shiji__sanchen = fk.CreateTriggerSkill{
  name = "ofl_shiji__sanchen",
  frequency = Skill.Wake,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
      (player.phase == Player.Start or player.phase == Player.Finish) and
      player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  can_wake = function(self, event, target, player, data)
    return player:getMark("@wuku") == 3
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, 1)
    if player:isWounded() and not player.dead then
      room:recover{
        who = player,
        num = 1,
        skillName = self.name,
      }
    end
    room:handleAddLoseSkills(player, "ofl_shiji__miewu", nil, true, false)
  end,
}
local ofl_shiji__miewu = fk.CreateViewAsSkill{
  name = "ofl_shiji__miewu",
  pattern = ".",
  prompt = "#ofl_shiji__miewu",
  interaction = function()
    local names, all_names = {}, {}
    local mark = Self:getTableMark("ofl_shiji__miewu-turn")
    for _, id in ipairs(Fk:getAllCardIds()) do
      local card = Fk:getCardById(id)
      if (card.type == Card.TypeBasic or card:isCommonTrick()) and not card.is_derived then
        table.insertIfNeed(all_names, card.name)
        local to_use = Fk:cloneCard(card.name)
        if not table.contains(mark, card.trueName) and
        ((Fk.currentResponsePattern == nil and Self:canUse(to_use) and not Self:prohibitUse(to_use)) or
        (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(to_use))) then
          table.insertIfNeed(names, card.name)
        end
      end
    end
    if #names == 0 then return false end
    return UI.ComboBox { choices = names, all_choices = all_names }
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0
  end,
  view_as = function(self, cards)
    if #cards ~= 1 or not self.interaction.data then return end
    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcards(cards)
    card.skillName = self.name
    return card
  end,
  before_use = function(self, player, use)
    local room = player.room
    room:removePlayerMark(player, "@wuku", 1)
    room:addTableMark(player, "ofl_shiji__miewu-turn", use.card.trueName)
  end,
  enabled_at_play = function(self, player)
    return player:getMark("@wuku") > 0 and not player:isNude()
  end,
  enabled_at_response = function(self, player, response)
    return player:getMark("@wuku") > 0 and not player:isNude()
  end,
}
duyu:addSkill(ofl_shiji__wuku)
duyu:addSkill(ofl_shiji__sanchen)
duyu:addRelatedSkill(ofl_shiji__miewu)
Fk:loadTranslationTable{
  ["ofl_shiji__duyu"] = "杜预",
  ["#ofl_shiji__duyu"] = "弼朝博虬",
  ["illustrator:ofl_shiji__duyu"] = "枭瞳",

  ["ofl_shiji__wuku"] = "武库",
  [":ofl_shiji__wuku"] = "锁定技，当你使用装备牌时或其他角色失去装备区内的一张牌时，你获得1枚“武库”标记（至多3枚）。",
  ["ofl_shiji__sanchen"] = "三陈",
  [":ofl_shiji__sanchen"] = "觉醒技，准备阶段或结束阶段，若你的“武库”标记为3，你加1点体力上限，回复1点体力，获得〖灭吴〗。",
  ["ofl_shiji__miewu"] = "灭吴",
  [":ofl_shiji__miewu"] = "每回合每种牌名限一次，你可以移去1枚“武库”标记，将一张牌当任意一张基本牌或普通锦囊牌使用或打出。",
  ["#ofl_shiji__miewu"] = "灭吴：你可以将一张牌当任意基本牌或普通锦囊牌使用或打出",

  ["$ofl_shiji__wuku1"] = "人非生而知之，但敏而求之也。",
  ["$ofl_shiji__wuku2"] = "广习经籍，只为上能弼国，下可安民。",
  ["$ofl_shiji__wuku3"] = "千计万策，随江即来也。",
  ["$ofl_shiji__wuku4"] = "万结之绳，不过一剑即解。",
  ["$ofl_shiji__sanchen1"] = "今便可荡平吴都，陛下何舍而不取？",
  ["$ofl_shiji__sanchen2"] = "天下思定已久，陛下当成四海之愿。",
  ["$ofl_shiji__miewu1"] = "驭虬吞江为平地，剑指东南定吴夷。",
  ["$ofl_shiji__miewu2"] = "九州从来向一统，岂容伪朝至两分？",
  ["~ofl_shiji__duyu"] = "此魂弃归泰山，永镇不轨之贼……",
}

local xunchen = General(extension, "ofl_shiji__xunchen", "qun", 3)
local ofl_shiji__weipo = fk.CreateActiveSkill{
  name = "ofl_shiji__weipo",
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  prompt = "#ofl_shiji__weipo",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    return #selected == 0
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    if not target:isAllNude() then
      local disable_ids = {}
      if player == target then
        disable_ids = table.filter(player:getCardIds("he"), function (id)
          return player:prohibitDiscard(id)
        end)
      end
      local cards = U.askforCardsChosenFromAreas(player, target, "hej", self.name, nil, disable_ids, false)
      if #cards > 0 then
        room:throwCard(cards, self.name, target, player)
      end
      if target.dead then return end
    end
    local names = room:getTag("Zhinang") or {"dismantlement", "nullification", "ex_nihilo"}
    table.insert(names, 1, "enemy_at_the_gates")
    local cards = table.filter(room:getBanner("@$fhyx_extra_pile"), function(id)
      return table.contains(names, Fk:getCardById(id).trueName)
    end)
    if #cards > 0 then
      cards = U.askforChooseCardsAndChoice(player, cards, {"OK"}, self.name, "#ofl_shiji__weipo-give::"..target.id)
      room:moveCardTo(cards, Card.PlayerHand, target, fk.ReasonJustMove, self.name, nil, true, player.id,
        MarkEnum.DestructIntoDiscard)
    end
  end,
}
local ofl_shiji__weipo_trigger = fk.CreateTriggerSkill{
  name = "#ofl_shiji__weipo_trigger",

  refresh_events = {fk.EventAcquireSkill, fk.AfterCardsMove},
  can_refresh = function(self, event, target, player, data)
    if event == fk.EventAcquireSkill then
      return target == player and data == self
    elseif player.seat == 1 then
      for _, move in ipairs(data) do
        for _, info in ipairs(move.moveInfo) do
          if player.room.tag["fhyx_extra_pile"] and
            table.contains(player.room.tag["fhyx_extra_pile"], info.cardId) then
            return true
          end
        end
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    if event == fk.EventAcquireSkill then
      local room = player.room
      PrepareExtraPile(room)
      local cards = room:getTag("fhyx_extra_pile")
      table.insert(cards, room:printCard("enemy_at_the_gates", Card.Spade, 7).id)
      room:setTag("fhyx_extra_pile", cards)
      room:setBanner("@$fhyx_extra_pile", table.simpleClone(room.tag["fhyx_extra_pile"]))
    else
      SetFhyxExtraPileBanner(player.room)
    end
  end,
}
local ofl_shiji__chenshi = fk.CreateTriggerSkill{
  name = "ofl_shiji__chenshi",
  anim_type = "control",
  events = {fk.TargetSpecified, fk.TargetConfirmed},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and data.card.name == "enemy_at_the_gates" and player ~= target and
      not target:isNude() and not target.dead
  end,
  on_cost = function(self, event, target, player, data)
    local card = player.room:askForCard(target, 1, 1, true, self.name, true, nil, "#ofl_shiji__chenshi-give:"..player.id)
    if #card > 0 then
      self.cost_data = {cards = card}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:moveCardTo(self.cost_data.cards, Card.PlayerHand, player, fk.ReasonGive, self.name, nil, false, target.id)
    if target.dead then return end
    if #room.draw_pile < 3 then
      room:shuffleDrawPile()
      if #room.draw_pile < 3 then
        room:gameOver("")
      end
    end
    local cards = table.slice(room.draw_pile, 1, 4)
    local to_discard = room:askForCardsChosen(target, target, 0, #cards, {
      card_data = {
        { "Top", cards }
      }
    }, self.name, "#ofl_shiji__chenshi-discard")
    if #to_discard > 0 then
      room:moveCardTo(to_discard, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, self.name, nil, true, target.id)
    end
    room:delay(1000)
  end,
}
local ofl_shiji__moushi = fk.CreateTriggerSkill{
  name = "ofl_shiji__moushi",
  anim_type = "defensive",
  events = {fk.DamageInflicted},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card and data.card.suit ~= Card.NoSuit and
      #player.room.logic:getActualDamageEvents(1, function(e)
        local damage = e.data[1]
        if damage.to == player and damage.card and damage.card.suit == data.card.suit then
          return true
        end
      end, Player.HistoryTurn) > 0
  end,
  on_use = Util.TrueFunc,
}
ofl_shiji__weipo:addRelatedSkill(ofl_shiji__weipo_trigger)
xunchen:addSkill(ofl_shiji__weipo)
xunchen:addSkill(ofl_shiji__chenshi)
xunchen:addSkill(ofl_shiji__moushi)
Fk:loadTranslationTable{
  ["ofl_shiji__xunchen"] = "荀谌",
  ["#ofl_shiji__xunchen"] = "谋刃略锋",
  ["illustrator:ofl_shiji__xunchen"] = "鬼画府",

  ["ofl_shiji__weipo"] = "危迫",
  [":ofl_shiji__weipo"] = "出牌阶段限一次，你可以选择一名其他角色，弃置其每个区域各一张牌（无牌则不弃），然后从额外牌堆选择一张"..
  "【兵临城下】或一张智囊牌令其获得。<br>"..
  "<font color='grey'><small>【兵临城下】<br>出牌阶段，对一名其他角色使用。你依次展示牌堆顶四张牌，若为【杀】，你对目标使用之；"..
  "若不为【杀】，将此牌置入弃牌堆。</small></font>",
  ["ofl_shiji__chenshi"] = "陈势",
  [":ofl_shiji__chenshi"] = "当其他角色使用【兵临城下】指定目标后，或当其他角色成为【兵临城下】的目标后，其可以交给你一张牌，"..
  "然后其观看牌堆顶三张牌并将其中任意张置入弃牌堆。",
  ["ofl_shiji__moushi"] = "谋识",
  [":ofl_shiji__moushi"] = "锁定技，当你受到牌造成的伤害时，若你本回合受到过此花色的牌造成的伤害，防止此伤害。",
  ["#ofl_shiji__weipo"] = "危迫：你可以选择一名角色，弃置其每个区域各一张牌，然后选择一张【兵临城下】或智囊令其获得",
  ["#ofl_shiji__weipo-give"] = "危迫：选择令 %dest 获得的牌",
  ["#ofl_shiji__chenshi-give"] = "陈势：你可以交给 %src 一张牌，观看牌堆顶三张牌，将其中任意张置入弃牌堆",
  ["#ofl_shiji__chenshi-discard"] = "陈势：你可以将其中任意张牌置入弃牌堆",
}

local godguojia = General(extension, "ofl_shiji__godguojia", "god", 3)
local ofl_shiji__huishi = fk.CreateActiveSkill{
  name = "ofl_shiji__huishi",
  anim_type = "drawcard",
  card_num = 0,
  target_num = 0,
  prompt = "#ofl_shiji__huishi",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local cards = {}
    while true do
      if player.dead then return end
      local pattern = table.concat(table.map(cards, function(card) return card:getSuitString() end), ",")
      local judge = {
        who = player,
        reason = self.name,
        pattern = ".|.|" .. (pattern == "" and "." or "^(" .. pattern .. ")"),
        skipDrop = true,
      }
      room:judge(judge)
      table.insert(cards, judge.card)
      if not table.every(cards, function(card) return card == judge.card or judge.card:compareSuitWith(card, true) end) or
        not room:askForSkillInvoke(player, self.name, nil, "#ofl_shiji__huishi-invoke")
      then
        break
      end
    end
    local targets = table.map(room.alive_players, function(p) return p.id end)
    cards = table.filter(cards, function(card) return room:getCardArea(card.id) == Card.Processing end)
    if #cards == 0 then return end
    local to = room:askForChoosePlayers(player, targets, 1, 1, "#ofl_shiji__huishi-give", self.name, true)
    if #to > 0 then
      room:obtainCard(to[1], cards, true, fk.ReasonGive)
    else
      room:moveCards({
        ids = table.map(cards, function(card) return card:getEffectiveId() end),
        toArea = Card.DiscardPile,
        moveReason = fk.ReasonPutIntoDiscardPile,
        skillName = self.name,
      })
    end
  end,
}
local ofl_shiji__tianyi = fk.CreateTriggerSkill{
  name = "ofl_shiji__tianyi",
  anim_type = "special",
  frequency = Skill.Wake,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
      player.phase == Player.Start and
      player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  can_wake = function(self, event, target, player, data)
    return table.every(player.room.alive_players, function(p)
      return #player.room.logic:getActualDamageEvents(1, function(e) return e.data[1].to == p end, Player.HistoryGame) > 0
    end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if player.maxHp < 10 then
      room:changeMaxHp(player, 10 - player.maxHp)
    end
    local tos = room:askForChoosePlayers(player, table.map(room.alive_players, Util.IdMapper), 1, 1,
      "#ofl_shiji__tianyi-choose", self.name, false)
    room:handleAddLoseSkills(room:getPlayerById(tos[1]), "zuoxing", nil, true, false)
  end,
}
local ofl_shiji__huishig = fk.CreateTriggerSkill{
  name = "ofl_shiji__huishig",
  anim_type = "support",
  frequency = Skill.Limited,
  events = {fk.EnterDying},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local to = player.room:askForChoosePlayers(player, table.map(player.room.alive_players, function(p)
      return p.id end), 1, 1, "#ofl_shiji__huishig-choose", self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    local skills = table.map(table.filter(to.player_skills, function(s)
      return s.frequency == Skill.Wake and to:usedSkillTimes(s.name, Player.HistoryGame) == 0 end), function(s) return s.name end)
    if #skills > 0 then
      local choice = room:askForChoice(player, skills, self.name, "#ofl_shiji__huishig-choice::"..to.id, true)
      local toWakeSkills = type(to:getMark(MarkEnum.StraightToWake)) == "table" and to:getMark(MarkEnum.StraightToWake) or {}
      table.insertIfNeed(toWakeSkills, choice)
      room:setPlayerMark(to, MarkEnum.StraightToWake, toWakeSkills)
    else
      to:drawCards(4, self.name)
    end
  end,
}
godguojia:addSkill(ofl_shiji__huishi)
godguojia:addSkill(ofl_shiji__tianyi)
godguojia:addSkill(ofl_shiji__huishig)
godguojia:addRelatedSkill("zuoxing")
Fk:loadTranslationTable{
  ["ofl_shiji__godguojia"] = "神郭嘉",
  ["#ofl_shiji__godguojia"] = "倚星折月",
  ["illustrator:ofl_shiji__godguojia"] = "M云涯",

  ["ofl_shiji__huishi"] = "慧识",
  [":ofl_shiji__huishi"] = "出牌阶段限一次，你可以进行判定，若结果的花色与本阶段以此法进行判定的结果均不同，你可以重复此流程。"..
  "然后你可以将所有生效的判定牌交给一名角色。",
  ["ofl_shiji__tianyi"] = "天翊",
  [":ofl_shiji__tianyi"] = "觉醒技，准备阶段，若所有存活角色均受到过伤害，你增加体力上限至10点，然后令一名角色获得〖佐幸〗。",
  ["ofl_shiji__huishig"] = "辉逝",
  [":ofl_shiji__huishig"] = "限定技，当你进入濒死状态时，你可以选择一名角色，若其有未发动的觉醒技，你可以选择其中一个令其视为已满足觉醒条件，"..
  "否则其摸四张牌。",
  ["#ofl_shiji__huishi"] = "慧识：你可以重复判定，将不同花色的判定牌交给一名角色",
  ["#ofl_shiji__huishi-invoke"] = "慧识：是否继续判定？",
  ["#ofl_shiji__huishi-give"] = "慧识：你可以令一名角色获得这些判定牌",
  ["#ofl_shiji__tianyi-choose"] = "天翊：令一名角色获得技能〖佐幸〗",
  ["#ofl_shiji__huishig-choose"] = "辉逝：你可以令一名角色视为已满足觉醒条件（若没有则摸四张牌）",
  ["#ofl_shiji__huishig-choice"] = "辉逝：选择令 %dest 视为满足条件的觉醒技",
}

local godxunyu = General(extension, "ofl_shiji__godxunyu", "god", 3)
local ofl_shiji__lingce = fk.CreateTriggerSkill{
  name = "ofl_shiji__lingce",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.CardUsing, fk.PreCardEffect},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and data.card:isCommonTrick() and
      player.room:getTag("Zhinang") and table.contains(player.room:getTag("Zhinang"), data.card.name) then
      if event == fk.CardUsing then
        return true
      else
        return data.from ~= player.id and data.to == player.id
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    if event == fk.CardUsing then
      player:drawCards(1, self.name)
    else
      return true
    end
  end,
}
local ofl_shiji__dinghan = fk.CreateTriggerSkill{
  name = "ofl_shiji__dinghan",
  anim_type = "special",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Start
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#ofl_shiji__dinghan-invoke")
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local zhinang = room:getTag("Zhinang")
    if zhinang then
      zhinang = table.simpleClone(zhinang)
    else
      zhinang = {"ex_nihilo", "dismantlement", "nullification"}
    end
    local choice = room:askForChoice(player, room:getTag("Zhinang"), self.name, "#ofl_shiji__dinghan-remove")
    table.removeOne(zhinang, choice)
    local choices = table.simpleClone(room:getTag("TrickNames"))
    for _, name in ipairs(zhinang) do
      table.removeOne(choices, name)
    end
    choice = room:askForChoice(player, choices, self.name, "#ofl_shiji__dinghan-add", false, room:getTag("TrickNames"))
    table.insert(zhinang, choice)
    room:setTag("Zhinang", zhinang)
    room:setPlayerMark(player, "@$ofl_shiji__dinghan", room:getTag("Zhinang"))
  end,

  refresh_events = {fk.GameStart},
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(self, true)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local TrickNames = room:getTag("TrickNames")
    if not TrickNames then
      local names = {}
      for _, id in ipairs(Fk:getAllCardIds()) do
        local card = Fk:getCardById(id)
        if card:isCommonTrick() and not card.is_derived then
          table.insertIfNeed(names, card.name)
        end
      end
      room:setTag("TrickNames", names)
    end
    local Zhinang = room:getTag("Zhinang")
    if not Zhinang then
      room:setTag("Zhinang", {"ex_nihilo", "dismantlement", "nullification"})
      room:setPlayerMark(player, "@$ofl_shiji__dinghan", room:getTag("Zhinang"))
    end
  end,
}
godxunyu:addSkill(ofl_shiji__lingce)
godxunyu:addSkill(ofl_shiji__dinghan)
godxunyu:addSkill("tianzuo")
Fk:loadTranslationTable{
  ["ofl_shiji__godxunyu"] = "神荀彧",
  ["#ofl_shiji__godxunyu"] = "洞心先识",
  ["illustrator:ofl_shiji__godxunyu"] = "三三画画了么",

  ["ofl_shiji__lingce"] = "灵策",
  [":ofl_shiji__lingce"] = "锁定技，其他角色使用的智囊牌对你无效；一名角色使用智囊牌时，你摸一张牌。",
  ["ofl_shiji__dinghan"] = "定汉",
  [":ofl_shiji__dinghan"] = "准备阶段，你可以移除一张智囊牌的记录，然后重新记录一张智囊牌（初始为【无中生有】【过河拆桥】【无懈可击】）。",
  ["@$ofl_shiji__dinghan"] = "智囊",
  ["#ofl_shiji__dinghan-invoke"] = "定汉：你可以修改一张本局游戏的智囊牌牌名",
  ["#ofl_shiji__dinghan-remove"] = "定汉：选择要移除的智囊牌",
  ["#ofl_shiji__dinghan-add"] = "定汉：选择要增加的智囊牌",
}

local yanghu = General(extension, "ofl_shiji__yanghu", "qun", 3)
yanghu.subkingdom = "jin"
local ofl_shiji__mingfa = fk.CreateTriggerSkill{
  name = "ofl_shiji__mingfa",
  anim_type = "control",
  events = {fk.EventPhaseStart, fk.PindianCardsDisplayed},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      if event == fk.EventPhaseStart then
        return target == player and player.phase == Player.Play and not player:isKongcheng() and
          table.find(player.room:getOtherPlayers(player), function (p)
            return player:canPindian(p)
          end)
      elseif event == fk.PindianCardsDisplayed then
        return player == data.from or data.results[player.id]
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    if event == fk.EventPhaseStart then
      local room = player.room
      local targets = table.filter(room:getOtherPlayers(player), function (p)
        return player:canPindian(p)
      end)
      local tos, card =  room:askForChooseCardAndPlayers(player, table.map(targets, Util.IdMapper), 1, 1, ".|.|.|hand",
        "#ofl_shiji__mingfa-choose", self.name, true)
      if #tos > 0 and card then
        self.cost_data = {tos = tos, cards = {card}}
        return true
      end
    else
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    if event == fk.EventPhaseStart then
      local room = player.room
      local to = room:getPlayerById(self.cost_data.tos[1])
      player:showCards(self.cost_data.cards)
      if player.dead or to.dead or not table.contains(player:getCardIds("h"), self.cost_data.cards[1]) or
        not player:canPindian(to) then return end
      local pindian = player:pindian({to}, self.name, Fk:getCardById(self.cost_data.cards[1]))
      if player.dead then return end
      if pindian.results[to.id].winner == player then
        if not to.dead and not to:isNude() then
          local id = room:askForCardChosen(player, to, "he", self.name)
          room:moveCardTo(id, Card.PlayerHand, player, fk.ReasonPrey, self.name, nil, false, player.id)
        end
        if not player.dead then
          player:drawCards(1, self.name)
        end
      else
        room:setPlayerMark(player, "@@ofl_shiji__mingfa-turn", 1)
      end
    else
      if player == data.from then
        data.fromCard.number = math.min(13, data.fromCard.number + 2)
      elseif data.results[player.id] then
        data.results[player.id].toCard.number = math.min(13, data.results[player.id].toCard.number + 2)
      end
    end
  end,
}
local ofl_shiji__mingfa_prohibit = fk.CreateProhibitSkill{
  name = "#ofl_shiji__mingfa_prohibit",
  is_prohibited = function(self, from, to, card)
    return from:getMark("@@ofl_shiji__mingfa-turn") > 0 and card and from ~= to
  end,
}
local ofl_shiji__rongbei = fk.CreateActiveSkill{
  name = "ofl_shiji__rongbei",
  anim_type = "support",
  target_num = 1,
  card_num = 0,
  frequency = Skill.Limited,
  prompt = "#ofl_shiji__rongbei",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    local target = Fk:currentRoom():getPlayerById(to_select)
    return #selected == 0 and #target:getCardIds("e") < #target:getAvailableEquipSlots()
  end,
  on_use = function(self, room, effect)
    local target = room:getPlayerById(effect.tos[1])
    for _, slot in ipairs(target:getAvailableEquipSlots()) do
      if target.dead then return end
      local type = Util.convertSubtypeAndEquipSlot(slot)
      if target:hasEmptyEquipSlot(type) then
        local cards = table.filter(room:getBanner("@$fhyx_extra_pile"), function(id)
          local card = Fk:getCardById(id)
          return card.sub_type == type and not target:isProhibited(target, card)
        end)
        if #cards > 0 then
          local card = Fk:getCardById(table.random(cards))
          room:setCardMark(card, MarkEnum.DestructIntoDiscard, 1)
          room:useCard({
            from = effect.tos[1],
            tos = {{effect.tos[1]}},
            card = card,
          })
        end
      end
    end
  end,
}
local ofl_shiji__rongbei_trigger = fk.CreateTriggerSkill{
  name = "#ofl_shiji__rongbei_trigger",

  refresh_events = {fk.EventAcquireSkill, fk.AfterCardsMove},
  can_refresh = function(self, event, target, player, data)
    if event == fk.EventAcquireSkill then
      return target == player and data == self
    elseif player.seat == 1 then
      for _, move in ipairs(data) do
        for _, info in ipairs(move.moveInfo) do
          if player.room.tag["fhyx_extra_pile"] and
            table.contains(player.room.tag["fhyx_extra_pile"], info.cardId) then
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
ofl_shiji__mingfa:addRelatedSkill(ofl_shiji__mingfa_prohibit)
ofl_shiji__rongbei:addRelatedSkill(ofl_shiji__rongbei_trigger)
yanghu:addSkill(ofl_shiji__mingfa)
yanghu:addSkill(ofl_shiji__rongbei)
Fk:loadTranslationTable{
  ["ofl_shiji__yanghu"] = "羊祜",
  ["#ofl_shiji__yanghu"] = "鹤德璋声",
  ["illustrator:ofl_shiji__yanghu"] = "凡果",

  ["ofl_shiji__mingfa"] = "明伐",
  [":ofl_shiji__mingfa"] = "你的拼点牌点数+2。出牌阶段开始时，你可以展示一张手牌，用此牌与一名其他角色拼点，若你：赢，你获得其一张牌，"..
  "然后你摸一张牌；没赢，本回合你不能对其他角色使用牌。",
  ["ofl_shiji__rongbei"] = "戎备",
  [":ofl_shiji__rongbei"] = "限定技，出牌阶段，你可以选择一名装备区有空置装备栏的角色，其为每个空置的装备栏从额外牌堆随机使用一张对应"..
  "类别的装备。",
  ["#ofl_shiji__mingfa-choose"] = "明伐：你可以展示一张手牌，用此牌与一名角色拼点，若赢，获得其一张牌并摸一张牌",
  ["@@ofl_shiji__mingfa-turn"] = "明伐失败",
  ["#ofl_shiji__rongbei"] = "戎备：令一名角色从额外牌堆每个空置的装备栏随机使用一张装备",

  ["$ofl_shiji__mingfa1"] = "我军素以德信著称，断不会行谲诈之策。",
  ["$ofl_shiji__mingfa2"] = "吾等不妨克日而战，以行君子之争。",
  ["$ofl_shiji__rongbei1"] = "吾等无休之时，速置军资，以充戎备。",
  ["$ofl_shiji__rongbei2"] = "军饷兵械多多益善，无恤时日之久。",
  ["~ofl_shiji__yanghu"] = "吾身虽殒，名可垂于竹帛……",
}

local xujing = General(extension, "ofl_shiji__xujing", "shu", 3)
local ofl_shiji__boming = fk.CreateActiveSkill{
  name = "ofl_shiji__boming",
  anim_type = "support",
  card_num = 1,
  target_num = 1,
  prompt = "#ofl_shiji__boming",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) < 2
  end,
  card_filter = Util.TrueFunc,
  target_filter = function(self, to_select, selected)
    return to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local mark = player:getTableMark(self.name)
    table.insertIfNeed(mark, target.id)
    room:setPlayerMark(player, self.name, mark)
    room:moveCardTo(effect.cards, Card.PlayerHand, target, fk.ReasonGive, self.name, nil, false, player.id)
  end,
}
local ofl_shiji__boming_trigger = fk.CreateTriggerSkill{
  name = "#ofl_shiji__boming_trigger",
  mute = true,
  main_skill = ofl_shiji__boming,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Finish and
      #player:getTableMark("ofl_shiji__boming") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player:broadcastSkillInvoke("ofl_shiji__boming")
    player.room:notifySkillInvoked(player, "ofl_shiji__boming", "drawcard")
    player:drawCards(#player:getTableMark("ofl_shiji__boming"), "ofl_shiji__boming")
  end,
}
local ofl_shiji__ejian = fk.CreateTriggerSkill{
  name = "ofl_shiji__ejian",
  anim_type = "control",
  frequency = Skill.Compulsory,
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      for _, move in ipairs(data) do
        if move.from == player.id and move.to and move.to ~= player.id and move.toArea == Card.PlayerHand then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
              return true
            end
          end
        end
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    local room = player.room
    local tos = {}
    for _, move in ipairs(data) do
      if move.from == player.id and move.to and move.to ~= player.id and move.toArea == Card.PlayerHand then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
            table.insertIfNeed(tos, move.to)
            break
          end
        end
      end
    end
    room:sortPlayersByAction(tos)
    for _, id in ipairs(tos) do
      if not player:hasSkill(self) then break end
      local to = room:getPlayerById(id)
      if to and not to.dead and not to:isNude() then
        self:doCost(event, to, player, data)
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    if not target:isKongcheng() then
      target:showCards(target:getCardIds("h"))
    end
    if target.dead or target:isNude() then return end
    room:delay(1000)
    local yes, cards = false, {}
    for _, move in ipairs(data) do
      if move.from == player.id and move.to and move.to ~= player.id and move.toArea == Card.PlayerHand then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
            for _, id in ipairs(target:getCardIds("he")) do
              if id ~= info.cardId and Fk:getCardById(id).type == Fk:getCardById(info.cardId).type then
                yes = true
                if not target:prohibitDiscard(id) then
                  table.insertIfNeed(cards, id)
                end
              end
            end
          end
        end
      end
    end
    if not yes then return end
    if #cards == 0 or not room:askForSkillInvoke(target, self.name, nil, "#ofl_shiji__ejian-discard:"..player.id) then
      room:damage{
        from = player,
        to = target,
        damage = 1,
        skillName = self.name,
      }
      room:setPlayerMark(player, "ofl_shiji__boming", 0)
    else
      room:throwCard(cards, self.name, target, target)
    end
  end,
}
ofl_shiji__boming:addRelatedSkill(ofl_shiji__boming_trigger)
xujing:addSkill(ofl_shiji__boming)
xujing:addSkill(ofl_shiji__ejian)
Fk:loadTranslationTable{
  ["ofl_shiji__xujing"] = "许靖",
  ["#ofl_shiji__xujing"] = "篡贤取良",
  ["illustrator:ofl_shiji__xujing"] = "铁杵文化",

  ["ofl_shiji__boming"] = "博名",
  [":ofl_shiji__boming"] = "出牌阶段限两次，你可以将一张牌交给一名其他角色。结束阶段，你摸X张牌（X为本局游戏你发动此技能交给过牌的角色数）。",
  ["ofl_shiji__ejian"] = "恶荐",
  [":ofl_shiji__ejian"] = "锁定技，当其他角色获得你的牌后，其展示所有手牌，若其有除此牌以外与此牌类别相同的牌，其选择一项："..
  "1.弃置这些牌；2.受到你造成的1点伤害，你重置〖博名〗记录的角色。",
  ["#ofl_shiji__boming"] = "博名：你可以将一张牌交给一名其他角色",
  ["#ofl_shiji__ejian-discard"] = "恶荐：弃置除获得的牌外和获得的牌类别相同的牌，或点“取消”%src 对你造成1点伤害",

  ["$ofl_shiji__boming1"] = "君子执仁立志，吾……断无先行之理！",
  ["$ofl_shiji__boming2"] = "人无礼不生，事无礼不成，诸君且先行！",
  ["$ofl_shiji__ejian1"] = "贤者当举而上之，不肖者当抑而废之。",
  ["$ofl_shiji__ejian2"] = "董公虽能臣天下之人，不能擅天下之士也。",
  ["~ofl_shiji__xujing"] = "靖获虚誉而得用，唯以荐才报君恩……",
}

--local zhangwen = General(extension, "ofl_shiji__zhangwen", "wu", 3)
local ofl_shiji__songshu = fk.CreateTriggerSkill{
  name = "ofl_shiji__songshu",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target.phase == Player.Play and not player:isNude()
  end,
  on_cost = function (self, event, target, player, data)
    local card = player.room:askForCard(player, 1, 1, true, self.name, true, nil, "#ofl_shiji__songshu-put::"..target.id)
    if #card > 0 then
      self.cost_data = {tos = {target.id}, cards = card}
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    U.AddToRenPile(room, self.cost_data.cards, self.name, player.id)
    if target.dead then return end
    if #U.GetRenPile(room) >= target:getHandcardNum() then
      room:setPlayerMark(target, "@@ofl_shiji__songshu-turn", 1)
    end
  end,

  refresh_events = {fk.AfterTurnEnd, fk.StartPlayCard, "fk.AfterRenMove"},
  can_refresh  = function (self, event, target, player, data)
    return player:getMark("@@ofl_shiji__songshu-turn") > 0
  end,
  on_refresh  = function (self, event, target, player, data)
    local room = player.room
    --[[if event == fk.AfterTurnEnd then
      player.special_cards["RenPile&"] = nil
      })
    else
      player.special_cards["RenPile&"] = U.GetRenPile(room)
      })
    end]]--  ChangeSelf丸辣！暂时想不到体验很好的实现方法
  end,
}
local ofl_shiji__songshu_prohibit = fk.CreateProhibitSkill{
  name = "#ofl_shiji__songshu_prohibit",
  prohibit_use = function(self, player, card)
    if player:getMark("@@ofl_shiji__songshu-turn") > 0 then
      local subcards = card:isVirtual() and card.subcards or {card.id}
      return #subcards == 0 or table.find(subcards, function(id)
        return not table.contains(player.special_cards["RenPile&"] or {}, id)
      end)
    end
  end,
  prohibit_response = function(self, player, card)
    if player:getMark("@@ofl_shiji__songshu-turn") > 0 then
      local subcards = card:isVirtual() and card.subcards or {card.id}
      return #subcards == 0 or table.find(subcards, function(id)
        return not table.contains(player.special_cards["RenPile&"] or {}, id)
      end)
    end
  end,
}
ofl_shiji__songshu:addRelatedSkill(ofl_shiji__songshu_prohibit)
--zhangwen:addSkill(ofl_shiji__songshu)
--zhangwen:addSkill("gebo")
Fk:loadTranslationTable{
  ["ofl_shiji__zhangwen"] = "张温",
  ["#ofl_shiji__zhangwen"] = "炜晔曜世",
  ["illustrator:ofl_shiji__zhangwen"] = "zoo",

  ["ofl_shiji__songshu"] = "颂蜀",
  [":ofl_shiji__songshu"] = "一名角色出牌阶段开始时，你可以将一张牌置入“仁”区，然后若“仁”区牌数不小于其手牌数，你令其本回合只能"..
  "使用或打出“仁”区牌。",
  ["#ofl_shiji__songshu-put"] = "颂蜀：你可以将一张牌置入仁区，然后若仁区牌数不小于 %dest 手牌数，其本回合只能使用打出仁区牌",
  ["@@ofl_shiji__songshu-turn"] = "颂蜀",
  ["RenPile&"] = "仁区",

  ["$gebo_ofl_shiji__zhangwen1"] = "高宗守丧而兴殷，成王德治以太平。",
  ["$gebo_ofl_shiji__zhangwen2"] = "化干戈玉帛，共伐乱贼。",
  ["$ofl_shiji__songshu1"] = "以陛下之聪恣，可比古贤。",
  ["$ofl_shiji__songshu2"] = "庭若灿星，统于有道之君。",
  ["~ofl_shiji__zhangwen"] = "臣未挟异心，请陛下明鉴……",
}

local qiaogong = General(extension, "ofl_shiji__qiaogong", "wu", 3)
local ofl_shiji__yizhu = fk.CreateTriggerSkill{
  name = "ofl_shiji__yizhu",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Finish and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local num = math.min(#room.players, #room.draw_pile)
    room:setPlayerMark(player, "ofl_shiji__yizhu-tmp", {".|.|heart,diamond", num})
    local success, dat = room:askForUseActiveSkill(player, "ofl_shiji__yizhu_active",
      "#ofl_shiji__yizhu-put:::red:"..num, true)
    room:setPlayerMark(player, "ofl_shiji__yizhu-tmp", 0)
    if success and dat then
      self.cost_data = {cards = dat.cards, choice = dat.interaction}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:moveCards({
      ids = self.cost_data.cards,
      from = player.id,
      toArea = Card.DrawPile,
      moveReason = fk.ReasonJustMove,
      skillName = self.name,
      drawPilePosition = tonumber(self.cost_data.choice),
    })
    room:sendLog{
      type = "#ofl_shiji__yizhu_toast",
      from = player.id,
      arg = self.cost_data.choice,
      card = self.cost_data.cards,
      toast = true,
    }
    if not player.dead then
      room:addTableMark(player, "ofl_shiji__yizhu_cards", self.cost_data.cards[1])
    end
    if player.dead or player:isNude() then return end
    local arg, pattern = "log_heart", ".|.|heart"
    if Fk:getCardById(self.cost_data.cards[1]).suit == Card.Heart then
      arg, pattern = "log_diamond", ".|.|diamond"
    end
    local num = math.min(#room.players, #room.draw_pile)
    room:setPlayerMark(player, "ofl_shiji__yizhu-tmp", {pattern, num})
    local success, dat = room:askForUseActiveSkill(player, "ofl_shiji__yizhu_active",
      "#ofl_shiji__yizhu-put:::"..arg..":"..num, true)
    room:setPlayerMark(player, "ofl_shiji__yizhu-tmp", 0)
    if success and dat then
      room:moveCards({
        ids = dat.cards,
        from = player.id,
        toArea = Card.DrawPile,
        moveReason = fk.ReasonJustMove,
        skillName = self.name,
        drawPilePosition = tonumber(dat.interaction),
      })
      room:sendLog{
        type = "#ofl_shiji__yizhu_toast",
        from = player.id,
        arg = dat.interaction,
        card = dat.cards,
        toast = true,
      }
      if not player.dead then
        room:addTableMark(player, "ofl_shiji__yizhu_cards", dat.cards[1])
      end
    end
  end,
}
local ofl_shiji__yizhu_trigger = fk.CreateTriggerSkill{
  name = "#ofl_shiji__yizhu_trigger",
  mute = true,
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    local mark = player:getTableMark("ofl_shiji__yizhu_cards")
    if #mark > 0 then
      for _, move in ipairs(data) do
        for _, info in ipairs(move.moveInfo) do
          if table.contains(mark, info.cardId) then
            return true
          end
        end
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    local room = player.room
    local mark = player:getTableMark("ofl_shiji__yizhu_cards")
    local tos = {}
    if #mark > 0 then
      for _, move in ipairs(data) do
        for _, info in ipairs(move.moveInfo) do
          if table.contains(mark, info.cardId) then
            room:removeTableMark(player, "ofl_shiji__yizhu_cards", info.cardId)
            if move.to and move.toArea == Card.PlayerHand then
              table.insert(tos, move.to)
            end
          end
        end
      end
    end
    if #tos > 0 then
      for _, id in ipairs(tos) do
        if player.dead then break end
        local to = room:getPlayerById(id)
        if not to.dead then
          self:doCost(event, to, player, data)
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, "ofl_shiji__yizhu", nil, "#ofl_shiji__yizhu-invoke::"..target.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("ofl_shiji__yizhu")
    room:notifySkillInvoked(player, "ofl_shiji__yizhu", "support")
    player:drawCards(1, "ofl_shiji__yizhu")
    if not target.dead then
      target:drawCards(1, "ofl_shiji__yizhu")
    end
  end,
}
local ofl_shiji__yizhu_active = fk.CreateActiveSkill{
  name = "ofl_shiji__yizhu_active",
  card_num = 1,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select):matchPattern(Self:getMark("ofl_shiji__yizhu-tmp")[1])
  end,
  target_num = 0,
  interaction = function()
    --[[return UI.Spin {
      from = 1,
      to = Self:getMark("ofl_shiji__yizhu-tmp")[2],  --FIXME: interaction类型为spin时，askForUseActiveSkill无法取消
    }]]--
    local choices = {}
    for i = 1, Self:getMark("ofl_shiji__yizhu-tmp")[2], 1 do
      table.insert(choices, tostring(i))
    end
    return UI.ComboBox { choices = choices }
  end,
}
Fk:addSkill(ofl_shiji__yizhu_active)
ofl_shiji__yizhu:addRelatedSkill(ofl_shiji__yizhu_trigger)
qiaogong:addSkill(ofl_shiji__yizhu)
qiaogong:addSkill("luanchou")
qiaogong:addRelatedSkill("gonghuan")
Fk:loadTranslationTable{
  ["ofl_shiji__qiaogong"] = "桥公",
  ["#ofl_shiji__qiaogong"] = "高风硕望",
  ["illustrator:ofl_shiji__qiaogong"] = "君桓文化",

  ["ofl_shiji__yizhu"] = "遗珠",
  [":ofl_shiji__yizhu"] = "结束阶段，你可以依次将至多两张花色不同的红色牌正面朝上置于牌堆顶前X张的任意位置（X为角色数）。当其他角色"..
  "获得“遗珠”牌后，你可以与其各摸一张牌。",
  ["ofl_shiji__yizhu_active"] = "遗珠",
  ["#ofl_shiji__yizhu-put"] = "遗珠：你可以将一张%arg牌置于牌堆前%arg2张的位置，其他角色获得遗珠牌后你可以与其各摸一张牌",
  ["#ofl_shiji__yizhu_toast"] = "%from 将 %card 置于牌堆顶第%arg张",
  ["#ofl_shiji__yizhu-invoke"] = "遗珠：是否与 %dest 各摸一张牌？",

  ["$ofl_shiji__yizhu1"] = "尝闻日久可消愁思，然却难愈遗珠之痛。",
  ["$ofl_shiji__yizhu2"] = "乱世天子尚如浮萍，更况吾女天香国色。",
  ["$luanchou_ofl_shiji__qiaogong1"] = "金玉结同心，天作成良缘。",
  ["$luanchou_ofl_shiji__qiaogong2"] = "姻缘夙世成，和顺从今定。",
  ["$gonghuan_ofl_shiji__qiaogong1"] = "魏似猛虎，吴蜀如羊，当此时势，复何虑也。",
  ["$gonghuan_ofl_shiji__qiaogong2"] = "两国当以联姻之谊，共抗魏国之击。",
  ["~ofl_shiji__qiaogong"] = "得婿如此，夫复何求……",
}

local liuzhang = General(extension, "ofl_shiji__liuzhang", "qun", 3)
local ofl_shiji__yinge = fk.CreateActiveSkill{
  name = "ofl_shiji__yinge",
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  prompt = "#ofl_shiji__yinge",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= Self.id and not Fk:currentRoom():getPlayerById(to_select):isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local card = room:askForCard(target, 1, 1, false, self.name, false, nil, "#ofl_shiji__yinge-card")
    U.AddToRenPile(room, card, self.name, target.id)
    local cards = U.GetRenPile(room)
    if target.dead or #cards == 0 then return end
    local use = U.askForUseRealCard(room, target, cards, nil, self.name,
      "#ofl_shiji__yinge-use:"..player.id, {bypass_times = true, expand_pile = cards, extraUse = true}, true, true)
    if use then
      if use.card.is_damage_card and not use.card.multiple_targets and
        table.contains(room:getUseExtraTargets(use, true), player.id) then
        table.insert(use.tos, {player.id})
      end
      room:useCard(use)
    end
  end,
}
local ofl_shiji__shiren = fk.CreateTriggerSkill{
  name = "ofl_shiji__shiren",
  anim_type = "drawcard",
  events = {fk.TargetConfirmed},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.from ~= player.id and data.card.is_damage_card
  end,
  on_cost = function (self, event, target, player, data)
    local choice = player.room:askForChoice(player, {"ofl_shiji__shiren1", "ofl_shiji__shiren2", "Cancel"}, self.name)
    if choice ~= "Cancel" then
      self.cost_data = {choice = choice}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if self.cost_data.choice == "ofl_shiji__shiren1" then
      U.AddToRenPile(room, room:getNCards(2), self.name, player.id)
      local cards = U.GetRenPile(room)
      if #cards == 0 then return end
      cards = U.askforChooseCardsAndChoice(target, cards, {"OK"}, self.name, "#ofl_shiji__shiren-prey")
      room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonJustMove, self.name, nil, true, player.id)
    else
      player:drawCards(2, self.name)
      if player.dead or player:isKongcheng() then return end
      local card = room:askForCard(player, 1, 1, false, self.name, false, nil, "#ofl_shiji__shiren-card")
      U.AddToRenPile(room, card, self.name, player.id)
    end
  end,
}
local ofl_shiji__jvyi = fk.CreateTriggerSkill{
  name = "ofl_shiji__jvyi$",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target.phase == Player.Discard and
      target ~= player and target.kingdom == "qun" and not target.dead and not target:isKongcheng()
  end,
  on_cost = function (self, event, target, player, data)
    local card = player.room:askForCard(target, 1, 1, false, self.name, true, nil, "#ofl_shiji__jvyi-put:"..player.id)
    if #card > 0 then
      self.cost_data = {tos = {player.id}, cards = card}
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    U.AddToRenPile(player.room, self.cost_data.cards, self.name, target.id)
  end,

  refresh_events = {fk.AfterCardsMove},
  can_refresh = function (self, event, target, player, data)
    if player:usedSkillTimes(self.name, Player.HistoryPhase) > 0 and not player.dead then
      local e = player.room.logic:getCurrentEvent():findParent(GameEvent.SkillEffect)
      if e and e.data[3] == self then
        return true
      end
    end
  end,
  on_refresh = function (self, event, target, player, data)
    for _, move in ipairs(data) do
      if move.toArea == Card.DiscardPile and move.skillName == "ren_overflow" then
        for _, info in ipairs(move.moveInfo) do
          if table.contains(player.room.discard_pile, info.cardId) then
            player.room:moveCardTo(info.cardId, Card.PlayerHand, player, fk.ReasonJustMove, self.name, nil, true, player.id)
          end
        end
      end
    end
  end,
}
liuzhang:addSkill(ofl_shiji__yinge)
liuzhang:addSkill(ofl_shiji__shiren)
liuzhang:addSkill(ofl_shiji__jvyi)
Fk:loadTranslationTable{
  ["ofl_shiji__liuzhang"] = "刘璋",
  ["#ofl_shiji__liuzhang"] = "半圭黯暗",
  ["illustrator:ofl_shiji__liuzhang"] = "",

  ["ofl_shiji__yinge"] = "引戈",
  [":ofl_shiji__yinge"] = "出牌阶段限一次，你可以令一名其他角色将一张手牌置入“仁”区，然后其可以使用一张“仁”区牌，若此牌为伤害类牌，"..
  "额外指定你为目标。"..
  "<br/><font color='grey'>#\"<b>仁区</b>\"<br/>"..
  "仁区是一个存于场上，用于存放牌的公共区域。仁区中的牌上限为6张，当仁区中的牌超过6张时，最先置入仁区中的牌将置入弃牌堆。",
  ["ofl_shiji__shiren"] = "施仁",
  [":ofl_shiji__shiren"] = "当你成为其他角色使用伤害类牌的目标后，你可以选择一项：1.将牌堆顶两张牌置入“仁”区，然后你获得一张“仁”区牌；"..
  "2.摸两张牌，然后将一张手牌置入“仁”区。",
  ["ofl_shiji__jvyi"] = "据益",
  [":ofl_shiji__jvyi"] = "主公技，其他群势力角色弃牌阶段开始时，其可以将一张手牌置入“仁”区，然后若“仁”区溢出，你获得因此溢出的牌。",
  ["#ofl_shiji__yinge"] = "引戈：令一名角色将一张手牌置入仁区，然后其可以使用一张仁区牌，若为伤害牌则额外指定你为目标",
  ["#ofl_shiji__yinge-card"] = "引戈：请将一张手牌置入仁区，然后你可以使用一张仁区牌",
  ["#ofl_shiji__yinge-use"] = "引戈：你可以使用一张仁区牌，若为伤害牌，额外指定 %src 为目标",
  ["ofl_shiji__shiren1"] = "将牌堆顶两张牌置入仁区，然后获得一张仁区牌",
  ["ofl_shiji__shiren2"] = "摸两张牌，然后将一张手牌置入仁区",
  ["#ofl_shiji__shiren-prey"] = "施仁：获得一张“仁”区牌",
  ["#ofl_shiji__shiren-card"] = "施仁：请将一张手牌置入仁区",
  ["#ofl_shiji__jvyi-put"] = "据益：你可以将一张手牌置入仁区，若因此溢出（仁区超过6张牌会溢出），%src 获得溢出的牌",
}

local zhugeshang = General(extension, "fhyx__zhugeshang", "shu", 3)
local ofl__sangu = fk.CreateTriggerSkill{
  name = "ofl__sangu",
  anim_type = "support",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target.phase == Player.Play and target:getHandcardNum() >= target.maxHp
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#ofl__sangu-invoke::"..target.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local ids = room:getNCards(3)
    local fakemove = {
      toArea = Card.PlayerHand,
      to = player.id,
      moveInfo = table.map(ids, function(id) return {cardId = id, fromArea = Card.Void} end),
      moveReason = fk.ReasonJustMove,
    }
    room:notifyMoveCards({player}, {fakemove})
    local availableCards = {}
    for _, id in ipairs(ids) do
      local card = Fk:getCardById(id)
      if card.type == Card.TypeBasic or card:isCommonTrick() then
        table.insertIfNeed(availableCards, id)
      end
    end
    room:setPlayerMark(player, "ofl__sangu_cards", availableCards)
    local success, dat = room:askForUseActiveSkill(player, "ofl__sangu_show", "#ofl__sangu-show::"..target.id, true)
    room:setPlayerMark(player, "ofl__sangu_cards", 0)
    fakemove = {
      from = player.id,
      toArea = Card.Void,
      moveInfo = table.map(ids, function(id) return {cardId = id, fromArea = Card.PlayerHand} end),
      moveReason = fk.ReasonJustMove,
    }
    room:notifyMoveCards({player}, {fakemove})
    for i = #ids, 1, -1 do
      table.insert(room.draw_pile, 1, ids[i])
    end
    if success then
      room:doIndicate(player.id, {target.id})
      room:moveCards({
        fromArea = Card.DrawPile,
        ids = dat.cards,
        toArea = Card.Processing,
        moveReason = fk.ReasonJustMove,
        skillName = self.name,
      })
      room:sendFootnote(dat.cards, {
        type = "##ShowCard",
        from = player.id,
      })
      room:delay(2000)
      room:moveCards({
        ids = dat.cards,
        toArea = Card.DiscardPile,
        moveReason = fk.ReasonJustMove,
        skillName = self.name,
      })
      if not target.dead then
        local mark = table.map(dat.cards, function(id) return Fk:getCardById(id).name end)
        room:setPlayerMark(target, "@$ofl__sangu-phase", mark)
        room:handleAddLoseSkills(target, "ofl__sangu&", nil, false, true)
        room.logic:getCurrentEvent():findParent(GameEvent.Phase, true):addCleaner(function()
          room:handleAddLoseSkills(target, '-ofl__sangu&', nil, false, true)
        end)
      end
    end
  end,
}
local ofl__sangu_show = fk.CreateActiveSkill{
  name = "ofl__sangu_show",
  min_card_num = 1,
  target_num = 0,
  card_filter = function(self, to_select, selected)
    local ids = Self:getMark("ofl__sangu_cards")
    return ids ~= 0 and table.contains(ids, to_select) and
      table.every(selected, function(id) return Fk:getCardById(to_select).trueName ~= Fk:getCardById(id).trueName end)
  end,
}
local ofl__sangu_active = fk.CreateViewAsSkill{
  name = "ofl__sangu&",
  pattern = ".",
  prompt = "#ofl__sangu",
  interaction = function()
    return UI.ComboBox {choices = Self:getMark("@$ofl__sangu-phase")}
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:currentRoom():getCardArea(to_select) == Player.Hand
  end,
  view_as = function(self, cards)
    if #cards ~= 1 or not self.interaction.data then return end
    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcard(cards[1])
    card.skillName = self.name
    return card
  end,
  before_use = function(self, player, use)
    player.room:removeTableMark(player, "@$ofl__sangu-phase", use.card.name)
  end,
  enabled_at_play = function(self, player)
    return not player:isKongcheng() and player:getMark("@$ofl__sangu-phase") ~= 0
  end,
  enabled_at_response = function(self, player, response)
    return not response and not player:isKongcheng() and player:getMark("@$ofl__sangu-phase") ~= 0
  end,
}
Fk:addSkill(ofl__sangu_show)
Fk:addSkill(ofl__sangu_active)
zhugeshang:addSkill(ofl__sangu)
zhugeshang:addSkill("yizu")
Fk:loadTranslationTable{
  ["fhyx__zhugeshang"] = "诸葛尚",
  ["#fhyx__zhugeshang"] = "碧落玄鹄",
  ["designer:fhyx__zhugeshang"] = "叫什么啊你妹",
  ["illustrator:fhyx__zhugeshang"] = "鬼画府",

  ["ofl__sangu"] = "三顾",
  [":ofl__sangu"] = "一名角色出牌阶段开始时，若其手牌数不小于其体力上限，你可以观看牌堆顶三张牌并亮出其中任意张牌名不同的基本牌或普通锦囊牌。"..
  "若如此做，此阶段每种牌名限一次，该角色可以将一张手牌当你亮出的一张牌使用。",
  ["#ofl__sangu-invoke"] = "三顾：你可以观看牌堆顶三张牌，令 %dest 本阶段可以将手牌当其中的牌使用",
  ["ofl__sangu_show"] = "三顾",
  ["#ofl__sangu-show"] = "三顾：你可以亮出其中的基本牌或普通锦囊牌，%dest 本阶段可以将手牌当亮出的牌使用",
  ["@$ofl__sangu-phase"] = "三顾",
  ["ofl__sangu&"] = "三顾",
  [":ofl__sangu&"] = "出牌阶段每种牌名限一次，你可以将一张手牌当一张“三顾”牌使用。",
  ["#ofl__sangu"] = "三顾：你可以将一张手牌当一张“三顾”牌使用",

  ["$ofl__sangu1"] = "蒙先帝三顾祖父之恩，吾父子自当为国用命！",
  ["$ofl__sangu2"] = "祖孙三代世受君恩，当效吾祖鞠躬尽瘁。",
  ["$yizu_fhyx__zhugeshang1"] = "自幼家学渊源，岂会看不穿此等伎俩？",
  ["$yizu_fhyx__zhugeshang2"] = "祖父在上，孩儿定不负诸葛之名！",
  ["~fhyx__zhugeshang"] = "今父既死于敌，我又何能独活？",
}

return extension
