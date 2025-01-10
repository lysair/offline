local extension = Package("sxfy_taiyin")
extension.extensionName = "offline"

local U = require "packages/utility/utility"

Fk:loadTranslationTable{
  ["sxfy_taiyin"] = "四象封印-太阴",
}

local xushu = General(extension, "sxfy__xushu", "shu", 3)
local sxfy__wuyan = fk.CreateFilterSkill{
  name = "sxfy__wuyan",
  frequency = Skill.Compulsory,
  card_filter = function(self, to_select, player)
    return player:hasSkill(self) and to_select.type == Card.TypeTrick and table.contains(player:getCardIds("h"), to_select.id)
  end,
  view_as = function(self, to_select)
    local card = Fk:cloneCard("nullification", to_select.suit, to_select.number)
    card.skillName = self.name
    return card
  end,
}
local sxfy__jujian = fk.CreateTriggerSkill{
  name = "sxfy__jujian",
  anim_type = "support",
  events = {fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card.trueName == "nullification" and
      player:usedSkillTimes(self.name, Player.HistoryTurn) == 0 and
      player.room:getCardArea(data.card) == Card.Processing
  end,
  on_cost = function(self, event, target, player, data)
    local to = player.room:askForChoosePlayers(player, table.map(player.room:getOtherPlayers(player), Util.IdMapper), 1, 1,
      "#sxfy__jujian-give:::"..data.card:toLogString(), self.name, true)
    if #to > 0 then
      self.cost_data = {tos = to}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data.tos[1])
    room:moveCardTo(data.card, Card.PlayerHand, to, fk.ReasonGive, self.name, nil, true, player.id)
  end,
}
xushu:addSkill(sxfy__wuyan)
xushu:addSkill(sxfy__jujian)
Fk:loadTranslationTable{
  ["sxfy__xushu"] = "徐庶",
  ["#sxfy__xushu"] = "身曹心汉",
  ["illustrator:sxfy__xushu"] = "Zero",

  ["sxfy__wuyan"] = "无言",
  [":sxfy__wuyan"] = "锁定技，你的锦囊牌视为【无懈可击】。",
  ["sxfy__jujian"] = "举荐",
  [":sxfy__jujian"] = "每回合限一次，当你使用的【无懈可击】结算结束后，你可以将此牌交给一名其他角色。",
  ["#sxfy__jujian-give"] = "举荐：你可以将此%arg交给一名角色",
}

local wangyuanji = General(extension, "sxfy__wangyuanji", "wei", 3, 3, General.Female)
local sxfy__qianchong = fk.CreateTargetModSkill{
  name = "sxfy__qianchong",
  frequency = Skill.Compulsory,
  bypass_times = function (self, player, skill, scope, card, to)
    return card and player:hasSkill(self) and #player:getCardIds("e") % 2 == 1
  end,
  bypass_distances = function (self, player, skill, card, to)
    return card and player:hasSkill(self) and #player:getCardIds("e") % 2 == 0
  end,
}
local sxfy__shangjian = fk.CreateTriggerSkill{
  name = "sxfy__shangjian",
  events = {fk.EventPhaseStart},
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and player.phase == Player.Finish then
      local yes, num = false, 0
      player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
        for _, move in ipairs(e.data) do
          if move.from == player.id then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
                num = num + 1
                if not yes and table.contains(player.room.discard_pile, info.cardId) then
                  yes = true
                end
              end
            end
          end
        end
      end, Player.HistoryTurn)
      return num <= player.hp and yes
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = {}
    room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
      for _, move in ipairs(e.data) do
        if move.from == player.id then
          for _, info in ipairs(move.moveInfo) do
            if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
              table.contains(room.discard_pile, info.cardId) then
              table.insertIfNeed(cards, info.cardId)
            end
          end
        end
      end
    end, Player.HistoryTurn)
    cards = U.askforChooseCardsAndChoice(player, cards, {"OK"}, self.name, "#sxfy__shangjian-prey")
    room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonJustMove, self.name, nil, true, player.id)
  end,
}
wangyuanji:addSkill(sxfy__qianchong)
wangyuanji:addSkill(sxfy__shangjian)
Fk:loadTranslationTable{
  ["sxfy__wangyuanji"] = "王元姬",
  ["#sxfy__wangyuanji"] = "清雅抑华",
  ["illustrator:sxfy__wangyuanji"] = "",

  ["sxfy__qianchong"] = "谦冲",
  [":sxfy__qianchong"] = "锁定技，若你的装备区的牌数为偶数/奇数，你使用牌无距离/次数限制。",
  ["sxfy__shangjian"] = "尚俭",
  [":sxfy__shangjian"] = "结束阶段，若你本回合失去的牌数不大于你的体力值，你可以从弃牌堆获得一张本回合你失去的牌。",
  ["#sxfy__shangjian-prey"] = "尚俭：获得其中一张牌",
}

