local extension = Package("sxfy_shaoyang")
extension.extensionName = "offline"

local U = require "packages/utility/utility"

Fk:loadTranslationTable{
  ["sxfy_shaoyang"] = "四象封印-少阳",
}

local zhangbaos = General(extension, "sxfy__zhangbaos", "shu", 4)
local juezhu = fk.CreateTriggerSkill{
  name = "sxfy__juezhu",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.Damage, fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) then
      if event == fk.Damage then
        return true
      else
        return data.from and not data.from.dead and data.from ~= player
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.Damage then
      room:setPlayerMark(player, "sxfy__juezhu-turn", 1)
    else
      room:useVirtualCard("duel", nil, player, data.from, self.name)
    end
  end,
}
local juezhu_targetmod = fk.CreateTargetModSkill{
  name = "#sxfy__juezhu_targetmod",
  bypass_times = function(self, player, skill, scope, card, to)
    return card and player:getMark("sxfy__juezhu-turn") > 0
  end,
}
local chengjiz = fk.CreateViewAsSkill{
  name = "sxfy__chengjiz",
  anim_type = "offensive",
  pattern = "slash",
  prompt = "#sxfy__chengjiz",
  handly_pile = true,
  card_filter = function(self, to_select, selected)
    if #selected == 0 then
      return true
    elseif #selected == 1 then
      return Fk:getCardById(to_select):compareColorWith(Fk:getCardById(selected[1]), true)
    end
  end,
  view_as = function(self, cards)
    if #cards ~= 2 then return end
    local c = Fk:cloneCard("slash")
    c.skillName = self.name
    c:addSubcards(cards)
    return c
  end,
}
juezhu:addRelatedSkill(juezhu_targetmod)
zhangbaos:addSkill(juezhu)
zhangbaos:addSkill(chengjiz)
Fk:loadTranslationTable{
  ["sxfy__zhangbaos"] = "张苞",
  ["#sxfy__zhangbaos"] = "虎翼将军",
  ["illustrator:sxfy__zhangbaos"] = "DEEMO",

  ["sxfy__juezhu"] = "角逐",
  [":sxfy__juezhu"] = "锁定技，当你造成伤害后，你本回合使用牌无次数限制；当你受到伤害后，你视为对伤害来源使用一张【决斗】。",
  ["sxfy__chengjiz"] = "承继",
  [":sxfy__chengjiz"] = "你可以将两张颜色不同的牌当【杀】使用或打出。",
  ["#sxfy__chengjiz"] = "承继：你可以将两张颜色不同的牌当【杀】使用或打出",
}

local liuchen = General(extension, "sxfy__liuchen", "shu", 4)
local zhanjue = fk.CreateViewAsSkill{
  name = "sxfy__zhanjue",
  anim_type = "offensive",
  prompt = "#sxfy__zhanjue",
  card_filter = Util.FalseFunc,
  view_as = function(self, cards)
    local card = Fk:cloneCard("duel")
    card:addSubcards(Self:getCardIds("h"))
    return card
  end,
  after_use = function(self, player, use)
    if not player.dead then
      player:drawCards(1, self.name)
    end
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end
}
local qinwang = fk.CreateViewAsSkill{
  name = "sxfy__qinwang$",
  pattern = "slash",
  anim_type = "defensive",
  prompt = "#sxfy__qinwang",
  card_filter = Util.FalseFunc,
  before_use = function(self, player, use)
    local room = player.room
    local yes = false
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if p.kingdom == "shu" then
        local card = room:askForDiscard(p, 1, 1, false, self.name, true, ".|.|.|.|.|basic", "#sxfy__qinwang-ask:"..player.id)
        if #card > 0 then
          yes = true
          break
        end
      end
    end
    if not yes then
      room:setPlayerMark(player, "sxfy__qinwang_failed-phase", 1)
      room.logic:getCurrentEvent():addCleaner(function()
        room:setPlayerMark(player, "sxfy__qinwang_failed-phase", 0)
      end)
      return self.name
    end
  end,
  view_as = function(self, cards)
    local card = Fk:cloneCard("slash")
    card.skillName = self.name
    return card
  end,
  enabled_at_play = Util.FalseFunc,
  enabled_at_response = function(self, player, response)
    return response and player:getMark("sxfy__qinwang_failed-phase") == 0 and
      table.find(Fk:currentRoom().alive_players, function(p)
        return p ~= player and p.kingdom == "shu" and not p:isKongcheng()
      end)
  end,
}
liuchen:addSkill(zhanjue)
liuchen:addSkill(qinwang)
Fk:loadTranslationTable{
  ["sxfy__liuchen"] = "刘谌",
  ["#sxfy__liuchen"] = "北地王",
  ["illustrator:sxfy__liuchen"] = "石蝉",

  ["sxfy__zhanjue"] = "战绝",
  [":sxfy__zhanjue"] = "出牌阶段限一次，你可以将所有手牌当【决斗】使用，然后你摸一张牌。",
  ["sxfy__qinwang"] = "勤王",
  [":sxfy__qinwang"] = "主公技，当你需打出【杀】时，其他蜀势力角色可以弃置一张基本牌，视为你打出一张【杀】。",
  ["#sxfy__zhanjue"] = "战绝：你可以将所有手牌当【决斗】使用，然后摸一张牌",
  ["#sxfy__qinwang"] = "勤王：令其他蜀势力角色选择是否弃置一张基本牌，视为你打出一张【杀】",
  ["#sxfy__qinwang-ask"] = "勤王：是否弃置一张基本牌，视为 %src 打出一张【杀】？",
}

