local extension = Package("sxfy_shaoyin")
extension.extensionName = "offline"

local U = require "packages/utility/utility"

Fk:loadTranslationTable{
  ["sxfy_shaoyin"] = "四象封印-少阴",
  ["sxfy"] = "四象封印",
}

local dengzhi = General(extension, "sxfy__dengzhi", "shu", 3)
local sxfy__jimeng = fk.CreateTriggerSkill{
  name = "sxfy__jimeng",
  anim_type = "support",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Start and not player:isNude() and
      #player.room.alive_players > 1
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local tos, cards = room:askForChooseCardsAndPlayers(player, 1, 999, table.map(room:getOtherPlayers(player, false), Util.IdMapper), 1, 1,
      nil, "#sxfy__jimeng-invoke", self.name, true, false)
    if #tos > 0 and #cards > 0 then
      self.cost_data = {tos[1], cards}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data[1])
    room:moveCardTo(self.cost_data[2], Card.PlayerHand, to, fk.ReasonGive, self.name, nil, false, player.id)
    if not player.dead and not to.dead and not to:isNude() then
      local cards = room:askForCard(to, 1, 999, true, self.name, false, nil, "#sxfy__jimeng-give::"..player.id)
      room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonGive, self.name, nil, false, to.id)
    end
  end,
}
local sxfy__hehe = fk.CreateTriggerSkill{
  name = "sxfy__hehe",
  anim_type = "support",
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Draw and
      table.find(player.room:getOtherPlayers(player, false), function (p)
        return p:getHandcardNum() == player:getHandcardNum()
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player, false), function (p)
      return p:getHandcardNum() == player:getHandcardNum()
    end)
    local tos = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 2, "#sxfy__hehe-invoke", self.name, true)
    if #tos > 0  then
      self.cost_data = tos
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:sortPlayersByAction(self.cost_data)
    for _, id in ipairs(self.cost_data) do
      local p = room:getPlayerById(id)
      if not p.dead then
        p:drawCards(1, self.name)
      end
    end
  end,
}
dengzhi:addSkill(sxfy__jimeng)
dengzhi:addSkill(sxfy__hehe)
Fk:loadTranslationTable{
  ["sxfy__dengzhi"] = "邓芝",
  ["#sxfy__dengzhi"] = "绝境的外交家",
  ["illustrator:sxfy__dengzhi"] = "小牛",

  ["sxfy__jimeng"] = "急盟",
  [":sxfy__jimeng"] = "准备阶段，你可以交给一名角色至少一张牌，然后其交给你至少一张牌。",
  ["sxfy__hehe"] = "和合",
  [":sxfy__hehe"] = "摸牌阶段结束时，你可以令至多两名手牌数与你相同的其他角色各摸一张牌。",
  ["#sxfy__jimeng-invoke"] = "急盟：你可以交给一名角色任意张牌，然后其交给你任意张牌",
  ["#sxfy__jimeng-give"] = "急盟：你可以交给 %dest 任意张牌",
  ["#sxfy__hehe-invoke"] = "和合：令至多两名手牌数与你相同的其他角色各摸一张牌",
}

local wenyang = General(extension, "sxfy__wenyang", "wei", 4)
local sxfy__quedi = fk.CreateViewAsSkill{
  name = "sxfy__quedi",
  anim_type = "offensive",
  pattern = "duel",
  prompt = "#sxfy__quedi",
  handly_pile = true,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).trueName == "slash"
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard("duel")
    card.skillName = self.name
    card:addSubcard(cards[1])
    return card
  end,
  enabled_at_response = function(self, player, response)
    return not response
  end,
}
wenyang:addSkill(sxfy__quedi)
Fk:loadTranslationTable{
  ["sxfy__wenyang"] = "文鸯",
  ["#sxfy__wenyang"] = "独骑破军",
  ["illustrator:sxfy__wenyang"] = "biou09",

  ["sxfy__quedi"] = "却敌",
  [":sxfy__quedi"] = "你可以将【杀】当【决斗】使用。",
  ["#sxfy__quedi"] = "却敌：你可以将【杀】当【决斗】使用",
}