local maliang = General(extension, "sxfy__maliang", "shu", 3)
local sxfy__xiemu = fk.CreateTriggerSkill{
  name = "sxfy__xiemu",
  attached_skill_name = "sxfy__xiemu&",
}
local sxfy__xiemu_active = fk.CreateActiveSkill{
  name = "sxfy__xiemu&",
  anim_type = "support",
  card_num = 1,
  target_num = 1,
  prompt = "#sxfy__xiemu&",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function (self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).type == Card.TypeBasic
  end,
  target_filter = function (self, to_select, selected)
    return #selected == 0 and Fk:currentRoom():getPlayerById(to_select):hasSkill("sxfy__xiemu")
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    player:showCards(effect.cards)
    if target.dead or not table.contains(player:getCardIds("h"), effect.cards[1]) then return end
    room:moveCardTo(effect.cards, Card.PlayerHand, target, fk.ReasonGive, "sxfy__xiemu", nil, true, player.id)
  end,
}
local sxfy__xiemu_attackrange = fk.CreateAttackRangeSkill{
  name = "#sxfy__xiemu_attackrange",
  correct_func = function (self, from, to)
    if from:usedSkillTimes("sxfy__xiemu&", Player.HistoryTurn) > 0 then
      return from:usedSkillTimes("sxfy__xiemu&", Player.HistoryTurn)
    end
    return 0
  end,
}
local sxfy__naman = fk.CreateActiveSkill{
  name = "sxfy__naman",
  anim_type = "offensive",
  min_card_num = 1,
  min_target_num = 1,
  prompt = "#sxfy__naman",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, to_select, selected, selected_targets)
    return Fk:getCardById(to_select).type == Card.TypeBasic
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    local card = Fk:cloneCard("savage_assault")
    card:addSubcards(selected_cards)
    return to_select ~= Self.id and #selected < #selected_cards and
      not Self:isProhibited(Fk:currentRoom():getPlayerById(to_select), card)
  end,
  feasible = function (self, selected, selected_cards)
    return #selected > 0 and #selected == #selected_cards
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:sortPlayersByAction(effect.tos)
    room:useVirtualCard("savage_assault", effect.cards, player,
      table.map(effect.tos, Util.Id2PlayerMapper), self.name)
  end
}
Fk:addSkill(sxfy__xiemu_active)
sxfy__xiemu:addRelatedSkill(sxfy__xiemu_attackrange)
maliang:addSkill(sxfy__xiemu)
maliang:addSkill(sxfy__naman)
Fk:loadTranslationTable{
  ["sxfy__maliang"] = "马良",
  ["#sxfy__maliang"] = "白眉智士",
  ["illustrator:sxfy__maliang"] = "biou09",

  ["sxfy__xiemu"] = "协穆",
  [":sxfy__xiemu"] = "其他角色出牌阶段限一次，其可以展示并交给你一张基本牌，然后本回合其攻击范围+1。",
  ["sxfy__naman"] = "纳蛮",
  [":sxfy__naman"] = "出牌阶段限一次，你可以将任意张基本牌当指定等量名目标的【南蛮入侵】使用。",

  ["sxfy__xiemu&"] = "协穆",
  [":sxfy__xiemu&"] = "出牌阶段限一次，你可以展示并交给马良一张基本牌，然后本回合你攻击范围+1。",
  ["#sxfy__xiemu&"] = "协穆：交给马良一张基本牌，本回合你攻击范围+1",
  ["#sxfy__naman"] = "纳蛮：将任意张基本牌当指定等量目标的【南蛮入侵】使用",
}

local jiangwan = General(extension, "sxfy__jiangwan", "shu", 3)
local sxfy__beiwu = fk.CreateViewAsSkill{
  name = "sxfy__beiwu",
  anim_type = "special",
  prompt = "#sxfy__beiwu",
  interaction = function()
    return UI.ComboBox {choices = {"ex_nihilo", "duel"}}
  end,
  card_filter = function (self, to_select, selected)
    return #selected == 0 and Fk:currentRoom():getCardArea(to_select) == Card.PlayerEquip and
      not table.contains(Self:getTableMark("sxfy__beiwu-turn"), to_select)
  end,
  view_as = function(self, cards)
    if #cards ~= 1 or self.interaction.data == nil then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = self.name
    card:addSubcards(cards)
    return card
  end,
  enabled_at_play = Util.TrueFunc,
  enabled_at_response = Util.FalseFunc,
}
local sxfy__beiwu_trigger = fk.CreateTriggerSkill{
  name = "#sxfy__beiwu_trigger",

  refresh_events = {fk.StartPlayCard},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(sxfy__beiwu, true)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local cards = {}
    room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
      for _, move in ipairs(e.data) do
        if move.to == player.id and move.toArea == Card.PlayerEquip then
          for _, info in ipairs(move.moveInfo) do
            table.insert(cards, info.cardId)
          end
        end
      end
    end, Player.HistoryTurn)
    room:setPlayerMark(player, "sxfy__beiwu-turn", cards)
  end,
}
local sxfy__chengshi = fk.CreateTriggerSkill{
  name = "sxfy__chengshi",
  anim_type = "special",
  frequency = Skill.Limited,
  events = {fk.Death},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#sxfy__chengshi-invoke::"..target.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:swapSeat(player, target)
    local cards1 = table.clone(player:getCardIds("e"))
    local cards2 = table.clone(target:getCardIds("e"))
    U.swapCards(room, player, player, target, cards1, cards2, self.name, Card.PlayerEquip)
  end,
}
sxfy__beiwu:addRelatedSkill(sxfy__beiwu_trigger)
jiangwan:addSkill(sxfy__beiwu)
jiangwan:addSkill(sxfy__chengshi)
Fk:loadTranslationTable{
  ["sxfy__jiangwan"] = "蒋琬",
  ["#sxfy__jiangwan"] = "方整威重",
  ["illustrator:sxfy__jiangwan"] = "depp",

  ["sxfy__beiwu"] = "备武",
  [":sxfy__beiwu"] = "你可以将装备区内一张不为本回合置入的牌当【无中生有】或【决斗】使用。",
  ["sxfy__chengshi"] = "承事",
  [":sxfy__chengshi"] = "限定技，当一名其他角色死亡时，你可以与其交换座次与装备区内的牌。",
  ["#sxfy__beiwu"] = "备武：你可以将一张不是本回合进入装备区的牌当【无中生有】或【决斗】使用",
  ["#sxfy__chengshi-invoke"] = "承事：是否与 %dest 交换座次并交换装备区内的牌？",
}