local dingfeng = General(extension, "sxfy__dingfeng", "wu", 4)
local fenxun = fk.CreateActiveSkill{
  name = "sxfy__fenxun",
  anim_type = "offensive",
  card_num = 1,
  target_num = 1,
  prompt = "#sxfy__fenxun",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).sub_type == Card.SubtypeArmor and
      not Self:prohibitDiscard(Fk:getCardById(to_select))
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:throwCard(effect.cards, self.name, player, player)
    if player.dead or target.dead then return end
    room:addTableMark(player, "sxfy__fenxun-turn", target.id)
  end,
}
local fenxun_attackrange = fk.CreateAttackRangeSkill{
  name = "#sxfy__fenxun_attackrange",
  within_func = function (self, from, to)
    return from:getMark("sxfy__fenxun-turn") ~= 0 and table.contains(from:getTableMark("sxfy__fenxun-turn"), to.id)
  end,
}
local duanbing = fk.CreateTriggerSkill{
  name = "sxfy__duanbing",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.DamageCaused},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card and data.card.trueName == "slash" and
      player:usedSkillTimes(self.name, Player.HistoryTurn) == 0 and
        #player.room.logic:getActualDamageEvents(1, function(e)
          local damage = e.data[1]
          return damage.from == player and damage.card and damage.card.trueName == "slash"
        end) == 0
  end,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage + 1
  end,
}
local duanbing_attackrange = fk.CreateAttackRangeSkill{
  name = "#sxfy__duanbing_attackrange",
  frequency = Skill.Compulsory,
  correct_func = function (self, from, to)
    if from:hasSkill(duanbing) then
      local baseValue = 1
      local weapons = from:getEquipments(Card.SubtypeWeapon)
      if #weapons > 0 then
        baseValue = 0
        for _, id in ipairs(weapons) do
          local weapon = Fk:getCardById(id)
          baseValue = math.max(baseValue, weapon:getAttackRange(from) or 1)
        end
      end

      local status_skills = Fk:currentRoom().status_skills[AttackRangeSkill] or Util.DummyTable
      local max_fixed, correct = nil, 0
      for _, skill in ipairs(status_skills) do
        if skill ~= self then
          local f = skill:getFixed(from)
          if f ~= nil then
            max_fixed = max_fixed and math.max(max_fixed, f) or f
          end
          local c = skill:getCorrect(from)
          correct = correct + (c or 0)
        end
      end

      return 1 - math.max(math.max(baseValue, (max_fixed or 0)) + correct, 0)
    end
  end,
}
duanbing:addRelatedSkill(duanbing_attackrange)
fenxun:addRelatedSkill(fenxun_attackrange)
dingfeng:addSkill(duanbing)
dingfeng:addSkill(fenxun)
Fk:loadTranslationTable{
  ["sxfy__dingfeng"] = "丁奉",
  ["#sxfy__dingfeng"] = "寸短寸险",
  ["illustrator:sxfy__dingfeng"] = "Zero",

  ["sxfy__duanbing"] = "短兵",
  [":sxfy__duanbing"] = "锁定技，你的攻击范围始终为1，你使用【杀】每回合首次造成的伤害+1。",
  ["sxfy__fenxun"] = "奋迅",
  [":sxfy__fenxun"] = "出牌阶段限一次，你可以弃置一张防具牌并选择一名其他角色，其本回合视为在你的攻击范围内。",
  ["#sxfy__fenxun"] = "奋迅：弃置一张防具牌，令一名角色本回合视为在你的攻击范围内",
}

local sunluban = General(extension, "sxfy__sunluban", "wu", 3, 3, General.Female)
local zenhui = fk.CreateTriggerSkill{
  name = "sxfy__zenhui",
  anim_type = "control",
  events = {fk.CardUsing},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and (data.card.trueName == "slash" or data.card.type == Card.TypeTrick) and
      table.find(player.room:getOtherPlayers(player, false), function (p)
        return not data.tos or not table.contains(TargetGroup:getRealTargets(data.tos), p.id)
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player, false), function (p)
      return not data.tos or not table.contains(TargetGroup:getRealTargets(data.tos), p.id)
    end)
    local to = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 1,
      "#sxfy__zenhui-choose:::"..data.card:toLogString(), self.name, true)
    if #to > 0 then
      self.cost_data = {tos = to}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    data.from = self.cost_data.tos[1]
  end,
}
local chuyi = fk.CreateTriggerSkill{
  name = "sxfy__chuyi",
  anim_type = "offensive",
  events = {fk.DamageCaused},
  can_trigger = function(self, event, target, player, data)
    return target and target ~= player and player:hasSkill(self) and player:inMyAttackRange(data.to) and
      player:usedSkillTimes(self.name, Player.HistoryRound) == 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#sxfy__chuyi-invoke::"..data.to.id)
  end,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage + 1
  end,
}
sunluban:addSkill(zenhui)
sunluban:addSkill(chuyi)
Fk:loadTranslationTable{
  ["sxfy__sunluban"] = "孙鲁班",
  ["#sxfy__sunluban"] = "为虎作伥",
  ["illustrator:sxfy__sunluban"] = "F.源",

  ["sxfy__zenhui"] = "谮毁",
  [":sxfy__zenhui"] = "当你使用【杀】或锦囊牌时，你可以令一名非目标角色成为此牌使用者。",
  ["sxfy__chuyi"] = "除异",
  [":sxfy__chuyi"] = "每轮限一次，当一名其他角色对你攻击范围内一名角色造成伤害时，你可以令此伤害+1。",
  ["#sxfy__zenhui-choose"] = "谮毁：你可以为你使用的%arg改变使用者",
  ["#sxfy__chuyi-invoke"] = "除异：是否令 %dest 受到的伤害+1？",
}