local chengpu = General(extension, "sxfy__chengpu", "wu", 4)
local sxfy__chunlao = fk.CreateTriggerSkill{
  name = "sxfy__chunlao",
  anim_type = "support",
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and player.phase == Player.Discard and 
      table.find(player.room:getOtherPlayers(player, false), function (p)
        return not p:isKongcheng()
      end) then
      local room = player.room
      local cards = {}
      local phase_event = room.logic:getCurrentEvent():findParent(GameEvent.Phase, true)
      if phase_event ~= nil then
        local end_id = phase_event.id
        room.logic:getEventsByRule(GameEvent.MoveCards, 1, function (e)
          for _, move in ipairs(e.data) do
            if move.from == target.id and move.toArea == Card.DiscardPile and move.moveReason == fk.ReasonDiscard then
              for _, info in ipairs(move.moveInfo) do
                if room:getCardArea(info.cardId) == Card.DiscardPile then
                  table.insertIfNeed(cards, info.cardId)
                end
              end
            end
          end
          return false
        end, end_id)
      end
      if #cards > 1 then
        self.cost_data = cards
        return true
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local choice = U.askforViewCardsAndChoice(player, self.cost_data, {"OK", "Cancel"}, self.name, "#sxfy__chunlao-choice")
    if choice == "OK" then
      local targets = table.filter(room:getOtherPlayers(player, false), function (p)
        return not p:isKongcheng()
      end)
      local to = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 1,
        "#sxfy__chunlao-give", self.name, true)
      if #to > 0 then
        self.cost_data = {to[1], self.cost_data}
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data[1])
    U.swapCardsWithPile(to, to:getCardIds("h"), self.cost_data[2], self.name, "discardPile", true, to.id)
    if not to.dead and not player.dead and player:isWounded() and
      room:askForSkillInvoke(to, self.name, nil, "#sxfy__chunlao-recover:"..player.id) then
      room:recover{
        who = player,
        num = 1,
        recoverBy = to,
        skillName = self.name,
      }
    end
  end,
}
chengpu:addSkill(sxfy__chunlao)
Fk:loadTranslationTable{
  ["sxfy__chengpu"] = "程普",
  ["#sxfy__chengpu"] = "三朝虎臣",
  ["illustrator:sxfy__chengpu"] = "Zero",

  ["sxfy__chunlao"] = "醇醪",
  [":sxfy__chunlao"] = "弃牌阶段结束时，你可以用弃牌堆中你本阶段弃置的所有牌（至少两张）交换一名其他角色的所有手牌，然后其可以令你回复1点体力。",
  ["#sxfy__chunlao-choice"] = "醇醪：是否用这些牌和一名角色的手牌交换？",
  ["#sxfy__chunlao-give"] = "醇醪：选择一名角色，用这些牌和其手牌交换",
  ["#sxfy__chunlao-recover"] = "醇醪：是否令 %src 回复1点体力？",
}

local lijue = General(extension, "sxfy__lijue", "qun", 5)
local sxfy__xiongsuan = fk.CreateTriggerSkill{
  name = "sxfy__xiongsuan",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Start and
      table.every(player.room.alive_players, function (p)
        return p.hp <= player.hp
      end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function (p)
      return p.hp == player.hp
    end)
    local tos = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 999,
      "#sxfy__xiongsuan-invoke", self.name, false)
    room:sortPlayersByAction(tos)
    for _, id in ipairs(tos) do
      local p = room:getPlayerById(id)
      if not p.dead then
        room:damage({
          from = player,
          to = p,
          damage = 1,
          skillName = self.name,
        })
      end
    end
  end,
}
lijue:addSkill(sxfy__xiongsuan)
Fk:loadTranslationTable{
  ["sxfy__lijue"] = "李傕",
  ["#sxfy__lijue"] = "奸谋恶勇",
  ["illustrator:sxfy__lijue"] = "XXX",

  ["sxfy__xiongsuan"] = "凶算",
  [":sxfy__xiongsuan"] = "锁定技，准备阶段，若没有角色体力值大于你，你须对至少一名体力值等于你的角色各造成1点伤害。",
  ["#sxfy__xiongsuan-invoke"] = "凶算：对任意名体力值等于你的角色造成1点伤害",
}

local feiyi = General(extension, "sxfy__feiyi", "shu", 3)
local sxfy__tiaohe = fk.CreateActiveSkill{
  name = "sxfy__tiaohe",
  anim_type = "control",
  card_num = 0,
  target_num = 2,
  prompt = "#sxfy__tiaohe",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected, selected_cards)
    local target = Fk:currentRoom():getPlayerById(to_select)
    if #selected == 0 then
      return #target:getEquipments(Card.SubtypeWeapon) > 0 or #target:getEquipments(Card.SubtypeArmor) > 0
    elseif #selected == 1 then
      local target1 = Fk:currentRoom():getPlayerById(selected[1])
      if #target1:getEquipments(Card.SubtypeWeapon) > 0 and #target1:getEquipments(Card.SubtypeArmor) == 0 then
        return #target:getEquipments(Card.SubtypeArmor) > 0
      elseif #target1:getEquipments(Card.SubtypeWeapon) == 0 and #target1:getEquipments(Card.SubtypeArmor) > 0 then
        return #target:getEquipments(Card.SubtypeWeapon) > 0
      elseif #target1:getEquipments(Card.SubtypeWeapon) > 0 and #target1:getEquipments(Card.SubtypeArmor) > 0 then
        return #target:getEquipments(Card.SubtypeWeapon) > 0 or #target:getEquipments(Card.SubtypeArmor) > 0
      end
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:sortPlayersByAction(effect.tos)
    local tag = {"", ""}
    for i = 1, 2, 1 do
      if #room:getPlayerById(effect.tos[i]):getEquipments(Card.SubtypeWeapon) > 0 then
        tag[i] = tag[i].."w"
      end
      if #room:getPlayerById(effect.tos[i]):getEquipments(Card.SubtypeArmor) > 0 then
        tag[i] = tag[i].."a"
      end
    end
    if string.len(tag[2]) == 1 then
      if tag[2] == "w" then
        tag[1] = "a"
      else
        tag[1] = "w"
      end
    end
    local moves = {}
    for i = 1, 2, 1 do
      local p = room:getPlayerById(effect.tos[i])
      local sub_type, ids = 1, {}
      if string.len(tag[i]) == 1 then
        if tag[i] == "w" then
          sub_type = Card.SubtypeWeapon
        else
          sub_type = Card.SubtypeArmor
        end
        if #p:getEquipments(sub_type) == 1 then
          ids = p:getEquipments(sub_type)
        else
          local cards = table.filter(p:getCardIds("e"), function (id)
            return Fk:getCardById(id).sub_type == sub_type
          end)
          ids = U.askforChooseCardsAndChoice(player, cards, {"OK"}, self.name, "#sxfy__tiaohe-discard::"..p.id)
        end
      else
        local cards = table.filter(p:getCardIds("e"), function (id)
          return Fk:getCardById(id).sub_type == Card.SubtypeWeapon or Fk:getCardById(id).sub_type == Card.SubtypeArmor
        end)
        ids = U.askforChooseCardsAndChoice(player, cards, {"OK"}, self.name, "#sxfy__tiaohe-discard::"..p.id)
      end
      if i == 1 and string.len(tag[2]) == 2 then
        if Fk:getCardById(ids[1]).sub_type == Card.SubtypeWeapon then
          tag[2] = "a"
        else
          tag[2] = "w"
        end
      end
      table.insert(moves, {
        ids = ids,
        from = effect.tos[i],
        toArea = Card.DiscardPile,
        moveReason = fk.ReasonDiscard,
        proposer = player.id,
        skillName = self.name,
      })
    end
    room:moveCards(table.unpack(moves))
  end,
}
local sxfy__qiansu = fk.CreateTriggerSkill{
  name = "sxfy__qiansu",
  anim_type = "drawcard",
  events = {fk.TargetConfirmed},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card.type == Card.TypeTrick and #player:getCardIds("e") == 0
  end,
  on_use = function (self, event, target, player, data)
    player:drawCards(1, self.name)
  end,
}
feiyi:addSkill(sxfy__tiaohe)
feiyi:addSkill(sxfy__qiansu)
Fk:loadTranslationTable{
  ["sxfy__feiyi"] = "费祎",
  ["#sxfy__feiyi"] = "洞世权相",
  ["illustrator:sxfy__feiyi"] = "木碗Rae",

  ["sxfy__tiaohe"] = "调和",
  [":sxfy__tiaohe"] = "出牌阶段限一次，你可以弃置场上一张武器牌和一张防具牌（不能为同一名角色的牌）。",
  ["sxfy__qiansu"] = "谦素",
  [":sxfy__qiansu"] = "当你成为锦囊牌的目标后，若你的装备区内没有牌，你可以摸一张牌。",
  ["#sxfy__tiaohe"] = "调和：选择两名角色，弃置一名角色的武器牌和另一名角色的防具牌",
  ["#sxfy__tiaohe-discard"] = "调和：选择弃置 %dest 的装备",
}