local sunshao = General(extension, "sxfy__sunshao", "wu", 3)
local sxfy__dingyi = fk.CreateTriggerSkill{
  name = "sxfy__dingyi",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target.phase == Player.Finish and not target.dead and
      #target:getCardIds("e") == 0
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askForSkillInvoke(target, self.name)
  end,
  on_use = function(self, event, target, player, data)
    target:drawCards(1, self.name)
  end,
}
local sxfy__zuici = fk.CreateTriggerSkill{
  name = "sxfy__zuici",
  anim_type = "masochism",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.from and not data.from.dead and
      table.find(player.room:getOtherPlayers(data.from), function (p)
        return p:canMoveCardsInBoardTo(data.from)
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(table.filter(room:getOtherPlayers(data.from), function (p)
      return p:canMoveCardsInBoardTo(data.from)
    end), Util.IdMapper)
    local to = room:askForChoosePlayers(player, targets, 1, 1, "#sxfy__zuici-choose::"..data.from.id, self.name, true, true)
    if #to > 0 then
      self.cost_data = {tos = to}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data.tos[1])
    room:askForMoveCardInBoard(player, to, data.from, self.name, nil, to)
  end
}
sunshao:addSkill(sxfy__dingyi)
sunshao:addSkill(sxfy__zuici)
Fk:loadTranslationTable{
  ["sxfy__sunshao"] = "孙邵",
  ["#sxfy__sunshao"] = "创基扶政",
  ["illustrator:sxfy__sunshao"] = "君桓文化",

  ["sxfy__dingyi"] = "定仪",
  [":sxfy__dingyi"] = "一名角色结束阶段，若其装备区内没有牌，其可以摸一张牌。",
  ["sxfy__zuici"] = "罪辞",
  [":sxfy__zuici"] = "当你受到伤害后，你可以将场上一张牌移至伤害来源对应的区域。",
  ["#sxfy__zuici-choose"] = "罪辞：你可以将场上一张牌移至 %dest 对应的区域",
}

local zhonghui = General(extension, "sxfy__zhonghui", "wei", 4)
local sxfy__xingfa = fk.CreateTriggerSkill{
  name = "sxfy__xingfa",
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Start and
      player:getHandcardNum() >= player.hp and #player.room.alive_players > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askForChoosePlayers(player, table.map(room:getOtherPlayers(player), Util.IdMapper), 1, 1,
      "#sxfy__xingfa-choose", self.name, true)
    if #to > 0 then
      self.cost_data = {tos = to}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:damage({
      from = player,
      to = room:getPlayerById(self.cost_data.tos[1]),
      damage = 1,
      skillName = self.name,
    })
  end,
}
zhonghui:addSkill(sxfy__xingfa)
Fk:loadTranslationTable{
  ["sxfy__zhonghui"] = "钟会",
  ["#sxfy__zhonghui"] = "桀骜的野心家",
  ["illustrator:sxfy__zhonghui"] = "biou09",

  ["sxfy__xingfa"] = "兴伐",
  [":sxfy__xingfa"] = "准备阶段，若你的手牌数不小于体力值，你可以对一名其他角色造成1点伤害。",
  ["#sxfy__xingfa-choose"] = "兴伐：你可以对一名其他角色造成1点伤害",
}

local guanxings = General(extension, "sxfy__guanxings", "shu", 4)
local sxfy__wuyou = fk.CreateActiveSkill{
  name = "sxfy__wuyou",
  anim_type = "offensive",
  card_num = 0,
  target_num = 1,
  prompt = "#sxfy__wuyou",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and Self:canPindian(Fk:currentRoom():getPlayerById(to_select))
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local pindian = player:pindian({target}, self.name)
    if pindian.results[target.id].winner ~= player then
      if not player.dead and not player:hasSkill("wusheng", true) then
        room:setPlayerMark(player, "sxfy__wuyou-turn", 1)
        room:handleAddLoseSkills(player, "wusheng", nil, true, false)
      end
    end
    local from, to = player, player
    if pindian.results[target.id].winner == player then
      to = target
    elseif pindian.results[target.id].winner == target then
      from = target
    end
    if from ~= to and not from.dead and not to.dead then
      room:useVirtualCard("duel", nil, from, to, self.name)
    end
  end,
}
local sxfy__wuyou_delay = fk.CreateTriggerSkill {
  name = "#sxfy__wuyou_delay",

  refresh_events = {fk.TurnEnd},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("sxfy__wuyou-turn") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:handleAddLoseSkills(player, "-wusheng", nil, true, false)
  end,
}
sxfy__wuyou:addRelatedSkill(sxfy__wuyou_delay)
guanxings:addSkill(sxfy__wuyou)
guanxings:addRelatedSkill("wusheng")
Fk:loadTranslationTable{
  ["sxfy__guanxings"] = "关兴",
  ["#sxfy__guanxings"] = "龙骧将军",
  ["illustrator:sxfy__guanxings"] = "峰雨同程",

  ["sxfy__wuyou"] = "武佑",
  [":sxfy__wuyou"] = "出牌阶段限一次，你可以与一名角色拼点，若你没赢，你本回合视为拥有〖武圣〗。然后拼点赢的角色视为对没赢的角色使用一张"..
  "【决斗】。",
  ["#sxfy__wuyou"] = "武佑：与一名角色拼点，若你没赢，你本回合获得〖武圣〗，然后赢的角色视为对没赢的角色使用一张【决斗】",
}