local liuzan = General(extension, "sxfy__liuzan", "wu", 4)
local fenyin = fk.CreateTriggerSkill{
  name = "sxfy__fenyin",
  anim_type = "drawcard",
  events = {fk.DrawNCards},
  on_use = function(self, event, target, player, data)
    data.n = data.n + 2
  end,
}
local fenyin_delay = fk.CreateTriggerSkill{
  name = "#sxfy__fenyin_delay",
  anim_type = "negative",
  events = {fk.CardUsing},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:usedSkillTimes("sxfy__fenyin", Player.HistoryTurn) > 0 and not player:isNude() and
      data.extra_data and data.extra_data.sxfy__fenyin
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:askForDiscard(player, 1, 1, true, "sxfy__fenyin", false)
  end,

  refresh_events = {fk.AfterCardUseDeclared},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:usedSkillTimes("sxfy__fenyin", Player.HistoryTurn) > 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local color = data.card:getColorString()
    if color == "nocolor" then
      room:setPlayerMark(player, "@sxfy__fenyin-turn", 0)
    else
      if color == player:getMark("@sxfy__fenyin-turn") then
        data.extra_data = data.extra_data or {}
        data.extra_data.sxfy__fenyin = true
      end
      room:setPlayerMark(player, "@sxfy__fenyin-turn", color)
    end
  end,
}
fenyin:addRelatedSkill(fenyin_delay)
liuzan:addSkill(fenyin)
Fk:loadTranslationTable{
  ["sxfy__liuzan"] = "留赞",
  ["#sxfy__liuzan"] = "啸天亢声",
  ["illustrator:sxfy__liuzan"] = "聚一",

  ["sxfy__fenyin"] = "奋音",
  [":sxfy__fenyin"] = "摸牌阶段，你可以多摸两张牌，若如此做，当你本回合使用牌时，若此牌与你本回合使用的上一张牌颜色相同，你须弃置一张牌。",
  ["#sxfy__fenyin_delay"] = "奋音",
  ["@sxfy__fenyin-turn"] = "奋音",
}

local sunyi = General(extension, "sxfy__sunyi", "wu", 4)
local zaoli = fk.CreateTriggerSkill{
  name = "sxfy__zaoli",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseStart},
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Start and not player:isNude()
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local choices = {}
    if not player:isKongcheng() and table.find(player:getCardIds("h"), function (id)
      return not player:prohibitDiscard(id)
    end) then
      table.insert(choices, "hand_card")
    end
    if #player:getCardIds("e") > 0 and table.find(player:getCardIds("e"), function (id)
      return not player:prohibitDiscard(id)
    end) then
      table.insert(choices, "$Equip")
    end
    local choice = "hand_card"
    if #choices == 1 then
      choice = choice[1]
    else
      choice = room:askForChoice(player, choices, self.name, "#sxfy__zaoli-choice", false, {"hand_card", "$Equip"})
    end
    local n = 0
    if choice == "hand_card" then
      n = #table.filter(player:getCardIds("h"), function (id)
        return not player:prohibitDiscard(id)
      end)
      player:throwAllCards("h")
    else
      n = #table.filter(player:getCardIds("e"), function (id)
        return not player:prohibitDiscard(id)
      end)
      player:throwAllCards("e")
    end
    if player.dead then return end
    n = n + player:getLostHp()
    if n > 0 then
      player:drawCards(n + player:getLostHp(), self.name)
    end
    if player.dead then return end
    room:loseHp(player, 1, self.name)
  end,
}
sunyi:addSkill(zaoli)
Fk:loadTranslationTable{
  ["sxfy__sunyi"] = "孙翊",
  ["#sxfy__sunyi"] = "骁悍激躁",
  ["illustrator:sxfy__sunyi"] = "simcity95",

  ["sxfy__zaoli"] = "躁厉",
  [":sxfy__zaoli"] = "锁定技，准备阶段，你须弃置所有手牌或装备区内的牌，然后摸等量的牌（每损失1点体力额外摸一张牌），然后你失去1点体力。",
  ["#sxfy__zaoli-choice"] = "躁厉：请选择弃置所有手牌或装备，摸等量（+已损失体力值）的牌",
}