local fanyufeng = General(extension, "sxfy__fanyufeng", "qun", 3, 3, General.Female)
local sxfy__bazhan = fk.CreateActiveSkill{
  name = "sxfy__bazhan",
  anim_type = "support",
  card_num = 1,
  target_num = 1,
  prompt = "#sxfy__bazhan",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) < 2
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:currentRoom():getCardArea(to_select) == Player.Hand
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= Self.id and Fk:currentRoom():getPlayerById(to_select):isMale()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local type = Fk:getCardById(effect.cards[1]):getTypeString()
    room:moveCardTo(effect.cards, Card.PlayerHand, target, fk.ReasonGive, self.name, nil, true, player.id)
    if player.dead or target.dead or target:isNude() then return end
    local card = room:askForCard(target, 1, 1, false, self.name, true, ".|.|.|.|.|^"..type,
      "#sxfy__bazhan-give:"..player.id.."::"..type)
    if #card > 0 then
      room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonGive, self.name, nil, true, target.id)
    end
  end,
}
local sxfy__jiaoying = fk.CreateTriggerSkill{
  name = "sxfy__jiaoying",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and player.phase ~= Player.NotActive and not data.chain and
      data.to:getHandcardNum() > data.to:getMark("sxfy__jiaoying-turn")
  end,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage + 1
  end,

  refresh_events = {fk.TurnStart},
  can_refresh = function (self, event, target, player, data)
    return target == player and player:hasSkill(self, true)
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room.alive_players) do
      room:setPlayerMark(p, "sxfy__jiaoying-turn", p:getHandcardNum())
    end
  end,
}
local sxfy__jiaoying_prohibit = fk.CreateProhibitSkill{
  name = "#sxfy__jiaoying_prohibit",
  frequency = Skill.Compulsory,
  main_skill = sxfy__jiaoying,
  prohibit_use = function(self, player, card)
    if player:getHandcardNum() > player:getMark("sxfy__jiaoying-turn") and card and card.color == Card.Red then
      return table.find(Fk:currentRoom().alive_players, function(p)
        return p.phase ~= Player.NotActive and p:hasSkill(sxfy__jiaoying) and table.contains(p.player_skills, sxfy__jiaoying)
      end)
    end
  end,
}
sxfy__jiaoying:addRelatedSkill(sxfy__jiaoying_prohibit)
fanyufeng:addSkill(sxfy__bazhan)
fanyufeng:addSkill(sxfy__jiaoying)
Fk:loadTranslationTable{
  ["sxfy__fanyufeng"] = "樊玉凤",
  ["#sxfy__fanyufeng"] = "红鸾寡宿",
  ["illustrator:sxfy__fanyufeng"] = "biou09",

  ["sxfy__bazhan"] = "把盏",
  [":sxfy__bazhan"] = "出牌阶段限两次，你可以将一张手牌展示并交给一名男性角色，然后其可将一张类别不同的手牌展示并交给你。",
  ["sxfy__jiaoying"] = "醮影",
  [":sxfy__jiaoying"] = "锁定技，你的回合内，手牌数多于本回合开始时的角色不能使用红色牌且受到的伤害+1。",
  ["#sxfy__bazhan"] = "把盏：将一张手牌交给一名角色，其可以交给你一张类别不同的手牌",
  ["#sxfy__bazhan-give"] = "把盏：你可以交给 %src 一张非%arg",
}