local xuezong = General(extension, "sxfy__xuezong", "wu", 3)
local sxfy__funan = fk.CreateTriggerSkill{
  name = "sxfy__funan",
  anim_type = "drawcard",
  events = {fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
      player:usedSkillTimes(self.name, Player.HistoryTurn) == 0 and
      data.responseToEvent and data.responseToEvent.from ~= player.id and
      player.room:getCardArea(data.responseToEvent.card) == Card.Processing
  end,
  on_use = function(self, event, target, player, data)
    player.room:moveCardTo(data.responseToEvent.card, Card.PlayerHand, player, fk.ReasonJustMove, self.name, nil, true, player.id)
  end,
}
local sxfy__jiexun = fk.CreateTriggerSkill{
  name = "sxfy__jiexun",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Finish and
      table.find(player.room.alive_players, function (p)
        return not p:isKongcheng()
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(table.filter(room.alive_players, function (p)
      return not p:isKongcheng()
    end), Util.IdMapper)
    local to = room:askForChoosePlayers(player, targets, 1, 1, "#sxfy__jiexun-choose", self.name, true)
    if #to > 0 then
      self.cost_data = {tos = to}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data.tos[1])
    local card = room:askForDiscard(to, 1, 1, false, self.name, false, nil, "#sxfy__jiexun-discard")
    if Fk:getCardById(card[1]).suit == Card.Diamond and not to.dead then
      to:drawCards(2, self.name)
    end
  end,
}
xuezong:addSkill(sxfy__funan)
xuezong:addSkill(sxfy__jiexun)
Fk:loadTranslationTable{
  ["sxfy__xuezong"] = "薛综",
  ["#sxfy__xuezong"] = "彬彬之玊",
  ["illustrator:sxfy__xuezong"] = "凝聚永恒",

  ["sxfy__funan"] = "复难",
  [":sxfy__funan"] = "每回合限一次，其他角色使用的牌被你抵消时，你可以获得之。",
  ["sxfy__jiexun"] = "诫训",
  [":sxfy__jiexun"] = "结束阶段，你可以令一名角色弃置一张手牌，然后若此牌为<font color='red'>♦</font>牌，其摸两张牌",
  ["#sxfy__jiexun-choose"] = "诫训：令一名角色弃一张手牌，若为<font color='red'>♦</font>牌，其摸两张牌",
  ["#sxfy__jiexun-discard"] = "诫训：请弃置一张手牌，若为<font color='red'>♦</font>牌，你摸两张牌",
}

local cenhun = General(extension, "sxfy__cenhun", "wu", 3)
local sxfy__jishe = fk.CreateActiveSkill{
  name = "sxfy__jishe",
  anim_type = "drawcard",
  card_num = 0,
  target_num = 0,
  prompt = "#sxfy__jishe",
  can_use = function(self, player)
    return player:getMaxCards() > 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:addPlayerMark(player, MarkEnum.MinusMaxCardsInTurn, 1)
    room:broadcastProperty(player, "MaxCards")
    player:drawCards(1, self.name)
  end,
}
local sxfy__wudu = fk.CreateTriggerSkill{
  name = "sxfy__wudu",
  anim_type = "defensive",
  events = {fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target:isKongcheng() and not target.dead
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#sxfy__wudu-invoke::"..data.to.id)
  end,
  on_use = function(self, event, target, player, data)
    player.room:changeMaxHp(player, -1)
    return true
  end,
}
cenhun:addSkill(sxfy__jishe)
cenhun:addSkill(sxfy__wudu)
Fk:loadTranslationTable{
  ["sxfy__cenhun"] = "岑昏",
  ["#sxfy__cenhun"] = "伐梁倾瓴",
  ["illustrator:sxfy__cenhun"] = "depp",

  ["sxfy__jishe"] = "极奢",
  [":sxfy__jishe"] = "出牌阶段，你可以令本回合手牌上限-1（至少为0），然后摸一张牌。",
  ["sxfy__wudu"] = "无度",
  [":sxfy__wudu"] = "当一名没有手牌的角色受到伤害时，你可以减1点体力上限，防止此伤害。",
  ["#sxfy__jishe"] = "极奢：本回合手牌上限-1，摸一张牌",
  ["#sxfy__wudu-invoke"] = "无度：是否减1点体力上限，防止 %dest 受到的伤害？",
}

local huaxin = General(extension, "sxfy__huaxin", "wei", 3)
local sxfy__yuanqing = fk.CreateTriggerSkill{
  name = "sxfy__yuanqing",
  events = {fk.TurnEnd},
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
      table.find(player.room.alive_players, function (p)
        return #player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
          for _, move in ipairs(e.data) do
            if move.from == p.id then
              for _, info in ipairs(move.moveInfo) do
                if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
                  table.contains(player.room.discard_pile, info.cardId) then
                    return true
                end
              end
            end
          end
          return false
        end, Player.HistoryTurn) > 0
      end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, table.map(room.alive_players, Util.IdMapper))
    for _, p in ipairs(room:getAlivePlayers()) do
      if not p.dead then
        local cards = {}
        room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
          for _, move in ipairs(e.data) do
            if move.from == p.id then
              for _, info in ipairs(move.moveInfo) do
                if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
                  table.contains(room.discard_pile, info.cardId) then
                  table.insertIfNeed(cards, info.cardId)
                end
              end
            end
          end
          return false
        end, Player.HistoryTurn)
        if #cards > 0 then
          local card = U.askforChooseCardsAndChoice(p, cards, {"OK"}, self.name, "#sxfy__yuanqing-prey")
          room:moveCardTo(card, Card.PlayerHand, p, fk.ReasonJustMove, self.name, nil, true, p.id)
        end
      end
    end
  end,
}
local sxfy__shuchen = fk.CreateViewAsSkill{
  name = "sxfy__shuchen",
  anim_type = "support",
  pattern = "peach",
  prompt = function ()
    return "#sxfy__shuchen:::"..(Self:getHandcardNum() - Self:getMaxCards())
  end,
  card_filter = function(self, to_select, selected)
    return Fk:currentRoom():getCardArea(to_select) == Card.PlayerHand and #selected < (Self:getHandcardNum() - Self:getMaxCards())
  end,
  view_as = function(self, cards)
    if #cards ~= (Self:getHandcardNum() - Self:getMaxCards()) then return end
    local c = Fk:cloneCard("peach")
    c.skillName = self.name
    c:addSubcards(cards)
    return c
  end,
  enabled_at_play = Util.FalseFunc,
  enabled_at_response = function(self, player, response)
    return not response and player.phase == Player.NotActive and player:getHandcardNum() > player:getMaxCards()
  end,
}
huaxin:addSkill(sxfy__yuanqing)
huaxin:addSkill(sxfy__shuchen)
Fk:loadTranslationTable{
  ["sxfy__huaxin"] = "华歆",
  ["#sxfy__huaxin"] = "清素拂浊",
  ["illustrator:sxfy__huaxin"] = "凡果",

  ["sxfy__yuanqing"] = "渊清",
  [":sxfy__yuanqing"] = "回合结束时，你可以令所有角色依次选择并获得弃牌堆中因其此回合失去而置入的一张牌。",
  ["sxfy__shuchen"] = "疏陈",
  [":sxfy__shuchen"] = "你的回合外，你可以将超出手牌上限部分的手牌当一张【桃】使用。",
  ["#sxfy__yuanqing-prey"] = "渊清：获得其中一张牌",
  ["#sxfy__shuchen"] = "疏陈：你可以%arg张手牌当一张【桃】使用",
}