local lvfan = General(extension, "sxfy__lvfan", "wu", 3)
local diaodu = fk.CreateTriggerSkill{
  name = "sxfy__diaodu",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Start and
      #player.room:canMoveCardInBoard("e") > 0
  end,
  on_cost = function(self, event, target, player, data)
    local tos = player.room:askForChooseToMoveCardInBoard(player, "#sxfy__diaodu-move", self.name, true, "e")
    if #tos == 2 then
      self.cost_data = {tos = tos}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(self.cost_data.tos, Util.Id2PlayerMapper)
    local result = room:askForMoveCardInBoard(player, targets[1], targets[2], self.name, "e")
    local to = room:getPlayerById(result.from)
    if not to.dead then
      to:drawCards(1, self.name)
    end
  end,
}
local diancai = fk.CreateTriggerSkill{
  name = "sxfy__diancai",
  anim_type = "drawcard",
  events = {fk.BeforeCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      local dat = {}
      for _, move in ipairs(data) do
        if move.from then
          dat[move.from] = dat[move.from] or {}
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerEquip then
              table.insertIfNeed(dat[move.from], info.cardId)
            end
          end
        end
      end
      local n = 0
      for id, cards in pairs(dat) do
        if #cards > 0 and #player.room:getPlayerById(id):getCardIds("e") == #cards then
          n = n + 1
        end
      end
      if n > 0 then
        self.cost_data = n
        return true
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    for i = 1, self.cost_data, 1 do
      if not player:hasSkill(self) then break end
      self:doCost(event, target, player, data)
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
  end,
}
lvfan:addSkill(diaodu)
lvfan:addSkill(diancai)
Fk:loadTranslationTable{
  ["sxfy__lvfan"] = "吕范",
  ["#sxfy__lvfan"] = "持筹廉悍",
  ["illustrator:sxfy__lvfan"] = "琛·美弟奇",

  ["sxfy__diaodu"] = "调度",
  [":sxfy__diaodu"] = "准备阶段，你可以移动一名角色装备区内的一张牌，然后其摸一张牌。",
  ["sxfy__diancai"] = "典财",
  [":sxfy__diancai"] = "当一名角色失去装备区内的最后一张牌时，你摸一张牌。",
  ["#sxfy__diaodu-move"] = "调度：你可以移动场上一张装备牌，失去装备的角色摸一张牌",
}

local xiahouba = General(extension, "sxfy__xiahouba", "shu", 4)
local baobian = fk.CreateTriggerSkill{
  name = "sxfy__baobian",
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Play and
      table.find(player.room:getOtherPlayers(player, false), function(p)
        return not p:isKongcheng()
      end)
  end,
  on_cost = function (self,event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player, false), function(p)
      return not p:isKongcheng()
    end)
    local to = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 1,
      "#sxfy__baobian-choose", self.name, true)
    if #to > 0 then
      self.cost_data = {tos = to}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:loseHp(player, 1, self.name)
    local to = room:getPlayerById(self.cost_data.tos[1])
    if to.dead or to:isKongcheng() then return end
    local card = room:askForDiscard(to, 1, 1, false, self.name, false, nil, "#sxfy__baobian-discard:"..player.id)
    if #card > 0 and Fk:getCardById(card[1]).type == Card.TypeBasic and not to.dead then
      room:useVirtualCard("slash", nil, player, to, self.name, true)
    end
  end,
}
xiahouba:addSkill(baobian)
Fk:loadTranslationTable{
  ["sxfy__xiahouba"] = "夏侯霸",
  ["#sxfy__xiahouba"] = "棘途壮志",
  ["illustrator:sxfy__xiahouba"] = "depp",

  ["sxfy__baobian"] = "豹变",
  [":sxfy__baobian"] = "出牌阶段开始时，你可以失去1点体力并指定一名其他角色，其需弃置一张手牌，若此牌为基本牌，你视为对其使用一张【杀】"..
  "（无距离次数限制）。",
  ["#sxfy__baobian-choose"] = "豹变：你可以失去1点体力，令一名角色弃置一张手牌，若为基本牌，视为对其使用【杀】",
  ["#sxfy__baobian-discard"] = "豹变：请弃置一张手牌，若为基本牌，视为 %src 对你使用【杀】！",
}

local taoqian = General(extension, "sxfy__taoqian", "qun", 4)
local yirang = fk.CreateTriggerSkill{
  name = "sxfy__yirang",
  anim_type = "support",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Play and
      not player:isKongcheng() and #player.room:getOtherPlayers(player, false) > 0
  end,
  on_cost = function (self,event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player, false), function (p)
      return table.every(room:getOtherPlayers(player, false), function (q)
        return q:getHandcardNum() >= p:getHandcardNum()
      end)
    end)
    local to = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 1,
      "#sxfy__yirang-choose", self.name, true)
    if #to > 0 then
      self.cost_data = {tos = to}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data.tos[1])
    local cards = player:getCardIds("h")
    local types = {}
    for _, id in ipairs(cards) do
      table.insertIfNeed(types, Fk:getCardById(id).type)
    end
    player:showCards(cards)
    if player.dead or to.dead then return end
    cards = table.filter(cards, function (id)
      return table.contains(player:getCardIds("h"), id)
    end)
    if #cards > 0 then
      room:moveCardTo(cards, Card.PlayerHand, to, fk.ReasonGive, self.name, nil, true, player.id)
    end
    if not player.dead then
      player:drawCards(#types, self.name)
    end
  end,
}
taoqian:addSkill(yirang)
Fk:loadTranslationTable{
  ["sxfy__taoqian"] = "陶谦",
  ["#sxfy__taoqian"] = "三让徐州",
  ["illustrator:sxfy__taoqian"] = "红字虾",

  ["sxfy__yirang"] = "揖让",
  [":sxfy__yirang"] = "出牌阶段开始时，你可以展示所有手牌，将这些牌交给一名手牌数最少的其他角色，然后你摸等同于交出类别数的牌。",
  ["#sxfy__yirang-choose"] = "揖让：你可以将所有手牌展示并交给手牌数最少的角色，你摸交出类别数的牌",
}

