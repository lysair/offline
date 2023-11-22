local extension = Package("fhyx")
extension.extensionName = "offline"

Fk:loadTranslationTable{
  ["fhyx"] = "线下-飞鸿映雪",
}

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
      local dummy = Fk:cloneCard("dilu")
      dummy:addSubcards(self.cost_data)
      room:obtainCard(target, dummy, false, fk.ReasonGive)
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

  refresh_events = {fk.AfterCardUseDeclared},
  can_refresh = function(self, event, target, player, data)
    return target == player and data.card.type == Card.TypeBasic and player:getMark("ofl__yuejian-round") == 0
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
    return #selected < 2
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
  ["ofl__shameng"] = "歃盟",
  [":ofl__shameng"] = "出牌阶段限一次，你可以展示一至两张手牌，然后令一名其他角色展示一至两张手牌，若如此做，你可以弃置这些牌，你摸等同于其中"..
  "花色数的牌，令该角色摸等同于其中类别数的牌。",
  ["#ofl__shameng"] = "歃盟：你可以展示至多两张手牌，令一名角色展示至多两张手牌，你可以弃置这些牌令双方摸牌",
  ["#ofl__shameng-show"] = "歃盟：请展示一至两张手牌，%src 可以弃置这些牌令双方摸牌",
  ["#ofl__shameng-discard"] = "歃盟：是否弃置这些牌令双方摸牌？你摸%arg张，%dest摸%arg2张",
}

