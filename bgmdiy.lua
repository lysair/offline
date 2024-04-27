local extension = Package("bgmdiy")
extension.extensionName = "offline"

Fk:loadTranslationTable{
  ["bgmdiy"] = "桌游志贴纸",
  ["bgm"] = "桌游志",
}

local U = require "packages/utility/utility"

local simazhao = General(extension, "bgm__simazhao", "wei", 3)

local bgm__zhaoxin = fk.CreateTriggerSkill{
  name = "bgm__zhaoxin",
  events = {fk.EventPhaseEnd},
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Draw and not player:isKongcheng()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:showCards(player.player_cards[Player.Hand])
    U.askForUseVirtualCard(room, player, "slash", nil, self.name, nil, false, true, true, true)
  end,
}
simazhao:addSkill(bgm__zhaoxin)

local langgu = fk.CreateTriggerSkill{
  name = "langgu",
  anim_type = "masochism",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self)
  end,
  on_trigger = function(self, event, target, player, data)
    self.cancel_cost = false
    for i = 1, data.damage do
      if self.cancel_cost or not player:hasSkill(self) then break end
      self:doCost(event, target, player, data)
    end
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askForSkillInvoke(player, self.name, data) then
      return true
    end
    self.cancel_cost = true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local judge = {
      who = player,
      reason = self.name,
      pattern = ".",
    }
    room:judge(judge)
    if player.dead or not data.from or data.from:isKongcheng() then return end
    room:doIndicate(player.id, {data.from.id})
    local all = data.from:getCardIds("h")
    local cards = table.filter(all, function(id) return Fk:getCardById(id).suit == judge.card.suit end)
    local throw, choice = U.askforChooseCardsAndChoice(player, cards, {"OK"}, self.name, "#langgu-card", {"langgu_all", "Cancel"},
    1, #cards, all)
    if choice == "langgu_all" then
      throw = cards
    end
    if #throw > 0 then
      room:throwCard(throw, self.name, data.from, player)
    end
  end,
}
local langgu_delay = fk.CreateTriggerSkill{
  name = "#langgu_delay",
  mute = true,
  events = {fk.AskForRetrial},
  can_trigger = function(self, event, target, player, data)
    return data.reason == "langgu" and player == data.who and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local prompt = "#langgu-ask:::" .. data.card:toLogString()
    local ids = table.filter(player:getCardIds("h"), function(id) return not player:prohibitResponse(Fk:getCardById(id)) end)
    local card = player.room:askForCard(player, 1, 1, false, "langgu", true, tostring(Exppattern{ id = ids }), prompt)
    if #card > 0 then
      self.cost_data = card[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:retrial(Fk:getCardById(self.cost_data), player, data, "langgu")
  end,
}
langgu:addRelatedSkill(langgu_delay)
simazhao:addSkill(langgu)

Fk:loadTranslationTable{
  ["bgm__simazhao"] = "司马昭",
  ["#bgm__simazhao"] = "狼子野心",
	["designer:bgm__simazhao"] = "尹昭晨",
	["illustrator:bgm__simazhao"] = "YellowKiss",

  ["bgm__zhaoxin"] = "昭心",
  [":bgm__zhaoxin"] = "摸牌阶段结束时，你可以展示所有手牌：若如此做，视为你使用一张【杀】。",
  ["langgu"] = "狼顾",
  [":langgu"] = "每当你受到1点伤害后，你可以进行判定且你可以打出一张手牌代替此判定牌，若如此做，你观看伤害来源的所有手牌，然后你可以弃置其中任意张与判定结果花色相同的牌。 ",
  ["#langgu-ask"] = "狼顾：你可以打出一张手牌代替判定牌 %arg",
  ["#langgu-card"] = "狼顾：选择要弃置的牌",
  ["langgu_all"] = "全部弃置",
}

local wangyuanji = General(extension, "bgm__wangyuanji", "wei", 3, 3, General.Female)

local fuluan = fk.CreateActiveSkill{
  name = "fuluan",
  anim_type = "control",
  prompt = "#fuluan",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and player:getMark("fuluan-phase") == 0
  end,
  card_num = 3,
  card_filter = function(self, to_select, selected)
    if #selected < 3 and not Self:prohibitDiscard(Fk:getCardById(to_select)) then
      return table.every(selected, function (id)
        return Fk:getCardById(id).suit == Fk:getCardById(to_select).suit
      end)
    end
  end,
  target_num = 1,
  target_filter = function(self, to_select, selected, cards)
    return #cards == 3 and #selected == 0 and Self:inMyAttackRange(Fk:currentRoom():getPlayerById(to_select))
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local to = room:getPlayerById(effect.tos[1])
    room:setPlayerMark(player, "@@fuluan-turn", 1)
    room:throwCard(effect.cards, self.name, player, player)
    if not to.dead then
      to:turnOver()
    end
  end,
}
local fuluan_record = fk.CreateTriggerSkill{
  name = "#fuluan_record",
  refresh_events = {fk.EventAcquireSkill, fk.AfterCardUseDeclared},
  can_refresh = function(self, event, target, player, data)
    if player.phase ~= Player.Play or player:getMark("fuluan_record") > 0 then return end
    if target == player and player:hasSkill(fuluan, true) then
      if event == fk.EventAcquireSkill then
        return data == self and target == player
      else
        return data.card.trueName == "slash"
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.EventAcquireSkill then
      if #room.logic:getEventsOfScope(GameEvent.UseCard, 1, function(e)
        local use = e.data[1]
        return use.from == player.id and use.card.trueName == "slash"
      end, Player.HistoryPhase) == 0 then return end
    end
    room:setPlayerMark(player, "fuluan-phase", 1)
  end,
}
fuluan:addRelatedSkill(fuluan_record)
local fuluan_prohibit = fk.CreateProhibitSkill{
  name = "#fuluan_prohibit",
  prohibit_use = function(self, player, card)
    return player:getMark("@@fuluan-turn") > 0 and card and card.trueName == "slash"
  end,
}
fuluan:addRelatedSkill(fuluan_prohibit)
wangyuanji:addSkill(fuluan)