local chengyu = General(extension, "sxfy__chengyu", "wei", 3)
local sxfy__shefu = fk.CreateTriggerSkill{
  name = "sxfy__shefu",
  anim_type = "control",
  derived_piles = "$sxfy__shefu",
  events ={fk.EventPhaseStart, fk.CardUsing},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      if event == fk.EventPhaseStart then
        return target == player and player.phase == Player.Finish and not player:isKongcheng()
      else
        return table.find(player:getPile("$sxfy__shefu"), function (id)
          return Fk:getCardById(id).trueName == data.card.trueName
        end)
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local card = {}
    if event == fk.EventPhaseStart then
      card = room:askForCard(player, 1, 1, false, self.name, true, ".", "#sxfy__shefu-put")
    else
      card = room:askForCard(player, 1, 1, false, self.name, true, data.card.trueName.."|.|.|$sxfy__shefu",
        "#sxfy__shefu-invoke::"..target.id..":"..data.card:toLogString(), "$sxfy__shefu")
    end
    if #card > 0 then
      self.cost_data = card
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.EventPhaseStart then
      player:addToPile("$sxfy__shefu", self.cost_data, false, self.name, player.id)
    else
      room:doIndicate(player.id, {target.id})
      room:moveCardTo(self.cost_data, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, self.name, nil, true, player.id)
      data.tos ={}
    end
  end,
}
local sxfy__yibing = fk.CreateTriggerSkill{
  name = "sxfy__yibing",
  anim_type = "control",
  events = {fk.EnterDying},
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(self) and not target:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, data, "#sxfy__yibing-invoke::"..target.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    local id = room:askForCardChosen(player, target, "h", self.name)
    room:moveCardTo(id, Card.PlayerHand, player, fk.ReasonPrey, self.name, nil, false, player.id)
  end,
}
chengyu:addSkill(sxfy__shefu)
chengyu:addSkill(sxfy__yibing)
Fk:loadTranslationTable{
  ["sxfy__chengyu"] = "程昱",
  ["#sxfy__chengyu"] = "泰山捧日",
  ["illustrator:sxfy__chengyu"] = "Mr_Sleeping",

  ["sxfy__shefu"] = "设伏",
  [":sxfy__shefu"] = "结束阶段，你可以将一张手牌扣置于武将牌上；当一名角色使用牌时，你可以移去你武将牌上的一张同名牌令之无效。",
  ["sxfy__yibing"] = "益兵",
  [":sxfy__yibing"] = "一名其他角色进入濒死状态时，你可以获得其一张手牌。",
  ["$sxfy__shefu"] = "设伏",
  ["#sxfy__shefu-put"] = "设伏：你可以将一张手牌扣置为“设伏”牌",
  ["#sxfy__shefu-invoke"] = "设伏：是否移去同名“设伏”牌，令 %dest 使用的%arg无效？",
  ["#sxfy__yibing-invoke"] = "益兵：是否获得 %dest 一张手牌？",
}

local zhangyiy = General(extension, "sxfy__zhangyiy", "shu", 4)
local sxfy__zhiyi = fk.CreateTriggerSkill{
  name = "sxfy__zhiyi",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and
      #player.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function(e)
        local use = e.data[1]
        return use.from == player.id and use.card.trueName == "slash"
      end, Player.HistoryTurn) > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if player:canUse(Fk:cloneCard("slash")) then
      if U.askForUseVirtualCard(room, player, "slash", nil, self.name, "#sxfy__zhiyi-slash", true, true, false, true) then
        return
      end
    end
    player:drawCards(1, self.name)
  end,
}
zhangyiy:addSkill(sxfy__zhiyi)
Fk:loadTranslationTable{
  ["sxfy__zhangyiy"] = "张翼",
  ["#sxfy__zhangyiy"] = "亢锐怀忠",
  ["illustrator:sxfy__zhangyiy"] = "影紫C",

  ["sxfy__zhiyi"] = "执义",
  [":sxfy__zhiyi"] = "锁定技，你使用过【杀】的回合结束时，你摸一张牌或视为使用一张【杀】。",
  ["#sxfy__zhiyi-slash"] = "执义：视为使用一张【杀】，或点“取消”摸一张牌",
}

