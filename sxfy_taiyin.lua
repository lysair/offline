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
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    room:moveCardTo(data.card, Card.PlayerHand, to, fk.ReasonGive, self.name, nil, true, player.id)
  end,
}
xushu:addSkill(sxfy__wuyan)
xushu:addSkill(sxfy__jujian)
Fk:loadTranslationTable{
  ["sxfy__xushu"] = "徐庶",
  ["#sxfy__xushu"] = "身曹心汉",
  ["illustrator:sxfy__xushu"] = "",

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
    return player:hasSkill(self) and #player:getCardIds("e") % 2 == 1
  end,
  bypass_distances = function (self, player, skill, card, to)
    return player:hasSkill(self) and #player:getCardIds("e") % 2 == 0
  end,
}
local sxfy__shangjian = fk.CreateTriggerSkill{
  name = "sxfy__shangjian",
  events = {fk.EventPhaseStart},
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and player.phase == Player.Finish then
      local cards, num = {}, 0
      player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
        for _, move in ipairs(e.data) do
          if move.from == player.id then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
                num = num + 1
                if table.contains(player.room.discard_pile, info.cardId) then
                  table.insertIfNeed(cards, info.cardId)
                end
              end
            end
          end
        end
        return false
      end, Player.HistoryTurn)
      if num <= player.hp and #cards > 0 then
        self.cost_data = cards
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = U.askforChooseCardsAndChoice(player, self.cost_data, {"OK"}, self.name, "#sxfy__shangjian-prey")
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

  refresh_events = {fk.GameStart, fk.EventAcquireSkill, fk.EventLoseSkill, fk.Deathed},
  can_refresh = function(self, event, target, player, data)
    if event == fk.GameStart then
      return player:hasSkill(self, true)
    elseif event == fk.EventAcquireSkill or event == fk.EventLoseSkill then
      return target == player and data == self and
        not table.find(player.room:getOtherPlayers(player), function(p) return p:hasSkill(self, true) end)
    else
      return target == player and player:hasSkill(self, true, true) and
        not table.find(player.room:getOtherPlayers(player), function(p) return p:hasSkill(self, true) end)
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.GameStart or event == fk.EventAcquireSkill then
      for _, p in ipairs(room:getOtherPlayers(player)) do
        room:handleAddLoseSkills(p, "sxfy__xiemu&", nil, false, true)
      end
    else
      for _, p in ipairs(room:getOtherPlayers(player, true, true)) do
        room:handleAddLoseSkills(p, "-sxfy__xiemu&", nil, false, true)
      end
    end
  end,
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
      table.map(effect.tos, function(id) return room:getPlayerById(id) end), self.name)
  end
}
Fk:addSkill(sxfy__xiemu_active)
sxfy__xiemu:addRelatedSkill(sxfy__xiemu_attackrange)
maliang:addSkill(sxfy__xiemu)
maliang:addSkill(sxfy__naman)
Fk:loadTranslationTable{
  ["sxfy__maliang"] = "马良",
  ["#sxfy__maliang"] = "白眉智士",
  ["illustrator:sxfy__maliang"] = "",

  ["sxfy__xiemu"] = "协穆",
  [":sxfy__xiemu"] = "其他角色出牌阶段限一次，其可以展示并交给你一张基本牌，然后本回合其攻击范围+1。",
  ["sxfy__naman"] = "纳蛮",
  [":sxfy__naman"] = "出牌阶段限一次，你可以将任意张基本牌当指定等量名目标的【南蛮入侵】使用。",

  ["sxfy__xiemu&"] = "协穆",
  [":sxfy__xiemu&"] = "出牌阶段限一次，你可以展示并交给马良一张基本牌，然后本回合你攻击范围+1。",
  ["#sxfy__xiemu&"] = "协穆：交给马良一张基本牌，本回合你攻击范围+1",
  ["#sxfy__naman"] = "纳蛮：将任意张基本牌当指定等量目标的【南蛮入侵】使用",
}

