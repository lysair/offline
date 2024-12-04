local extension = Package("ofl_other2")
extension.extensionName = "offline"

local U = require "packages/utility/utility"

Fk:loadTranslationTable{
  ["ofl_other2"] = "线下-综合2",
}

Fk:loadTranslationTable{
  ["ofl__godzhangjiao"] = "神张角",
  ["#ofl__godzhangjiao"] = "",
  ["illustrator:ofl__godzhangjiao"] = "",

  ["ofl__mingdao"] = "瞑道",
  [":ofl__mingdao"] = "游戏开始时，你可以将一张“众”置入你的装备区。",
  ["ofl__zhongfu"] = "众附",
  [":ofl__zhongfu"] = "每轮开始时，你可以声明一种花色，然后令手牌最少的角色依次选择一项：1.将一张牌置于牌堆顶；2.从牌堆底摸一张牌，"..
  "当以此法失去牌的角色造成伤害，你发动一次〖瞑道〗。",
  ["ofl__dangjing"] = "荡京",
  [":ofl__dangjing"] = "当你发动〖众附〗后，若你装备区内的牌为全场最多，你可以令一名角色进行一次判定，若为你〖众附〗声明的花色，你对其造成1点"..
  "雷电伤害并重复此流程。",
  ["ofl__sanshou"] = "三首",
  [":ofl__sanshou"] = "锁定技，你的准备阶段和结束阶段改为出牌阶段，并在此阶段将武将牌改为张宝或张梁。此阶段结束后把武将牌替换回张角。",
}

Fk:loadTranslationTable{
  ["ofl__godzhangbao"] = "神张宝",
  ["#ofl__godzhangbao"] = "",
  ["illustrator:ofl__godzhangbao"] = "",

  ["ofl__zhouyuan"] = "咒怨",
  [":ofl__zhouyuan"] = "出牌阶段限一次，你可以选择你和一名其他角色所有手牌，然后其将所有黑色/红色扣置于其武将牌上，"..
  "你将所有红色/黑色手牌置于武将牌上，这些牌称为“咒兵”。出牌阶段结束时，你与其收回“咒兵”。",
  ["ofl__zhaobing"] = "诏兵",
  [":ofl__zhaobing"] = "出牌阶段，你可以将“咒兵”如手牌般使用或打出。",
}

Fk:loadTranslationTable{
  ["ofl__godzhangliang"] = "神张梁",
  ["#ofl__godzhangliang"] = "",
  ["illustrator:ofl__godzhangliang"] = "",

  ["ofl__jijun"] = "集军",
  [":ofl__jijun"] = "当你使用牌指定你为目标后，你可以进行判定，然后选择一项：1.获得此牌；2.将判定牌置于武将牌上，称为“方”。",
  ["ofl__fangtong"] = "方统",
  [":ofl__fangtong"] = "出牌阶段结束时，若有“方”，你可以重铸一张手牌，若你重铸的牌与你的任意“方”点数之和为36，你可以将对应的“方”置入弃牌堆，"..
  "然后对一名其他角色造成3点雷电伤害。",
}