local wanglang = General(extension, "sxfy__wanglang", "wei", 3)
local sxfy__gushe = fk.CreateActiveSkill{
  name = "sxfy__gushe",
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  prompt = "#sxfy__gushe",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and Self:canPindian(Fk:currentRoom():getPlayerById(to_select))
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    while true do
      local pindian = player:pindian({target}, self.name)
      local from, to = player, player
      if pindian.results[target.id].winner == player then
        to = target
      elseif pindian.results[target.id].winner == target then
        from = target
      end
      if from ~= to and not from.dead then
        from:drawCards(1, self.name)
      end
      if from ~= to and not from.dead and not to.dead and to:canPindian(from) and
        room:askForSkillInvoke(to, self.name, nil, "#sxfy__gushe-invoke::"..from.id) then
        player, target = to, from
        room:doIndicate(to.id, {from.id})
      else
        return
      end
    end
  end,
}
local sxfy__jici = fk.CreateTriggerSkill{
  name = "sxfy__jici",
  anim_type = "special",
  events = {fk.PindianCardsDisplayed},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and (player == data.from or data.results[player.id])
  end,
  on_cost = function (self, event, target, player, data)
    local prompt, to = "win"
    if player == data.from then
      for id, dat in pairs(data.results) do
        to = id
        if data.fromCard.number < data.results[id].toCard.number then
          prompt = "lose"
        elseif data.fromCard.number == data.results[id].toCard.number then
          prompt = "draw"
        end
      end
    elseif data.results[player.id] then
      to = data.from.id
      if data.results[player.id].toCard.number < data.fromCard.number then
        prompt = "lose"
      elseif data.results[player.id].toCard.number == data.fromCard.number then
        prompt = "draw"
      end
    end
    return player.room:askForSkillInvoke(player, self.name, nil, "#sxfy__jici_"..prompt.."-invoke::"..to)
  end,
  on_use = function(self, event, target, player, data)
    if player == data.from then
      data.fromCard.number = 13
    elseif data.results[player.id] then
      data.results[player.id].toCard.number = 13
    end
    player.room:loseHp(player, 1, self.name)
  end,
}
wanglang:addSkill(sxfy__gushe)
wanglang:addSkill(sxfy__jici)
Fk:loadTranslationTable{
  ["sxfy__wanglang"] = "王朗",
  ["#sxfy__wanglang"] = "凤鶥",
  ["illustrator:sxfy__wanglang"] = "小牛",

  ["sxfy__gushe"] = "鼓舌",
  [":sxfy__gushe"] = "出牌阶段限一次，你可以与一名角色拼点，拼点赢的角色摸一张牌，然后拼点输的角色可以与对方重复此流程。",
  ["sxfy__jici"] = "激词",
  [":sxfy__jici"] = "当你亮出拼点牌时，你可以失去1点体力，令你的拼点牌的点数视为K。",
  ["#sxfy__gushe"] = "鼓舌：与一名角色拼点，赢的角色摸一张牌，输的角色可以继续拼点",
  ["#sxfy__gushe-invoke"] = "鼓舌：是否继续与 %dest 拼点？",
  ["#sxfy__jici_win-invoke"] = "激词：你和 %dest 拼点赢了，是否要失去1点体力让点数视为K？",
  ["#sxfy__jici_draw-invoke"] = "激词：你和 %dest 拼点平了，是否要失去1点体力让点数视为K？",
  ["#sxfy__jici_lose-invoke"] = "激词：你和 %dest 拼点输了，是否要失去1点体力让点数视为K？",
}