Fk:loadTranslationTable{
  ["ofl__sunshao"] = "孙邵",
  ["ofl__dingyi"] = "定仪",
  [":ofl__dingyi"] = "每轮开始时，你可以摸一张牌，然后将一张与“定仪”牌花色均不同的牌置于一名没有“定仪”牌的角色武将牌旁。有“定仪”牌的角色根据花色"..
  "获得对应效果：<br>♠，手牌上限+4；<br><font color='red'>♥</font>，每回合首次脱离濒死状态时，回复2点体力；♣，使用牌无距离限制；"..
  "<font color='red'>♦</font>，摸牌阶段多摸两张牌。",
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
    return player:getMark("@wuku") > 0
  end,
  enabled_at_response = function(self, player, response)
    return player:getMark("@wuku") > 0
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
  card_filter = function(self, to_select, selected)
    return false
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    return false
  end,
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
      to = to[1]
      local dummy = Fk:cloneCard("dilu")
      dummy:addSubcards(table.map(cards, function(card) return card:getEffectiveId() end))
      room:obtainCard(to, dummy, true, fk.ReasonGive)
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
    return table.every(player.room.alive_players, function(p) return p:getMark(self.name) > 0 end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if player.maxHp < 10 then
      room:changeMaxHp(player, 10 - player.maxHp)
    end
    local to = room:askForChoosePlayers(player, table.map(room.alive_players, function(p)
      return p.id end), 1, 1, "#ofl__tianyi-choose", self.name, false)
    if #to > 0 then
      to = to[1]
    else
      to = player.id
    end
    room:handleAddLoseSkills(room:getPlayerById(to), "zuoxing", nil, true, false)
  end,

  refresh_events = {fk.Damaged},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark(self.name) == 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, self.name, 1)
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


local ofl__godmachao = General(extension, "ofl__godmachao", "god", 4)
local getHorse = function (room, player, mark, n)
  local old = player:getMark(mark)
  room:setPlayerMark(player, mark, old + n)
  if old == 0 then
    local slot = (mark == "@ofl__jun") and Player.OffensiveRideSlot or Player.DefensiveRideSlot
    room:abortPlayerArea(player, slot)
  else
    room.logic:trigger("fk.OflShouliMarkChanged", player, {n = old + n})
  end
end
local loseAllHorse = function (room, player, mark)
  room:setPlayerMark(player, mark, 0)
  local slot = (mark == "@ofl__jun") and Player.OffensiveRideSlot or Player.DefensiveRideSlot
  room:resumePlayerArea(player, slot)
end
local ofl__shouli = fk.CreateViewAsSkill{
  name = "ofl__shouli",
  pattern = "slash,jink",
  prompt = "#ofl__shouli-promot",
  interaction = function()
    local names = {}
    local pat = Fk.currentResponsePattern
    if ((pat == nil and not Self:prohibitUse(Fk:cloneCard("slash"))) or (pat and Exppattern:Parse(pat):matchExp("slash")))
    and Self:getMark("ofl__shouli_slash-turn") == 0
    and table.find(Fk:currentRoom().alive_players, function(p) return p ~= Self and p:getMark("@ofl__jun") > 0 end) then
      table.insert(names, "slash")
    end
    if pat and Exppattern:Parse(pat):matchExp("jink")
    and Self:getMark("ofl__shouli_jink-turn") == 0
    and table.find(Fk:currentRoom().alive_players, function(p) return p ~= Self and p:getMark("@ofl__li") > 0 end) then
      table.insert(names, "jink")
    end
    if #names == 0 then return end
    return UI.ComboBox {choices = names}
  end,
  view_as = function(self)
    if self.interaction.data == nil then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = self.name
    return card
  end,
  before_use = function(self, player, use)
    local room = player.room
    use.extraUse = true
    local mark = (use.card.trueName == "slash") and "@ofl__jun" or "@ofl__li"
    room:addPlayerMark(player, "ofl__shouli_"..use.card.trueName.."-turn")
    local targets = table.filter(room:getOtherPlayers(player), function (p)
      return p:getMark(mark) > 0
    end)
    if #targets > 0 then
      local tos = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 1, "#ofl__shouli-horse:::" .. mark, self.name, false, true)
      if #tos > 0 then
        local to = room:getPlayerById(tos[1])
        local next = to:getNextAlive()
        local last = to:getLastAlive()
        local choice = room:askForChoice(player, {"ofl__shouli_next:"..next.id, "ofl__shouli_last:"..last.id}, self.name,
        "#ofl__shouli-move::"..to.id..":"..mark)
        local receiver = choice:startsWith("ofl__shouli_next") and next or last
        local n = to:getMark(mark)
        loseAllHorse (room, to, mark)
        getHorse (room, receiver, mark, n)
      end
    end
  end,
  enabled_at_play = function(self, player)
    return player:getMark("ofl__shouli_slash-turn") == 0 and table.find(Fk:currentRoom().alive_players, function(p)
      return p ~= player and p:getMark("@ofl__jun") > 0
    end)
  end,
  enabled_at_response = function(self, player)
    local pat = Fk.currentResponsePattern
    if not pat then return end
    if Exppattern:Parse(pat):matchExp("slash") and player:getMark("ofl__shouli_slash-turn") == 0 then
      return table.find(Fk:currentRoom().alive_players, function(p)
        return p ~= player and p:getMark("@ofl__jun") > 0
      end)
    end
    if Exppattern:Parse(pat):matchExp("jink") and player:getMark("ofl__shouli_jink-turn") == 0 then
      return table.find(Fk:currentRoom().alive_players, function(p)
        return p ~= player and p:getMark("@ofl__li") > 0
      end)
    end
  end,
}
local ofl__shouli_trigger = fk.CreateTriggerSkill{
  name = "#ofl__shouli_trigger",
  events = {fk.GameStart, fk.DrawNCards, fk.TargetSpecified, fk.Damaged,fk.DamageInflicted, fk.DamageCaused},
  mute = true,
  main_skill = ofl__shouli,
  can_trigger = function(self, event, target, player, data)
    if event == fk.GameStart then
      return player:hasSkill(self)
    elseif event == fk.DrawNCards then
      return player:hasSkill(self) and target == player and (player:getMark("@ofl__jun") > 1 or player:getMark("@ofl__li") > 1)
    elseif event == fk.TargetSpecified then
      return target == player and player:hasSkill(self) and data.card.trueName == "slash" and player:getMark("@ofl__jun") > 2
    elseif event == fk.Damaged then
      return player:hasSkill(self) and target == player and (data.damageType ~= fk.NormalDamage
      or (data.card and (data.card.name == "savage_assault" or data.card.name == "archery_attack")))
      and (player:getMark("@ofl__jun") > 0 or player:getMark("@ofl__li") > 0) and player:getNextAlive() ~= player
    else
      return player:hasSkill(self) and target == player and player:getMark("@ofl__li") > 2
    end
  end,
  on_cost = function() return true end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(ofl__shouli.name)
    room:notifySkillInvoked(player, ofl__shouli.name)
    if event == fk.GameStart then
      local horse = {"@ofl__jun", "@ofl__jun", "@ofl__jun", "@ofl__li", "@ofl__li", "@ofl__li", "@ofl__li"}
      for _, p in ipairs(room:getOtherPlayers(player)) do
        if not player.dead and not p.dead and #horse > 0 then
          local mark = table.remove(horse, math.random(1, #horse))
          getHorse (room, p, mark, 1)
        end
      end
    elseif event == fk.DrawNCards then
      local n = 0
      if player:getMark("@ofl__jun") > 1 then n = n + 1 end
      if player:getMark("@ofl__li") > 1 then n = n + 1 end
      data.n = data.n + n
    elseif event == fk.TargetSpecified then
      local to = room:getPlayerById(data.to)
      room:addPlayerMark(to, MarkEnum.UncompulsoryInvalidity .. "-turn")
      room:addPlayerMark(to, "@@ofl__shouli_tieji-turn")
    elseif event == fk.Damaged then
      local jun = player:getMark("@ofl__jun")
      if jun > 0 then
        loseAllHorse (room, player, "@ofl__jun")
        getHorse (room, player:getLastAlive(), "@ofl__jun", jun)
      end
      local li = player:getMark("@ofl__li")
      if li > 0 then
        loseAllHorse (room, player, "@ofl__li")
        getHorse (room, player:getNextAlive(), "@ofl__li", li)
      end
    else
      local n = player:getMark("@ofl__li")
      if n > 2 then
        data.damageType = fk.ThunderDamage
      end
      if n > 3 then
        data.damage = data.damage + 1
      end
    end
  end,
}
local ofl__shouli_distance = fk.CreateDistanceSkill{
  name = "#ofl__shouli_distance",
  correct_func = function(self, from, to)
    if from:hasSkill(self) and from:getMark("@ofl__jun") > 0 then
      return -1
    end
    if to:hasSkill(self) and to:getMark("@ofl__li") > 0 then
      return 1
    end
  end,
}
local ofl__shouli_targetmod = fk.CreateTargetModSkill{
  name = "#ofl__shouli_targetmod",
  bypass_times = function(self, player, skill, scope, card)
    return table.contains(card.skillNames, "ofl__shouli")
  end,
  bypass_distances = function(self, player, skill, card)
    return table.contains(card.skillNames, "ofl__shouli")
  end,
}
ofl__shouli:addRelatedSkill(ofl__shouli_trigger)
ofl__shouli:addRelatedSkill(ofl__shouli_distance)
ofl__shouli:addRelatedSkill(ofl__shouli_targetmod)
ofl__godmachao:addSkill(ofl__shouli)
-- 耦了!
local ofl__hengwu = fk.CreateTriggerSkill{
  name = "ofl__hengwu",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {"fk.OflShouliMarkChanged"},
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(self)
  end,
  on_use = function (self, event, target, player, data)
    player:drawCards(data.n, self.name)
  end,
}
ofl__godmachao:addSkill(ofl__hengwu)
Fk:loadTranslationTable{
  ["ofl__godmachao"] = "神马超",
  ["ofl__shouli"] = "狩骊",
  ["#ofl__shouli_trigger"] = "狩骊",
  ["#ofl__shouli_delay"] = "狩骊",
  [":ofl__shouli"] = "①游戏开始时，所有其他角色随机获得1枚“狩骊”标记。"..
  "<br>②每回合各限一次，你可以选择一项：1.移动一名其他角色的所有“骏”至其上家或下家，并视为使用或打出一张无距离和次数限制的【杀】；2.移动一名其他角色的所有“骊”至其上家或下家，并视为使用或打出一张【闪】。"..
  "<br>③“狩骊”标记包括4枚“骊”和3枚“骏”，获得“骏”/“骊”时废除装备区的进攻/防御坐骑栏，失去所有“骏”/“骊”时恢复之。"..
  "<br>④若你的“骏”数量大于0，你与其他角色的距离-1；大于1，摸牌阶段，你多摸一张牌；大于2，当你使用【杀】指定目标后，该角色本回合非锁定技失效。"..
  "<br>⑤若你的“骊”数量大于0，其他角色与你的距离+1；大于1，摸牌阶段，你多摸一张牌；大于2，你造成或受到的伤害均视为雷电伤害；大于3，你造成或受到的伤害+1。"..
  "<br>⑥当你受到属性伤害或【南蛮入侵】、【万箭齐发】造成的伤害后，你的所有“骏”移动至你上家，所有“骊”移动至你下家。",
  ["ofl__hengwu"] = "横骛",
  [":ofl__hengwu"] = "锁定技，有“骏”/“骊”的角色获得“骏”/“骊”后，你摸X张牌（X为其拥有该标记的数量）。",

  ["@ofl__jun"] = "骏",
  ["@ofl__li"] = "骊",
  ["@@ofl__shouli_tieji-turn"] = "狩骊封技",
  ["ofl__shouli_last"] = "上家:%src",
  ["ofl__shouli_next"] = "下家:%src",
  ["#ofl__shouli-promot"] = "狩骊：移动一名其他角色的所有“骏”/“骊”，视为使用或打出【杀】/【闪】",
  ["#ofl__shouli-horse"] = "狩骊：选择一名有 %arg 标记的其他角色",
  ["#ofl__shouli-move"] = "狩骊：将 %dest 所有 %arg 标记移动至其上家或下家",

  ["$ofl__shouli1"] = "饲骊胡肉，饮骥虏血，一骑可定万里江山！",
  ["$ofl__shouli2"] = "折兵为弭，纫甲为服，此箭可狩在野之龙！",
  ["$ofl__hengwu1"] = "此身独傲，天下无不可敌之人，无不可去之地！",
  ["$ofl__hengwu2"] = "神威天降，世间无不可驭之雷，无不可降之马！",
  ["~ofl__godmachao"] = "以战入圣，贪战而亡。",
}
















return extension