local yanzhengh = General(extension, "yanzhengh", "qun", 4)
local dishi = fk.CreateTriggerSkill{
  name = "ofl__dishi",
  anim_type = "offensive",
  frequency = Skill.Limited,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Play and player:isWounded() and
      not player:isKongcheng() and player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local success, dat = room:askForUseActiveSkill(player, "ofl__dishi_viewas", "#ofl__dishi-invoke", true,
    {
      bypass_distances = true,
      bypass_times = true,
    })
    if success and dat then
      self.cost_data = dat
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local card = Fk:cloneCard("slash")
    card:addSubcards(player:getCardIds("h"))
    card.skillName = self.name
    local use = {
      from = player.id,
      tos = table.map(self.cost_data.targets, function (id) return {id} end),
      card = card,
      extraUse = true,
      additionalDamage = player:getHandcardNum() - 1,
    }
    player.room:useCard(use)
  end,
}
local dishi_viewas = fk.CreateViewAsSkill{
  name = "ofl__dishi_viewas",
  card_filter = Util.FalseFunc,
  view_as = function(self, cards)
    local card = Fk:cloneCard("slash")
    card:addSubcards(Self:getCardIds("h"))
    card.skillName = "ofl__dishi"
    return card
  end,
}
local xianxiang = fk.CreateTriggerSkill{
  name = "ofl__xianxiang",
  anim_type = "support",
  events = {fk.Death},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and data.damage and data.damage.from == player and #player.room.alive_players > 1 and
      not target:isAllNude()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:askForChoosePlayers(player, table.map(room:getOtherPlayers(player), Util.IdMapper), 1, 1,
      "#ofl__xianxiang-invoke::"..target.id, self.name, false)
    room:moveCardTo(target:getCardIds("hej"), Card.PlayerHand, to[1], fk.ReasonJustMove, self.name, nil, false, player.id)
  end,
}
Fk:addSkill(dishi_viewas)
yanzhengh:addSkill(dishi)
yanzhengh:addSkill(xianxiang)
Fk:loadTranslationTable{
  ["yanzhengh"] = "严政",
  ["#yanzhengh"] = "",
  ["illustrator:yanzhengh"] = "",

  ["ofl__dishi"] = "地逝",
  [":ofl__dishi"] = "限定技，出牌阶段开始时，若你已受伤，你可以将所有手牌当一张无距离限制且伤害为X的【杀】使用（X为你的手牌数）。",
  ["ofl__xianxiang"] = "献降",
  [":ofl__xianxiang"] = "锁定技，当你杀死一名角色时，你令一名其他角色获得死亡角色区域内的所有牌",
  ["ofl__dishi_viewas"] = "地逝",
  ["#ofl__dishi-invoke"] = "地逝：你可以将所有手牌当一张无距离限制的【杀】使用，伤害为牌数！",
  ["#ofl__xianxiang-invoke"] = "献降：令一名其他角色获得 %dest 区域内所有牌",
}

local bairao = General(extension, "bairao", "qun", 5)
local xyin = fk.CreateTriggerSkill{
  name = "ofl__xyin",
  anim_type = "control",
  frequency = Skill.Compulsory,
  events = {fk.Damage},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and (data.extra_data or {}).ofl__xyin
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(1, self.name)
    if not data.to.dead then
      U.askForPlayCard(room, data.to, nil, nil, self.name, "#ofl__xyin-use", {
        bypass_times = true,
        extraUse = true,
      })
    end
  end,

  refresh_events = {fk.BeforeHpChanged},
  can_refresh = function(self, event, target, player, data)
    return data.damageEvent and data.damageEvent.from == player and
      player:inMyAttackRange(target) and target:inMyAttackRange(player)
  end,
  on_refresh = function(self, event, target, player, data)
    data.damageEvent.extra_data = data.damageEvent.extra_data or {}
    data.damageEvent.extra_data.ofl__xyin = true
  end,
}
local xyin_targetmod = fk.CreateTargetModSkill{
  name = "#ofl__xyin_targetmod",
  frequency = Skill.Compulsory,
  main_skill = xyin,
  bypass_times = function(self, player, skill, scope, card, to)
    return player:hasSkill(xyin) and card and card.trueName == "slash" and
      to and player:inMyAttackRange(to) and to:inMyAttackRange(player)
  end,
}
xyin:addRelatedSkill(xyin_targetmod)
bairao:addSkill(xyin)
Fk:loadTranslationTable{
  ["bairao"] = "白绕",
  ["#bairao"] = "",
  ["illustrator:bairao"] = "",

  ["ofl__xyin"] = "技能",
  [":ofl__xyin"] = "锁定技，你对攻击范围内含有你且你攻击范围内有其的其他角色：使用【杀】无次数限制；当你对这些角色造成伤害后，你摸一张牌，"..
  "然后其选择是否使用一张牌。",
  ["#ofl__xyin-use"] = "技能：你可以使用一张牌",
}

