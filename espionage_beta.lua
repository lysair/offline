local extension = Package("espionage_beta")
extension.extensionName = "offline"

local U = require "packages/utility/utility"

Fk:loadTranslationTable{
  ["espionage_beta"] = "线下-用间beta",
  ["es"] = "用间",
}

local caoang = General(extension, "es__caoang", "wei", 4)
local xuepin = fk.CreateActiveSkill{
  name = "xuepin",
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  prompt = "#xuepin",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected, selected_cards)
    local target = Fk:currentRoom():getPlayerById(to_select)
    return #selected == 0 and Self:inMyAttackRange(target) and not target:isNude()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:loseHp(player, 1, self.name)
    if player.dead or target:isNude() then return end
    local cards = room:askForCardsChosen(player, target, 1, 2, "he", self.name)
    room:throwCard(cards, self.name, target, player)
    if player.dead or not player:isWounded() then return end
    if #cards == 2 and Fk:getCardById(cards[1]).type == Fk:getCardById(cards[2]).type then
      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = self.name
      }
    end
  end,
}
caoang:addSkill(xuepin)
Fk:loadTranslationTable{
  ["es__caoang"] = "曹昂",
  ["#es__caoang"] = "悍不畏死",
  --["designer:es__caoang"] = "",
  ["illustrator:es__caoang"] = "木美人",

  ["xuepin"] = "血拼",
  [":xuepin"] = "出牌阶段限一次，你可以失去1点体力，弃置你攻击范围内一名角色至多两张牌。若弃置的两张牌类别相同，你回复1点体力。",
  ["#xuepin"] = "血拼：失去1点体力弃置攻击范围内一名角色两张牌，若类别相同你回复1点体力",
}

local caohong = General(extension, "es__caohong", "wei", 4)
local lifengs = fk.CreateActiveSkill{
  name = "lifengs",
  anim_type = "drawcard",
  prompt = "#lifengs",
  card_num = 1,
  target_num = 0,
  expand_pile = function (self)
    return table.filter(Fk:currentRoom().discard_pile, function (id)
      return Fk:getCardById(id).type == Card.TypeEquip
    end)
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and
      table.find(Fk:currentRoom().discard_pile, function (id)
        return Fk:getCardById(id).type == Card.TypeEquip
      end)
  end,
  card_filter = function (self, to_select, selected)
    return #selected == 0 and table.contains(Fk:currentRoom().discard_pile, to_select)
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:moveCardTo(effect.cards, Card.PlayerHand, player, fk.ReasonJustMove, self.name, nil, true, player.id)
  end,

  on_acquire = function (self, player, is_start)
    local room = player.room
    if player:hasSkill("present_skill&", true) then
      room:handleAddLoseSkills(player, "-present_skill&|lifengs_present_skill&", nil, false, true)
    else
      room:handleAddLoseSkills(player, "lifengs_present_skill&", nil, false, true)
    end
  end,
  on_lose = function (self, player, is_death)
    local room = player.room
    if table.find(room:getOtherPlayers(player, false), function (p)
      return p:hasSkill("present_skill&", true)
    end) then
      room:handleAddLoseSkills(player, "-lifengs_present_skill&|present_skill&", nil, false, true)
    else
      room:handleAddLoseSkills(player, "-lifengs_present_skill&", nil, false, true)
    end
  end,
}
local lifengs_present_skill = fk.CreateActiveSkill{
  name = "lifengs_present_skill&",
  prompt = "#lifengs_present_skill&",
  anim_type = "support",
  card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    return table.find(player:getCardIds("h"), function(id)
      return Fk:getCardById(id):getMark("@@present") > 0
    end) or (player:hasSkill(lifengs) and
    table.find(player:getCardIds("he"), function(id)
      return Fk:getCardById(id).type == Card.TypeEquip
    end))
  end,
  card_filter = function(self, to_select, selected)
    if #selected == 0 then
      if Fk:getCardById(to_select):getMark("@@present") > 0 and table.contains(Self:getCardIds("h"), to_select) then
        return true
      end
      if Self:hasSkill(lifengs) then
        if Fk:getCardById(to_select).type == Card.TypeEquip then
          return true
        end
      end
    end
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    U.presentCard(player, target, Fk:getCardById(effect.cards[1]))
  end,
}
Fk:addSkill(lifengs_present_skill)
caohong:addSkill(lifengs)
Fk:loadTranslationTable{
  ["es__caohong"] = "曹洪",
  ["#es__caohong"] = "忠烈为心",
  --["designer:es__caohong"] = "",
  ["illustrator:es__caohong"] = "李秀森",

  ["lifengs"] = "厉锋",
  [":lifengs"] = "出牌阶段限一次，你可以获得弃牌堆中的一张装备牌。你可以赠予手牌或装备区内的装备牌。",
  ["#lifengs"] = "厉锋：你可以获得弃牌堆中的一张装备牌",
  ["lifengs_present_skill&"] = "赠予",
  [":lifengs_present_skill&"] = "出牌阶段，你可以将一张有“赠”标记的手牌或一张装备牌正面向上赠予其他角色。若此牌不是装备牌，则进入该角色手牌区；"..
  "若此牌是装备牌，则进入该角色装备区且替换已有装备。",
  ["#lifengs_present_skill&"] = "将一张有“赠”标记的牌或一张装备牌赠予其他角色",
}