local jianggan = General(extension, "sxfy__jianggan", "wei", 3)
local sxfy__daoshu = fk.CreateTriggerSkill{
  name = "sxfy__daoshu",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target.phase == Player.Start and not target.dead and
      player:usedSkillTimes(self.name, Player.HistoryRound) == 0 and
      table.find(player.room:getOtherPlayers(target), function(p)
        return not p:isKongcheng()
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(table.filter(room:getOtherPlayers(target), function(p)
      return not p:isKongcheng()
    end), Util.IdMapper)
    local to = room:askForChoosePlayers(player, targets, 1, 1, "#sxfy__daoshu-choose::"..target.id, self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    local card = room:askForCardChosen(player, to, "h", self.name, "#sxfy__daoshu-card:"..target.id..":"..to.id)
    local suit = Fk:getCardById(card):getSuitString(true)
    to:showCards(card)
    if target.dead or not table.contains(to:getCardIds("h"), card) then return end
    room:moveCardTo(card, Card.PlayerHand, target, fk.ReasonPrey, self.name, nil, true, target.id)
    if suit == "log_nosuit" then return end
    if not player.dead then
      room:setPlayerMark(player, "@sxfy__daoshu-turn", suit)
    end
    if target ~= player and not target.dead then
      room:setPlayerMark(target, "@sxfy__daoshu-turn", suit)
    end
  end,
}
local sxfy__daoshu_prohibit = fk.CreateProhibitSkill{
  name = "#sxfy__daoshu_prohibit",
  prohibit_use = function(self, player, card)
    if player:getMark("@sxfy__daoshu-turn") ~= 0 and card then
      local subcards = card:isVirtual() and card.subcards or {card.id}
      return #subcards > 0 and table.every(subcards, function(id)
        return table.contains(player:getCardIds("h"), id) and
          player:getMark("@sxfy__daoshu-turn") == Fk:getCardById(id):getSuitString(true)
      end)
    end
  end,
}
local sxfy__daizui = fk.CreateTriggerSkill{
  name = "sxfy__daizui",
  anim_type = "masochism",
  frequency = Skill.Compulsory,
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:usedSkillTimes("sxfy__daoshu", Player.HistoryRound) > 0
  end,
  on_use = function(self, event, target, player, data)
    player:setSkillUseHistory("sxfy__daoshu", 0, Player.HistoryRound)
  end,
}
sxfy__daoshu:addRelatedSkill(sxfy__daoshu_prohibit)
jianggan:addSkill(sxfy__daoshu)
jianggan:addSkill(sxfy__daizui)
Fk:loadTranslationTable{
  ["sxfy__jianggan"] = "蒋干",
  ["#sxfy__jianggan"] = "独步江淮",
  ["illustrator:sxfy__jianggan"] = "黑桃J",

  ["sxfy__daoshu"] = "盗书",
  [":sxfy__daoshu"] = "每轮限一次，一名角色准备阶段，你可以展示其以外的角色一张手牌并令其获得之，然后你与其本回合不能使用与之花色相同的手牌。",
  ["sxfy__daizui"] = "戴罪",
  [":sxfy__daizui"] = "锁定技，当你受到伤害后，〖盗书〗视为本轮未发动过。",
  ["#sxfy__daoshu-choose"] = "盗书：你可以展示一名角色一张手牌，令 %dest 获得之，本回合你与其不能使用此花色手牌",
  ["#sxfy__daoshu-card"] = "盗书：选择 %dest 的一张手牌，令 %src 获得之",
  ["@sxfy__daoshu-turn"] = "盗书",
}

local mayunlu = General(extension, "sxfy__mayunlu", "shu", 4, 4, General.Female)
local sxfy__fengpo = fk.CreateTriggerSkill{
  name = "sxfy__fengpo",
  anim_type = "offensive",
  events = {fk.DamageCaused},
  can_trigger = function(self, event, target, player, data)
    return target and target == player and player:hasSkill(self) and data.card and data.card.trueName == "slash" and
      player.room.logic:damageByCardEffect() and not (player:isNude() and data.to:isNude())
  end,
  on_cost = function(self, event, target, player, data)
    local targets = {}
    if not player:isNude() then
      table.insert(targets, player.id)
    end
    if not  data.to:isNude() then
      table.insert(targets,  data.to.id)
    end
    local to = player.room:askForChoosePlayers(player, targets, 1, 1, "#sxfy__fengpo-invoke::"..data.to.id, self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    local card = room:askForCardChosen(player, to, "he", self.name)
    if Fk:getCardById(card).suit == Card.Diamond then
      data.damage = data.damage + 1
    end
    room:throwCard(card, self.name, to, player)
  end,
}
mayunlu:addSkill(sxfy__fengpo)
mayunlu:addSkill("mashu")
Fk:loadTranslationTable{
  ["sxfy__mayunlu"] = "马云騄",
  ["#sxfy__mayunlu"] = "剑胆琴心",
  ["illustrator:sxfy__mayunlu"] = "木美人",

  ["sxfy__fengpo"] = "凤魄",
  [":sxfy__fengpo"] = "你使用【杀】对目标造成伤害时，你可以弃置你或其一张牌，若此牌为<font color='red'>♦</font>牌，则此伤害+1。",
  ["#sxfy__fengpo-invoke"] = "凤魄：你可以弃置你或 %dest 一张牌，若为<font color='red'>♦</font>，此伤害+1",
}

local mateng = General(extension, "sxfy__mateng", "qun", 4)
local sxfy__xiongyi = fk.CreateActiveSkill{
  name = "sxfy__xiongyi",
  anim_type = "offensive",
  frequency = Skill.Limited,
  card_num = 0,
  min_target_num = 1,
  prompt = "#sxfy__xiongyi",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = Util.TrueFunc,
  on_use = function(self, room, effect)
    room:sortPlayersByAction(effect.tos)
    while true do
      for _, id in ipairs(effect.tos) do
        local target = room:getPlayerById(id)
        if target.dead then
          return
        else
          local use = room:askForUseCard(target, self.name, "slash", "#sxfy__xiongyi-slash", true, {bypass_times = true})
          if use then
            use.disresponsiveList = table.map(room.alive_players, Util.IdMapper)
            use.extraUse = true
            room:useCard(use)
          else
            return
          end
        end
      end
    end
  end,
}
local sxfy__youqi = fk.CreateTriggerSkill{
  name = "sxfy__youqi$",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and player.phase == Player.Start then
      local room = player.room
      for _, p in ipairs(room.alive_players) do
        if p.kingdom == "qun" then
          local cards = table.simpleClone(p:getEquipments(Card.SubtypeOffensiveRide))
          table.insertTable(cards, p:getEquipments(Card.SubtypeDefensiveRide))
          if #cards > 0 then
            for _, id in ipairs(cards) do
              for _, q in ipairs(room:getOtherPlayers(p)) do
                if p:canMoveCardInBoardTo(q, id) then
                  return true
                end
              end
            end
          end
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local success, dat = player.room:askForUseActiveSkill(player, "sxfy__youqi_active", "#sxfy__youqi_active", true, nil, false)
    if success and dat then
      self.cost_data = dat.targets
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local target1 = room:getPlayerById(self.cost_data[1])
    local target2 = room:getPlayerById(self.cost_data[2])
    local excludeIds = table.filter(target1:getCardIds("e"), function (id)
      return Fk:getCardById(id).sub_type ~= Card.SubtypeOffensiveRide and Fk:getCardById(id).sub_type ~= Card.SubtypeDefensiveRide
    end)
    room:askForMoveCardInBoard(player, target1, target2, self.name, "e", target1, excludeIds)
  end,
}
local sxfy__youqi_active = fk.CreateActiveSkill{
  name = "sxfy__youqi_active",
  card_num = 0,
  target_num = 2,
  card_filter = Util.FalseFunc,
  target_filter = function (self, to_select, selected)
    if #selected == 0 then
      local target = Fk:currentRoom():getPlayerById(to_select)
      return target.kingdom == "qun" and
        (#target:getEquipments(Card.SubtypeOffensiveRide) > 0 or #target:getEquipments(Card.SubtypeDefensiveRide) > 0)
    elseif #selected == 1 then
      local src = Fk:currentRoom():getPlayerById(selected[1])
      local cards = table.simpleClone(src:getEquipments(Card.SubtypeOffensiveRide))
      table.insertTable(cards, src:getEquipments(Card.SubtypeDefensiveRide))
      for _, id in ipairs(cards) do
        if src:canMoveCardInBoardTo(Fk:currentRoom():getPlayerById(to_select), id) then
          return true
        end
      end
    end
  end,
}
Fk:addSkill(sxfy__youqi_active)
mateng:addSkill(sxfy__xiongyi)
mateng:addSkill("mashu")
mateng:addSkill(sxfy__youqi)
Fk:loadTranslationTable{
  ["sxfy__mateng"] = "马腾",
  ["#sxfy__mateng"] = "勇冠西州",
  ["illustrator:sxfy__mateng"] = "峰雨同程",

  ["sxfy__xiongyi"] = "雄异",
  [":sxfy__xiongyi"] = "限定技，出牌阶段，你可以令任意名角色依次可以使用一张【杀】（不可被响应），然后这些角色重复此流程直到有角色不使用。",
  ["sxfy__youqi"] = "游骑",
  [":sxfy__youqi"] = "主公技，准备阶段，你可以移动一名群势力角色装备区内的一张坐骑牌。",
  ["#sxfy__xiongyi"] = "雄异：令任意名角色可以依次使用不可被响应的【杀】！",
  ["#sxfy__xiongyi-slash"] = "雄异：请使用一张不可被响应的【杀】，或点“取消”终止此流程",
  ["sxfy__youqi_active"] = "游骑",
  ["#sxfy__youqi_active"] = "游骑：你可以移动一名群势力角色装备区内的一张坐骑牌",
}

local sunhao = General(extension, "sxfy__sunhao", "wu", 5)
local sxfy__canshi = fk.CreateTriggerSkill{
  name = "sxfy__canshi",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events ={fk.DrawNCards},
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = #table.filter(room.alive_players, function (p)
      return p:isWounded() or (player:hasSkill("guiming") and p.kingdom == "wu" and p ~= player)
    end)
    data.n = math.max(1, n)
  end,
}
local sxfy__canshi_delay = fk.CreateTriggerSkill{
  name = "#sxfy__canshi_delay",
  mute = true,
  events = {fk.TargetSpecifying},
  can_trigger = function(self, event, target, player, data)
    return target == player and (data.card.trueName == "slash" or data.card:isCommonTrick()) and data.firstTarget and
      player:usedSkillTimes("sxfy__canshi", Player.HistoryTurn) > 0 and not player:isNude() and
      table.find(AimGroup:getAllTargets(data.tos), function (id)
        local p = player.room:getPlayerById(id)
        return p:isWounded() or (player:hasSkill("guiming") and p.kingdom == "wu" and p ~= player)
      end)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:askForDiscard(player, 1, 1, true, "sxfy__canshi", false)
  end,
}
sxfy__canshi:addRelatedSkill(sxfy__canshi_delay)
sunhao:addSkill(sxfy__canshi)
sunhao:addSkill("chouhai")
sunhao:addSkill("guiming")
Fk:loadTranslationTable{
  ["sxfy__sunhao"] = "孙皓",
  ["#sxfy__sunhao"] = "时日曷丧",
  ["illustrator:sxfy__sunhao"] = "王立雄",

  ["sxfy__canshi"] = "残蚀",
  [":sxfy__canshi"] = "锁定技，摸牌阶段，你改为摸受伤角色数的牌（至少一张），然后你本回合使用【杀】或普通锦囊牌指定受伤角色为目标时，你须弃置"..
  "一张牌。",
  ["#sxfy__canshi_delay"] = "残蚀",
}

local luotong = General(extension, "sxfy__luotong", "wu", 3)
local sxfy__jinjian = fk.CreateTriggerSkill{
  name = "sxfy__jinjian",
  mute = true,
  events = {fk.DamageCaused, fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    if target and target == player and player:hasSkill(self) then
      if event == fk.DamageCaused then
        return player:getMark("sxfy__jinjian1-turn") == 0 or player:getMark("@@sxfy__jinjian1-turn") > 0
      elseif event == fk.DamageInflicted then
        return player:getMark("sxfy__jinjian2-turn") == 0 or player:getMark("@@sxfy__jinjian2-turn") > 0
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    if event == fk.DamageCaused then
      if player:getMark("sxfy__jinjian1-turn") == 0 then
        return player.room:askForSkillInvoke(player, self.name, nil, "#sxfy__jinjian1-invoke::"..data.to.id)
      else
        return true
      end
    else
      if player:getMark("sxfy__jinjian2-turn") == 0 then
        return player.room:askForSkillInvoke(player, self.name, nil, "#sxfy__jinjian2-invoke")
      else
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(self.name)
    if event == fk.DamageCaused then
      if player:getMark("sxfy__jinjian1-turn") == 0 then
        room:notifySkillInvoked(player, self.name, "support")
        room:setPlayerMark(player, "sxfy__jinjian1-turn", 1)
        room:setPlayerMark(player, "@@sxfy__jinjian1-turn", 1)
        return true
      else
        room:notifySkillInvoked(player, self.name, "offensive")
        room:setPlayerMark(player, "@@sxfy__jinjian1-turn", 0)
        data.damage = data.damage + 1
      end
    else
      if player:getMark("sxfy__jinjian2-turn") == 0 then
        room:notifySkillInvoked(player, self.name, "defensive")
        room:setPlayerMark(player, "sxfy__jinjian2-turn", 1)
        room:setPlayerMark(player, "@@sxfy__jinjian2-turn", 1)
        return true
      else
        room:notifySkillInvoked(player, self.name, "negative")
        room:setPlayerMark(player, "@@sxfy__jinjian2-turn", 0)
        data.damage = data.damage + 1
      end
    end
  end,
}
local sxfy__renzheng = fk.CreateTriggerSkill{
  name = "sxfy__renzheng",
  anim_type = "support",
  frequency = Skill.Compulsory,
  events = {fk.DamageFinished},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and not data.dealtRecorderId then
      local turn_event = player.room.logic:getCurrentEvent():findParent(GameEvent.Turn)
      if turn_event == nil then return end
      return not player.room.current.dead
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {room.current.id})
    room.current:drawCards(1, self.name)
  end,
}
luotong:addSkill(sxfy__jinjian)
luotong:addSkill(sxfy__renzheng)
Fk:loadTranslationTable{
  ["sxfy__luotong"] = "骆统",
  ["#sxfy__luotong"] = "蹇谔匪躬",
  ["illustrator:sxfy__luotong"] = "李敏然",

  ["sxfy__jinjian"] = "进谏",
  [":sxfy__jinjian"] = "每回合各限一次，当你受到/造成伤害时，你可以防止此伤害，然后你本回合下次受到/造成的伤害+1。",
  ["sxfy__renzheng"] = "仁政",
  [":sxfy__renzheng"] = "锁定技，当有伤害被防止时，你令当前回合角色摸一张牌。",
  ["#sxfy__jinjian1-invoke"] = "进谏：是否防止你对 %dest 造成的伤害，本回合你下次造成伤害+1？",
  ["#sxfy__jinjian2-invoke"] = "进谏：是否防止你受到的伤害，本回合你下次受到伤害+1？",
  ["@@sxfy__jinjian1-turn"] = "造成伤害+1",
  ["@@sxfy__jinjian2-turn"] = "受到伤害+1",
}

local yanghu = General(extension, "sxfy__yanghu", "wei", 4)
local sxfy__mingfa = fk.CreateActiveSkill{
  name = "sxfy__mingfa",
  anim_type = "support",
  card_num = 0,
  target_num = 1,
  prompt = "#sxfy__mingfa",
  can_use = Util.TrueFunc,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and Fk:currentRoom():getPlayerById(to_select).hp > 1
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:setPlayerMark(player, self.name, target.id)
    room:invalidateSkill(player, self.name)
    room:damage{
      from = player,
      to = target,
      damage = 1,
      skillName = self.name,
    }
  end,
}
local sxfy__mingfa_trigger = fk.CreateTriggerSkill{
  name = "#sxfy__mingfa_trigger",

  refresh_events = {fk.Deathed, fk.HpRecover},
  can_refresh = function(self, event, target, player, data)
    return player:getMark("sxfy__mingfa") == target.id
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:validateSkill(player, self.name)
    room:setPlayerMark(player, self.name, 0)
  end,
}
sxfy__mingfa:addRelatedSkill(sxfy__mingfa_trigger)
yanghu:addSkill(sxfy__mingfa)
Fk:loadTranslationTable{
  ["sxfy__yanghu"] = "羊祜",
  ["#sxfy__yanghu"] = "制紘同轨",
  ["illustrator:sxfy__yanghu"] = "芝芝不加糖",

  ["sxfy__mingfa"] = "明伐",
  [":sxfy__mingfa"] = "出牌阶段，你可以对一名体力值大于1的角色造成1点伤害，然后此技能失效直到其死亡或回复体力。",
  ["#sxfy__mingfa"] = "明伐：对一名体力值大于1的角色造成1点伤害",

  ["$sxfy__mingfa1"] = "以诚相待，吴人倾心，攻之必克。",
  ["$sxfy__mingfa2"] = "以强击弱，易如反掌，何须诡诈？",
  ["~sxfy__yanghu"] = "憾东吴尚存，天下未定也。",
}

local lvlingqi = General(extension, "sxfy__lvlingqi", "qun", 4, 4, General.Female)
local sxfy__huiji = fk.CreateTriggerSkill{
  name = "sxfy__huiji",
  anim_type = "offensive",
  events = {fk.AfterCardTargetDeclared},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card.trueName == "slash" and
      #player.room:getUseExtraTargets(data) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = room:getUseExtraTargets(data)
    local tos = room:askForChoosePlayers(player, targets, 1, 2, "#sxfy__huiji-choose:::"..data.card:toLogString(), self.name, true)
    if #tos > 0 then
      self.cost_data = tos
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    for _, id in ipairs(self.cost_data) do
      table.insert(data.tos, {id})
    end
    data.extra_data = data.extra_data or {}
    data.extra_data.sxfy__huiji = true
  end,
}
local sxfy__huiji_delay = fk.CreateTriggerSkill{
  name = "#sxfy__huiji_delay",
  mute = true,
  events = {fk.AskForCardUse},
  can_trigger = function(self, event, target, player, data)
    if target == player and
      (data.cardName == "jink" or (data.pattern and Exppattern:Parse(data.pattern):matchExp("jink|0|nosuit|none"))) and
      (data.extraData == nil or data.extraData.sxfy__huiji_ask == nil) then
      local e = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
      if e then
        local use = e.data[1]
        if use.card.trueName == "slash" and use.extra_data and use.extra_data.sxfy__huiji then
          local targets =  table.filter(TargetGroup:getRealTargets(use.tos), function (id)
            return id ~= player.id and not player.room:getPlayerById(id).dead
          end)
          if #targets > 0 then
            self.cost_data = targets
            return true
          end
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, "sxfy__huiji", nil, "#sxfy__huiji-invoke")
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {self.cost_data})
    for _, id in ipairs(self.cost_data) do
      local p = room:getPlayerById(id)
      if not p.dead then
        local cardResponded = room:askForResponse(p, "jink", "jink", "#sxfy__huiji-ask:"..player.id, true, {sxfy__huiji_ask = true})
        if cardResponded then
          room:responseCard({
            from = p.id,
            card = cardResponded,
            skipDrop = true,
          })

            data.result = {
              from = player.id,
              card = Fk:cloneCard('jink'),
            }
            data.result.card:addSubcards(room:getSubcardsByRule(cardResponded, { Card.Processing }))
            data.result.card.skillName = "sxfy__huiji"

            if data.eventData then
              data.result.toCard = data.eventData.toCard
              data.result.responseToEvent = data.eventData.responseToEvent
            end
          return true
        end
      end
    end
  end,
}
sxfy__huiji:addRelatedSkill(sxfy__huiji_delay)
lvlingqi:addSkill(sxfy__huiji)
Fk:loadTranslationTable{
  ["sxfy__lvlingqi"] = "吕玲绮",
  ["#sxfy__lvlingqi"] = "无双虓姬",
  ["illustrator:sxfy__lvlingqi"] = "木美人",

  ["sxfy__huiji"] = "挥戟",
  [":sxfy__huiji"] = "你使用【杀】可以额外指定至多两名角色为目标，若如此做，此【杀】的目标角色可以令其他目标角色选择是否代替其使用【闪】"..
  "来抵消此【杀】。",
  ["#sxfy__huiji-choose"] = "挥戟：你可以为%arg增加至多两个目标",
  ["#sxfy__huiji_delay"] = "挥戟",
  ["#sxfy__huiji-invoke"] = "挥戟：是否令其他目标角色选择代替你使用【闪】？",
  ["#sxfy__huiji-ask"] = "挥戟：你可以替 %src 使用【闪】",
}