local busi = General(extension, "busi", "qun", 4, 6)
local weiluan = fk.CreateTriggerSkill{
  name = "ofl__weiluan",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
      table.contains({Player.Start, Player.Draw, Player.Play}, player.phase)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local judge = {
      who = player,
      reason = self.name,
      pattern = ".|.|spade",
    }
    room:judge(judge)
    if judge.card.suit == Card.Spade and not player.dead then
      local mark = player:getMark("@ofl__weiluan")
      if player.phase == Player.Start then
        mark[1] = mark[1] + 1
      elseif player.phase == Player.Draw then
        mark[2] = mark[2] + 1
      elseif player.phase == Player.Play then
        mark[3] = mark[3] + 1
      end
      room:setPlayerMark(player, "@ofl__weiluan", mark)
    end
  end,

  refresh_events = {fk.DrawNCards},
  can_refresh = function (self, event, target, player, data)
    return target == player and player:getMark("@ofl__weiluan") ~= 0
  end,
  on_refresh = function (self, event, target, player, data)
    data.n = data.n + player:getMark("@ofl__weiluan")[2]
  end,

  on_acquire = function (self, player, is_start)
    player.room:setPlayerMark(player, "@ofl__weiluan", {0, 0, 0})
  end,
}
local weiluan_attackrange = fk.CreateAttackRangeSkill{
  name = "#ofl__weiluan_attackrange",
  correct_func = function (self, from, to)
    if from:getMark("@ofl__weiluan") ~= 0 then
      return from:getMark("@ofl__weiluan")[1]
    end
    return 0
  end,
}
local weiluan_targetmod = fk.CreateTargetModSkill{
  name = "#ofl__weiluan_targetmod",
  residue_func = function(self, player, skill, scope)
    if skill.trueName == "slash_skill" and player:getMark("@ofl__weiluan") ~= 0 and scope == Player.HistoryPhase then
      return player:getMark("@ofl__weiluan")[3]
    end
  end,
}
local tianpan = fk.CreateTriggerSkill{
  name = "ofl__tianpan",
  mute = true,
  frequency = Skill.Compulsory,
  events = {fk.FinishJudge},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self)
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(self.name)
    if data.card.suit == Card.Spade then
      room:notifySkillInvoked(player, self.name, "support")
      if room:getCardArea(data.card) == Card.Processing then
        room:moveCardTo(data.card, Card.PlayerHand, player, fk.ReasonJustMove, self.name, nil, true, player.id)
        if player.dead then return end
      end
      local choices = {"ofl__tianpan1"}
      if player:isWounded() then
        table.insert(choices, "recover")
      end
      local choice = room:askForChoice(player, choices, self.name)
      if choice == "ofl__tianpan1" then
        room:changeMaxHp(player, 1)
      else
        room:recover{
          who = player,
          num = 1,
          recoverBy = player,
          skillName = self.name,
        }
      end
    else
      room:notifySkillInvoked(player, self.name, "negative")
      local choice = room:askForChoice(player, {"loseMaxHp", "loseHp"}, self.name)
      if choice == "loseMaxHp" then
        room:changeMaxHp(player, -1)
      else
        room:loseHp(player, 1, self.name)
      end
    end
  end,
}
local gaiming = fk.CreateTriggerSkill{
  name = "ofl__gaiming",
  anim_type = "control",
  events = {fk.AskForRetrial},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and (not data.card or data.card.suit ~= Card.Spade) and
      player:usedSkillTimes(self.name, Player.HistoryTurn) == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local move1 = {
      ids = room:getNCards(1),
      toArea = Card.Processing,
      moveReason = fk.ReasonJustMove,
      skillName = self.name,
      proposer = player.id,
    }
    local move2 = {
      ids = {data.card:getEffectiveId()},
      toArea = Card.DiscardPile,
      moveReason = fk.ReasonJustMove,
      skillName = self.name,
    }
    room:moveCards(move1, move2)
    data.card = Fk:getCardById(move1.ids[1])
    room:sendLog{
      type = "#ChangedJudge",
      from = player.id,
      to = {player.id},
      card = {move1.ids[1]},
      arg = self.name
    }
  end,
}
weiluan:addRelatedSkill(weiluan_attackrange)
weiluan:addRelatedSkill(weiluan_targetmod)
busi:addSkill(weiluan)
busi:addSkill(tianpan)
busi:addSkill(gaiming)
Fk:loadTranslationTable{
  ["busi"] = "卜巳",
  ["#busi"] = "",
  ["illustrator:busi"] = "",

  ["ofl__weiluan"] = "为乱",
  [":ofl__weiluan"] = "锁定技，准备阶段/摸牌阶段/出牌阶段开始时，你进行判定，若结果为♠，你的攻击范围/摸牌阶段摸牌数/使用【杀】次数上限+1。",
  ["ofl__tianpan"] = "天判",
  [":ofl__tianpan"] = "锁定技，当你的判定牌生效后，若结果：为♠，你获得此牌，然后你回复1点体力或加1点体力上限；不为♠，你失去1点体力或减1点体力上限。",
  ["ofl__gaiming"] = "改命",
  [":ofl__gaiming"] = "每回合限一次，当你的判定牌生效前，若结果不为♠，你可以亮出牌堆顶的一张牌代替之。",
  ["@ofl__weiluan"] = "为乱",
  ["ofl__tianpan1"] = "加1点体力上限",
}

