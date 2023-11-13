local extension = Package("espionage_beta")
extension.extensionName = "offline"

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
  card_filter = function(self, to_select, selected)
    return false
  end,
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
  ["xuepin"] = "血拼",
  [":xuepin"] = "出牌阶段限一次，你可以失去1点体力，弃置你攻击范围内一名角色至多两张牌。若弃置的两张牌类别相同，你回复1点体力。",
  ["#xuepin"] = "血拼：失去1点体力弃置攻击范围内一名角色两张牌，若类别相同你回复1点体力",
}

Fk:loadTranslationTable{
  ["es__caohong"] = "曹洪",
  ["lifengs"] = "厉锋",
  [":lifengs"] = "出牌阶段限一次，你可以获得弃牌堆中的一张装备牌。你可以赠予手牌或装备区内的装备牌。",
}

Fk:loadTranslationTable{
  ["es__zhangfei"] = "张飞",
  ["mangji"] = "莽击",
  [":mangji"] = "锁定技，当你装备区的牌数变化或当你体力值变化后，若你体力值不小于1，你弃置一张手牌并视为使用一张【杀】。",
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
  on_cost = function(self, event, target, player, data)
    return true
  end,
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
  ["jielve"] = "劫掠",
  [":jielve"] = "出牌阶段限一次，你可以将两张相同颜色的牌当【趁火打劫】使用。你使用【趁火打劫】效果改为：目标角色展示所有手牌，你选择一项："..
  "1.将其中一张牌交给另一名角色；2.你对其造成1点伤害。",
  ["#jielve"] = "劫掠：你可以将两张相同颜色的牌当【趁火打劫】使用",
  ["jielve__looting_skill"] = "趁火打劫",
  ["#jielve__looting-choose"] = "趁火打劫：选择一名角色将%arg交给其，或点“取消”对 %dest 造成1点伤害",
}

local sunluban = General(extension, "es__sunluban", "wu", 3, 3, General.Female)
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
      target:hasSkill(data, true) and not data.attached_equip and not data.name:startsWith("#") and not data.name:endsWith("&") and
      not data:isInstanceOf(ViewAsSkill) and  --FIXME: 转化技！
      not table.contains({Skill.Limited, Skill.Wake, Skill.Quest}, data.frequency)
  end,
  on_cost = function(self, event, target, player, data)
    return true
  end,
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
  card_filter = function(self, to_select, selected)
    return false
  end,
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
    local to = player.room:askForChoosePlayers(player, table.map(player.room:getOtherPlayers(player), function(p)
      return p.id end), 1, 1, "#yaoling-choose", self.name, true)
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
      table.find(player.room:getOtherPlayers(player), function(p) return p.kingdom == "qun" and not p:isNude() end)
  end,
  on_cost = function(self, event, target, player, data)
    return true
  end,
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

Fk:loadTranslationTable{
  ["es__liru"] = "李儒",  --重量级
  ["dumou"] = "毒谋",
  [":dumou"] = "锁定技，你的回合内，其他角色的黑色手牌均视为【毒】，你的【毒】均视为【过河拆桥】。",
  ["weiquan"] = "威权",
  [":weiquan"] = "限定技，出牌阶段，你可以选择至多X名角色（X为游戏轮数），这些角色依次将一张手牌交给你选择的另一名角色，然后若该角色手牌数"..
  "大于体力值，其执行一个额外的弃牌阶段。",
  ["es__renwang"] = "人望",
  [":es__renwang"] = "出牌阶段限一次，你可以选择弃牌堆中一张黑色基本牌，令一名角色获得之。",
}

Fk:loadTranslationTable{
  ["es__xuyou"] = "许攸",
  ["es__shicai"] = "恃才",
  [":es__shicai"] = "①出牌阶段限一次，你可以弃置一张牌，展示并获得牌堆顶牌；当你本回合失去此牌时，此技能视为未发动过。②你的回合内牌堆顶牌对你可见。",
  ["chenggong"] = "逞功",
  [":chenggong"] = "当一名角色使用牌指定目标后，若目标数大于一，你可以令其摸一张牌。",
  ["zezhu"] = "择主",
  [":zezhu"] = "出牌阶段限一次，你可以获得主公区域内一张牌，然后交给其一张牌。",
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
  ["es__luoshen"] = "洛神",
  [":es__luoshen"] = "准备阶段，你可以判定，并获得生效后的判定牌，然后若你本次以此法获得的牌颜色均相同，你可以重复此流程。",
}

Fk:loadTranslationTable{
  ["es__jiaxu"] = "贾诩",
  ["es__zhenlve"] = "缜略",
  [":es__zhenlve"] = "锁定技，你不能成为延时锦囊牌的目标，你使用的普通锦囊牌不能被响应。",
  ["es__jianshu"] = "间书",
  [":es__jianshu"] = "出牌阶段限一次，你可以将一张手牌交给一名其他角色，令其与你选择的另一名其他角色拼点，没赢的角色失去1点体力。",
  ["es__yongdi"] = "拥嫡",
  [":es__yongdi"] = "限定技，准备阶段，你可以令一名男性角色加1点体力上限并回复1点体力，然后其获得其武将牌上的主公技。",
}

Fk:loadTranslationTable{
  ["es__caocao"] = "曹操",
  ["xiandao"] = "献刀",
  [":xiandao"] = "每回合限一次，你赠予其他角色牌时，你可以令其本回合不能使用此花色的牌，然后若此牌为：锦囊牌，你摸两张牌；"..
  "装备牌，你获得其另一张牌；武器牌，你对其造成1点伤害。",
  ["sancai"] = "散财",
  [":sancai"] = "出牌阶段限一次，你可以展示所有手牌，若均为同一类别，你可以将其中一张牌赠予其他角色。",
  ["yibing"] = "义兵",
  [":yibing"] = "当你于摸牌阶段外获得牌后，你可以将这些牌当无距离次数限制的【杀】使用。",
}

return extension