local zhangfei = General(extension, "es__zhangfei", "shu", 4)
zhangfei.hidden = true
local mangji = fk.CreateTriggerSkill{
  name = "mangji",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.HpChanged, fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and player.hp > 0 then
      if event == fk.HpChanged then
        return target == player
      else
        local equipnum = #player:getCardIds("e")
        for _, move in ipairs(data) do
          for _, info in ipairs(move.moveInfo) do
            if move.from == player.id and info.fromArea == Card.PlayerEquip then
              equipnum = equipnum + 1
            elseif move.to == player.id and move.toArea == Card.PlayerEquip then
              equipnum = equipnum - 1
            end
          end
        end
        return #player:getCardIds("e") ~= equipnum
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if not player:isKongcheng() then
      room:askForDiscard(player, 1, 1, false, self.name, false, ".", "#mangji-discard")
    end
    if not player.dead then
      U.askForUseVirtualCard(room, player, "slash", nil, self.name, nil, false, true, false, true)
    end
  end,
}
zhangfei:addSkill(mangji)
Fk:loadTranslationTable{
  ["es__zhangfei"] = "张飞",
  ["#es__zhangfei"] = "万人敌",
  --["designer:es__zhangfei"] = "",
  ["illustrator:es__zhangfei"] = "秋呆呆",

  ["mangji"] = "莽击",
  [":mangji"] = "锁定技，当你装备区的牌数变化或当你体力值变化后，若你体力值不小于1，你弃置一张手牌并视为使用一张【杀】。",
  ["#mangji-discard"] = "莽击：你需弃置一张手牌并视为使用一张【杀】",
}

local chendao = General(extension, "es__chendao", "shu", 4)
local jianglie = fk.CreateTriggerSkill{
  name = "jianglie",
  anim_type = "offensive",
  events = {fk.TargetSpecified},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and player.phase == Player.Play and
      data.card.trueName == "slash" and data.firstTarget and player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 then
      local to = player.room:getPlayerById(data.to)
      return not to.dead and not to:isKongcheng()
    end
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#jianglie-invoke::"..data.to)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(data.to)
    to:showCards(to:getCardIds("h"))
    if not to.dead then
      local choices = {}
      if table.find(to:getCardIds("h"), function(id) return Fk:getCardById(id).color == Card.Red end) then
        table.insert(choices, "red")
      end
      if table.find(to:getCardIds("h"), function(id) return Fk:getCardById(id).color == Card.Black end) then
        table.insert(choices, "black")
      end
      local choice = room:askForChoice(to, choices, self.name, "#jianglie-discard")
      room:throwCard(table.filter(to:getCardIds("h"), function(id)
        return Fk:getCardById(id):getColorString() == choice end), self.name, to, to)
    end
  end,
}
chendao:addSkill(jianglie)
Fk:loadTranslationTable{
  ["es__chendao"] = "陈到",
  ["#es__chendao"] = "白毦护军",
  --["designer:es__chendao"] = "",
  ["illustrator:es__chendao"] = "石婵",

  ["jianglie"] = "将烈",
  [":jianglie"] = "出牌阶段限一次，当你使用【杀】指定一个目标后，你可以令其展示所有手牌，然后其需弃置其中一种颜色所有的牌。",
  ["#jianglie-invoke"] = "将烈：你可以令 %dest 展示手牌并弃置其中一种颜色的牌",
  ["#jianglie-discard"] = "将烈：选择你要弃置手牌的颜色",
}

