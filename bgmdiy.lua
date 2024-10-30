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
    math.min(#cards, 1), #cards, all)
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

local liuxie = General(extension, "bgm__liuxie", "qun", 4)

local huangen = fk.CreateTriggerSkill{
  name = "huangen",
  anim_type = "defensive",
  events = {fk.TargetSpecifying},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and data.firstTarget and player.hp > 0 and
    data.card.type == Card.TypeTrick and #AimGroup:getAllTargets(data.tos) > 1
  end,
  on_cost = function(self, event, target, player, data)
    local tos = player.room:askForChoosePlayers(player, AimGroup:getAllTargets(data.tos), 1, player.hp, "#huangen-choose:::"..player.hp, self.name, true)
    if #tos > 0 then
      player.room:sortPlayersByAction(tos)
      self.cost_data = tos
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, pid in ipairs(self.cost_data) do
      AimGroup:cancelTarget(data, pid)
      local p = room:getPlayerById(pid)
      if not p.dead then
        p:drawCards(1, self.name)
      end
    end
    return table.contains(self.cost_data, data.to)
  end,
}
liuxie:addSkill(huangen)

local hantong = fk.CreateActiveSkill{
  name = "hantong",
  card_num = 1,
  target_num = 0,
  prompt = "#hantong-active",
  expand_pile = "bgm_edict",
  derived_piles = "bgm_edict",
  interaction = function(self)
    local names = table.filter({"jijiang","hujia","xueyi","jiuyuan"}, function (skill)
      return not Self:hasSkill(skill, true)
    end)
    if #names > 0 then
      return UI.ComboBox { choices = names }
    end
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Self:getPileNameOfId(to_select) == "bgm_edict"
  end,
  can_use = function(self, player)
    return #player:getPile("bgm_edict") > 0 and table.find({"jijiang","hujia","xueyi","jiuyuan"}, function (skill)
      return not player:hasSkill(skill, true)
    end)
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:moveCards({
      ids = effect.cards,
      from = player.id,
      toArea = Card.DiscardPile,
      moveReason = fk.ReasonPutIntoDiscardPile,
      skillName = self.name,
      proposer = player.id,
    })
    if player.dead then return end
    local skill = self.interaction.data
    room:handleAddLoseSkills(player, skill)
    room.logic:getCurrentEvent():findParent(GameEvent.Turn):addCleaner(function()
      room:handleAddLoseSkills(player, "-"..skill)
    end)
    player:broadcastSkillInvoke(skill)
  end,
}
local hantong_trigger = fk.CreateTriggerSkill{
  name = "#hantong_trigger",
  events = {fk.EventPhaseEnd, fk.EventPhaseStart, fk.AskForCardUse, fk.AskForCardResponse, fk.PreHpRecover},
  mute = true,
  main_skill = hantong,
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(hantong)) then return end
    if event == fk.EventPhaseEnd then
      if player.phase == Player.Discard then
        local ids = {}
        local logic = player.room.logic
        logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
          for _, move in ipairs(e.data) do
            if move.from == player.id and move.moveReason == fk.ReasonDiscard and move.skillName == "phase_discard" then
              for _, info in ipairs(move.moveInfo) do
                if player.room:getCardArea(info.cardId) == Card.DiscardPile then
                  table.insertIfNeed(ids, info.cardId)
                end
              end
            end
          end
          return false
        end, Player.HistoryPhase)
        if #ids > 0 then
          self.cost_data = ids
          return true
        end
      end
    elseif #player:getPile("bgm_edict") > 0 then
      if event == fk.PreHpRecover then
        if not player:hasSkill("jiuyuan", true) and data.card and data.card.trueName == "peach" and
        data.recoverBy and data.recoverBy.kingdom == "wu" and data.recoverBy ~= player then
          self.cost_data = {"jiuyuan"}
          return true
        end
      elseif event == fk.EventPhaseStart then
        if not player:hasSkill("xueyi", true) and player.phase == Player.Discard
        and table.find(player.room.alive_players, function (p) return p ~= player and p.kingdom == "qun" end) then
          self.cost_data = {"xueyi"}
          return true
        end
      else
        local list = {}
        if not player:hasSkill("hujia", true) and (data.extraData == nil or data.extraData.hujia_ask == nil)
          and (data.cardName == "jink" or (data.pattern and Exppattern:Parse(data.pattern):matchExp("jink|0|nosuit|none")))
          and table.find(player.room.alive_players, function (p) return p ~= player and p.kingdom == "wei" end) then
          table.insert(list, "hujia")
        end
        if not player:hasSkill("jijiang", true)
          and (data.cardName == "slash" or (data.pattern and Exppattern:Parse(data.pattern):matchExp("slash|0|nosuit|none")))
          and table.find(player.room.alive_players, function (p) return p ~= player and p.kingdom == "shu" end) then
          table.insert(list, "jijiang")
        end
        if #list > 0 then
          self.cost_data = list
          return true
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if event == fk.EventPhaseEnd then
      return room:askForSkillInvoke(player, self.name, nil, "#hantong-invoke")
    else
      local x = 1
      local prompt = "#hantong-cost:::"..self.cost_data[1]
      if #self.cost_data > 1 then
        prompt = "#hantong-two"
        x = 2
      end
      local cards = room:askForCard(player, 1, x, false, self.name, true, ".|.|.|bgm_edict", prompt, "bgm_edict")
      if #cards > 0 then
        local choices = (#cards == #self.cost_data) and self.cost_data or
        {room:askForChoice(player, self.cost_data, self.name, "#hantong-choice")}
        self.cost_data = {cards, choices}
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.EventPhaseEnd then
      player:addToPile("bgm_edict", self.cost_data, true, self.name)
    else
      room:moveCards({
        ids = self.cost_data[1],
        from = player.id,
        toArea = Card.DiscardPile,
        moveReason = fk.ReasonPutIntoDiscardPile,
        skillName = self.name,
        proposer = player.id,
      })
      if player.dead then return end
      local skills = self.cost_data[2]
      room:handleAddLoseSkills(player, table.concat(skills, "|"))
      room.logic:getCurrentEvent():findParent(GameEvent.Turn):addCleaner(function()
        room:handleAddLoseSkills(player, "-"..table.concat(skills, "|-"))
      end)
    end
  end,
}
hantong:addRelatedSkill(hantong_trigger)
liuxie:addSkill(hantong)