local suigu = General(extension, "suigu", "qun", 5)
local tuntians = fk.CreateTriggerSkill{
  name = "ofl__tuntians",
  anim_type = "special",
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Start
  end,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "@ofl__tuntians", 1)
  end,
}
local tuntians_delay = fk.CreateTriggerSkill{
  name = "#ofl__tuntians_delay",
  mute = true,
  frequency = Skill.Compulsory,
  events = {fk.DrawNCards, fk.DamageInflicted},
  can_trigger = function (self, event, target, player, data)
    if target == player and player:getMark("@ofl__tuntians") > 0 then
      if event == fk.DrawNCards then
        return true
      elseif event == fk.DamageInflicted then
        return #player.room.logic:getEventsOfScope(GameEvent.Damage, 2, function (e)
          return e.data[1].to == player
        end, Player.HistoryTurn) == 1
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("ofl__tuntians")
    if event == fk.DrawNCards then
      room:notifySkillInvoked(player, "ofl__tuntians", "drawcard")
      data.n = data.n + player:getMark("@ofl__tuntians")
    elseif event == fk.DamageInflicted then
      room:notifySkillInvoked(player, "ofl__tuntians", "negative")
      data.damage = data.damage + player:getMark("@ofl__tuntians")
    end
  end,
}
local tuntians_maxcards = fk.CreateMaxCardsSkill{
  name = "#ofl__tuntians_maxcards",
  correct_func = function(self, player)
    return player:getMark("@ofl__tuntians")
  end,
}
local qianjun = fk.CreateActiveSkill{
  name = "ofl__qianjun",
  anim_type = "support",
  card_num = 0,
  target_num = 1,
  prompt = "#ofl__qianjun",
  frequency = Skill.Limited,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0 and
      #player:getCardIds("e") > 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:setPlayerMark(player, "@ofl__tuntians", 0)
    room:moveCardTo(player:getCardIds("e"), Card.PlayerHand, target, fk.ReasonGive, self.name, nil, true, player.id)
    room:swapSeat(player, target)
    if player.dead then return end
    if player:isWounded() then
      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = self.name,
      }
      if player.dead then return end
    end
    room:handleAddLoseSkills(player, "luanji", nil, true, false)
  end,
}
tuntians:addRelatedSkill(tuntians_delay)
tuntians:addRelatedSkill(tuntians_maxcards)
suigu:addSkill(tuntians)
suigu:addSkill(qianjun)
suigu:addRelatedSkill("luanji")
Fk:loadTranslationTable{
  ["suigu"] = "眭固",
  ["#suigu"] = "",
  ["illustrator:suigu"] = "",

  ["ofl__tuntians"] = "屯天",
  [":ofl__tuntians"] = "锁定技，准备阶段，你令你本局游戏摸牌阶段的摸牌数，手牌上限和每回合首次受到的伤害+1，直到你发动〖迂军〗。",
  ["ofl__qianjun"] = "迁军",
  [":ofl__qianjun"] = "限定技，出牌阶段，你可以交给一名其他角色装备区里的所有牌并与其交换座次，然后你回复1点体力并获得〖乱击〗。",
  ["@ofl__tuntians"] = "屯天",
  ["#ofl__tuntians_delay"] = "屯天",
  ["#ofl__qianjun"] = "迁军：将所有装备交给一名角色并与其交换座次，你回复1点体力并获得〖乱击〗！",
}