local liuzhang = General(extension, "sxfy__liuzhang", "qun", 3)
local sxfy__yinge = fk.CreateActiveSkill{
  name = "sxfy__yinge",
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  prompt = "#sxfy__yinge",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id and not Fk:currentRoom():getPlayerById(to_select):isNude()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local card = room:askForCard(target, 1, 1, true, self.name, false, nil, "#sxfy__yinge-give:"..player.id)
    room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonGive, self.name, nil, false, target.id)
    if player.dead or target.dead then return end
    local targets = table.filter(room:getOtherPlayers(target), function (p)
      return player:inMyAttackRange(p) and not target:isProhibited(p, Fk:cloneCard("slash"))
    end)
    if not target:isProhibited(player, Fk:cloneCard("slash")) then
      table.insert(targets, player)
    end
    if #targets == 0 then return end
    targets = table.map(targets, Util.IdMapper)
    U.askForUseVirtualCard(room, target, "slash", nil, self.name,
      "#sxfy__yinge-slash:"..player.id, false, true, true, true, {exclusive_targets = targets})
  end,
}
local sxfy__shiren = fk.CreateTriggerSkill{
  name = "sxfy__shiren",
  anim_type = "drawcard",
  events = {fk.TargetConfirmed},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card.trueName == "slash" and
      player.id ~= data.from and player:usedSkillTimes(self.name, Player.HistoryTurn) == 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#sxfy__shiren-invoke::"..data.from)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(2, self.name)
    local to = room:getPlayerById(data.from)
    if player.dead or to.dead or player:isNude() then return end
    local card = room:askForCard(player, 1, 1, true, self.name, false, nil, "#sxfy__shiren-give::"..to.id)
    room:moveCardTo(card, Card.PlayerHand, to, fk.ReasonGive, self.name, nil, false, player.id)
  end,
}
local sxfy__juyi = fk.CreateTriggerSkill{
  name = "sxfy__juyi$",
  anim_type = "defensive",
  events = {fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.from and data.from.kingdom == "qun" and data.from ~= player and
      not data.from.dead and player:usedSkillTimes(self.name, Player.HistoryTurn) == 0 and
      #player.room.logic:getActualDamageEvents(2, function(e)
        return e.data[1].from == data.from and e.data[1].to == player
      end) == 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(data.from, self.name, nil, "#sxfy__juyi-invoke:"..player.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(data.from.id, {player.id})
    if not player:isNude() then
      local card = room:askForCardChosen(data.from, player, "he", self.name)
      room:moveCardTo(card, Card.PlayerHand, data.from, fk.ReasonPrey, self.name, nil, false, data.from.id)
    end
    return true
  end,
}
liuzhang:addSkill(sxfy__yinge)
liuzhang:addSkill(sxfy__shiren)
liuzhang:addSkill(sxfy__juyi)
Fk:loadTranslationTable{
  ["sxfy__liuzhang"] = "刘璋",
  ["#sxfy__liuzhang"] = "求仁失益",
  ["illustrator:sxfy__liuzhang"] = "HM",

  ["sxfy__yinge"] = "引戈",
  [":sxfy__yinge"] = "出牌阶段限一次，你可以令一名其他角色交给你一张牌，然后其视为对你或你攻击范围内的另一名角色使用一张【杀】。",
  ["sxfy__shiren"] = "施仁",
  [":sxfy__shiren"] = "每回合限一次，当你成为其他角色使用【杀】的目标后，你可以摸两张牌，然后交给该角色一张牌。",
  ["sxfy__juyi"] = "据益",
  [":sxfy__juyi"] = "主公技，其他群势力角色每回合首次对你造成伤害时，其可以防止此伤害，然后获得你一张牌。",
  ["#sxfy__yinge"] = "引戈：令一名角色交给你一张牌，然后其视为对你或你攻击范围内的一名角色使用【杀】",
  ["#sxfy__yinge-give"] = "引戈：请交给 %src 一张牌",
  ["#sxfy__yinge-slash"] = "引戈：请视为对 %src 或其攻击范围内一名角色使用【杀】",
  ["#sxfy__shiren-invoke"] = "施仁：你可以摸两张牌，交给 %dest 一张牌",
  ["#sxfy__shiren-give"] = "施仁：请交给 %dest 一张牌",
  ["#sxfy__juyi-invoke"] = "据益：是否防止对 %src 造成的伤害并获得其一张牌？",
}

local gongsunyuan = General(extension, "sxfy__gongsunyuan", "qun", 4)
local sxfy__huaiyi = fk.CreateTriggerSkill{
  name = "sxfy__huaiyi",
  anim_type = "control",
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Start and not player:isKongcheng()
  end,
  on_use = function(self, event, target, player, data)
    Fk.skills["huaiyi"]:onUse(player.room, {
      from = player.id,
    })
  end,
}
local sxfy__fengbai = fk.CreateTriggerSkill{
  name = "sxfy__fengbai$",
  anim_type = "support",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      for _, move in ipairs(data) do
        if move.to == player.id and move.toArea == Player.Hand and move.from and
          player.room:getPlayerById(move.from).kingdom == "qun" then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerEquip then
              return true
            end
          end
        end
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    local room = player.room
    local dat = {}
    for _, move in ipairs(data) do
      if move.to == player.id and move.toArea == Player.Hand and move.from and
        room:getPlayerById(move.from).kingdom == "qun" then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerEquip then
            dat[string.format("%.0f", move.from)] = (dat[string.format("%.0f", move.from)] or 0) + 1
          end
        end
      end
    end
    for _, p in ipairs(room:getAlivePlayers()) do
      if dat[string.format("%.0f", p.id)] then
        self.cancel_cost = false
        local n = dat[string.format("%.0f", p.id)]
        for i = 1, n, 1 do
          if self.cancel_cost or not player:hasSkill(self) or p.dead then break end
          self.cost_data = p.id
          self:doCost(event, target, player, data)
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askForSkillInvoke(player, self.name, nil, "#sxfy__fengbai-invoke::"..self.cost_data) then
      self.cost_data = {tos = {self.cost_data}}
      return true
    end
    self.cancel_cost = true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data.tos[1])
    room:doIndicate(player.id, {to.id})
    to:drawCards(1, self.name)
  end,
}
gongsunyuan:addSkill(sxfy__huaiyi)
gongsunyuan:addSkill(sxfy__fengbai)
Fk:loadTranslationTable{
  ["sxfy__gongsunyuan"] = "公孙渊",
  ["#sxfy__gongsunyuan"] = "狡徒悬海",
  ["illustrator:sxfy__gongsunyuan"] = "Zero",

  ["sxfy__huaiyi"] = "怀异",
  [":sxfy__huaiyi"] = "锁定技，准备阶段，你展示所有手牌，若颜色不全部相同，你弃置其中一种颜色的所有牌，获得至多等量名其他角色各一张牌，"..
  "若超过一名角色，你失去1点体力。",
  ["sxfy__fengbai"] = "封拜",
  [":sxfy__fengbai"] = "主公技，当你获得一名群势力角色装备区里的一张牌后，你可以令其摸一张牌。",
  ["#sxfy__fengbai-invoke"] = "封拜：是否令 %dest 摸一张牌？",
}