local zhouchu = General(extension, "sxfy__zhouchu", "wu", 4)
local sxfy__xiongxia = fk.CreateActiveSkill{
  name = "sxfy__xiongxia",
  anim_type = "offensive",
  card_num = 2,
  target_num = 2,
  prompt = "#sxfy__xiongxia",
  can_use = Util.TrueFunc,
  card_filter = function(self, to_select, selected, selected_targets)
    return #selected < 2
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    if #selected_cards == 2 then
      local card = Fk:cloneCard("duel")
      card:addSubcards(selected_cards)
      card.skillName = self.name
      return card.skill:canUse(Self, card) and card.skill:modTargetFilter(to_select, selected, Self.id, card) and
        not Self:prohibitUse(card) and not Self:isProhibited(Fk:currentRoom():getPlayerById(to_select), card)
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:sortPlayersByAction(effect.tos)
    local use = room:useVirtualCard("duel", effect.cards, player, table.map(effect.tos, Util.Id2PlayerMapper), self.name)
    if use and use.damageDealt and use.damageDealt[effect.tos[1]] and use.damageDealt[effect.tos[2]] and not player.dead then
      room:invalidateSkill(player, self.name, "-turn")
    end
  end,
}
zhouchu:addSkill(sxfy__xiongxia)
Fk:loadTranslationTable{
  ["sxfy__zhouchu"] = "周处",
  ["#sxfy__zhouchu"] = "英情天逸",
  ["illustrator:sxfy__zhouchu"] = "西国红云&zoo",

  ["sxfy__xiongxia"] = "凶侠",
  [":sxfy__xiongxia"] = "出牌阶段，你可以将两张牌当【决斗】对两名其他角色使用，然后此牌结算结束后，若此牌对所有目标角色均造成过伤害，此技能"..
  "本回合失效。",
  ["#sxfy__xiongxia"] = "凶侠：你可以将两张牌当【决斗】对两名其他角色使用",
}

return extension