local ganning = General(extension, "es__ganning", "wu", 4)
local jielve = fk.CreateViewAsSkill{
  name = "jielve",
  anim_type = "control",
  prompt = "#jielve",
  card_filter = function(self, to_select, selected)
    if #selected == 1 then
      return Fk:getCardById(to_select).color == Fk:getCardById(selected[1]).color
    elseif #selected > 1 then
      return false
    end
    return true
  end,
  view_as = function(self, cards)
    if #cards ~= 2 then return end
    local card = Fk:cloneCard("looting")
    card:addSubcards(cards)
    card.skillName = self.name
    return card
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player:isNude()
  end,
}
local jielve__lootingSkill = fk.CreateActiveSkill{
  name = "jielve__looting_skill",
  target_num = 1,
  mod_target_filter = function(self, to_select, selected, user, card, distance_limited)
    return to_select ~= user and not Fk:currentRoom():getPlayerById(to_select):isKongcheng()
  end,
  target_filter = function(self, to_select)
    return to_select ~= Self.id and not Fk:currentRoom():getPlayerById(to_select):isKongcheng()
  end,
  on_effect = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.to)
    if player.dead or target.dead or target:isKongcheng() then return end
    target:showCards(target:getCardIds("h"))
    if player.dead or target.dead or target:isKongcheng() then return end
    local id = room:askForCardChosen(player, target, {card_data = {{target.general, target:getCardIds("h")}}}, self.name)
    local targets = table.map(room:getOtherPlayers(target), function(p) return p.id end)
    local to = room:askForChoosePlayers(player, targets, 1, 1,
      "#jielve__looting-choose::"..target.id..":"..Fk:getCardById(id, true):toLogString(), self.name, true)
    if #to > 0 then
      room:obtainCard(to[1], id, false, fk.ReasonGive)
    else
      room:damage({
        from = player,
        to = target,
        card = effect.card,
        damage = 1,
        skillName = self.name
      })
    end
  end
}
local jielve_trigger = fk.CreateTriggerSkill{
  name = "#jielve_trigger",
  main_skill = jielve,
  mute = true,
  events = {fk.PreCardEffect},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill("jielve") and data.from == player.id and data.card.trueName == "looting"
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local card = data.card:clone()
    local c = table.simpleClone(data.card)
    for k, v in pairs(c) do
      if card[k] == nil then
        card[k] = v
      end
    end
    card.skill = jielve__lootingSkill
    data.card = card
  end,
}
Fk:addSkill(jielve__lootingSkill)
jielve:addRelatedSkill(jielve_trigger)
ganning:addSkill(jielve)
Fk:loadTranslationTable{
  ["es__ganning"] = "甘宁",
  ["#es__ganning"] = "锦帆贼",
  --["designer:es__ganning"] = "",
  ["illustrator:es__ganning"] = "黑山老妖",

  ["jielve"] = "劫掠",
  [":jielve"] = "出牌阶段限一次，你可以将两张相同颜色的牌当【趁火打劫】使用。你使用【趁火打劫】效果改为：目标角色展示所有手牌，你选择一项："..
  "1.将其中一张牌交给另一名角色；2.你对其造成1点伤害。",
  ["#jielve"] = "劫掠：你可以将两张相同颜色的牌当【趁火打劫】使用",
  ["jielve__looting_skill"] = "趁火打劫",
  ["#jielve__looting-choose"] = "趁火打劫：选择一名角色将%arg交给其，或点“取消”对 %dest 造成1点伤害",
}