--local jiangwan = General(extension, "sxfy__jiangwan", "shu", 3)
Fk:loadTranslationTable{
  ["sxfy__jiangwan"] = "蒋琬",
  ["#sxfy__jiangwan"] = "方整威重",
  ["illustrator:sxfy__jiangwan"] = "depp",

  ["sxfy__beiwu"] = "备武",
  [":sxfy__beiwu"] = "你可以将装备区内一张不为本回合置入的牌当【无中生有】或【决斗】使用。",
  ["sxfy__chengshi"] = "承事",
  [":sxfy__chengshi"] = "限定技，当一名其他角色死亡时，你可以与其交换座次与装备区内的牌。",
}

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
Fk:loadTranslationTable{
  ["sxfy__sunshao"] = "孙邵",
  ["#sxfy__sunshao"] = "创基扶政",
  ["illustrator:sxfy__sunshao"] = "",

  ["sxfy__dingyi"] = "定仪",
  [":sxfy__dingyi"] = "一名角色结束阶段，若其装备区内没有牌，其可以摸一张牌。",
  ["sxfy__zuici"] = "罪辞",
  [":sxfy__zuici"] = "当你受到伤害后，你可以将场上一张牌移至伤害来源对应的区域。",
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
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:damage({
      from = player,
      to = room:getPlayerById(self.cost_data),
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

Fk:loadTranslationTable{
  ["sxfy__guanxing"] = "关兴",
  ["#sxfy__guanxing"] = "龙骧将军",
  ["illustrator:sxfy__guanxing"] = "峰雨同程",

  ["sxfy__wuyou"] = "武佑",
  [":sxfy__wuyou"] = "出牌阶段限一次，你可以与一名角色拼点，若你没赢，你本回合视为拥有〖武圣〗。然后拼点赢的角色视为对没赢的角色使用一张"..
  "【决斗】。",
}

Fk:loadTranslationTable{
  ["sxfy__xuezong"] = "薛综",
  ["#sxfy__xuezong"] = "彬彬之玊",
  ["illustrator:sxfy__xuezong"] = "",

  ["sxfy__funan"] = "复难",
  [":sxfy__funan"] = "每回合限一次，其他角色使用的牌被你抵消时，你可以获得之。",
  ["sxfy__jiexun"] = "诫训",
  [":sxfy__jiexun"] = "结束阶段，你可以令一名角色弃置一张手牌，然后若此牌为<font color='red'>♦</font>牌，其摸两张牌",
}

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
Fk:loadTranslationTable{
  ["sxfy__cenhun"] = "岑昏",
  ["#sxfy__cenhun"] = "伐梁倾瓴",
  ["illustrator:sxfy__cenhun"] = "",

  ["sxfy__jishe"] = "极奢",
  [":sxfy__jishe"] = "出牌阶段，你可以令本回合手牌上限-1（至少为0），然后摸一张牌。",
  ["sxfy__wudu"] = "无度",
  [":sxfy__wudu"] = "当一名没有手牌的角色受到伤害时，你可以减1点体力上限，防止此伤害。",
  ["#sxfy__jishe"] = "极奢：本回合手牌上限-1，摸一张牌",
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
Fk:loadTranslationTable{
  ["sxfy__huaxin"] = "华歆",
  ["#sxfy__huaxin"] = "清素拂浊",
  ["illustrator:sxfy__huaxin"] = "",

  ["sxfy__yuanqing"] = "渊清",
  [":sxfy__yuanqing"] = "回合结束时，你可以令所有角色依次选择并获得弃牌堆中因其此回合失去而置入的一张牌。",
  ["sxfy__shuchen"] = "疏陈",
  [":sxfy__shuchen"] = "你的回合外，你可以将超出手牌上限部分的手牌当一张【桃】使用。",

  ["#sxfy__shuchen"] = "疏陈：你可以%arg张手牌当一张【桃】使用",
}

Fk:loadTranslationTable{
  ["sxfy__wanglang"] = "王朗",
  ["#sxfy__wanglang"] = "凤鶥",
  ["illustrator:sxfy__wanglang"] = "小牛",

  ["sxfy__gushe"] = "鼓舌",
  [":sxfy__gushe"] = "出牌阶段限一次，你可以与一名角色拼点，拼点赢的角色摸一张牌，然后拼点输的角色可以与对方重复此流程。",
  ["sxfy__jici"] = "激词",
  [":sxfy__jici"] = "当你亮出拼点牌时，你可以失去1点体力，令你的拼点牌的点数视为K。",
}

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
}

Fk:loadTranslationTable{
  ["sxfy__gongsunyuan"] = "公孙渊",
  ["#sxfy__gongsunyuan"] = "狡徒悬海",
  ["illustrator:sxfy__gongsunyuan"] = "Zero",

  ["sxfy__huaiyi"] = "怀异",
  [":sxfy__huaiyi"] = "锁定技，准备阶段，你展示所有手牌，若颜色不全部相同，你弃置其中一种颜色的所有牌，获得至多等量名其他角色各一张牌，"..
  "若超过一名角色，你失去1点体力。",
  ["sxfy__fengbai"] = "封拜",
  [":sxfy__fengbai"] = "主公技，当你获得一名群势力角色装备区里的一张牌后，你可以令其摸一张牌。",
}

Fk:loadTranslationTable{
  ["sxfy__liubiao"] = "刘表",
  ["#sxfy__liubiao"] = "跨蹈汉南",
  ["illustrator:sxfy__liubiao"] = "波子",

  ["sxfy__zishou"] = "自守",
  [":sxfy__zishou"] = "出牌阶段开始前，你可以摸当前势力张牌，然后你跳过此阶段。",
  ["sxfy__jujing"] = "踞荆",
  [":sxfy__jujing"] = "主公技，当你受到其他群势力角色造成的伤害后，你可以弃置两张牌，然后回复1点体力。",
}

Fk:loadTranslationTable{
  ["sxfy__simashi"] = "司马师",
  ["#sxfy__simashi"] = "摧坚荡异",
  ["illustrator:sxfy__simashi"] = "",

  ["sxfy__jinglve"] = "景略",
  [":sxfy__jinglve"] = "其他角色弃牌阶段开始时，你可以展示并交给其两张牌，令其本阶段不能弃置这些牌，然后你可以于本阶段结束时获得本阶段弃置的"..
  "一张牌。",
}

Fk:loadTranslationTable{
  ["sxfy__fuhuanghou"] = "伏皇后",
  ["#sxfy__fuhuanghou"] = "孤注一掷",
  ["illustrator:sxfy__fuhuanghou"] = "",

  ["sxfy__zhuikong"] = "惴恐",
  [":sxfy__zhuikong"] = "其他角色准备阶段，你可以用【杀】与其拼点，赢的角色可以使用对方的拼点牌。",
  ["sxfy__qiuyuan"] = "求援",
  [":sxfy__qiuyuan"] = "当你成为一名角色使用【杀】的目标时，你可以令另一名角色选择交给你一张牌或成为此【杀】的额外目标。",
}

return extension