local liubiao = General(extension, "sxfy__liubiao", "qun", 3)
local sxfy__zishou = fk.CreateTriggerSkill{
  name = "sxfy__zishou",
  anim_type = "drawcard",
  events = {fk.EventPhaseChanging},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.to == Player.Play
  end,
  on_use = function(self, event, target, player, data)
    local kingdoms = {}
    for _, p in ipairs(player.room.alive_players) do
      table.insertIfNeed(kingdoms, p.kingdom)
    end
    player:drawCards(#kingdoms, self.name)
    return true
  end,
}
local sxfy__jujing = fk.CreateTriggerSkill{
  name = "sxfy__jujing$",
  anim_type = "defensive",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.from and data.from.kingdom == "qun" and data.from ~= player and
      player:isWounded() and #player:getCardIds("he") > 1
  end,
  on_cost = function(self, event, target, player, data)
    local cards = player.room:askForDiscard(player, 2, 2, true, self.name, true, nil, "#sxfy__jujing-invoke", true)
    if #cards == 2 then
      self.cost_data = {cards = cards}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(self.cost_data.cards, self.name, player, player)
    if not player.dead and player:isWounded() then
      room:recover({
        who = player,
        num = 1,
        recoverBy = player,
        skillName = self.name,
      })
    end
  end,
}
liubiao:addSkill(sxfy__zishou)
liubiao:addSkill("zongshi")
liubiao:addSkill(sxfy__jujing)
Fk:loadTranslationTable{
  ["sxfy__liubiao"] = "刘表",
  ["#sxfy__liubiao"] = "跨蹈汉南",
  ["illustrator:sxfy__liubiao"] = "波子",

  ["sxfy__zishou"] = "自守",
  [":sxfy__zishou"] = "出牌阶段开始前，你可以摸当前势力张牌，然后你跳过此阶段。",
  ["sxfy__jujing"] = "踞荆",
  [":sxfy__jujing"] = "主公技，当你受到其他群势力角色造成的伤害后，你可以弃置两张牌，然后回复1点体力。",
  ["#sxfy__jujing-invoke"] = "踞荆：你可以弃置两张牌，回复1点体力",
}

local simashi = General(extension, "sxfy__simashi", "wei", 4)
local sxfy__jinglve = fk.CreateTriggerSkill{
  name = "sxfy__jinglve",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(self) and target.phase == Player.Discard and not target.dead and
      #player:getCardIds("he") > 1
  end,
  on_cost = function(self, event, target, player, data)
    local cards = player.room:askForCard(player, 2, 2, true, self.name, true, nil, "#sxfy__jinglve-invoke::"..target.id)
    if #cards > 0 then
      self.cost_data = {tos = {target.id}, cards = cards}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = table.simpleClone(self.cost_data.cards)
    player:showCards(cards)
    cards = table.filter(cards, function (id)
      return table.contains(player:getCardIds("h"), id)
    end)
    if #cards == 0 or target.dead then return end
    room:moveCardTo(cards, Card.PlayerHand, target, fk.ReasonGive, self.name, nil, true, player.id, "@@sxfy__jinglve-phase")
  end,
}
local sxfy__jinglve_delay = fk.CreateTriggerSkill{
  name = "#sxfy__jinglve_delay",
  mute = true,
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    return target.phase == Player.Discard and player:usedSkillTimes("sxfy__jinglve", Player.HistoryPhase) > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = {}
    local phase_event = room.logic:getCurrentEvent():findParent(GameEvent.Phase, true)
    if phase_event ~= nil then
      local end_id = phase_event.id
      room.logic:getEventsByRule(GameEvent.MoveCards, 1, function (e)
        for _, move in ipairs(e.data) do
          if move.toArea == Card.DiscardPile and move.moveReason == fk.ReasonDiscard then
            for _, info in ipairs(move.moveInfo) do
              if room:getCardArea(info.cardId) == Card.DiscardPile then
                table.insertIfNeed(cards, info.cardId)
              end
            end
          end
        end
        return false
      end, end_id)
      if #cards > 0 then
        local card, choice = U.askforChooseCardsAndChoice(player, cards, {"OK"}, "sxfy__jinglve", "#sxfy__jinglve-prey", {"Cancel"})
        if choice == "OK" then
          room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonJustMove, "sxfy__jinglve", nil, true, player.id)
        end
      end
    end
  end,
}
local sxfy__jinglve_prohibit = fk.CreateProhibitSkill{
  name = "#sxfy__jinglve_prohibit",
  prohibit_discard = function(self, player, card)
    return card and card:getMark("@@sxfy__jinglve-phase") > 0
  end,
}
sxfy__jinglve:addRelatedSkill(sxfy__jinglve_delay)
sxfy__jinglve:addRelatedSkill(sxfy__jinglve_prohibit)
simashi:addSkill(sxfy__jinglve)
Fk:loadTranslationTable{
  ["sxfy__simashi"] = "司马师",
  ["#sxfy__simashi"] = "摧坚荡异",
  ["illustrator:sxfy__simashi"] = "M云涯",

  ["sxfy__jinglve"] = "景略",
  [":sxfy__jinglve"] = "其他角色弃牌阶段开始时，你可以展示并交给其两张牌，令其本阶段不能弃置这些牌，然后你可以于本阶段结束时获得本阶段弃置的"..
  "一张牌。",
  ["#sxfy__jinglve-invoke"] = "景略：你可以交给 %dest 两张牌，其本阶段不能弃置这些牌，本阶段结束时你可以获得一张弃置牌",
  ["@@sxfy__jinglve-phase"] = "景略",
  ["#sxfy__jinglve-prey"] = "景略：你可以获得其中一张牌",
}