local sunluban = General(extension, "es__sunluban", "wu", 3, 3, General.Female)
sunluban.hidden = true
local jiaozong = fk.CreateProhibitSkill{
  name = "jiaozong",
  frequency = Skill.Compulsory,
  is_prohibited = function(self, from, to, card)
    if from.phase == Player.Play and card.color == Card.Red and from:getMark("jiaozong-phase") == 0 then
      return table.find(Fk:currentRoom().alive_players, function(p)
        return p:hasSkill(self) and p ~= from and p ~= to
      end)--桃子无中、装备等需要特判
    end
  end,
  prohibit_use = function(self, player, card)
    if player.phase == Player.Play and card.color == Card.Red and player:getMark("jiaozong-phase") == 0 then
      return table.find(Fk:currentRoom().alive_players, function(p) return p:hasSkill(self) and p ~= player end) and
        (card.type == Card.TypeEquip or table.contains({"peach", "ex_nihilo", "lightning", "analeptic", "foresight"}, card.trueName))
    end
  end,
}
local jiaozong_record = fk.CreateTriggerSkill{
  name = "#jiaozong_record",

  refresh_events = {fk.AfterCardUseDeclared},
  can_refresh = function(self, event, target, player, data)
    return target == player and player.phase == Player.Play and data.card.color == Card.Red
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "jiaozong-phase", 1)
  end,
}
local jiaozong_targetmod = fk.CreateTargetModSkill{
  name = "#jiaozong_targetmod",
  bypass_distances = function(self, player, skill, card, to)
    return to:hasSkill("jiaozong") and player.phase == Player.Play and player:getMark("jiaozong-phase") == 0 and
      card and card.color == Card.Red
  end,
}
local chouyou = fk.CreateTriggerSkill{
  name = "chouyou",
  anim_type = "control",
  events = {fk.TargetConfirming},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card.trueName == "slash" and #player.room.alive_players > 2
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = {}
    local from = room:getPlayerById(data.from)
    for _, p in ipairs(room.alive_players) do
      if p ~= player and p.id ~= data.from and not from:isProhibited(p, data.card) then
        table.insert(targets, p.id)
      end
    end
    local to = room:askForChoosePlayers(player, targets, 1, 1, "#chouyou-choose:::"..data.card:toLogString(), self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    local choice = room:askForChoice(to, {"chouyou_slash", "chouyou_control:"..player.id}, self.name)
    if choice == "chouyou_slash" then
      TargetGroup:removeTarget(data.targetGroup, player.id)
      TargetGroup:pushTargets(data.targetGroup, to.id)
    else
      local mark = to:getMark("@@chouyou")
      if mark == 0 then mark = {} end
      table.insertIfNeed(mark, player.id)
      room:setPlayerMark(to, "@@chouyou", mark)
    end
  end,
}
local chouyou_trigger = fk.CreateTriggerSkill{
  name = "#chouyou_trigger",
  mute = true,
  events = {fk.SkillEffect},
  can_trigger = function(self, event, target, player, data)
    return target and target:getMark("@@chouyou") ~= 0 and table.contains(target:getMark("@@chouyou"), player.id) and not player.dead and
      target:hasSkill(data, true) and data:isPlayerSkill(target) and not data.name:startsWith("#") and
      not data:isInstanceOf(ViewAsSkill) and  --FIXME: 转化技！
      not table.contains({Skill.Limited, Skill.Wake, Skill.Quest}, data.frequency)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if not room:askForSkillInvoke(player, "chouyou", nil, "#chouyou-control::"..target.id..":"..data.name) then
      player:broadcastSkillInvoke("chouyou")
      room:notifySkillInvoked(player, "chouyou")
      room:doIndicate(player.id, {target.id})
      --room:setPlayerMark(target, "chouyou-phase", data.name)
      local e = room.logic:getCurrentEvent():findParent(GameEvent.SkillEffect)
      if e then
        room:sendLog{
          type = "#chouyou_prohibit",
          from = player.id,
          to = {target.id},
          arg = data.name
        }
        e:shutdown()
      end
    end
  end,

  refresh_events = {fk.AfterSkillEffect, fk.HpRecover},
  can_refresh = function(self, event, target, player, data)
    if target == player then
      if event == fk.AfterSkillEffect then
        --return player:getMark("@@chouyou") ~= 0 and player:getMark("chouyou-phase") ~= 0
      else
        return data.recoverBy and data.recoverBy:getMark("@@chouyou") ~= 0 and table.contains(data.recoverBy:getMark("@@chouyou"), player.id)
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.AfterSkillEffect then
      room:setPlayerMark(player, "chouyou-phase", 0)
    else
      local mark = target:getMark("@@chouyou")
      table.removeOne(mark, player.id)
      if #mark == 0 then mark = 0 end
      room:setPlayerMark(target, "@@chouyou", mark)
    end
  end,
}
--[[local chouyou_invalidity = fk.CreateInvaliditySkill {--FIXME: 想实现防止空发好像有点难
  name = "#chouyou_invalidity",
  invalidity_func = function(self, from, skill)
    return from:getMark("chouyou-phase") ~= 0 and from:hasSkill(skill, true) and from:getMark("chouyou-phase") == skill.name
  end
}]]
jiaozong:addRelatedSkill(jiaozong_record)
jiaozong:addRelatedSkill(jiaozong_targetmod)
sunluban:addSkill(jiaozong)
chouyou:addRelatedSkill(chouyou_trigger)
--chouyou:addRelatedSkill(chouyou_invalidity)
sunluban:addSkill(chouyou)
Fk:loadTranslationTable{
  ["es__sunluban"] = "孙鲁班",  --重量级
  ["#es__sunluban"] = "为虎作伥",
  --["designer:es__sunluban"] = "",
  ["illustrator:es__sunluban"] = "FOOLTOWN",

  ["jiaozong"] = "骄纵",
  [":jiaozong"] = "锁定技，其他角色于其出牌阶段使用的第一张红色牌目标须为你，且无距离限制。",
  ["chouyou"] = "仇幽",
  [":chouyou"] = "当你成为其他角色使用【杀】的目标时，你可以令另一名其他角色选择一项：1.代替你成为此【杀】目标；2.发动非锁定技前需经你同意，"..
  "直到其令你回复体力。",
  ["#chouyou-choose"] = "仇幽：你可以令一名其他角色选择：代替你成为%arg目标，或发动技能需经你同意！",
  ["chouyou_slash"] = "此【杀】转移给你",
  ["chouyou_control"] = "发动非锁定技前需经 %src 同意，直到你令其回复体力",
  ["@@chouyou"] = "仇幽",
  ["#chouyou-control"] = "仇幽：是否允许 %dest 发动“%arg”？",
  ["#chouyou_prohibit"] = "%from 不允许 %to 发动 “%arg”！",
}

local dongzhuo = General(extension, "es__dongzhuo", "qun", 7)
local tuicheng = fk.CreateViewAsSkill{
  name = "tuicheng",
  anim_type = "control",
  pattern = "sincere_treat",
  prompt = "#tuicheng",
  card_filter = Util.FalseFunc,
  view_as = function(self, cards)
    local card = Fk:cloneCard("sincere_treat")
    card.skillName = self.name
    return card
  end,
  before_use = function(self, player, use)
    player.room:loseHp(player, 1, self.name)
  end,
}
local yaoling = fk.CreateTriggerSkill{
  name = "yaoling",
  anim_type = "control",
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Play
  end,
  on_cost = function(self, event, target, player, data)
    local to = player.room:askForChoosePlayers(player, table.map(player.room:getOtherPlayers(player, false), Util.IdMapper), 1, 1, "#yaoling-choose", self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, -1)
    local to = room:getPlayerById(self.cost_data)
    if player.dead or to.dead then return end
    local dest = room:askForChoosePlayers(player, table.map(room:getOtherPlayers(to), function(p)
      return p.id end), 1, 1, "#yaoling-dest::"..to.id, self.name, false)
    if #dest > 0 then
      dest = dest[1]
    else
      dest = player.id
    end
    local use = room:askForUseCard(to, "slash", "slash", "#yaoling-use:"..player.id..":"..dest, true, {must_targets = {dest}})
    if use then
      room:useCard(use)
    else
      if not to:isNude() then
        room:doIndicate(player.id, {to.id})
        local card = room:askForCardChosen(player, to, "he", self.name)
        room:throwCard({card}, self.name, to, player)
      end
    end
  end,
}
local shicha = fk.CreateTriggerSkill{
  name = "shicha",
  anim_type = "negative",
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Discard and
      player:usedSkillTimes("tuicheng", Player.HistoryTurn) == 0 and player:usedSkillTimes("yaoling", Player.HistoryTurn) == 0
  end,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "shicha-turn", 1)
  end,
}
local shicha_maxcards = fk.CreateMaxCardsSkill{
  name = "#shicha_maxcards",
  fixed_func = function(self, player)
    if player:getMark("shicha-turn") > 0 then
      return 1
    end
  end
}
local yongquan = fk.CreateTriggerSkill{
  name = "yongquan$",
  anim_type = "support",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Finish and
      table.find(player.room:getOtherPlayers(player, false), function(p) return p.kingdom == "qun" and not p:isNude() end)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, table.map(table.filter(room:getOtherPlayers(player), function(p)
      return p.kingdom == "qun" end), function(p) return p.id end))
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if player.dead then return end
      if p.kingdom == "qun" and not p:isNude() and not p.dead then
        local card = room:askForCard(p, 1, 1, true, self.name, true, ".", "#yongquan-give:"..player.id)
        if #card > 0 then
          room:obtainCard(player, card[1], false, fk.ReasonGive)
        end
      end
    end
  end,
}
shicha:addRelatedSkill(shicha_maxcards)
dongzhuo:addSkill(tuicheng)
dongzhuo:addSkill(yaoling)
dongzhuo:addSkill(shicha)
dongzhuo:addSkill(yongquan)
Fk:loadTranslationTable{
  ["es__dongzhuo"] = "董卓",
  ["#es__dongzhuo"] = "乱世的魔王",
  --["designer:es__dongzhuo"] = "",
  ["illustrator:es__dongzhuo"] = "天龙",

  ["tuicheng"] = "推诚",
  [":tuicheng"] = "你可以失去1点体力，视为使用一张【推心置腹】。",
  ["yaoling"] = "耀令",
  [":yaoling"] = "出牌阶段结束时，你可以减1点体力上限，令一名其他角色选择一项：1.对你指定的另一名角色使用一张【杀】；2.你弃置其一张牌。",
  ["shicha"] = "失察",
  [":shicha"] = "锁定技，弃牌阶段开始时，若你本回合〖推诚〗和〖耀令〗均未发动，你本回合手牌上限改为1。",
  ["yongquan"] = "拥权",
  [":yongquan"] = "主公技，结束阶段，其他群势力角色可以依次交给你一张牌。",
  ["#tuicheng"] = "推诚：你可以失去1点体力，视为使用一张【推心置腹】",
  ["#yaoling-choose"] = "耀令：减1点体力上限选择一名角色，其需对你指定的角色使用【杀】或你弃置其一张牌",
  ["#yaoling-dest"] = "耀令：选择令 %dest 使用【杀】的目标",
  ["#yaoling-use"] = "耀令：对 %dest 使用【杀】，否则 %src 弃置你一张牌",
  ["#yongquan-give"] = "拥权：你可以交给 %src 一张牌",
}