local jiling = General(extension, "sxfy__jiling", "qun", 4)
local shuangren = fk.CreateTriggerSkill{
  name = "sxfy__shuangren",
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Play and not player:isKongcheng() and
      table.find(player.room:getOtherPlayers(player, false), function(p)
        return player:canPindian(p)
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player, false), function(p)
        return player:canPindian(p)
      end)
    local to = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 1,
      "#sxfy__shuangren-choose", self.name, true)
    if #to > 0 then
      self.cost_data = {tos = to}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data.tos[1])
    local pindian = player:pindian({to}, self.name)
    if pindian.results[to.id].winner == player then
      if player.dead then return end
      local card = Fk:cloneCard("slash")
      card.skillName = self.name
      if player:prohibitUse(card) then return end
      local targets = table.filter(room:getOtherPlayers(player, false), function(p)
          return p:distanceTo(to) == 1 and not player:isProhibited(p, card)
        end)
      if #targets == 0 then return end
      local tos = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 2,
        "#sxfy__shuangren-use::"..to.id, self.name, true)
      if #tos > 0 then
        room:sortPlayersByAction(tos)
        for _, id in ipairs(tos) do
          if player.dead then return end
          local p = room:getPlayerById(id)
          if not p.dead then
            room:useVirtualCard("slash", nil, player, p, self.name, false)
          end
        end
      end
    else
      room:setPlayerMark(player, "sxfy__shuangren_fail-turn", 1)
    end
  end,
}
local shuangren_prohibit = fk.CreateProhibitSkill{
  name = "#sxfy__shuangren_prohibit",
  prohibit_use = function(self, player, card)
    return player:getMark("sxfy__shuangren_fail-turn") > 0 and card.trueName == "slash"
  end,
}
shuangren:addRelatedSkill(shuangren_prohibit)
jiling:addSkill(shuangren)
Fk:loadTranslationTable{
  ["sxfy__jiling"] = "纪灵",
  ["#sxfy__jiling"] = "仲帝大将",
  ["illustrator:sxfy__jiling"] = "YanBai",

  ["sxfy__shuangren"] = "双刃",
  [":sxfy__shuangren"] = "出牌阶段开始时，你可以与一名其他角色拼点，若你赢，你可以视为对其距离1的至多两名角色各使用一张【杀】"..
  "（无距离限制，计入次数）；若你没赢，你本回合不能使用【杀】。",
  ["#sxfy__shuangren-choose"] = "双刃：你可以拼点，若赢，视为对目标距离1的至多两名角色使用【杀】！",
  ["#sxfy__shuangren-use"] = "双刃：视为对 %dest 距离1的至多两名角色使用【杀】！",
}

local liru = General(extension, "sxfy__liru", "qun", 3)
local mieji = fk.CreateActiveSkill{
  name = "sxfy__mieji",
  anim_type = "control",
  card_num = 1,
  target_num = 1,
  prompt = "#sxfy__mieji",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, to_select, selected, targets)
    local card = Fk:getCardById(to_select)
    return #selected == 0 and card.type == Card.TypeTrick and card.color == Card.Black
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:moveCardTo(effect.cards, Card.PlayerHand, target, fk.ReasonGive, self.name, nil, true, player.id)
    if player.dead or target.dead or target:isNude() then return end
    local cards = room:askForCardsChosen(player, target, 0, 2, "he", self.name, "#sxfy__mieji-discard::"..target.id)
    if #cards > 0 then
      room:throwCard(cards, self.name, target, player)
    end
  end,
}
local juece = fk.CreateTriggerSkill{
  name = "sxfy__juece",
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and player.phase == Player.Finish then
      local dat = {}
      player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
        for _, move in ipairs(e.data) do
          if move.from then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
                dat[move.from] = (dat[move.from] or 0) + 1
              end
            end
          end
        end
      end, Player.HistoryTurn)
      local targets = {}
      for id, n in pairs(dat) do
        if n > 1 then
          table.insert(targets, id)
        end
      end
      if #targets > 0 then
        self.cost_data = targets
        return true
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askForChoosePlayers(player, self.cost_data, 1, 1, "#sxfy__juece-choose", self.name, true)
    if #to > 0 then
      self.cost_data = {tos = to}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:damage{
      from = player,
      to = player.room:getPlayerById(self.cost_data.tos[1]),
      damage = 1,
      skillName = self.name,
    }
  end,
}
liru:addSkill(mieji)
liru:addSkill(juece)
Fk:loadTranslationTable{
  ["sxfy__liru"] = "李儒",
  ["#sxfy__liru"] = "魔仕",
  ["illustrator:sxfy__liru"] = "木美人",

  ["sxfy__mieji"] = "灭计",
  [":sxfy__mieji"] = "出牌阶段限一次，你可以交给一名其他角色一张黑色锦囊牌，然后你可以弃置其至多两张牌。",
  ["sxfy__juece"] = "绝策",
  [":sxfy__juece"] = "结束阶段，你可以对一名本回合失去过至少两张牌的角色造成1点伤害。",
  ["#sxfy__mieji"] = "灭计：交给一名角色一张黑色锦囊牌，然后你可以弃置其至多两张牌",
  ["#sxfy__mieji-discard"] = "灭计：你可以弃置 %dest 至多两张牌",
  ["#sxfy__juece-choose"] = "绝策：你可以对其中一名角色造成1点伤害！",
}