local heman = General(extension, "heman", "qun", 5, 6)
local juedian = fk.CreateTriggerSkill{
  name = "ofl__juedian",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.Damage},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and data.card and
      not data.to.dead and player:canUseTo(Fk:cloneCard("duel"), data.to) then
      local room = player.room
      local turn_event = room.logic:getCurrentEvent():findParent(GameEvent.Turn)
      if turn_event == nil then return end
      local use_event = room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
      if use_event == nil then return end
      if #TargetGroup:getRealTargets(use_event.data[1].tos) ~= 1 then return end
      return #room.logic:getEventsOfScope(GameEvent.UseCard, 2, function(e)
        local use = e.data[1]
        return use.from == player.id and use.tos and #TargetGroup:getRealTargets(use.tos) == 1 and use.damageDealt
      end, Player.HistoryTurn) == 1
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choice = room:askForChoice(player, {"loseHp", "loseMaxHp", "ofl__juedian_beishui"}, self.name,
      "#ofl__juedian-choice::"..data.to.id)
    local card = Fk:cloneCard("duel")
    card.skillName = self.name
    local use = {
      from = player.id,
      tos = {{data.to.id}},
      card = card,
    }
    if choice ~= "loseMaxHp" then
      room:loseHp(player, 1, self.name)
    end
    if choice ~= "loseHp" and not player.dead then
      room:changeMaxHp(player, -1)
    end
    if choice == "ofl__juedian_beishui" and not player.dead then
      use.additionalDamage = 1
    end
    if not data.to.dead and player:canUseTo(card, data.to) then
      room:useCard(use)
    end
  end,
}
local nitian = fk.CreateActiveSkill{
  name = "ofl__nitian",
  anim_type = "offensive",
  card_num = 0,
  target_num = 0,
  prompt = "#ofl__nitian",
  frequency = Skill.Limited,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  card_filter = Util.FalseFunc,
}
local nitian_delay = fk.CreateTriggerSkill{
  name = "#ofl__nitian_delay",
  mute = true,
  events = {fk.CardUsing, fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:usedSkillTimes("ofl__nitian", Player.HistoryTurn) > 0 then
      if event == fk.CardUsing then
        return data.card.trueName == "slash" or data.card:isCommonTrick()
      elseif event == fk.EventPhaseStart then
        return player.phase == Player.Finish and
        #player.room.logic:getEventsOfScope(GameEvent.Death, 1, function (e)
          local death = e.data[1]
          return death.damage and death.damage.from == player
        end, Player.HistoryTurn) == 0
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("ofl__nitian")
    if event == fk.CardUsing then
      room:notifySkillInvoked(player, "ofl__nitian", "offensive")
      data.unoffsetableList = table.map(room.alive_players, Util.IdMapper)
    elseif event == fk.EventPhaseStart then
      room:notifySkillInvoked(player, "ofl__nitian", "negative")
      room:killPlayer({who = player.id})
    end
  end,
}
nitian:addRelatedSkill(nitian_delay)
heman:addSkill(juedian)
heman:addSkill(nitian)
Fk:loadTranslationTable{
  ["heman"] = "何曼",
  ["#heman"] = "截天夜叉",
  ["illustrator:heman"] = "千秋秋千秋",

  ["ofl__juedian"] = "决巅",
  [":ofl__juedian"] = "锁定技，当你每回合首次使用指定唯一目标的牌造成伤害后，你选择一项，然后视为对受伤角色使用一张【决斗】：1.失去1点体力；"..
  "2.减1点体力上限；背水：此【决斗】造成的伤害+1。",
  ["ofl__nitian"] = "逆天",
  [":ofl__nitian"] = "限定技，出牌阶段，令你本回合使用牌不能被抵消；结束阶段，若你本回合未杀死角色，你死亡。",
  ["ofl__juedian_beishui"] = "背水：此【决斗】伤害+1",
  ["#ofl__juedian-choice"] = "决巅：请选择一项，视为对 %dest 视为使用【决斗】",
  ["#ofl__nitian"] = "逆天：令你本回合使用牌不能被抵消，若本回合未杀死角色则死亡！",
  ["#ofl__nitian_delay"] = "逆天",
}

