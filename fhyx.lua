local extension = Package("fhyx")
extension.extensionName = "offline"

Fk:loadTranslationTable{
  ["fhyx"] = "线下-飞鸿映雪",
}

local U = require "packages/utility/utility"

local bianfuren = General(extension, "ofl__bianfuren", "wei", 3, 3, General.Female)
local ofl__fuding = fk.CreateTriggerSkill{
  name = "ofl__fuding",
  anim_type = "support",
  events = {fk.EnterDying, fk.AfterDying},
  can_trigger = function(self, event, target, player, data)
    if event == fk.EnterDying then
      return player:hasSkill(self) and target ~= player and not player:isNude() and
        player:usedSkillTimes(self.name, Player.HistoryRound) == 0
    else
      return not target.dead and data.extra_data and data.extra_data.ofl__fuding and data.extra_data.ofl__fuding[1] == player.id and
        not player.dead
    end
  end,
  on_cost = function(self, event, target, player, data)
    if event == fk.EnterDying then
      local cards = player.room:askForCard(player, 1, 5, true, self.name, true, ".", "#ofl__fuding-invoke::"..target.id)
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
      data.extra_data.ofl__fuding = {player.id, #self.cost_data}
    else
      player:drawCards(data.extra_data.ofl__fuding[2], self.name)
      if player:isWounded() and not player.dead then
        room:recover{
          who = player,
          num = 1,
          recoverBy = player,
          skillName = self.name
        }
      end
    end
  end,
}
local ofl__yuejian = fk.CreateViewAsSkill{
  name = "ofl__yuejian",
  pattern = ".|.|.|.|.|basic",
  prompt = "#ofl__yuejian",
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
    return player:getMark("ofl__yuejian-round") == 0
  end,
  enabled_at_response = function(self, player, response)
    return not response and player:getMark("ofl__yuejian-round") == 0
  end,
}
local ofl__yuejian_record = fk.CreateTriggerSkill{
  name = "#ofl__yuejian_record",

  refresh_events = {fk.AfterCardUseDeclared, fk.EventAcquireSkill},
  can_refresh = function(self, event, target, player, data)
    if event == fk.AfterCardUseDeclared then
      return target == player and data.card.type == Card.TypeBasic and player:getMark("ofl__yuejian-round") == 0
    elseif target == player and data == self and player:getMark("ofl__yuejian-round") == 0 and player.room:getTag("RoundCount") then
      return #player.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function(e)
        local use = e.data[1]
        return use.from == player.id and use.card.type == Card.TypeBasic
      end, Player.HistoryRound) > 0
    end
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "ofl__yuejian-round", 1)
  end,
}
local ofl__yuejian_maxcards = fk.CreateMaxCardsSkill{
  name = "#ofl__yuejian_maxcards",
  correct_func = function(self, player)
    if player:hasSkill("ofl__yuejian") then
      return player.maxHp
    else
      return 0
    end
  end,
}
ofl__yuejian:addRelatedSkill(ofl__yuejian_record)
ofl__yuejian:addRelatedSkill(ofl__yuejian_maxcards)
bianfuren:addSkill(ofl__fuding)
bianfuren:addSkill(ofl__yuejian)
Fk:loadTranslationTable{
  ["ofl__bianfuren"] = "卞夫人",
  ["#ofl__bianfuren"] = "内助贤后",
  ["illustrator:ofl__bianfuren"] = "云涯", -- 史诗皮肤 蝶恋琵琶
  ["ofl__fuding"] = "抚定",
  [":ofl__fuding"] = "每轮限一次，当一名其他角色进入濒死状态时，你可以交给其至多五张牌，若如此做，当其脱离濒死状态时，你摸等量牌并回复1点体力。",
  ["ofl__yuejian"] = "约俭",
  [":ofl__yuejian"] = "你的手牌上限+X（X为你的体力上限）。当你需使用一张基本牌时，若你本轮未使用过基本牌，你可以视为使用之。",
  ["#ofl__fuding-invoke"] = "抚定：你可以交给 %dest 至多五张牌，其脱离濒死状态后你摸等量牌并回复1点体力",
  ["#ofl__yuejian"] = "约俭：你可以视为使用一张基本牌",
}