--local liru = General(extension, "es__liru", "qun", 3)
local dumou = fk.CreateFilterSkill{
  name = "dumou",
  frequency = Skill.Compulsory,
  card_filter = function(self, to_select, player)
    if player:hasSkill(self) and player.phase ~= Player.NotActive and table.contains(player:getCardIds("h"), to_select.id) then
      return to_select.trueName == "poison"
    end
    if table.find(Fk:currentRoom().alive_players, function(p)
      return p.phase ~= Player.NotActive and p:hasSkill(self) and p ~= player and table.contains(p.player_skills, self)
    end) and table.contains(player:getCardIds("h"), to_select.id) then
      return to_select.color == Card.Black
    end
  end,
  view_as = function(self, to_select)
    local card
    if Self.phase == Player.NotActive then
      card = Fk:cloneCard("es__poison", to_select.suit, to_select.number)
    else
      card = Fk:cloneCard("dismantlement", to_select.suit, to_select.number)
    end
    card.skillName = self.name
    return card
  end,
}
--liru:addSkill(dumou)
Fk:loadTranslationTable{
  ["es__liru"] = "李儒",  --重量级
  ["#es__liru"] = "绝策的毒士",
  --["designer:es__liru"] = "",
  ["illustrator:es__liru"] = "孟迭",

  ["dumou"] = "毒谋",
  [":dumou"] = "锁定技，你的回合内，其他角色的黑色手牌均视为【毒】，你的【毒】均视为【过河拆桥】。",
  ["weiquan"] = "威权",
  [":weiquan"] = "限定技，出牌阶段，你可以选择至多X名角色（X为游戏轮数），这些角色依次将一张手牌交给你选择的另一名角色，然后若该角色手牌数"..
  "大于体力值，其执行一个额外的弃牌阶段。",
  ["es__renwang"] = "人望",
  [":es__renwang"] = "出牌阶段限一次，你可以选择弃牌堆中一张黑色基本牌，令一名角色获得之。",
}