local yudu = General(extension, "yudu", "qun", 4)
local dafu = fk.CreateTriggerSkill{
  name = "ofl__dafu",
  anim_type = "offensive",
  events ={fk.TargetSpecified},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card.is_damage_card
  end,
  on_cost = function (self, event, target, player, data)
    if player.room:askForSkillInvoke(player, self.name, nil, "#ofl__dafu-invoke::"..data.to..":"..data.card:toLogString()) then
      self.cost_data = {tos = {data.to}}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    data.disresponsiveList = data.disresponsiveList or {}
    table.insertIfNeed(data.disresponsiveList, data.to)
    player.room:getPlayerById(data.to):drawCards(1, self.name)
  end,
}
local jipin = fk.CreateTriggerSkill{
  name = "ofl__jipin",
  anim_type = "control",
  events = {fk.Damage},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:getHandcardNum() < data.to:getHandcardNum() and not data.to.dead
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askForSkillInvoke(target, self.name, nil, "#ofl__jipin-invoke::"..data.to.id) then
      self.cost_data = {tos = {data.to}}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = room:askForCardChosen(target, data.to, "h", self.name, "#ofl__jipin-prey::"..data.to.id)
    room:moveCardTo(card, Card.PlayerHand, target, fk.ReasonPrey, self.name, nil, false, target.id)
    if player.dead or not table.contains(player:getCardIds("h"), card) or #room:getOtherPlayers(player) == 0 then return end
    local to = room:askForChoosePlayers(player, table.map(room:getOtherPlayers(player), Util.IdMapper), 1, 1,
      "#ofl__jipin-give:::"..Fk:getCardById(card):toLogString(), self.name, true)
    if #to > 0 then
      room:moveCardTo(card, Card.PlayerHand, to[1], fk.ReasonGive, self.name, nil, false, target.id)
    end
  end,
}
yudu:addSkill(dafu)
yudu:addSkill(jipin)
Fk:loadTranslationTable{
  ["yudu"] = "于毒",
  ["#yudu"] = "",
  ["illustrator:yudu"] = "",

  ["ofl__dafu"] = "打富",
  [":ofl__dafu"] = "当你使用伤害牌指定目标后，你可以令目标角色摸一张牌，然后其不能响应此牌。",
  ["ofl__jipin"] = "济贫",
  [":ofl__jipin"] = "当你对手牌数大于你的角色造成伤害后，你可以获得其一张手牌，然后可以将之交给一名其他角色。",
  ["#ofl__dafu-invoke"] = "打富：是否令 %dest 摸一张牌，其不能响应此%arg？",
  ["#ofl__jipin-invoke"] = "济贫：是否获得 %dest 一张手牌？",
  ["#ofl__jipin-prey"] = "济贫：获得 %dest 一张手牌",
  ["#ofl__jipin-give"] = "济贫：你可以将这张%arg交给一名其他角色",
}

--local tangzhou = General(extension, "tangzhou", "qun", 4)
Fk:loadTranslationTable{
  ["tangzhou"] = "唐周",
  ["#tangzhou"] = "",
  ["illustrator:tangzhou"] = "",

  ["ofl__jukou"] = "举寇",
  [":ofl__jukou"] = "出牌阶段限一次，你可以令一名角色摸一张牌/获得其武将牌上的所有牌，然后其本回合不能使用【杀】/手牌。",
  ["ofl__weipan"] = "违叛",
  [":ofl__weipan"] = "限定技，出牌阶段，你可以展示一名其他角色的所有手牌，然后你与另一名角色各摸三张牌。若如此做，其对另一名角色依次使用手牌中"..
  "所有伤害牌，这两名角色互相使用牌无次数限制直到游戏结束。",
}