local chenzhen = General(extension, "ofl__chenzhen", "shu", 3)
local ofl__shameng = fk.CreateActiveSkill{
  name = "ofl__shameng",
  anim_type = "drawcard",
  min_card_num = 1,
  max_card_num = 2,
  target_num = 1,
  prompt = "#ofl__shameng",
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
    local cards = room:askForCard(target, 1, 2, false, self.name, false, ".", "#ofl__shameng-show:"..player.id)
    for _, id in ipairs(cards) do
      local card = Fk:getCardById(id)
      if card.suit ~= Card.NoSuit then
        table.insertIfNeed(suits, card.suit)
      end
      table.insertIfNeed(types, card.type)
    end
    target:showCards(cards)
    if player.dead then return end
    if room:askForSkillInvoke(player, self.name, nil, "#ofl__shameng-discard::"..target.id..":"..#suits..":"..#types) then
      local move1 = {
        ids = table.filter(effect.cards, function(id) return room:getCardOwner(id) == player and room:getCardArea(id) == Player.Hand end),
        from = player.id,
        toArea = Card.DiscardPile,
        moveReason = fk.ReasonDiscard,
        proposer = player.id,
        skillName = self.name,
      }
      local move2 = {
        ids = table.filter(cards, function(id) return room:getCardOwner(id) == target and room:getCardArea(id) == Player.Hand end),
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
chenzhen:addSkill(ofl__shameng)
Fk:loadTranslationTable{
  ["ofl__chenzhen"] = "陈震",
  ["#ofl__chenzhen"] = "歃盟使节",
  ["ofl__shameng"] = "歃盟",
  [":ofl__shameng"] = "出牌阶段限一次，你可以展示一至两张手牌，然后令一名其他角色展示一至两张手牌，若如此做，你可以弃置这些牌，你摸等同于其中"..
  "花色数的牌，令该角色摸等同于其中类别数的牌。",
  ["#ofl__shameng"] = "歃盟：你可以展示至多两张手牌，令一名角色展示至多两张手牌，你可以弃置这些牌令双方摸牌",
  ["#ofl__shameng-show"] = "歃盟：请展示一至两张手牌，%src 可以弃置这些牌令双方摸牌",
  ["#ofl__shameng-discard"] = "歃盟：是否弃置这些牌令双方摸牌？你摸%arg张，%dest摸%arg2张",
}

--[[
local sunshao = General:new(extension, "ofl__sunshao", "wu", 3)
local ofl__dingyi = fk.CreateTriggerSkill{
  name = "ofl__dingyi",
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
    local tos, cardId = room:askForChooseCardAndPlayers(player, targets, 1, 1, ".|.|^("..table.concat(suits,",")..")", "#ofl__dingyi-use", self.name, true)
    if #tos > 0 and cardId then
      local to = room:getPlayerById(tos[1])
      to:addToPile(self.name, cardId, true, self.name)
      room:broadcastProperty(to, "MaxCards")
    end
  end,
}
local ofl__dingyi_delay = fk.CreateTriggerSkill{
  name = "#ofl__dingyi_delay",
  mute = true,
  events = {fk.DrawNCards, fk.AfterDying},
  can_trigger = function(self, event, target, player, data)
    if target == player and #player:getPile("ofl__dingyi") > 0 then
      if event == fk.DrawNCards then
        return Fk:getCardById(player:getPile("ofl__dingyi")[1]).suit == Card.Diamond
      elseif Fk:getCardById(player:getPile("ofl__dingyi")[1]).suit == Card.Heart and player:isWounded() then
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
        skillName = "dingyi",
      })
    end
  end,
}
local ofl__dingyi_maxcards = fk.CreateMaxCardsSkill{
  name = "#ofl__dingyi_maxcards",
  correct_func = function(self, player)
    if #player:getPile("ofl__dingyi") > 0 and Fk:getCardById(player:getPile("ofl__dingyi")[1]).suit == Card.Spade then
      return 4
    end
  end,
}
local ofl__dingyi_targetmod = fk.CreateTargetModSkill{
  name = "#ofl__dingyi_targetmod",
  bypass_distances = function(self, player)
    return #player:getPile("ofl__dingyi") > 0 and Fk:getCardById(player:getPile("ofl__dingyi")[1]).suit == Card.Club
  end,
}
ofl__dingyi:addRelatedSkill(ofl__dingyi_delay)
ofl__dingyi:addRelatedSkill(ofl__dingyi_maxcards)
ofl__dingyi:addRelatedSkill(ofl__dingyi_targetmod)
sunshao:addSkill(ofl__dingyi)
local zuici = fk.CreateTriggerSkill{
  name = "ofl__zuici",
  anim_type = "masochism",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.from and not data.from.dead and data.from:getMark("@dingyi") ~= 0
  end,
  on_cost = function(self, event, target, player, data)
    local choice = player.room:askForChoice(player, {"Cancel", "dismantlement", "ex_nihilo", "nullification"}, self.name,
      "#zuici-invoke::"..data.from.id)
    if choice ~= "Cancel" then
      self.cost_data = choice
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {data.from.id})
    room:setPlayerMark(data.from, "@dingyi", 0)
    local cards = room:getCardsFromPileByRule(self.cost_data)
    if #cards > 0 then
      room:moveCards({
        ids = cards,
        to = data.from.id,
        toArea = Card.PlayerHand,
        moveReason = fk.ReasonJustMove,
        proposer = player.id,
        skillName = self.name,
      })
    end
  end,
}
--]]