local fuhuanghou = General(extension, "sxfy__fuhuanghou", "qun", 3, 3, General.Female)
local sxfy__zhuikong = fk.CreateTriggerSkill{
  name = "sxfy__zhuikong",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target ~= player and target.phase == Player.Start and not target.dead and
      player:canPindian(target)
  end,
  on_cost = function(self, event, target, player, data)
    local card = player.room:askForCard(player, 1, 1, false, self.name, true, "slash", "#sxfy__zhuikong-invoke::"..target.id)
    if #card > 0 then
      self.cost_data = {tos = {target.id}, cards = card}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local pindian = player:pindian({target}, self.name, Fk:getCardById(self.cost_data.cards[1]))
    local winner = pindian.results[target.id].winner
    if winner and not winner.dead then
      local card = -1
      if winner == player then
        card = pindian.results[target.id].toCard:getEffectiveId()
      else
        card = pindian.fromCard:getEffectiveId()
      end
      if not table.contains(room.discard_pile, card) then return end
      U.askForUseRealCard(room, winner, {card}, ".", self.name,
        "#sxfy__zhuikong-use:::"..Fk:getCardById(card):toLogString(), {extraUse = true, expand_pile = {card}})
    end
  end
}
local sxfy__qiuyuan = fk.CreateTriggerSkill{
  name = "sxfy__qiuyuan",
  anim_type = "defensive",
  events = {fk.TargetConfirming},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card.trueName == "slash" and
      table.find(player.room:getOtherPlayers(player), function (p)
        return p.id ~= data.from
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(table.filter(room:getOtherPlayers(player), function(p)
      return p.id ~= data.from end), Util.IdMapper)
    local to = room:askForChoosePlayers(player, targets, 1, 1, "#sxfy__qiuyuan-choose", self.name, true)
    if #to > 0 then
      self.cost_data = {tos = to}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data.tos[1])
    local card = room:askForCard(to, 1, 1, false, self.name, true, nil, "#sxfy__qiuyuan-give::"..player.id)
    if #card > 0 then
      room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonGive, self.name, nil, false, to.id)
    elseif not table.contains(TargetGroup:getRealTargets(data.tos), to.id) then
      TargetGroup:pushTargets(data.targetGroup, to.id)
    end
  end,
}
fuhuanghou:addSkill(sxfy__zhuikong)
fuhuanghou:addSkill(sxfy__qiuyuan)
Fk:loadTranslationTable{
  ["sxfy__fuhuanghou"] = "伏皇后",
  ["#sxfy__fuhuanghou"] = "孤注一掷",
  ["illustrator:sxfy__fuhuanghou"] = "鬼画府",

  ["sxfy__zhuikong"] = "惴恐",
  [":sxfy__zhuikong"] = "其他角色准备阶段，你可以用【杀】与其拼点，赢的角色可以使用对方的拼点牌。",
  ["sxfy__qiuyuan"] = "求援",
  [":sxfy__qiuyuan"] = "当你成为一名角色使用【杀】的目标时，你可以令另一名角色选择交给你一张牌或成为此【杀】的额外目标。",
  ["#sxfy__zhuikong-invoke"] = "惴恐：你可以用一张【杀】与 %dest 拼点，赢的角色可以使用对方的拼点牌",
  ["#sxfy__zhuikong-use"] = "惴恐：你可以使用%arg",
  ["#sxfy__qiuyuan-choose"] = "求援：令一名角色选择交给你一张牌或成为此【杀】的额外目标",
  ["#sxfy__qiuyuan-give"] = "求援：你需交给 %dest 一张牌，否则成为此【杀】额外目标",
}

return extension