local guohuanghou = General(extension, "sxfy__guohuanghou", "wei", 3, 3, General.Female)
local jiaozhao = fk.CreateActiveSkill{
  name = "sxfy__jiaozhao",
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  prompt = "#sxfy__jiaozhao",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= Self.id and Fk:currentRoom():getPlayerById(to_select):getHandcardNum() > 1
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local cards = {}
    if target:getHandcardNum() > 2 then
      cards = room:askForCard(target, 2, 2, false, self.name, false, nil, "#sxfy__jiaozhao-show")
    else
      cards = target:getCardIds("h")
    end
    target:showCards(cards)
    if player.dead or target.dead then return end
    cards = table.filter(cards, function (id)
      return table.contains(target:getCardIds("h"), id)
    end)
    if #cards == 0 then return end
    if self.cost_data and self.cost_data.sxfy__danxin then
      self.cost_data = nil
      local card = U.askforChooseCardsAndChoice(player, cards, {"OK"}, self.name, "#sxfy__jiaozhao-prey")
      room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonPrey, self.name, nil, true, player.id)
    elseif not player:isKongcheng() then
      local results = U.askForExchange(player, Fk:translate(target.general), Fk:translate(player.general),
        cards, player:getCardIds("h"), "#sxfy__jiaozhao-exchange::"..target.id, 1, true)
      if #results > 0 then
        local card1, card2 = {results[1]}, {results[2]}
        if table.contains(player:getCardIds("h"), results[2]) then
          card1, card2 = {results[2]}, {results[1]}
        end
        U.swapCards(room, player, player, target, card1, card2, self.name)
      end
    end
  end,
}
local danxin = fk.CreateTriggerSkill{
  name = "sxfy__danxin",
  anim_type = "masochism",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
      table.find(player.room:getOtherPlayers(player, false), function(p)
        return not p:isKongcheng()
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player, false), function(p)
      return not p:isKongcheng()
    end)
    local to = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 1,
      "#sxfy__danxin-choose:::"..data.card:toLogString(), self.name, true)
    if #to > 0 then
      self.cost_data = {tos = to}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    jiaozhao.cost_data = jiaozhao.cost_data or {}
    jiaozhao.cost_data.sxfy__danxin = true
    jiaozhao:onUse(player.room, {
      from = player.id,
      tos = self.cost_data.tos,
    })
  end,
}
guohuanghou:addSkill(jiaozhao)
guohuanghou:addSkill(danxin)
Fk:loadTranslationTable{
  ["sxfy__guohuanghou"] = "郭皇后",
  ["#sxfy__guohuanghou"] = "月华驱霾",
  ["illustrator:sxfy__guohuanghou"] = "alien",

  ["sxfy__jiaozhao"] = "矫诏",
  [":sxfy__jiaozhao"] = "出牌阶段限一次，你可以令一名其他角色展示两张手牌，然后你可以用一张手牌交换其中一张牌。",
  ["sxfy__danxin"] = "殚心",
  [":sxfy__danxin"] = "当你受到伤害后，你可以发动一次〖矫诏〗且改为你获得其展示的一张牌。",
  ["#sxfy__jiaozhao"] = "矫诏：令一名角色展示两张手牌，你可以用一张手牌交换其中一张牌",
  ["#sxfy__jiaozhao-show"] = "矫诏：请展示两张手牌",
  ["#sxfy__jiaozhao-prey"] = "矫诏：获得其中一张牌",
  ["#sxfy__jiaozhao-exchange"] = "矫诏：你可以用一张手牌交换 %dest 其中一张牌",
  ["#sxfy__danxin-choose"] = "殚心：你可以对一名角色发动“矫诏”，且改为你获得其展示的一张牌",
}