--local bocai = General(extension, "bocai", "qun", 5)
Fk:loadTranslationTable{
  ["bocai"] = "波才",
  ["#bocai"] = "",
  ["illustrator:bocai"] = "HOOO",

  ["ofl__weijun"] = "围军",
  [":ofl__weijun"] = "锁定技，你的初始手牌数+4，手牌数小于你的角色不能响应你使用的牌，你不能响应手牌数大于你的角色使用的牌。",
  ["ofl__yingzhan"] = "营战",
  [":ofl__yingzhan"] = "锁定技，你造成或受到的属性伤害+1。",
  ["ofl__cuiji"] = "摧击",
  [":ofl__cuiji"] = "其他角色的出牌阶段开始时，若你手牌数大于其，你可以将X张手牌当一张雷【杀】对其使用，若你以此法造成了伤害，你摸等量的牌。",
}

--local chengyuanzhi = General(extension, "chengyuanzhi", "qun", 5)
Fk:loadTranslationTable{
  ["chengyuanzhi"] = "程远志",
  ["#chengyuanzhi"] = "",
  ["illustrator:chengyuanzhi"] = "HOOO",

  ["ofl__wux"] = "武x",
  [":ofl__wux"] = "锁定技，当每回合首次有红色牌进入弃牌堆后，你本回合下次造成或受到的伤害+1。",
  ["ofl__qian"] = "前x",
  [":ofl__qian"] = "出牌阶段，你可以弃置两张红色牌视为使用一张【决斗】，若对目标造成伤害，你摸一张牌。",
}

--local dengmao = General(extension, "dengmao", "qun", 5)
Fk:loadTranslationTable{
  ["dengmao"] = "邓茂",
  ["#dengmao"] = "",
  ["illustrator:dengmao"] = "HOOO",

  ["ofl__paoxi"] = "咆袭",
  [":ofl__paoxi"] = "锁定技，每回合各限一次，当你连续成为牌的目标后/使用牌指定目标后，你本回合下次受到/造成的伤害+1。",
  ["ofl__houying"] = "后应",
  [":ofl__houying"] = "出牌阶段，你可以弃置两张黑色牌并视为使用一张无次数限制的【杀】，若对目标造成伤害，你摸一张牌。",
}

--local gaosheng = General(extension, "gaosheng", "qun", 5)
Fk:loadTranslationTable{
  ["gaosheng"] = "高升",
  ["#gaosheng"] = "",
  ["illustrator:gaosheng"] = "",

  ["ofl__xshi"] = "x势",
  [":ofl__xshi"] = "每名角色出牌阶段限一次，其可以将一张手牌置于你武将牌上。",
  ["ofl__difeng"] = "地锋",
  [":ofl__difeng"] = "锁定技，当一名角色将牌置于武将牌后，你与其各摸一张牌；你造成或受到伤害时，伤害来源可以弃置你武将牌上一张牌，令此伤害+1。",
}

local fuyun = General(extension, "fuyun", "qun", 4)
local suiqu = fk.CreateTriggerSkill{
  name = "ofl__suiqu",
  anim_type = "support",
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target.phase == Player.Discard and not player:isKongcheng()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local yes = table.find(player:getCardIds("h"), function (id)
      return not player:prohibitDiscard(id)
    end)
    player:throwAllCards("h")
    if player.dead then return end
    if yes then
      local choices = {"ofl__tianpan1"}
      if player:isWounded() then
        table.insert(choices, "recover")
      end
      local choice = room:askForChoice(player, choices, self.name)
      if choice == "ofl__tianpan1" then
        room:changeMaxHp(player, 1)
      else
        room:recover{
          who = player,
          num = 1,
          recoverBy = player,
          skillName = self.name,
        }
      end
    end
  end,
}
local yure = fk.CreateTriggerSkill{
  name = "ofl__yure",
  anim_type = "support",
  frequency = Skill.Limited,
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) or player.room:getOtherPlayers(player, false) == 0 or
      player:usedSkillTimes(self.name, Player.HistoryGame) > 0 then return end
    local cards = {}
    for _, move in ipairs(data) do
      if move.from == player.id and move.moveReason == fk.ReasonDiscard and move.toArea == Card.DiscardPile then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
            table.insertIfNeed(cards, info.cardId)
          end
        end
      end
    end
    cards = table.filter(cards, function(id) return player.room:getCardArea(id) == Card.DiscardPile end)
    cards = U.moveCardsHoldingAreaCheck(player.room, cards)
    if #cards > 0 then
      self.cost_data = {cards = cards}
      return true
    end
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local cards = self.cost_data.cards
    local move = room:askForYiji(player, cards, room:getOtherPlayers(player, false), self.name, 0, #cards,
      "#ofl__yure-give", cards, true)
    local check
    for _, cds in pairs(move) do
      if #cds > 0 then
        check = true
        break
      end
    end
    if check then
      self.cost_data = move
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doYiji(self.cost_data, player.id, self.name)
  end,
}
fuyun:addSkill(suiqu)
fuyun:addSkill(yure)
Fk:loadTranslationTable{
  ["fuyun"] = "浮云",
  ["#fuyun"] = "黄天末代",
  ["illustrator:fuyun"] = "苍月白龙",

  ["ofl__suiqu"] = "随去",
  [":ofl__suiqu"] = "锁定技，所有角色的弃牌阶段，你弃置所有手牌，若至少弃置一张牌，你加1点体力上限或回复1点体力。",
  ["ofl__yure"] = "余热",
  [":ofl__yure"] = "限定技，当你弃置牌后，你可以将所有弃置的牌交给任意名其他角色。",
  ["#ofl__yure-give"] = "余热：你可以将弃置的牌分配给其他角色",
}