Fk:loadTranslationTable{
  ["ofl__sunshao"] = "孙邵",
  ["ofl__dingyi"] = "定仪",
  [":ofl__dingyi"] = "每轮开始时，你可以摸一张牌，然后将一张与“定仪”牌花色均不同的牌置于一名没有“定仪”牌的角色武将牌旁。有“定仪”牌的角色根据花色"..
  "获得对应效果：<br>♠，手牌上限+4；<br><font color='red'>♥</font>，每回合首次脱离濒死状态时，回复2点体力；♣，使用牌无距离限制；"..
  "<font color='red'>♦</font>，摸牌阶段多摸两张牌。",
  ["#ofl__dingyi-use"] = "定仪：一张与“定仪”牌花色均不同的牌置于一名角色武将牌旁",
  ["#ofl__dingyi_delay"] = "定仪",
  ["ofl__zuici"] = "罪辞",
  [":ofl__zuici"] = "当你受到伤害后，你可以获得一名角色的“定仪”牌，然后你从额外牌堆选择一张智囊牌令其获得。",
}

local duyu = General(extension, "ofl__duyu", "qun", 4)
duyu.subkingdom = "jin"
local ofl__wuku = fk.CreateTriggerSkill{
  name = "ofl__wuku",
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
local ofl__sanchen = fk.CreateTriggerSkill{
  name = "ofl__sanchen",
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
    if player:isWounded() then
      room:recover{
        who = player,
        num = 1,
        skillName = self.name,
      }
    end
    room:handleAddLoseSkills(player, "ofl__miewu", nil, true, false)
  end,
}
local ofl__miewu = fk.CreateViewAsSkill{
  name = "ofl__miewu",
  pattern = ".",
  prompt = "#ofl__miewu",
  interaction = function()
    local names = {}
    local mark = Self:getMark("@$ofl__miewu-turn")
    for _, id in ipairs(Fk:getAllCardIds()) do
      local card = Fk:getCardById(id)
      if (card.type == Card.TypeBasic or card:isCommonTrick()) and not card.is_derived then
        local to_use = Fk:cloneCard(card.name)
        if ((Fk.currentResponsePattern == nil and Self:canUse(to_use) and not Self:prohibitUse(to_use)) or
        (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(to_use))) then
          if mark == 0 or (not table.contains(mark, card.trueName)) then
            table.insertIfNeed(names, card.name)
          end
        end
      end
    end
    if #names == 0 then return false end
    return UI.ComboBox { choices = names }
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
    local mark = player:getMark("@$ofl__miewu-turn")
    if mark == 0 then mark = {} end
    table.insert(mark, use.card.trueName)
    room:setPlayerMark(player, "@$ofl__miewu-turn", mark)
  end,
  enabled_at_play = function(self, player)
    return player:getMark("@wuku") > 0 and not player:isNude()
  end,
  enabled_at_response = function(self, player, response)
    return player:getMark("@wuku") > 0 and not player:isNude()
  end,
}
duyu:addSkill(ofl__wuku)
duyu:addSkill(ofl__sanchen)
duyu:addRelatedSkill(ofl__miewu)
Fk:loadTranslationTable{
  ["ofl__duyu"] = "杜预",
  ["ofl__wuku"] = "武库",
  [":ofl__wuku"] = "锁定技，当你使用装备牌时或其他角色失去装备区内的一张牌时，你获得1枚“武库”标记（至多3枚）。",
  ["ofl__sanchen"] = "三陈",
  [":ofl__sanchen"] = "觉醒技，准备阶段或结束阶段，若你的“武库”标记为3，你加1点体力上限，回复1点体力，获得〖灭吴〗。",
  ["ofl__miewu"] = "灭吴",
  [":ofl__miewu"] = "每回合每种牌名限一次，你可以移去1枚“武库”标记，将一张牌当任意一张基本牌或普通锦囊牌使用或打出。",
  ["#ofl__miewu"] = "灭吴：你可以将一张牌当任意基本牌或普通锦囊牌使用或打出",
  ["@$ofl__miewu-turn"] = "灭吴",
}

Fk:loadTranslationTable{
  ["ofl__luotong"] = "骆统",
  ["ofl__minshi"] = "悯施",
  [":ofl__minshi"] = "出牌阶段限一次，你可以选择所有手牌数少于体力值的角色并观看额外牌堆中至多三张基本牌，然后你可以依次将其中任意张牌"..
  "交给任意角色。然后你选择的角色中每有一名未获得牌的角色，你失去1点体力。",
  ["ofl__xianming"] = "显名",
  [":ofl__xianming"] = "每回合限一次，当额外牌堆中失去最后一张基本牌时，你可以摸两张牌并回复1点体力。",
}

local godguojia = General(extension, "ofl__godguojia", "god", 3)
local ofl__huishi = fk.CreateActiveSkill{
  name = "ofl__huishi",
  anim_type = "drawcard",
  card_num = 0,
  target_num = 0,
  prompt = "#ofl__huishi",
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
        not room:askForSkillInvoke(player, self.name, nil, "#ofl__huishi-invoke")
      then
        break
      end
    end
    local targets = table.map(room.alive_players, function(p) return p.id end)
    cards = table.filter(cards, function(card) return room:getCardArea(card.id) == Card.Processing end)
    if #cards == 0 then return end
    local to = room:askForChoosePlayers(player, targets, 1, 1, "#ofl__huishi-give", self.name, true)
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
local ofl__tianyi = fk.CreateTriggerSkill{
  name = "ofl__tianyi",
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
      return #U.getActualDamageEvents(player.room, 1, function(e) return e.data[1].to == p end, Player.HistoryGame) > 0
    end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if player.maxHp < 10 then
      room:changeMaxHp(player, 10 - player.maxHp)
    end
    local tos = room:askForChoosePlayers(player, table.map(room.alive_players, Util.IdMapper), 1, 1, "#ofl__tianyi-choose", self.name, false)
    room:handleAddLoseSkills(room:getPlayerById(tos[1]), "zuoxing", nil, true, false)
  end,
}
local ofl__huishig = fk.CreateTriggerSkill{
  name = "ofl__huishig",
  anim_type = "support",
  frequency = Skill.Limited,
  events = {fk.EnterDying},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local to = player.room:askForChoosePlayers(player, table.map(player.room.alive_players, function(p)
      return p.id end), 1, 1, "#ofl__huishig-choose", self.name, true)
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
      local choice = room:askForChoice(player, skills, self.name, "#ofl__huishig-choice::"..to.id, true)
      local toWakeSkills = type(to:getMark(MarkEnum.StraightToWake)) == "table" and to:getMark(MarkEnum.StraightToWake) or {}
      table.insertIfNeed(toWakeSkills, choice)
      room:setPlayerMark(to, MarkEnum.StraightToWake, toWakeSkills)
    else
      to:drawCards(4, self.name)
    end
  end,
}
godguojia:addSkill(ofl__huishi)
godguojia:addSkill(ofl__tianyi)
godguojia:addSkill(ofl__huishig)
godguojia:addRelatedSkill("zuoxing")
Fk:loadTranslationTable{
  ["ofl__godguojia"] = "神郭嘉",
  ["ofl__huishi"] = "慧识",
  [":ofl__huishi"] = "出牌阶段限一次，你可以进行判定，若结果的花色与本阶段以此法进行判定的结果均不同，你可以重复此流程。然后你可以将所有生效"..
  "的判定牌交给一名角色。",
  ["ofl__tianyi"] = "天翊",
  [":ofl__tianyi"] = "觉醒技，准备阶段，若所有存活角色均受到过伤害，你增加体力上限至10点，然后令一名角色获得〖佐幸〗。",
  ["ofl__huishig"] = "辉逝",
  [":ofl__huishig"] = "限定技，当你进入濒死状态时，你可以选择一名角色，若其有未发动的觉醒技，你可以选择其中一个令其视为已满足觉醒条件，否则其"..
  "摸四张牌。",
  ["#ofl__huishi"] = "慧识：你可以重复判定，将不同花色的判定牌交给一名角色",
  ["#ofl__huishi-invoke"] = "慧识：是否继续判定？",
  ["#ofl__huishi-give"] = "慧识：你可以令一名角色获得这些判定牌",
  ["#ofl__tianyi-choose"] = "天翊：令一名角色获得技能〖佐幸〗",
  ["#ofl__huishig-choose"] = "辉逝：你可以令一名角色视为已满足觉醒条件（若没有则摸四张牌）",
  ["#ofl__huishig-choice"] = "辉逝：选择令 %dest 视为满足条件的觉醒技",
}

local godxunyu = General(extension, "ofl__godxunyu", "god", 3)
local ofl__lingce = fk.CreateTriggerSkill{
  name = "ofl__lingce",
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
local ofl__dinghan = fk.CreateTriggerSkill{
  name = "ofl__dinghan",
  anim_type = "special",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Start
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#ofl__dinghan-invoke")
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local zhinang = room:getTag("Zhinang")
    if zhinang then
      zhinang = table.simpleClone(zhinang)
    else
      zhinang = {"ex_nihilo", "dismantlement", "nullification"}
    end
    local choice = room:askForChoice(player, room:getTag("Zhinang"), self.name, "#ofl__dinghan-remove")
    table.removeOne(zhinang, choice)
    local choices = table.simpleClone(room:getTag("TrickNames"))
    for _, name in ipairs(zhinang) do
      table.removeOne(choices, name)
    end
    choice = room:askForChoice(player, choices, self.name, "#ofl__dinghan-add", false, room:getTag("TrickNames"))
    table.insert(zhinang, choice)
    room:setTag("Zhinang", zhinang)
    room:setPlayerMark(player, "@$ofl__dinghan", room:getTag("Zhinang"))
  end,

  refresh_events = {fk.GameStart},
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(self.name, true)
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
    local Zhinang = room:getTag("Zhinang")  --请不要模仿这两个tag，之后会将记录本局游戏所用牌名和智囊写到源码游戏流程中
    if not Zhinang then
      room:setTag("Zhinang", {"ex_nihilo", "dismantlement", "nullification"})
      room:setPlayerMark(player, "@$ofl__dinghan", room:getTag("Zhinang"))
    end
  end,
}
godxunyu:addSkill(ofl__lingce)
godxunyu:addSkill(ofl__dinghan)
godxunyu:addSkill("tianzuo")
Fk:loadTranslationTable{
  ["ofl__godxunyu"] = "神荀彧",
  ["ofl__lingce"] = "灵策",
  [":ofl__lingce"] = "锁定技，其他角色使用的智囊牌对你无效；一名角色使用智囊牌时，你摸一张牌。",
  ["ofl__dinghan"] = "定汉",
  [":ofl__dinghan"] = "准备阶段，你可以移除一张智囊牌的记录，然后重新记录一张智囊牌（智囊牌初始为【无中生有】、【过河拆桥】、【无懈可击】）。",
  ["@$ofl__dinghan"] = "智囊",
  ["#ofl__dinghan-invoke"] = "定汉：你可以修改一张本局游戏的智囊牌牌名",
  ["#ofl__dinghan-remove"] = "定汉：选择要移除的智囊牌",
  ["#ofl__dinghan-add"] = "定汉：选择要增加的智囊牌",
}

local zhugeshang = General(extension, "ofl__zhugeshang", "shu", 3)
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
  mute = true,
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
    local mark = player:getMark("@$ofl__sangu-phase")
    if mark ~= 0 then
      table.removeOne(mark, use.card.name)
      if #mark == 0 then mark = 0 end
    end
    player.room:setPlayerMark(player, "@$ofl__sangu-phase", mark)
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
  ["ofl__zhugeshang"] = "诸葛尚",
  ["ofl__sangu"] = "三顾",
  [":ofl__sangu"] = "一名角色出牌阶段开始时，若其手牌数不小于其体力上限，你可以观看牌堆顶三张牌并亮出其中任意张牌名不同的基本牌或普通锦囊牌。若如此做，"..
  "此阶段每种牌名限一次，该角色可以将一张手牌当你亮出的一张牌使用。",
  ["#ofl__sangu-invoke"] = "三顾：你可以观看牌堆顶三张牌，令 %dest 本阶段可以将手牌当其中的牌使用",
  ["ofl__sangu_show"] = "三顾",
  ["#ofl__sangu-show"] = "三顾：你可以亮出其中的基本牌或普通锦囊牌，%dest 本阶段可以将手牌当亮出的牌使用",
  ["@$ofl__sangu-phase"] = "三顾",
  ["ofl__sangu&"] = "三顾",
  [":ofl__sangu&"] = "出牌阶段每种牌名限一次，你可以将一张手牌当一张“三顾”牌使用。",
  ["#ofl__sangu"] = "三顾：你可以将一张手牌当一张“三顾”牌使用",

  ["$ofl__sangu1"] = "蒙先帝三顾祖父之恩，吾父子自当为国用命！",
  ["$ofl__sangu2"] = "祖孙三代世受君恩，当效吾祖鞠躬尽瘁。",
  ["$yizu_ofl__zhugeshang1"] = "自幼家学渊源，岂会看不穿此等伎俩？",
  ["$yizu_ofl__zhugeshang2"] = "祖父在上，孩儿定不负诸葛之名！",
  ["~ofl__zhugeshang"] = "今父既死于敌，我又何能独活？",
}

--[[local goddianwei = General(extension, "ofl__goddianwei", "god", 4)
local juanjia = fk.CreateTriggerSkill{
  name = "juanjia",
  anim_type = "special",
  frequency = Skill.Compulsory,
  events = {fk.GamePrepared},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if #player:getAvailableEquipSlots(Card.SubtypeArmor) > 0 then
      room:abortPlayerArea(player, {Player.ArmorSlot})
    end
    table.insert(player.equipSlots, 2, Player.WeaponSlot)
  end,
}
goddianwei:addSkill(juanjia)]]--
Fk:loadTranslationTable{
  ["ofl__goddianwei"] = "神典韦",
  ["juanjia"] = "捐甲",
  [":juanjia"] = "锁定技，游戏开始时，废除你的防具栏，然后你获得一个额外的武器栏。",
  ["cuijue"] = "摧决",
  [":cuijue"] = "出牌阶段对每名角色限一次，你可以弃置一张牌，对攻击范围内距离最远的一名其他角色造成1点伤害。",
}

return extension