local guansuo = General(extension, "sxfy__guansuo", "shu", 4)
local zhengnan = fk.CreateTriggerSkill{
  name = "sxfy__zhengnan",
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Start and #player:getHandlyIds() > 0
  end,
  on_cost = function(self, event, target, player, data)
    local success, dat = player.room:askForUseActiveSkill(player, "sxfy__zhengnan_viewas",
      "#sxfy__zhengnan-use", true, {
        bypass_times = true,
        extraUse = true,
      })
    if success then
      self.cost_data = dat
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = Fk.skills["sxfy__zhengnan_viewas"]:viewAs(self.cost_data.cards)
    room:useCard{
      from = player.id,
      tos = table.map(self.cost_data.targets, function (id)
        return {id}
      end),
      card = card,
      extraUse = true,
    }
  end,
}
local zhengnan_delay = fk.CreateTriggerSkill{
  name = "#sxfy__zhengnan_delay",
  mute = true,
  events = {fk.Death},
  can_trigger = function(self, event, target, player, data)
    return data.damage and data.damage.from and data.damage.from == player and not player.dead and
      data.damage.card and table.contains(data.damage.card.skillNames, "sxfy__zhengnan")
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player:drawCards(2, "sxfy__zhengnan")
  end,
}
local zhengnan_viewas = fk.CreateViewAsSkill{
  name = "sxfy__zhengnan_viewas",
  handly_pile = true,
  card_filter = function (self, to_select, selected)
    return #selected == 0 and table.contains(Self:getHandlyIds(), to_select) and Fk:getCardById(to_select).color == Card.Red
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard("slash")
    card.skillName = "sxfy__zhengnan"
    card:addSubcard(cards[1])
    return card
  end,
}
Fk:addSkill(zhengnan_viewas)
zhengnan:addRelatedSkill(zhengnan_delay)
guansuo:addSkill(zhengnan)
Fk:loadTranslationTable{
  ["sxfy__guansuo"] = "关索",
  ["#sxfy__guansuo"] = "征南先锋",
  ["illustrator:sxfy__guansuo"] = "木美人",

  ["sxfy__zhengnan"] = "征南",
  [":sxfy__zhengnan"] = "准备阶段，你可以将一张红色手牌当【杀】使用，若因此杀死了角色，你摸两张牌。",
  ["#sxfy__zhengnan-use"] = "征南：你可以将一张红色手牌当【杀】使用",
  ["#sxfy__zhengnan_delay"] = "征南",
}

local liuye = General(extension, "sxfy__liuye", "wei", 3)
local polu = fk.CreateTriggerSkill{
  name = "sxfy__polu",
  anim_type = "masochism",
  events = {fk.Damage, fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and not data.to.dead and #data.to:getCardIds("e") > 0
  end,
  on_cost = function(self, event, target, player, data)
    if data.to == player then
      local card = player.room:askForDiscard(player, 1, 1, true, self.name, true, ".|.|.|equip", "#sxfy__polu1-invoke", true)
      if #card > 0 then
        self.cost_data = {cards = card}
        return true
      end
    else
      return player.room:askForSkillInvoke(player, self.name, nil, "#sxfy__polu2-invoke::"..data.to.id)
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if data.to == player then
      room:throwCard(self.cost_data.cards, self.name, player, player)
      if player.dead then return end
      player:drawCards(1, self.name)
    else
      room:doIndicate(player.id, {data.to.id})
      local card = room:askForCardChosen(player, data.to, "e", self.name, "#sxfy__polu-discard::"..data.to.id)
      room:throwCard(card, self.name, data.to, player)
    end
  end,
}
local choulve = fk.CreateActiveSkill{
  name = "sxfy__choulve",
  anim_type = "support",
  card_num = 1,
  target_num = 1,
  prompt = "#sxfy__choulve",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, to_select, selected, targets)
    return #selected == 0 and table.contains(Self:getCardIds("h"), to_select)
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:moveCardTo(effect.cards, Card.PlayerHand, target, fk.ReasonGive, self.name, nil, false, player.id)
    if player.dead or target.dead or target:isNude() then return end
    local card = room:askForCard(target, 1, 1, true, self.name, true, ".|.|.|.|.|equip", "#sxfy__choulve-give:"..player.id)
    if #card > 0 then
      room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonGive, self.name, nil, true, target.id)
    end
  end,
}
liuye:addSkill(polu)
liuye:addSkill(choulve)
Fk:loadTranslationTable{
  ["sxfy__liuye"] = "刘晔",
  ["#sxfy__liuye"] = "佐世之才",
  ["illustrator:sxfy__liuye"] = "影紫C",

  ["sxfy__polu"] = "破橹",
  [":sxfy__polu"] = "当你造成或受到伤害后，你可以弃置受伤角色装备区内的一张牌，若为你，你摸一张牌。",
  ["sxfy__choulve"] = "筹略",
  [":sxfy__choulve"] = "出牌阶段限一次，你可以交给一名其他角色一张手牌，然后其可以交给你一张装备牌。",
  ["#sxfy__polu1-invoke"] = "破橹：是否弃置一张装备，摸一张牌？",
  ["#sxfy__polu2-invoke"] = "破橹：是否弃置 %dest 一张装备？",
  ["#sxfy__polu-discard"] = "破橹：弃置 %dest 一张装备",
  ["#sxfy__choulve"] = "筹略：交给一名角色一张手牌，然后其可以交给你一张装备牌",
  ["#sxfy__choulve-give"] = "筹略：你可以交给 %src 一张装备牌",
}