--local taosheng = General(extension, "taosheng", "qun", 5)
Fk:loadTranslationTable{
  ["taosheng"] = "陶升",
  ["#taosheng"] = "",
  ["illustrator:taosheng"] = "",

  ["ofl__guannei"] = "观内",
  [":ofl__guannei"] = "限定技，出牌阶段，你可以选择一名其他角色，然后你与其距离视为1，直到你进入濒死状态。",
  ["ofl__hanwei"] = "扞卫",
  [":ofl__hanwei"] = "出牌阶段限一次，你可以展示并交给距离为1的一名其他角色任意张非伤害类牌并摸等量的牌，然后其可以使用你交给其的任意张牌。",
}

Fk:loadTranslationTable{
  ["godhuangfusong"] = "神皇甫嵩",--4
  ["#godhuangfusong"] = "厥功至伟",
  ["illustrator:godhuangfusong"] = "",

  ["ofl__shice"] = "势策",
  [":ofl__shice"] = "转换技，①当你受到属性伤害时，若的技能数不大于伤害来源，你可以防止此伤害并视为便用一张【火攻】；②当你不因此技能使用牌"..
  "指定唯一目标后，你可以令其弃置装备区任意张牌，然后此牌额外结算X次（X为其装备区的牌数）。",
  ["ofl__podai"] = "破怠",
  [":ofl__podai"] = "每轮各限一次，一名角色的回合开始或结束时，你可以选择一顶：1.令其描述中含有基本牌名或数字的一个技能失效；2.令其摸三张牌，"..
  "然后对其造成1点火焰伤害。",
}

Fk:loadTranslationTable{
  ["godluzhi"] = "神卢植",--4
  ["#godluzhi"] = "",
  ["illustrator:godluzhi"] = "",

  ["ofl__xgan"] = "x干",
  [":ofl__xgan"] = "每个回合结束时，若有xx计算距离发生过变化，你可以令其他两名角色分别视为使用一张基本牌。",
  ["ofl__podai"] = "破怠",
  [":ofl__podai"] = "出牌阶段限一次，你可以xx任意张手牌并。",
  ["ofl__xquan"] = "x权",
  [":ofl__xquan"] = "你可以将一张装备牌当未以此法使用过的锦囊牌对体力不小于你的xx角色使用。",
}

Fk:loadTranslationTable{
  ["godzhujun"] = "神朱儁",--4
  ["#godzhujun"] = "",
  ["illustrator:godzhujun"] = "",

  ["ofl__xji"] = "x击",
  [":ofl__xji"] = "出牌阶段限一次，你可以，然后令一名其他角色xx等量张手牌，若：【杀】，你对其造成1点火焰伤害；【闪】，其对；【桃】，你与其各摸两张牌。",
  ["ofl__p"] = "",
  [":ofl__p"] = "锁定技，你的回合内，一名角色使用属性【杀】指定目标后，目标角色。",
  ["ofl__kuixiang"] = "溃降",
  [":ofl__kuixiang"] = "每名角色限一次，。",
}

return extension