local zhenji = General(extension, "es__zhenji", "wei", 3, 3, General.Female)
local es__luoshen = fk.CreateTriggerSkill{
  name = "es__luoshen",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Start
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local color = ""
    local pattern = ".|.|."
    while true do
      if color == "red" then
        pattern = ".|.|heart,diamond"
      elseif color == "black" then
        pattern = ".|.|spade,club"
      end
      local judge = {
        who = player,
        reason = self.name,
        pattern = pattern,
        skipdrop = true,
      }
      room:judge(judge)
      if color == "" then
        color = judge.card:getColorString()
      end
      if room:getCardArea(judge.card.id) == Card.DiscardPile and not player.dead then
        room:obtainCard(player.id, judge.card.id, true, fk.ReasonJustMove)
      end
      if judge.card:getColorString() ~= color or player.dead or not room:askForSkillInvoke(player, self.name) then
        break
      end
    end
  end,
}
zhenji:addSkill(es__luoshen)
zhenji:addSkill("qingguo")
Fk:loadTranslationTable{
  ["es__zhenji"] = "甄姬",
  ["#es__zhenji"] = "薄幸的美人",
  ["illustrator:es__zhenji"] = "石婵",

  ["es__luoshen"] = "洛神",
  [":es__luoshen"] = "准备阶段，你可以判定，并获得生效后的判定牌，然后若你本次以此法获得的牌颜色均相同，你可以重复此流程。",
}