local shude = fk.CreateTriggerSkill{
  name = "shude",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target == player and player.phase == Player.Finish and player:getHandcardNum() < player.maxHp
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(player.maxHp - player:getHandcardNum(), self.name)
  end,
}
wangyuanji:addSkill(shude)

Fk:loadTranslationTable{
  ["bgm__wangyuanji"] = "王元姬",
  ["#bgm__wangyuanji"] = "文明皇后",
	["designer:bgm__wangyuanji"] = "尹昭晨",
	["illustrator:bgm__wangyuanji"] = "YellowKiss",

  ["fuluan"] = "扶乱",
  [":fuluan"] = "出牌阶段限一次，若你未于本阶段使用过【杀】，你可以弃置三张相同花色的牌并选择攻击范围内的一名角色：若如此做，该角色将武将牌翻面，你不能使用【杀】直到回合结束。 ",
  ["#fuluan"] = "扶乱：弃置三张相同花色的牌，令攻击范围内一名角色翻面",
  ["@@fuluan-turn"] = "扶乱",
  ["shude"] = "淑德",
  [":shude"] = "结束阶段开始时，你可以将手牌补至体力上限。",
}

local gongsunzan = General(extension, "bgm__gongsunzan", "qun", 4)
local yicong = fk.CreateTriggerSkill{
  name = "bgm__yicong",
  events = {fk.EventPhaseEnd},
  derived_piles = "bgm_follower",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target == player and player.phase == Player.Discard and not player:isNude()
  end,
  on_cost = function (self, event, target, player, data)
    local cards = player.room:askForCard(player, 1, 9999, true, self.name, true, ".", "#bgm__yicong-cost")
    if #cards > 0 then
      self.cost_data = cards
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player:addToPile("bgm_follower", self.cost_data, true, self.name)
  end,
}
local yicong_distance = fk.CreateDistanceSkill{
  name = "#bgm__yicong_distance",
  correct_func = function(self, from, to)
    if to:hasSkill(yicong) then
      return #to:getPile("bgm_follower")
    end
  end,
}
yicong:addRelatedSkill(yicong_distance)
gongsunzan:addSkill(yicong)

local tuqi = fk.CreateTriggerSkill{
  name = "tuqi",
  events = {fk.EventPhaseStart},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target == player and player.phase == Player.Start and #player:getPile("bgm_follower") > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = player:getPile("bgm_follower")
    room:moveCards({
      ids = cards,
      from = player.id,
      toArea = Card.DiscardPile,
      moveReason = fk.ReasonPutIntoDiscardPile,
      skillName = self.name,
      proposer = player.id,
    })
    room:addPlayerMark(player, "tuqi-turn", #cards)
    if not player.dead and #cards <= 2 then
      player:drawCards(1, self.name)
    end
  end,
}
local tuqi_distance = fk.CreateDistanceSkill{
  name = "#bgm__tuqi_distance",
  correct_func = function(self, from, to)
    return - from:getMark("tuqi-turn")
  end,
}
tuqi:addRelatedSkill(tuqi_distance)
gongsunzan:addSkill(tuqi)

Fk:loadTranslationTable{
  ["bgm__gongsunzan"] = "公孙瓒",
  ["#bgm__gongsunzan"] = "白马将军",
	["designer:bgm__gongsunzan"] = "爱放泡的鱼",
	["illustrator:bgm__gongsunzan"] = "XXX",

  ["bgm__yicong"] = "义从",
  [":bgm__yicong"] = "弃牌阶段结束时，你可以将至少一张牌置于武将牌上，称为“扈”。其他角色与你的距离+X。（X为“扈”的数量）",
  ["bgm_follower"] = "扈",
  ["#bgm__yicong-cost"] = "义从：你可以将至少一张牌置于武将牌上称为“扈”",
  ["tuqi"] = "突骑",
  [":tuqi"] = "锁定技，准备阶段开始时，若你的武将牌上有“扈”，你将所有“扈”置入弃牌堆，本回合你与其他角色的距离-X，若X小于或等于2，你摸一张牌。（X为以此法置入弃牌堆的“扈”的数量）",
}


return extension