local caorui = General(extension, "sxfy__caorui", "wei", 3)
local huituo = fk.CreateTriggerSkill{
  name = "sxfy__huituo",
  events = {fk.Damaged},
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = room:getNCards(2)
    room:moveCardTo(cards, Card.Processing, nil, fk.ReasonJustMove, self.name, nil, true, player.id)
    room:delay(1600)
    room:moveCards({
      ids = cards,
      toArea = Card.DrawPile,
      moveReason = fk.ReasonJustMove,
      skillName = self.name,
    })
    if not player:isKongcheng() then
      local result = room:askForArrangeCards(player, self.name,
      {
        cards, player:getCardIds("h"),
        "Top", "$Hand"
      },
        "#sxfy__huituo-exchange", false)
      U.swapCardsWithPile(player, result[1], result[2], self.name, "Top")
    end
  end,
}
local mingjian = fk.CreateActiveSkill{
  name = "sxfy__mingjian",
  anim_type = "support",
  card_num = 1,
  target_num = 1,
  prompt = "#sxfy__mingjian",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local id = effect.cards[1]
    player:showCards(effect.cards)
    if not table.contains(player:getCardIds("he"), id) then return end
    room:moveCardTo(effect.cards, Card.PlayerHand, target, fk.ReasonGive, self.name, nil, true, player.id)
    if not target.dead and table.contains(target:getCardIds("he"), id) then
      room:askForUseRealCard(target, {id}, self.name, "#sxfy__mingjian-use", {
        bypass_times = true,
        extraUse = true,
      })
    end
  end,
}
caorui:addSkill(huituo)
caorui:addSkill(mingjian)
caorui:addSkill("xingshuai")
Fk:loadTranslationTable{
  ["sxfy__caorui"] = "曹叡",
  ["#sxfy__caorui"] = "天资的明君",
  ["illustrator:sxfy__caorui"] = "王立雄",

  ["sxfy__huituo"] = "恢拓",
  [":sxfy__huituo"] = "当你受到伤害后，你可以展示牌堆顶两张牌，用任意张手牌替换等量的牌。",
  ["sxfy__mingjian"] = "明鉴",
  [":sxfy__mingjian"] = "出牌阶段限一次，你可以展示并交给一名其他角色一张牌，然后其可以使用此牌。",
  ["#sxfy__huituo-exchange"] = "恢拓：你可以用手牌替换其中的牌",
  ["#sxfy__mingjian"] = "明鉴：你可以展示并交给一名角色一张牌，其可以使用之",
  ["#sxfy__mingjian-use"] = "明鉴：你可以使用这张牌",
}

local wangyun = General(extension, "sxfy__wangyun", "qun", 3)
local yunji = fk.CreateViewAsSkill{
  name = "sxfy__yunji",
  anim_type = "control",
  pattern = "collateral",
  prompt = "#sxfy__yunji",
  handly_pile = true,
  card_filter = function (self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).type == Card.TypeEquip
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard("collateral")
    card.skillName = self.name
    card:addSubcard(cards[1])
    return card
  end,
  enabled_at_response = function (self, player, response)
    return not response
  end,
}
local zongji = fk.CreateTriggerSkill{
  name = "sxfy__zongji",
  anim_type = "masochism",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and data.card and (data.card.trueName == "slash" or data.card.trueName == "duel") and
      ((not data.to.dead and not data.to:isNude()) or (data.from and not data.from.dead and not data.from:isNude()))
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = {}
    if not data.to.dead and not data.to:isNude() then
      if data.to == player then
        if table.find(player:getCardIds("he"), function (id)
          return not player:prohibitDiscard(id)
        end) then
          table.insert(targets, player.id)
        end
      else
        table.insert(targets, data.to.id)
      end
    end
    if data.from and not data.from.dead and not data.from:isNude() then
      if data.from == player then
        if table.find(player:getCardIds("he"), function (id)
          return not player:prohibitDiscard(id)
        end) then
          table.insertIfNeed(targets, player.id)
        end
      else
        table.insertIfNeed(targets, data.from.id)
      end
    end
    if #targets == 0 then
      room:askForCard(player, 1, 1, false, self.name, true, "false", "#sxfy__zongji1-invoke:"..player.id)
      return false
    end
    room:sortPlayersByAction(targets)
    local prompt = "#sxfy__zongji1-invoke:"..targets[1]
    if #targets > 1 then
      prompt = "#sxfy__zongji2-invoke:"..targets[1]..":"..targets[2]
    end
    if room:askForSkillInvoke(player, self.name, nil, prompt) then
      self.cost_data = {tos = targets}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, id in ipairs(self.cost_data.tos) do
      if player.dead then return end
      local p = room:getPlayerById(id)
      if not p.dead and not p:isNude() then
        if p == player then
          room:askForDiscard(player, 1, 1, true, self.name, false)
        else
          local card = room:askForCardChosen(player, p, "he", self.name, "#sxfy__zongji-discard::"..p.id)
          room:throwCard(card, self.name, p, player)
        end
      end
    end
  end,
}
wangyun:addSkill(yunji)
wangyun:addSkill(zongji)
Fk:loadTranslationTable{
  ["sxfy__wangyun"] = "王允",
  ["#sxfy__wangyun"] = "忠魂不泯",
  ["illustrator:sxfy__wangyun"] = "L",

  ["sxfy__yunji"] = "运机",
  [":sxfy__yunji"] = "你可以将一张装备牌当【借刀杀人】使用。",
  ["sxfy__zongji"] = "纵计",
  [":sxfy__zongji"] = "当一名角色受到【杀】或【决斗】造成的伤害后，你可以弃置其与伤害来源各一张牌。",
  ["#sxfy__yunji"] = "运机：你可以将一张装备牌当【借刀杀人】使用",
  ["#sxfy__zongji1-invoke"] = "纵计：是否弃置 %src 一张牌？",
  ["#sxfy__zongji2-invoke"] = "纵计：是否弃置 %src 和 %dest 各一张牌？",
  ["#sxfy__zongji-discard"] = "纵计：弃置 %dest 一张牌",
}

return extension