local caocao = General(extension, "es__caocao", "qun", 4)
caocao.hidden = true
local xiandao = fk.CreateTriggerSkill{
  name = "xiandao",
  anim_type = "control",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryTurn) == 0 then
      for _, move in ipairs(data) do
        if move.to and not player.room:getPlayerById(move.to).dead and move.proposer == player.id and move.skillName == "present" then
          return true
        end
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    local room = player.room
    local dat = {}
    for _, move in ipairs(data) do
      if move.to and not room:getPlayerById(move.to).dead and move.proposer == player.id and move.skillName == "present" then
        for _, info in ipairs(move.moveInfo) do
          table.insertIfNeed(dat, {move.to, info.cardId})
        end
      end
    end
    for _, d in ipairs(dat) do
      if not player:hasSkill(self) or player:usedSkillTimes(self.name, Player.HistoryTurn) > 0 then break end
      local to = room:getPlayerById(d[1])
      self:doCost(event, to, player, d[2])
    end
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#xiandao-trigger::"..target.id..":"..Fk:getCardById(data):toLogString())
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    local card = Fk:getCardById(data)
    room:addTableMarkIfNeed(target, "@xiandao-turn", card:getSuitString(true))
    if not player.dead then
      if card.type == Card.TypeTrick then
        player:drawCards(2, self.name)
      elseif card.type == Card.TypeEquip then
        if not target.dead and not target:isNude() then
          local card_data = {}
          if target:getHandcardNum() > 0 then
            local dat = {}
            for i = 1, target:getHandcardNum(), 1 do
              if target:getCardIds("h")[i] ~= card.id then
                table.insert(dat, -1)
              end
            end
            if #dat > 0 then
              table.insert(card_data, {"$Hand", dat})
            end
          end
          if #target:getCardIds("e") > 0 then
            local dat = target:getCardIds("e")
            table.removeOne(dat, card.id)
            if #dat > 0 then
              table.insert(card_data, {"$Equip", dat})
            end
          end
          if #card_data > 0 then
            local c = room:askForCardChosen(player, target, {card_data = card_data}, self.name)
            if c == -1 then
              c = table.random(target:getCardIds("h"))
            end
            room:moveCardTo(Fk:getCardById(c), Card.PlayerHand, player, fk.ReasonPrey, self.name, nil, false, player.id)
          end
          if card.sub_type == Card.SubtypeWeapon and not player.dead and not target.dead then
            room:damage{
              from = player,
              to = target,
              damage = 1,
              skillName = self.name,
            }
          end
        end
      end
    end
  end,
}
local xiandao_prohibit = fk.CreateProhibitSkill{
  name = "#xiandao_prohibit",
  prohibit_use = function(self, player, card)
    return player:getMark("@xiandao-turn") ~= 0 and table.contains(player:getMark("@xiandao-turn"), card:getSuitString(true))
  end,
}
local sancai = fk.CreateActiveSkill{
  name = "sancai",
  anim_type = "support",
  card_num = 0,
  target_num = 0,
  prompt = "#sancai",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local cards = player:getCardIds("h")
    player:showCards(cards)
    if table.every(cards, function(id) return Fk:getCardById(id).type == Fk:getCardById(cards[1]).type end) then
      cards = table.filter(cards, function(id) return table.contains(player:getCardIds("h"), id) end)
      if #cards > 0 and #room.alive_players > 1 then
        local to, card = room:askForChooseCardAndPlayers(player, table.map(player.room:getOtherPlayers(player, false), Util.IdMapper), 1, 1,
          ".|.|.|.|.|.|"..table.concat(cards, ","), "#sancai-choose", self.name, true)
        if #to > 0 and card then
          U.presentCard(player, room:getPlayerById(to[1]), Fk:getCardById(card))
        end
      end
    end
  end,
}
local yibing = fk.CreateTriggerSkill{
  name = "yibing",
  anim_type = "offensive",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and player:getMark(self.name) == 0 then
      for _, move in ipairs(data) do
        if move.to == player.id and move.toArea == Player.Hand and player.phase ~= Player.Draw then
          for _, info in ipairs(move.moveInfo) do
            if table.contains(player:getCardIds("h"), info.cardId) then
              return true
            end
          end
        end
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    local cards = {}
    for _, move in ipairs(data) do
      if move.to == player.id and move.toArea == Player.Hand then
        for _, info in ipairs(move.moveInfo) do
          if table.contains(player:getCardIds("h"), info.cardId) then
            table.insertIfNeed(cards, info.cardId)
          end
        end
      end
    end
    self:doCost(event, nil, player, cards)
  end,
  on_cost = function(self, event, target, player, data)
    local use = U.askForUseVirtualCard(player.room, player, "slash", data, self.name, "#yibing-slash", true, true, true, true, {}, true)
    if use then
      self.cost_data = use
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, self.name, 1)
    local use = self.cost_data
    use.extra_data = use.extra_data or {}
    use.extra_data.yibing_user = player.id
    player.room:useCard(use)
  end,

  refresh_events = {fk.CardUseFinished},
  can_refresh = function (self, event, target, player, data)
    return data.extra_data and data.extra_data.yibing_user == player.id
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:setPlayerMark(player, self.name, 0)
  end,
}
xiandao:addRelatedSkill(xiandao_prohibit)
caocao:addSkill(xiandao)
caocao:addSkill(sancai)
caocao:addSkill(yibing)
Fk:loadTranslationTable{
  ["es__caocao"] = "曹操",
  ["#es__caocao"] = "谯水击蛟",
  ["illustrator:es__caocao"] = "墨心绘意",

  ["xiandao"] = "献刀",
  [":xiandao"] = "每回合限一次，你赠予其他角色牌后，你可以令其本回合不能使用此花色的牌，然后若此牌为：锦囊牌，你摸两张牌；装备牌，你获得其另一张牌；"..
  "武器牌，你对其造成1点伤害。",
  ["sancai"] = "散财",
  [":sancai"] = "出牌阶段限一次，你可以展示所有手牌，若均为同一类别，你可以将其中一张牌赠予其他角色。",
  ["yibing"] = "义兵",
  [":yibing"] = "当你于摸牌阶段外获得牌后，你可以将这些牌当无距离次数限制的【杀】使用，此【杀】结算结束前，你不能发动〖义兵〗。",-- 高达插结的权宜之策
  ["#xiandao-trigger"] = "献刀：你即将赠予 %dest %arg，是否对其发动“献刀”？",
  ["@xiandao-turn"] = "献刀",
  ["#sancai"] = "散财：展示所有手牌，若均为同一类别，你可以将其中一张赠予其他角色",
  ["#sancai-choose"] = "散财：你可以将其中一张牌赠予其他角色",
  ["#yibing-slash"] = "义兵：你可以将这些牌当无距离次数限制的【杀】使用（直接选择【杀】的目标）",
}

return extension