Fk:loadTranslationTable{
  ["bgm__liuxie"] = "刘协",
  ["#bgm__liuxie"] = "汉献帝",
  ["designer:bgm__liuxie"] = "姚以轩",
  ["illustrator:bgm__liuxie"] = "XXX",

  ["huangen"] = "皇恩",
  [":huangen"] = "当锦囊牌指定指定多于一个目标时，你可以取消至多X个目标（X为你的体力值），然后这些角色各摸一张牌。",
  ["#huangen-choose"] = "皇恩：你可以取消至多 %arg 的目标，并令这些角色各摸一张牌",
  ["hantong"] = "汉统",
  [":hantong"] = "弃牌阶段结束时，你可以将此阶段内你因游戏规则弃置的牌置于武将牌上，称为“诏”。你可以移去一张“诏”，获得〖护驾〗，〖激将〗，〖救援〗或〖血裔〗直到回合结束。 ",
  ["bgm_edict"] = "诏",
  ["#hantong-active"] = "汉统：你可以移去一张“诏”，本回合获得〖护驾〗，〖激将〗，〖救援〗或〖血裔〗",
  ["#hantong-invoke"] = "汉统：你可以将此阶段内弃置的牌置于武将牌上称为“诏”",
  ["#hantong-cost"] = "汉统：你可以移去一张“诏”，获得〖%arg〗直到回合结束",
  ["#hantong-two"] = "汉统：你可以移去至多两张“诏”，获得〖护驾〗或〖激将〗直到回合结束",
  ["#hantong-choice"] = "汉统：选择你要获得的技能",
  ["#hantong_trigger"] = "汉统",
}


return extension
