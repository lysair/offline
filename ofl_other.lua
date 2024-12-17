local extension = Package("ofl_other")
extension.extensionName = "offline"

local U = require "packages/utility/utility"

Fk:loadTranslationTable{
  ["ofl_other"] = "线下-综合",
  ["ofl"] = "线下",
  ["rom"] = "风花雪月",
  ["chaos"] = "文和乱武",
  ["sgsh"] = "三国杀·幻",
}

local caesar = General(extension, "caesar", "god", 4)
local conqueror = fk.CreateTriggerSkill{
  name = "conqueror",
  anim_type = "offensive",
  events = {fk.TargetSpecified},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card.trueName == "slash" and data.to ~= player.id and
      not player.room:getPlayerById(data.to).dead
  end,
  on_cost = function(self, event, target, player, data)
    local choice = player.room:askForChoice(player, {"Cancel", "basic", "equip", "trick"}, self.name,
      "#conqueror-choice::"..data.to..":"..data.card:toLogString())
    if choice ~= "Cancel" then
      self.cost_data = choice
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(data.to)
    if not to:isNude() then
      local card = room:askForCard(to, 1, 1, true, self.name, true, ".|.|.|.|.|"..self.cost_data,
        "#conqueror-give:"..player.id.."::"..self.cost_data)
      if #card > 0 then
        room:obtainCard(player.id, card[1], true, fk.ReasonGive, to.id, self.name)
        table.insertIfNeed(data.nullifiedTargets, data.to)
        return
      end
    end
    data.disresponsiveList = data.disresponsiveList or {}
    table.insert(data.disresponsiveList, data.to)
  end,
}
caesar:addSkill(conqueror)
Fk:loadTranslationTable{
  ["caesar"] = "Caesar",
  ["conqueror"] = "Conqueror",
  [":conqueror"] = "When you use a <b>Strike</b> and successfully target another hero, you may declare a card type "..
  "(Basic, Equipment, or Scroll) and then the target must select one of the following: <br> 1. Negate the effect of the <b>Strike</b> and "..
  "give you a card of the declared type. <br> 2. That <b>Strike</b> may not be <b>Dodged</b>.",
  ["#conqueror-choice"] = "Conqueror: You may declare a card type, %dest shall give you a card of the declared type<br>"..
  "to negate the effect, or the %arg may not be Dodged",
  ["#conqueror-give"] = "Conqueror: You shall give %src a %arg to negate the effect, or the Strike may not be Dodged",
}

local sunhanhua = General(extension, "ofl__sunhanhua", "wu", 3, 3, General.Female)
local ofl__chongxu = fk.CreateActiveSkill{
  name = "ofl__chongxu",
  anim_type = "drawcard",
  card_num = 0,
  target_num = 0,
  prompt = "#ofl__chongxu",
  interaction = function()
    return UI.ComboBox {choices = {"ofl__chongxu_yes", "ofl__chongxu_no"}}
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local cards = room:getNCards(2)
    room:moveCards({
      ids = cards,
      toArea = Card.Processing,
      moveReason = fk.ReasonJustMove,
      skillName = self.name,
      proposer = player.id,
    })
    room:sendCardVirtName(cards, self.name)
    room:delay(2000)
    if (self.interaction.data == "ofl__chongxu_yes" and Fk:getCardById(cards[1]).color == Fk:getCardById(cards[2]).color) or
      (self.interaction.data == "ofl__chongxu_no" and Fk:getCardById(cards[1]).color ~= Fk:getCardById(cards[2]).color) then
      local all_choices = {"ofl__chongxu_get", "miaojian_update", "lianhuas_update"}
      local choices = table.simpleClone(all_choices)
      if player:getMark("@miaojian") == "status3" then
        table.removeOne(choices, "miaojian_update")
      end
      if player:getMark("@lianhuas") == "status3" then
        table.removeOne(choices, "lianhuas_update")
      end
      local choice = room:askForChoice(player, choices, self.name, "", false, all_choices)
      if choice == "ofl__chongxu_get" then
        room:obtainCard(player, cards, true, fk.ReasonJustMove, player.id, self.name)
      else
        if choice == "miaojian_update" then
          if player:getMark("@miaojian") == 0 then
            room:setPlayerMark(player, "@miaojian", "status2")
          else
            room:setPlayerMark(player, "@miaojian", "status3")
          end
        elseif choice == "lianhuas_update" then
          if player:getMark("@lianhuas") == 0 then
            room:setPlayerMark(player, "@lianhuas", "status2")
          else
            room:setPlayerMark(player, "@lianhuas", "status3")
          end
        end
      end
    else
      local chosen = room:askForCardsChosen(player, player, 0, 1, { card_data = { { self.name, cards }  } }, self.name, "$ChooseCard")
      if #chosen == 1 then
        room:obtainCard(player, chosen, true, fk.ReasonJustMove, player.id, self.name)
      end
    end
    room:cleanProcessingArea(cards, self.name)
  end,
}
local miaojian = fk.CreateViewAsSkill{
  name = "miaojian",
  prompt = function ()
    if Self:getMark("@miaojian") == 0 then
      return "#miaojian1"
    elseif Self:getMark("@miaojian") == "status2" then
      return "#miaojian2"
    elseif Self:getMark("@miaojian") == "status3" then
      return "#miaojian3"
    end
    return ""
  end,
  interaction = function()
    return UI.ComboBox {choices = {"stab__slash", "ex_nihilo"}}
  end,
  card_filter = function(self, to_select, selected)
    if #selected == 0 then
      local card = Fk:getCardById(to_select)
      if Self:getMark("@miaojian") == 0 then
        if self.interaction.data == "stab__slash" then
          return card.trueName == "slash"
        elseif self.interaction.data == "ex_nihilo" then
          return card.type == Card.TypeTrick
        end
      elseif Self:getMark("@miaojian") == "status2" then
        if self.interaction.data == "stab__slash" then
          return card.type == Card.TypeBasic
        elseif self.interaction.data == "ex_nihilo" then
          return card.type ~= Card.TypeBasic
        end
      elseif Self:getMark("@miaojian") == "status3" then
        return false
      end
    end
  end,
  view_as = function(self, cards)
    if not self.interaction.data then return end
    local card = Fk:cloneCard(self.interaction.data)
    if Self:getMark("@miaojian") == 0 or Self:getMark("@miaojian") == "status2" then
      if #cards ~= 1 then return end
      card:addSubcard(cards[1])
    end
    card.skillName = self.name
    return card
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  enabled_at_response = function(self, player)
    return false
  end,
}
local lianhuas = fk.CreateTriggerSkill{
  name = "lianhuas",
  events = {fk.TargetConfirming},
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card.trueName == "slash"
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(1, self.name)
    if player.dead or player:getMark("@lianhuas") == 0 then return end
    if player:getMark("@lianhuas") == "status2" then
      local judge = {
        who = player,
        reason = self.name,
        pattern = ".|.|spade",
      }
      room:judge(judge)
      if judge.card.suit == Card.Spade then
        AimGroup:cancelTarget(data, player.id)
      end
    elseif player:getMark("@lianhuas") == "status3" then
      local from = room:getPlayerById(data.from)
      if from.dead or from:isNude() or
        #room:askForDiscard(from, 1, 1, true, self.name, true, ".", "#lianhuas-discard:"..player.id) == 0 then
        AimGroup:cancelTarget(data, player.id)
      end
    end
  end,
}
sunhanhua:addSkill(ofl__chongxu)
sunhanhua:addSkill(miaojian)
sunhanhua:addSkill(lianhuas)
Fk:loadTranslationTable{
  ["ofl__sunhanhua"] = "孙寒华",
  ["#ofl__sunhanhua"] = "挣绽的青莲",
  ["illustrator:ofl__sunhanhua"] = "匠人绘",

  ["ofl__chongxu"] = "冲虚",
  [":ofl__chongxu"] = "出牌阶段限一次，你可以猜测牌堆顶两张牌颜色是否相同，然后亮出之，若你猜对，你可以选择一项：1.获得之；2.修改〖妙剑〗；"..
  "3.修改〖莲华〗；若你猜错，你可以获得其中一张牌。",
  ["miaojian"] = "妙剑",
  [":miaojian"] = "出牌阶段限一次，你可以将【杀】当刺【杀】、锦囊牌当【无中生有】使用。<br>二阶：出牌阶段限一次，你可以将基本牌当刺【杀】、"..
  "非基本牌当【无中生有】使用。<br>三阶：出牌阶段限一次，你可以视为使用一张刺【杀】或【无中生有】。",
  ["lianhuas"] = "莲华",
  [":lianhuas"] = "当你成为【杀】的目标时，你摸一张牌。<br>二阶：当你成为【杀】的目标时，你摸一张牌，然后你判定，若为♠，取消之。<br>"..
  "三阶：当你成为【杀】的目标时，你摸一张牌，然后使用者需弃置一张牌，否则取消之。",
  ["#ofl__chongxu"] = "冲虚：猜测牌堆顶两张牌颜色是否相同，猜对获得之或升级技能，猜错获得其中一张",
  ["ofl__chongxu_yes"] = "相同",
  ["ofl__chongxu_no"] = "不同",
  ["ofl__chongxu_get"] = "获得这些牌",
  ["miaojian_update"] = "升级〖妙剑〗",
  ["lianhuas_update"] = "升级〖莲华〗",
  ["#miaojian1"] = "妙剑：你可以将【杀】当刺【杀】、锦囊牌当【无中生有】使用",
  ["#miaojian2"] = "妙剑：你可以将基本牌当刺【杀】、非基本牌当【无中生有】使用",
  ["#miaojian3"] = "妙剑：你可以视为使用一张刺【杀】或【无中生有】",
  ["@miaojian"] = "妙剑",
  ["@lianhuas"] = "莲华",
  ["status2"] = "二阶",
  ["status3"] = "三阶",
  ["#lianhuas-discard"] = "莲华：你需弃置一张牌，否则 %src 取消此【杀】",

  ["$ofl__chongxu1"] = "阳炁冲三关，斩尸除阴魔。",
  ["$ofl__chongxu2"] = "蒲团清静坐，神归了道真。",
  ["$miaojian1"] = "谨以三尺玄锋，代天行化，布令宣威。",
  ["$miaojian2"] = "布天罡，踏北斗，有秽皆除，无妖不斩。",
  ["$lianhuas1"] = "刀兵水火，速离身形。",
  ["$lianhuas2"] = "体有金光，覆映全身。",
  ["~ofl__sunhanhua"] = "天有寒暑，人有死生……",
}

local miheng = General(extension, "ofl__miheng", "qun", 3)

local kuangcai = fk.CreateTriggerSkill{
  name = "ofl__kuangcai",
  mute = true,
  events = {fk.EventPhaseStart, fk.CardUsing},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) then
      if event == fk.EventPhaseStart then
        return player.phase == Player.Play
      else
        return player:getMark("ofl__kuangcai-phase") > 0
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    return event == fk.CardUsing or player.room:askForSkillInvoke(player, self.name, nil, "#ofl__kuangcai-invoke")
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, self.name, "drawcard")
    if event == fk.EventPhaseStart then
      player:broadcastSkillInvoke(self.name, 2)
      room:setPlayerMark(player, "ofl__kuangcai-phase", 1)
      room:setPlayerMark(player, "@ofl__kuangcai-phase", 5)
    else
      player:broadcastSkillInvoke(self.name, 1)
      player:drawCards(1, self.name)
    end
  end,

  refresh_events = {fk.CardUsing},
  can_refresh = function (self, event, target, player, data)
    return player:getMark("@ofl__kuangcai-phase") > 0
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:removePlayerMark(player, "@ofl__kuangcai-phase")
  end,
}
local kuangcai_targetmod = fk.CreateTargetModSkill{
  name = "#ofl__kuangcai_targetmod",
  bypass_times = function(self, player, skill, scope, card)
    return card and player:getMark("ofl__kuangcai-phase") > 0
  end,
  bypass_distances = function(self, player, skill, card)
    return card and player:getMark("ofl__kuangcai-phase") > 0
  end,
}
kuangcai:addRelatedSkill(kuangcai_targetmod)
local kuangcai_prohibit = fk.CreateProhibitSkill{
  name = "#ofl__kuangcai_prohibit",
  prohibit_use = function(self, player, card)
    return table.find(Fk:currentRoom().alive_players, function (p)
      return p:getMark("ofl__kuangcai-phase") > 0 and p:getMark("@ofl__kuangcai-phase") == 0
    end)
  end,
}
kuangcai:addRelatedSkill(kuangcai_prohibit)
miheng:addSkill(kuangcai)
miheng:addSkill("mobile__shejian")
Fk:loadTranslationTable{
  ["ofl__miheng"] = "祢衡",
  ["#ofl__miheng"] = "鸷鹗啄孤凤",
  ["ofl__kuangcai"] = "狂才",
  [":ofl__kuangcai"] = "出牌阶段开始时，你可以令你此阶段使用牌无次数距离限制且当你使用牌时你摸一张牌。若如此做，本阶段所有角色合计使用牌数不能超过五张。",
  ["#ofl__kuangcai-invoke"] = "祢衡：可令本阶段使用牌时无次数距离限制且摸一张牌，所有角色至多使用5张牌！",
  ["@ofl__kuangcai-phase"] = "狂才",
  ["$ofl__kuangcai1"] = "（激烈的鼓声）",
  ["$ofl__kuangcai2"] = "来吧，速战速决！",
}

local liuhong = General(extension, "rom__liuhong", "qun", 4)
local rom__zhenglian = fk.CreateTriggerSkill{
  name = "rom__zhenglian",
  events = {fk.EventPhaseStart},
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Start 
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = room:getOtherPlayers(player)
    local prompt = "#rom__zhenglian-ask:" .. player.id
    local tos = {}
    for _, p in ipairs(targets) do
      if player.dead then return end
      if not p.dead then
        local card = room:askForCard(p, 1, 1, true, self.name, true, nil, prompt)
        if #card > 0 then
          room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonGive, self.name, nil, false, player.id)
        else
          table.insert(tos, p)
        end
      end
    end
    local num = #tos
    tos = table.map(table.filter(tos, function(p) return not p:isNude() end), Util.IdMapper)
    local to = room:askForChoosePlayers(player, tos, 1, 1, "#rom__zhenglian-discard:::" .. num, self.name, true)
    if #to > 0 then
      room:askForDiscard(room:getPlayerById(to[1]), num, num, true, self.name, false)
    end
  end
}
liuhong:addSkill(rom__zhenglian)
Fk:loadTranslationTable{
  ["rom__liuhong"] = "刘宏",
  ["rom__zhenglian"] = "征敛",
  [":rom__zhenglian"] = "准备阶段，你可以令所有其他角色依次选择是否交给你一张牌。所有角色选择完毕后，你可以令一名选择否的角色弃置X张牌（X为选择否的角色数）。",
  ["#rom__zhenglian-ask"] = "征敛：交给 %src 一张牌，否则有可能被其要求弃牌",
  ["#rom__zhenglian-discard"] = "征敛：你可以令一名选择否的角色弃置 %arg 张牌",
}

local godjiaxu = General(extension, "godjiaxu", "god", 4)

---@param player ServerPlayer
local function UpdateLianpo(player)
  local room = player.room
  local exist_roles = table.map(room.alive_players, function(p) return p.role end)
  if type(room:getBanner("@lianpoj_add")) == "table" then
    table.insertTable(exist_roles, room:getBanner("@lianpoj_add"))
  end
  local rolos = {0, 0, 0}
  for _, role in ipairs(exist_roles) do
    if role == "lord" or role == "loyalist" then
      rolos[1] = rolos[1] + 1
    elseif role == "rebel" then
      rolos[2] = rolos[2] + 1
    elseif role == "renegade" then
      rolos[3] = rolos[3] + 1
    end
  end
  local max_num = 0
  for i = 1, 3 do
    max_num = math.max(max_num, rolos[i])
  end
  local max_roles = {}
  for i = 1, 3 do
    if rolos[i] == max_num then
      table.insert(max_roles, "lianpoj"..i)
    end
  end
  room:setPlayerMark(player, "@lianpoj", max_roles)
end
local lianpoj = fk.CreateTriggerSkill{
  name = "lianpoj",
  anim_type = "special",
  frequency = Skill.Compulsory,
  events = {fk.RoundStart, fk.EnterDying, fk.Deathed},
  mute = true,
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(self) then
      if event == fk.RoundStart then
        return true
      elseif event == fk.EnterDying then
        return table.contains(player:getTableMark("@lianpoj"), "lianpoj1")
      elseif event == fk.Deathed then
        return #player:getTableMark("@lianpoj") > 1
        and data.damage and data.damage.from and not data.damage.from.dead
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, self.name)
    if event == fk.RoundStart then
      player:broadcastSkillInvoke(self.name, math.random(1, 2))
      local all_roles = {"lord", "loyalist", "rebel", "renegade"}
      local rolesMap = {["lord"] = 0, ["loyalist"] = 0, ["rebel"] = 0, ["renegade"] = 0}
      if room:isGameMode("role_mode") then
        rolesMap = {["lord"] = 1, ["loyalist"] = 3, ["rebel"] = 4, ["renegade"] = 2}
        for _, p in ipairs(room.players) do
          if rolesMap[p.role] then
            rolesMap[p.role] = math.max(0, rolesMap[p.role] - 1)
          end
        end
      end
      for _, p in ipairs(room.players) do
        if p.dead and table.contains(all_roles, p.role) then
          rolesMap[p.role] = rolesMap[p.role] + 1
        end
      end
      if type(room:getBanner("@lianpoj_add")) == "table" then
        for _, p in ipairs(room:getBanner("@lianpoj_add")) do
          if rolesMap[p.role] then
            rolesMap[p.role] = rolesMap[p.role] - 1
          end
        end
      end
      local choices = {}
      for _, role in ipairs(all_roles) do
        if rolesMap[role] > 0 then
          table.insert(choices, role)
        end
      end
      if #choices == 0 then return end
      local choice = room:askForChoice(player, choices, self.name, "#lianpoj-choice", false, all_roles)
      room:sendLog{
        type = "#LianpojAddRole",
        arg = choice,
        toast = true,
      }
      local banner = type(room:getBanner("@lianpoj_add")) == "table" and room:getBanner("@lianpoj_add") or {}
      table.insert(banner, choice)
      room:setBanner("@lianpoj_add", banner)
      UpdateLianpo(player)
    elseif event == fk.EnterDying then
      player:broadcastSkillInvoke(self.name, 3)
      room:notifySkillInvoked(player, self.name)
    elseif event == fk.Deathed then
      player:broadcastSkillInvoke(self.name, 4)
      local p = data.damage.from
      local choices = {"draw2"}
      if p:isWounded() then
        table.insert(choices, "recover")
      end
      local choice = room:askForChoice(p, choices, self.name)
      if choice == "draw2" then
        p:drawCards(2, self.name)
      else
        room:recover({
          who = p,
          num = 1,
          recoverBy = p,
          skillName = self.name
        })
      end
    end
  end,

  refresh_events = {fk.GameStart, fk.EventAcquireSkill, fk.GameOverJudge, fk.AfterPlayerRevived, fk.RoundEnd, fk.EventLoseSkill},
  can_refresh = function(self, event, target, player, data)
    if event == fk.RoundEnd then
      return type(player.room:getBanner("@lianpoj_add")) == "table"
    elseif event == fk.EventLoseSkill then
      return target == player and data == self
    elseif player:hasSkill(self, true) then
      if event == fk.EventAcquireSkill then
        return target == player and data == self
      else
        return true
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.RoundEnd then
      room:setBanner("@lianpoj_add", 0)
      for _, p in ipairs(room.alive_players) do
        if p:hasSkill(self, true) then
          UpdateLianpo(p)
        end
      end
    elseif event == fk.EventLoseSkill then
      room:setPlayerMark(player, "@lianpoj", 0)
    else
      UpdateLianpo(player)
    end
  end,
}
local lianpoj_maxcards = fk.CreateMaxCardsSkill{
  name = "#lianpoj_maxcards",
  frequency = Skill.Compulsory,
  correct_func = function(self, player)
    local n = 0
    for _, p in ipairs(Fk:currentRoom().alive_players) do
      if table.contains(p:getTableMark("@lianpoj"), "lianpoj2") and p ~= player then
        n = n - 1
      end
    end
    return n
  end,
}
local lianpoj_targetmod = fk.CreateTargetModSkill{
  name = "#lianpoj_targetmod",
  frequency = Skill.Compulsory,
  residue_func = function(self, player, skill, scope)
    if skill.trueName == "slash_skill" and scope == Player.HistoryPhase then
      local n = 0
      for _, p in ipairs(Fk:currentRoom().alive_players) do
        if table.contains(p:getTableMark("@lianpoj"), "lianpoj2") then
          n = n + 1
        end
      end
      return n
    end
  end,
}
local lianpoj_attackrange = fk.CreateAttackRangeSkill{
  name = "#lianpoj_attackrange",
  frequency = Skill.Compulsory,
  correct_func = function (self, from, to)
    local n = 0
    for _, p in ipairs(Fk:currentRoom().alive_players) do
      if table.contains(p:getTableMark("@lianpoj"), "lianpoj2") then
        n = n + 1
      end
    end
    return n
  end,
}
local lianpoj_prohibit = fk.CreateProhibitSkill{
  name = "#lianpoj_prohibit",
  is_prohibited = function (self, from, to, card)
    if card and card.name == "peach" and from ~= to and to.dying then
      return table.find(Fk:currentRoom().alive_players, function(p)
        return table.contains(p:getTableMark("@lianpoj"), "lianpoj1") and p ~= from
      end)
    end
  end,
}
local zhaoluan = fk.CreateActiveSkill{
  name = "zhaoluan",
  mute = true,
  frequency = Skill.Limited,
  card_num = 0,
  target_num = 1,
  prompt = function(self)
    return "#zhaoluan-damage::"..Self:getMark(self.name)
  end,
  can_use = function(self, player)
    return player:getMark(self.name) ~= 0 and not Fk:currentRoom():getPlayerById(player:getMark(self.name)).dead
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and not table.contains(Self:getTableMark("zhaoluan_target-phase"), to_select)
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:addTableMark(player, "zhaoluan_target-phase", target.id)
    local src = room:getPlayerById(player:getMark(self.name))
    player:broadcastSkillInvoke(self.name, math.random(3, 4))
    room:notifySkillInvoked(player, self.name, "offensive")
    room:doIndicate(player.id, {src.id})
    room:doIndicate(src.id, {target.id})
    room:changeMaxHp(src, -1)
    room:damage{
      from = src,
      to = target,
      damage = 1,
      skillName = self.name,
    }
  end,
}
local zhaoluan_trigger = fk.CreateTriggerSkill{
  name = "#zhaoluan_trigger",
  anim_type = "special",
  frequency = Skill.Limited,
  main_skill = zhaoluan,
  mute = true,
  events = {fk.AskForPeachesDone},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and not target.dead and target.hp < 1 and player:getMark("zhaoluan") == 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, "zhaoluan", nil, "#zhaoluan-invoke::"..target.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    room:setPlayerMark(player, "zhaoluan", target.id)  --FIXME: 谨防刷新限定技
    player:broadcastSkillInvoke("zhaoluan", math.random(1, 2))
    room:notifySkillInvoked(player, "zhaoluan", "big")
    room:changeMaxHp(target, 3)
    local skills = {}
    for _, s in ipairs(target.player_skills) do
      if s:isPlayerSkill(target) and s.frequency ~= Skill.Compulsory and s.frequency ~= Skill.Wake then
        table.insertIfNeed(skills, s.name)
      end
    end
    if room.settings.gameMode == "m_1v2_mode" and target.role == "lord" then
      table.removeOne(skills, "m_feiyang")
      table.removeOne(skills, "m_bahu")
    end
    if #skills > 0 then
      room:handleAddLoseSkills(target, "-"..table.concat(skills, "|-"), nil, true, false)
    end
    if not target.dead and target.hp < 3 and target:isWounded() then
      room:recover({
        who = target,
        num = math.min(3, target.maxHp) - target.hp,
        recoverBy = player,
        skillName = self.name,
      })
    end
    if not target.dead then
      target:drawCards(4, self.name)
    end
  end,
}
lianpoj:addRelatedSkill(lianpoj_maxcards)
lianpoj:addRelatedSkill(lianpoj_targetmod)
lianpoj:addRelatedSkill(lianpoj_attackrange)
lianpoj:addRelatedSkill(lianpoj_prohibit)
zhaoluan:addRelatedSkill(zhaoluan_trigger)
godjiaxu:addSkill(lianpoj)
godjiaxu:addSkill(zhaoluan)
Fk:loadTranslationTable{
  ["godjiaxu"] = "神贾诩",
  ["#godjiaxu"] = "倒悬云衢",
  ["cv:godjiaxu"] = "酉良",
  ["illustrator:godjiaxu"] = "鬼画府",

  ["lianpoj"] = "炼魄",
  [":lianpoj"] = "锁定技，若场上的最大阵营为：<br>反贼，其他角色手牌上限-1，所有角色出牌阶段使用【杀】次数上限+1、攻击范围+1；<br>"..
  "主忠，其他角色不能对除其以外的角色使用【桃】；<br>多个最大阵营，其他角色死亡后，伤害来源摸两张牌或回复1点体力。<br>"..
  "每轮开始时，你展示一张未加入游戏的身份牌或一张已死亡角色的身份牌，本轮视为该阵营角色数+1。",
  ["zhaoluan"] = "兆乱",
  [":zhaoluan"] = "限定技，一名角色濒死结算后，若其仍处于濒死状态，你可以令其加3点体力上限并失去所有非锁定技，回复体力至3并摸四张牌。"..
  "出牌阶段对每名角色限一次，你可以令该角色减1点体力上限，其对一名你选择的角色造成1点伤害。",
  ["@lianpoj"] = "炼魄",
  ["@lianpoj_add"] = "炼魄增加",
  ["#lianpoj-choice"] = "炼魄：选择本轮视为增加的一个身份",
  ["#LianpojAddRole"] = "“炼魄”本轮视为人数+1的身份是：%arg",
  ["lianpoj1"] = "主忠",
  ["lianpoj2"] = "反",
  ["lianpoj3"] = "内",
  ["#zhaoluan_trigger"] = "兆乱",
  ["#zhaoluan-invoke"] = "兆乱：%dest 即将死亡，你可以令其复活并操纵其进行攻击！",
  ["#zhaoluan-damage"] = "兆乱：你可以令 %dest 减1点体力上限，其对你指定的一名角色造成1点伤害！",

  ["$lianpoj1"] = "圣人伏阳汞炼魄，飞阴铅拘魂。",
  ["$lianpoj2"] = "荡荡古今魂，湛湛紫云天。",
  ["$lianpoj3"] = "北辰居其所，谁人可囊血射之？",
  ["$lianpoj4"] = "大火在中，其明胜月，今邀诸君共掇。",
  ["$zhaoluan1"] = "杀汝，活汝，吾一念之间。",
  ["$zhaoluan2"] = "故山千岫，折得清香。故人，还不醒转？",
  ["$zhaoluan3"] = "汝之形名，悉吾所赐，须奉骨报偿！",
  ["$zhaoluan4"] = "心在柙中，不知窍数，取出与吾把示。",
  ["~godjiaxu"] = "虎兕出于柙，龟玉毁于椟中，谁之过与？",
}

local caojinyu = General(extension, "ofl__caojinyu", "wei", 3, 3, General.Female)
local yuqi = fk.CreateTriggerSkill{
  name = "ofl__yuqi",
  anim_type = "masochism",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and not target.dead and player:usedSkillTimes(self.name) < 2 and
    (target == player or player:distanceTo(target) <= player:getMark("ofl__yuqi1"))
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n1, n2, n3 = player:getMark("ofl__yuqi2"), player:getMark("ofl__yuqi3"), player:getMark("ofl__yuqi4")
    if n1 < 2 and n2 < 1 and n3 < 1 then
      return false
    end
    local cards = room:getNCards(n1)
    local result = room:askForArrangeCards(player, self.name, {cards, "Top", target.general, player.general}, "#ofl__yuqi",
    false, 0, {n1, n2, n3}, {0, 1, 1})
    local top, bottom = result[2], result[3]
    local moveInfos = {}
    if #top > 0 then
      table.insert(moveInfos, {
        ids = top,
        to = target.id,
        toArea = Card.PlayerHand,
        moveReason = fk.ReasonGive,
        proposer = player.id,
        skillName = self.name,
        visiblePlayers = player.id,
      })
      for _, id in ipairs(top) do
        table.removeOne(cards, id)
      end
    end
    if #bottom > 0 then
      table.insert(moveInfos, {
        ids = bottom,
        to = player.id,
        toArea = Card.PlayerHand,
        moveReason = fk.ReasonJustMove,
        proposer = player.id,
        skillName = self.name,
      })
      for _, id in ipairs(bottom) do
        table.removeOne(cards, id)
      end
    end
    room:moveCards(table.unpack(moveInfos))
  end,

  on_acquire = function (self, player, is_start)
    local room = player.room
    room:setPlayerMark(player, "ofl__yuqi1", 0)
    room:setPlayerMark(player, "ofl__yuqi2", 3)
    room:setPlayerMark(player, "ofl__yuqi3", 1)
    room:setPlayerMark(player, "ofl__yuqi4", 1)
    room:setPlayerMark(player, "@" .. self.name, string.format("%d-%d-%d-%d", 0, 3, 1, 1))
  end,
  on_lose = function (self, player, is_death)
    local room = player.room
    room:setPlayerMark(player, "ofl__yuqi1", 0)
    room:setPlayerMark(player, "ofl__yuqi2", 0)
    room:setPlayerMark(player, "ofl__yuqi3", 0)
    room:setPlayerMark(player, "ofl__yuqi4", 0)
    room:setPlayerMark(player, "@" .. self.name, 0)
  end,
}
local function AddYuqi(player, skillName, num)
  local room = player.room
  local choices = {}
  for i = 1, 4, 1 do
    if player:getMark("ofl__yuqi" .. tostring(i)) < 3 then
      table.insert(choices, "ofl__yuqi" .. tostring(i))
    end
  end
  if #choices > 0 then
    local choice = room:askForChoice(player, choices, skillName)
    local x = player:getMark(choice)
    if x + num < 4 then
      x = x + num
    else
      x = 3
    end
    room:setPlayerMark(player, choice, x)
    room:setPlayerMark(player, "@ofl__yuqi", string.format("%d-%d-%d-%d",
    player:getMark("ofl__yuqi1"),
    player:getMark("ofl__yuqi2"),
    player:getMark("ofl__yuqi3"),
    player:getMark("ofl__yuqi4")))
  end
end
local shanshen = fk.CreateTriggerSkill{
  name = "ofl__shanshen",
  anim_type = "control",
  events = {fk.Death},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target ~= player and not player.dead
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    AddYuqi(player, self.name, 2)
    if player:isWounded() and #room.logic:getActualDamageEvents(1, function(e)
      local damage = e.data[1]
      if damage.from == player and damage.to == target then
        return true
      end
    end, nil, 0) == 0 then
      room:recover{
        who = player,
        num = 1,
        skillName = self.name,
      }
    end
  end,
}
local xianjing = fk.CreateTriggerSkill{
  name = "ofl__xianjing",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and player.phase == Player.Start then
      for i = 1, 4, 1 do
        if player:getMark("yuqi" .. tostring(i)) < 5 then
          return true
        end
      end
    end
    return false
  end,
  on_use = function(self, event, target, player, data)
    AddYuqi(player, self.name, 1)
    if not player:isWounded() then
      AddYuqi(player, self.name, 1)
    end
  end,
}
caojinyu:addSkill(yuqi)
caojinyu:addSkill(shanshen)
caojinyu:addSkill(xianjing)
Fk:loadTranslationTable{
  ["ofl__caojinyu"] = "曹金玉",
  ["#ofl__caojinyu"] = "瑞雪纷华",
  ["illustrator:ofl__caojinyu"] = "米糊PU",

  ["ofl__yuqi"] = "隅泣",
  [":ofl__yuqi"] = "每回合限两次，当一名角色受到伤害后，若你与其距离0或者更少，你可以观看牌堆顶的3张牌，将其中至多1张交给受伤角色，"..
  "至多1张自己获得，剩余的牌放回牌堆顶。",
  ["ofl__shanshen"] = "善身",
  [":ofl__shanshen"] = "当有角色死亡时，你可令〖隅泣〗中的一个数字+2（单项不能超过3）。然后若你没有对死亡角色造成过伤害，你回复1点体力。",
  ["ofl__xianjing"] = "娴静",
  [":ofl__xianjing"] = "准备阶段，你可令〖隅泣〗中的一个数字+1（单项不能超过3）。若你满体力值，则再令〖隅泣〗中的一个数字+1。",
  ["@ofl__yuqi"] = '<font color="#7ABEEA">隅泣</font>',
  ["ofl__yuqi1"] = "距离",
  ["ofl__yuqi2"] = "观看牌数",
  ["ofl__yuqi3"] = "交给受伤角色牌数",
  ["ofl__yuqi4"] = "自己获得牌数",
  ["#ofl__yuqi"] = "隅泣：请分配卡牌，余下的牌置于牌堆顶",

  ["$ofl__yuqi1"] = "玉儿摔倒了，要阿娘抱抱。",
  ["$ofl__yuqi2"] = "这么漂亮的雪花，为什么只能在寒冬呢？",
  ["$ofl__shanshen1"] = "人家只想做安安静静的小淑女。",
  ["$ofl__shanshen2"] = "雪花纷飞，独存寒冬。",
  ["$ofl__xianjing1"] = "得父母之爱，享公主之礼遇。",
  ["$ofl__xianjing2"] = "哼，可不要小瞧女孩子啊。",
  ["~ofl__caojinyu"] = "娘亲，雪人不怕冷吗？",
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
    return card and table.contains(card.skillNames, "ofl__shouli")
  end,
  bypass_distances = function(self, player, skill, card)
    return card and table.contains(card.skillNames, "ofl__shouli")
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
  ["#ofl__godmachao"] = "雷挝缚苍",
  ["illustrator:ofl__godmachao"] = "鬼画府",

  ["ofl__shouli"] = "狩骊",
  ["#ofl__shouli_trigger"] = "狩骊",
  ["#ofl__shouli_delay"] = "狩骊",
  [":ofl__shouli"] = "①游戏开始时，所有其他角色随机获得1枚“狩骊”标记。"..
  "<br>②每回合各限一次，你可以选择一项：1.移动一名其他角色的所有“骏”至其上家或下家，并视为使用或打出一张无距离和次数限制的【杀】；2.移动一名其他角色的"..
  "所有“骊”至其上家或下家，并视为使用或打出一张【闪】。"..
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

local jiaxu = General(extension, "chaos__jiaxu", "qun", 3)
local miesha = fk.CreateTriggerSkill{
  name = "miesha",
  anim_type = "offensive",
  events = {fk.DamageCaused},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.to.hp == 1 and data.to ~= player
  end,
  on_use = function(self, event, target, player, data)
    player:broadcastSkillInvoke("wansha")
    data.damage = data.damage + 1
  end,
}
jiaxu:addSkill(miesha)
jiaxu:addSkill("luanwu")
jiaxu:addSkill("weimu")
Fk:loadTranslationTable{
  ["chaos__jiaxu"] = "贾诩",
  ["miesha"] = "灭杀",
  [":miesha"] = "锁定技，当你对一名其他角色造成伤害时，若其体力值为1，你令伤害值+1。",
}

local lijue = General(extension, "chaos__lijue", "qun", 4, 6)
local feixiong = fk.CreateTriggerSkill{
  name = "feixiong",
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(self) and player.phase == Player.Play and not player:isKongcheng()) then return end
    local targets = table.map(table.filter(player.room:getOtherPlayers(player), function (p)
      return not p:isKongcheng()
    end), Util.IdMapper)
    if #targets > 0 then
      self.cost_data = targets
      return true
    end
  end,
  on_cost = function(self, event, target, player, data)
    local targets = self.cost_data
    local target = player.room:askForChoosePlayers(player, targets, 1, 1, "#feixiong-ask", self.name, true)
    if #target > 0 then
      self.cost_data = target[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("langxi")
    local target = room:getPlayerById(self.cost_data)
    local pindian = player:pindian({target}, self.name)
    local from = pindian.results[target.id].winner
    if from then
      local to = from == player and target or player
      room:damage{
        from = from,
        to = to,
        damage = 1,
        skillName = self.name,
      }
    end
  end,
}

local cesuan = fk.CreateTriggerSkill{
  name = "cesuan",
  anim_type = "defensive",
  events = {fk.DamageInflicted},
  frequency = Skill.Compulsory,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("yisuan")
    if player.hp < player.maxHp then
      room:changeMaxHp(player, -1)
    else
      room:changeMaxHp(player, -1)
      player:drawCards(1, self.name)
    end
    return true
  end,
}
lijue:addSkill(feixiong)
lijue:addSkill(cesuan)
Fk:loadTranslationTable{
  ["chaos__lijue"] = "李傕",
  ["feixiong"] = "飞熊",
  [":feixiong"] = "出牌阶段开始时，你可与一名其他角色拼点，拼点赢的角色对拼点未赢的角色造成1点伤害。",
  ["cesuan"] = "策算",
  [":cesuan"] = "锁定技，当你受到伤害时，你防止此伤害，若你的体力：小于体力上限，你减1点体力上限；不小于体力上限，你减1点体力上限，摸一张牌。",

  ["#feixiong-ask"] = "飞熊：你可与一名其他角色拼点，拼点赢的角色对拼点未赢的角色造成1点伤害",
}

local zhangji = General(extension, "chaos__zhangji", "qun", 4)
local lulue = fk.CreateActiveSkill{
  name = "chaos__lulue",
  anim_type = "offensive",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, to_select, selected)
    return not Self:prohibitDiscard(Fk:getCardById(to_select))
  end,
  target_filter = function(self, to_select, selected, cards)
    if #cards == 0 or to_select == Self.id then return end
    local target = Fk:currentRoom():getPlayerById(to_select)
    return #cards == #target:getCardIds(Player.Equip)
  end,
  target_num = 1,
  min_card_num = 1,
  max_card_num = 999,
  on_use = function(self, room, effect)
    local from = room:getPlayerById(effect.from)
    local to = room:getPlayerById(effect.tos[1])
    from:broadcastSkillInvoke("lueming")
    room:throwCard(effect.cards, self.name, from, from)
    if not from.dead and not to.dead then
      room:damage{
        from = from,
        to = to,
        damage = 1,
        skillName = self.name,
      }
    end
  end,
}
zhangji:addSkill(lulue)
Fk:loadTranslationTable{
  ["chaos__zhangji"] = "张济",
  ["chaos__lulue"] = "掳掠",
  [":chaos__lulue"] = "出牌阶段限一次，你可选择一名装备区里有牌的其他角色并弃置X张牌（X为其装备区里的牌数），对其造成1点伤害。",
}

local wangyun = General(extension, "ofl__wangyun", "qun", 3)
local ofl__lianji = fk.CreateTriggerSkill{
  name = "ofl__lianji",
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and player.phase == Player.Play then
      local types = {}
      player.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function(e)
        local use = e.data[1]
        if use.from == player.id then
          table.insertIfNeed(types, use.card.type)
        end
      end, Player.HistoryPhase)
      if #types > 0 then
        self.cost_data = #types
        return true
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:askForChoosePlayers(player, table.map(room.alive_players, Util.IdMapper), 1, 1,
      "#ofl__lianji1-invoke", self.name, true)
    if #to > 0 then
      room:getPlayerById(to[1]):drawCards(1, self.name)
    end
    if player.dead or self.cost_data < 2 then return end
    if player:isWounded() and room:askForSkillInvoke(player, self.name, nil, "#ofl__lianji2-invoke") then
      room:recover({
        who = player,
        num = 1,
        recoverBy = player,
        skillName = self.name,
      })
    end
    if player.dead or self.cost_data < 3 or #room.alive_players < 2 then return end
    to = room:askForChoosePlayers(player, table.map(room:getOtherPlayers(player), Util.IdMapper), 1, 1,
      "#ofl__lianji3-invoke", self.name, true)
    if #to > 0 then
      room:setPlayerMark(player, "ofl__lianji-turn", to[1])
    end
  end,
}
local ofl__lianji_delay = fk.CreateTriggerSkill{
  name = "#ofl__lianji_delay",
  mute = true,
  events = {fk.EventPhaseChanging},
  can_trigger = function (self, event, target, player, data)
    if target == player and player:getMark("ofl__lianji_skipping") > 0 then
      data.to = player:getMark("ofl__lianji_skipping")
      player.phase = player:getMark("ofl__lianji_skipping")
      player.room:broadcastProperty(player, "phase")
      player.room:setPlayerMark(player, "ofl__lianji_skipping", 0)
      return true
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = Util.TrueFunc,

  refresh_events = {fk.EventPhaseChanging},
  can_refresh = function (self, event, target, player, data)
    return target == player and player:getMark("ofl__lianji-turn") ~= 0 and data.to < 8 and data.to > 1 and
      not player.room:getPlayerById(player:getMark("ofl__lianji-turn")).dead
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(player:getMark("ofl__lianji-turn"))
    player.phase = Player.PhaseNone
    room:broadcastProperty(player, "phase")
    room:setPlayerMark(player, "ofl__lianji_skipping", data.to)

    local skip = room.logic:trigger(fk.EventPhaseChanging, to, {
        from = to.phase,
        to = data.to,
      })
    to.phase = data.to
    room:broadcastProperty(to, "phase")

    local cancel_skip = true
    if data.to ~= Player.NotActive and (skip) then
      cancel_skip = room.logic:trigger(fk.EventPhaseSkipping, to)
    end

    if (not skip) or (cancel_skip) then
      GameEvent.Phase:create(to, to.phase):exec()
    else
      room:sendLog{
        type = "#PhaseSkipped",
        from = to.id,
        arg = data.to,
      }
    end
  end,
}
local ofl__moucheng = fk.CreateViewAsSkill{
  name = "ofl__moucheng",
  anim_type = "control",
  pattern = "collateral",
  prompt = "#ofl__moucheng",
  card_filter = function (self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).color == Card.Black
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard("collateral")
    card.skillName = self.name
    card:addSubcard(cards[1])
    return card
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryTurn) == 0
  end,
}
ofl__lianji:addRelatedSkill(ofl__lianji_delay)
wangyun:addSkill(ofl__lianji)
wangyun:addSkill(ofl__moucheng)
Fk:loadTranslationTable{
  ["ofl__wangyun"] = "王允",
  ["#ofl__wangyun"] = "计随鞘出",
  ["illustrator:ofl__wangyun"] = "鬼画府",

  ["ofl__lianji"] = "连计",
  [":ofl__lianji"] = "出牌阶段结束时，若你本阶段使用牌类别数不小于：1，你可以令一名角色摸一张牌；2.你可以回复1点体力；3.你可以令一名其他角色"..
  "代替你执行本回合剩余阶段。",
  ["ofl__moucheng"] = "谋逞",
  [":ofl__moucheng"] = "每回合限一次，你可以将一张黑色牌当【借刀杀人】使用。",
  ["#ofl__lianji1-invoke"] = "连计：你可以令一名角色摸一张牌",
  ["#ofl__lianji2-invoke"] = "连计：你可以回复1点体力",
  ["#ofl__lianji3-invoke"] = "连计：你可以令一名其他角色代替你执行本回合剩余阶段",
  ["#ofl__moucheng"] = "谋逞：你可以将一张黑色牌当【借刀杀人】使用",
}

local longyufei = General(extension, "longyufei", "shu", 3, 4, General.Female)
local longyi = fk.CreateViewAsSkill{
  name = "longyi",
  anim_type = "special",
  pattern = ".|.|.|.|.|basic",
  prompt = "#longyi",
  interaction = function()
    local all_names = U.getAllCardNames("b")
    local names = U.getViewAsCardNames(Self, "longyi", all_names, Self:getCardIds("h"))
    if #names > 0 then
      return U.CardNameBox { choices = names, all_choices = all_names }
    end
  end,
  card_filter = Util.FalseFunc,
  view_as = function(self, cards)
    if not self.interaction.data then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = self.name
    card:addSubcards(Self:getCardIds("h"))
    return card
  end,
  before_use = function(self, player, use)
    if table.find(use.card.subcards, function (id)
      return Fk:getCardById(id).type == Card.TypeTrick
    end) then
      player:drawCards(1, self.name)
    end
    if table.find(use.card.subcards, function (id)
      return Fk:getCardById(id).type == Card.TypeEquip
    end) then
      use.disresponsiveList = table.map(player.room.alive_players, Util.IdMapper)
    end
  end,
  enabled_at_play = function(self, player)
    return not player:isKongcheng()
  end,
  enabled_at_response = function(self, player, response)
    return not player:isKongcheng()
  end,
}
local zhenjue = fk.CreateTriggerSkill{
  name = "zhenjue",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target.phase == Player.Finish and player:isKongcheng() and not target.dead
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askForSkillInvoke(player, self.name, nil, "#zhenjue-invoke::"..target.id) then
      self.cost_data = {tos = {target.id}}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if target:isNude() or
      #room:askForDiscard(target, 1, 1, true, self.name, true, nil, "#zhenjue-discard:"..player.id) == 0 then
      player:drawCards(1, self.name)
    end
  end,
}
longyufei:addSkill(longyi)
longyufei:addSkill(zhenjue)
Fk:loadTranslationTable{
  ["longyufei"] = "龙羽飞",
  ["#longyufei"] = "将星之魂",
  ["illustrator:longyufei"] = "DH",

  ["longyi"] = "龙裔",
  [":longyi"] = "你可以将所有手牌当任意一张基本牌使用或打出，若其中有：锦囊牌，你摸一张牌；装备牌，此牌不可被响应。",
  ["zhenjue"] = "阵绝",
  [":zhenjue"] = "一名角色结束阶段，若你没有手牌，你可以令其选择一项：1.弃置一张牌；2.你摸一张牌。",
  ["#longyi"] = "龙裔：你可以将所有手牌当任意一张基本牌使用或打出",
  ["#zhenjue-invoke"] = "阵绝：是否令 %dest 选择弃一张牌或令你摸一张牌？",
  ["#zhenjue-discard"] = "阵绝：请弃置一张牌，否则 %src 摸一张牌",
}

local sgsh__huanhua_blacklist = {
  "zuoci", "ol_ex__zuoci", "js__xushao", "shichangshi", "starsp__xiahoudun"
}

local nanhualaoxian = General(extension, "sgsh__nanhualaoxian", "qun", 3)
local sgsh__jidao = fk.CreateTriggerSkill{
  name = "sgsh__jidao",
  anim_type = "drawcard",
  events = {fk.PropertyChange},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and player.general == "sgsh__nanhualaoxian" and data.deputyGeneral and target.deputyGeneral ~= ""
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
  end,
}
local sgsh__feisheng = fk.CreateTriggerSkill{
  name = "sgsh__feisheng",
  anim_type = "drawcard",
  events = {fk.PropertyChange},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.deputyGeneral == "sgsh__nanhualaoxian" and
      data.deputyGeneral
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choices = {"draw2"}
    if player:isWounded() then
      table.insert(choices, "recover")
    end
    local choice = room:askForChoice(player, choices, self.name)
    if choice == "draw2" then
      player:drawCards(2, self.name)
    else
      room:recover({
        who = player,
        num = 1,
        recoverBy = player,
        skillName = self.name
      })
    end
  end,
}
local sgsh__jinghe = fk.CreateTriggerSkill{
  name = "sgsh__jinghe",
  anim_type = "support",
  events = {fk.BeforePropertyChange},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and data.deputyGeneral and data.deputyGeneral ~= "" and not target.dead
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#sgsh__jinghe-invoke::"..target.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    local generals = room:getNGenerals(2)
    local general = room:askForGeneral(target, generals, 1, true)
    if general == nil then
      general = table.random(generals)
    end
    table.removeOne(generals, general)
    room:returnToGeneralPile(generals)
    data.deputyGeneral = general
  end,
}
local sgsh__huanhua = fk.CreateTriggerSkill{
  name = "sgsh__huanhua",
  mute = true,
  frequency = Skill.Compulsory,
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return target == player and not player.dead
  end,
  on_trigger = function(self, event, target, player, data)  --假装不是技能
    local room = player.room
    for i = 1, data.damage do
      if player.dead then break end
      local generals = table.filter(room.general_pile, function(name)
        return not table.contains(sgsh__huanhua_blacklist, name)
      end)
      local general = table.random(generals)
      table.removeOne(room.general_pile, general)
      if player.deputyGeneral ~= "" then
        room:returnToGeneralPile({player.deputyGeneral})
      end
      room:changeHero(player, general, false, true, true, false, false)
    end
  end,
}
nanhualaoxian:addSkill(sgsh__jidao)
nanhualaoxian:addSkill(sgsh__feisheng)
nanhualaoxian:addSkill(sgsh__jinghe)
nanhualaoxian:addSkill(sgsh__huanhua)
Fk:loadTranslationTable{
  ["sgsh__nanhualaoxian"] = "幻南华老仙",
  ["#sgsh__nanhualaoxian"] = "虚步太清",
  ["illustrator:sgsh__nanhualaoxian"] = "鬼画府",

  ["sgsh__jidao"] = "祭祷",
  [":sgsh__jidao"] = "主将技，当一名角色的副将被移除时，你可以摸一张牌。",
  ["sgsh__feisheng"] = "飞升",
  [":sgsh__feisheng"] = "副将技，当此武将牌被移除时，你可以回复1点体力或摸两张牌。",
  ["sgsh__jinghe"] = "经合",
  [":sgsh__jinghe"] = "当一名其他角色获得副将武将牌前，你可以令其改为观看两张未加入游戏的武将牌并选择一张作为副将。",
  ["sgsh__huanhua"] = "幻化",
  [":sgsh__huanhua"] = "锁定技，当一名角色受到1点伤害后，移除其副将，其从未加入游戏的武将牌中随机获得一张作为副将。此技能不会失效。",
  --原本是一个逆天的四将模式，魔改一下
  ["#sgsh__jinghe-invoke"] = "经合：%dest 即将获得随机副将，是否改为其观看两张并选择一张作为副将？",

  ["$sgsh__jidao"] = "含气求道，祸福难料，且与阁下共参之。",
  ["$sgsh__feisheng"] = "蕴气修德，其理易现，容吾为君讲解一二。",
  ["$sgsh__jinghe1"] = "此经所书晦涩难明，吾偶有所悟，愿为君陈之。",
  ["$sgsh__jinghe2"] = "大音希声，大象无形，天理难明，以经合之。",
  ["~sgsh__nanhualaoxian"] = "此理闻所未闻，参不透啊。",
}

local sgsh__zuoci = General(extension, "sgsh__zuoci", "qun", 3)
local sgsh__huashen = fk.CreateActiveSkill{
  name = "sgsh__huashen",
  prompt = "#sgsh__huashen",
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local skills = Fk.generals[target.general]:getSkillNameList()
      if Fk.generals[target.deputyGeneral] then
        table.insertTableIfNeed(skills, Fk.generals[target.deputyGeneral]:getSkillNameList())
      end
      skills = table.filter(skills, function(skill_name)
        local skill = Fk.skills[skill_name]
        return not player:hasSkill(skill, true) and (#skill.attachedKingdom == 0 or table.contains(skill.attachedKingdom, player.kingdom))
      end)
      if #skills > 0 then
        local skill = room:askForChoice(player, skills, self.name, "#sgsh__huashen-choice", true)
        room:setPlayerMark(player, "@sgsh__huashen-turn", skill)
        room:handleAddLoseSkills(player, skill, nil, true, false)
      end
  end,
}
local sgsh__huashen_delay = fk.CreateTriggerSkill {
  name = "#sgsh__huashen_delay",

  refresh_events = {fk.TurnEnd},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@sgsh__huashen-turn") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    local skill = player:getMark("@sgsh__huashen-turn")
    player.room:handleAddLoseSkills(player, "-"..skill, nil, true, true)
  end,
}
local sgsh__xinsheng = fk.CreateTriggerSkill{
  name = "sgsh__xinsheng",
  anim_type = "special",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Start and
      player.general == "sgsh__zuoci" and player.deputyGeneral ~= ""
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:returnToGeneralPile({player.deputyGeneral})
    room:changeHero(player, "", false, true, true, false, false)
    if player.dead then return end
    local generals = table.filter(room.general_pile, function(name)
      return not table.contains(sgsh__huanhua_blacklist, name)
    end)
    local general = table.random(generals)
    table.removeOne(room.general_pile, general)
    room:changeHero(player, general, false, true, true, false, false)
  end,
}
sgsh__huashen:addRelatedSkill(sgsh__huashen_delay)
sgsh__zuoci:addSkill(sgsh__huashen)
sgsh__zuoci:addSkill(sgsh__xinsheng)
sgsh__zuoci:addSkill("sgsh__huanhua")
Fk:loadTranslationTable{
  ["sgsh__zuoci"] = "幻左慈",
  ["#sgsh__zuoci"] = "谜之仙人",
  ["illustrator:sgsh__zuoci"] = "JanusLausDeo",

  ["sgsh__huashen"] = "化身",
  [":sgsh__huashen"] = "出牌阶段限一次，你可以选择一名其他角色，声明其武将牌上的一个技能，你获得此技能直到回合结束。",
  ["sgsh__xinsheng"] = "新生",
  [":sgsh__xinsheng"] = "主将技，准备阶段，你可以移除副将，然后随机获得一张未加入游戏的武将牌作为副将。",
  ["#sgsh__huashen"] = "化身：获得一名其他角色武将牌上的一个技能，直到回合结束",
  ["#sgsh__huashen-choice"] = "化身：选择你要获得的技能",
  ["@sgsh__huashen-turn"] = "化身",

  ["$sgsh__huashen1"] = "幻化之术谨之，为政者自当为国为民。",
  ["$sgsh__huashen2"] = "天之政者，不可逆之，逆之，虽胜必衰矣。",
  ["$sgsh__xinsheng1"] = "傍日月，携宇宙，游乎尘垢之外。",
  ["$sgsh__xinsheng2"] = "吾多与天地精神之往来，生即死，死又复生。",
  ["~sgsh__zuoci"] = "万事，皆有因果。",
}

local sgsh__jianggan = General(extension, "sgsh__jianggan", "wei", 3)
local sgsh__daoshu = fk.CreateActiveSkill{
  name = "sgsh__daoshu",
  anim_type = "offensive",
  card_num = 0,
  target_num = 1,
  prompt = "#sgsh__daoshu",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local suits = {"log_spade", "log_club", "log_heart", "log_diamond"}
    local choice = room:askForChoice(player, suits, self.name)
    room:doBroadcastNotify("ShowToast", Fk:translate(player.general)..Fk:translate("#sgsh__daoshu-chose")..Fk:translate(choice))
    if target:isKongcheng() then
      room:damage{
        from = player,
        to = target,
        damage = 1,
        skillName = self.name,
      }
    else
      target:showCards(target:getCardIds("h"))
      if target.dead then return end
      local cards = table.filter(target:getCardIds("h"), function(id) return Fk:getCardById(id):getSuitString(true) == choice end)
      if #cards == 0 then
        room:damage{
          from = player,
          to = target,
          damage = 1,
          skillName = self.name,
        }
      elseif player.dead or room:askForSkillInvoke(target, self.name, nil, "#sgsh__daoshu-give:"..player.id.."::"..choice) then
        room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonGive, self.name, nil, true, target.id)
      else
        room:damage{
          from = player,
          to = target,
          damage = 1,
          skillName = self.name,
        }
      end
    end
  end,
}
sgsh__jianggan:addSkill(sgsh__daoshu)
sgsh__jianggan:addSkill("weicheng")
Fk:loadTranslationTable{
  ["sgsh__jianggan"] = "蒋干",
  ["sgsh__daoshu"] = "盗书",
  [":sgsh__daoshu"] = "出牌阶段限一次，你可以选择一名其他角色并声明一种花色，其展示所有手牌并选择一项：1.交给你所有你此花色的手牌；2.你对其造成1点伤害。",
  ["#sgsh__daoshu"] = "盗书：声明一种花色，令一名角色选择交给你所有此花色手牌或你对其造成伤害",
  ["#sgsh__daoshu-chose"] = "盗书选择了：",
  ["#sgsh__daoshu-give"] = "盗书：交给%src所有%arg手牌，或点“取消”其对你造成1点伤害",

  ["$sgsh__daoshu1"] = "赤壁之战，我军之患，不足为惧。",
  ["$sgsh__daoshu2"] = "取此机密，简直易如反掌。",
  ["$weicheng_sgsh__jianggan1"] = "公瑾，吾之诚心，天地可鉴。",
  ["$weicheng_sgsh__jianggan2"] = "遥闻芳烈，故来叙阔。",
  ["~sgsh__jianggan"] = "蔡张之罪，非我之过呀！",
}

local sgsh__huaxiong = General(extension, "sgsh__huaxiong", "qun", 4)
local sgsh__yaowu = fk.CreateTriggerSkill{
  name = "sgsh__yaowu",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.DamageCaused, fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card and data.card.trueName == "slash"
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
  end,
}
sgsh__huaxiong:addSkill(sgsh__yaowu)
Fk:loadTranslationTable{
  ["sgsh__huaxiong"] = "华雄",
  ["sgsh__yaowu"] = "耀武",
  [":sgsh__yaowu"] = "锁定技，当一名角色对你使用【杀】造成伤害时，或当你使用【杀】造成伤害时，你摸一张牌。",

  ["$sgsh__yaowu1"] = "来将通名，吾刀下不斩无名之辈！",
  ["$sgsh__yaowu2"] = "且看汝比那祖茂潘凤如何？",
  ["~sgsh__huaxiong"] = "错失先机，呃啊！",
}

local sgsh__lisu = General(extension, "sgsh__lisu", "qun", 3)
local sgsh__kuizhul = fk.CreateTriggerSkill{
  name = "sgsh__kuizhul",
  anim_type = "support",
  events = {fk.Damage},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target and target ~= player and not player:isKongcheng() and not target.dead
  end,
  on_cost = function(self, event, target, player, data)
    local card = player.room:askForCard(player, 1, 1, false, self.name, true, ".", "#sgsh__kuizhul-invoke::"..target.id)
    if #card > 0 then
      self.cost_data = card[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:moveCardTo(Fk:getCardById(self.cost_data), Card.PlayerHand, target, fk.ReasonGive, self.name, nil, false, player.id)
    if not player.dead and player:getHandcardNum() > target:getHandcardNum() then
      player:drawCards(1, self.name)
    end
  end,
}
local sgsh__qiaoyan = fk.CreateTriggerSkill{
  name = "sgsh__qiaoyan",
  anim_type = "support",
  events = {fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and player:usedSkillTimes("sgsh__kuizhul", Player.HistoryTurn) > 0 and player:isWounded()
  end,
  on_use = function(self, event, target, player, data)
    player.room:recover({
      who = player,
      num = 1,
      recoverBy = player,
      skillName = self.name,
    })
  end,
}
sgsh__lisu:addSkill(sgsh__kuizhul)
sgsh__lisu:addSkill(sgsh__qiaoyan)
Fk:loadTranslationTable{
  ["sgsh__lisu"] = "李肃",
  ["sgsh__kuizhul"] = "馈珠",
  [":sgsh__kuizhul"] = "当一名其他角色造成伤害后，你可以交给其一张手牌，然后若其手牌数小于你，你摸一张牌。",
  ["sgsh__qiaoyan"] = "巧言",
  [":sgsh__qiaoyan"] = "一名角色结束阶段，若你本回合发动过〖馈珠〗，你可以回复1点体力。",
  ["#sgsh__kuizhul-invoke"] = "馈珠：你可以交给 %dest 一张手牌",

  ["$sgsh__kuizhul1"] = "宝珠万千，皆予将军一人。",
  ["$sgsh__kuizhul2"] = "馈珠还情，邀买人心。",
  ["$sgsh__qiaoyan1"] = "金银渐欲迷人眼，利字当前诱汝行！",
  ["$sgsh__qiaoyan2"] = "以利驱虎，无往不利！",
  ["~sgsh__lisu"] = "见利忘义，必遭天谴。",
}

local mengda = General(extension, "ofl__mengda", "shu", 4)
mengda.subkingdom = "wei"
local qiuan = fk.CreateTriggerSkill{
  name = "ofl__qiuan",
  mute = true,
  events = {fk.DamageInflicted},
  derived_piles = "ofl__mengda_letter",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card
      and #player:getPile("ofl__mengda_letter") == 0 and U.hasFullRealCard(player.room, data.card)
  end,
  on_use = function(self, event, target, player, data)
    player:broadcastSkillInvoke("ld__qiuan")
    player.room:notifySkillInvoked(player, self.name, "defensive")
    player:addToPile("ofl__mengda_letter", data.card, true, self.name)
    if #player:getPile("ofl__mengda_letter") > 0 then
      return true
    end
  end,
}
local liangfan = fk.CreateTriggerSkill{
  name = "ofl__liangfan",
  mute = true,
  events = {fk.TurnStart, fk.Damage},
  can_trigger = function(self, event, target, player, data)
    if event == fk.TurnStart then
      return target == player and player:hasSkill(self) and #player:getPile("ofl__mengda_letter") > 0
    end
    if event == fk.Damage then
      return target == player and player:usedSkillTimes(self.name, Player.HistoryTurn) > 0 and
        data.card and data.card:getMark("@@ofl__mengda_letter-turn") > 0 and
        not data.to:isNude() and not player.dead and not data.to.dead
    end
  end,
  on_cost = function(self, event, target, player, data)
    if event == fk.TurnStart then
      return true
    else
      return player.room:askForSkillInvoke(player, self.name, nil, "#ofl__liangfan-invoke::"..data.to.id)
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("ld__liangfan")
    if event == fk.TurnStart then
      room:notifySkillInvoked(player, self.name, "drawcard")
      for _, id in ipairs(player:getPile("ofl__mengda_letter")) do
        room:setCardMark(Fk:getCardById(id), "@@ofl__mengda_letter-turn", 1)
      end
      room:obtainCard(player, player:getPile("ofl__mengda_letter"), true)
      if not player.dead then
        room:loseHp(player, 1, self.name)
      end
    else
      room:notifySkillInvoked(player, self.name, "control")
      room:doIndicate(player.id, {data.to.id})
      local card = room:askForCardChosen(player, data.to, "he", self.name)
      room:obtainCard(player, card, false, fk.ReasonPrey)
    end
  end,
}
mengda:addSkill(qiuan)
mengda:addSkill(liangfan)
Fk:loadTranslationTable{
  ["ofl__mengda"] = "孟达",
  ["#ofl__mengda"] = "怠军反复",
  ["designer:ofl__mengda"] = "韩旭",
  ["illustrator:ofl__mengda"] = "张帅",

  ["ofl__qiuan"] = "求安",
  [":ofl__qiuan"] = "当你受到伤害时，若没有“函”，你可以防止此伤害，并将造成此伤害的牌置于武将牌上，称为“函”。",
  ["ofl__liangfan"] = "量反",
  [":ofl__liangfan"] = "回合开始时，若你有“函”，你获得之，然后失去1点体力；当你本回合内使用此牌造成伤害后，你可以获得受伤角色的一张牌。",
  ["ofl__mengda_letter"] = "函",
  ["@@ofl__mengda_letter-turn"] = "函",
  ["#ofl__liangfan-invoke"] = "量反：是否获得 %dest 一张牌？",

  ["$ofl__qiuan1"] = "明公神文圣武，吾自当举城来降。",
  ["$ofl__qiuan2"] = "臣心不自安，乃君之过也。",
  ["$ofl__liangfan1"] = "今举兵投魏，必可封王拜相，一展宏图。",
  ["$ofl__liangfan2"] = "今举义军事若成，吾为复汉元勋也。",
  ["~ofl__mengda"] = "吾一生寡信，今报应果然来矣...",
}

local wenqin = General(extension, "ofl__wenqin", "wei", 4)
wenqin.subkingdom = "wu"
local jinfa = fk.CreateActiveSkill{
  name = "ofl__jinfa",
  mute = true,
  card_num = 1,
  target_num = 1,
  prompt = "#ofl__jinfa",
  can_use = function (self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player:isNude()
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and not Self:prohibitDiscard(to_select)
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and not Fk:currentRoom():getPlayerById(to_select):isNude() and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    player:broadcastSkillInvoke("ld__jinfa")
    room:notifySkillInvoked(player, self.name, "control")
    room:throwCard(effect.cards, self.name, player, player)
    if target.dead then return end
    local card1 = room:askForCard(target, 1, 1, true, self.name, true, ".|.|.|.|.|equip", "ofl__jinfa_give:"..player.id)
    if #card1 == 1 then
      room:moveCardTo(card1, Card.PlayerHand, player, fk.ReasonGive, self.name, nil, true, target.id)
      if Fk:getCardById(card1[1]).suit == Card.Spade and not player.dead and not target.dead then
        room:useVirtualCard("slash", nil, target, player, self.name, true)
      end
    else
      local card2 = room:askForCardChosen(player, target, "he", self.name)
      room:moveCardTo(card2, Card.PlayerHand, player, fk.ReasonPrey, self.name, nil, true, player.id)
    end
  end,
}
wenqin:addSkill(jinfa)
Fk:loadTranslationTable{
  ["ofl__wenqin"] = "文钦",
  ["#ofl__wenqin"] = "勇而无算",
  ["designer:ofl__wenqin"] = "逍遥鱼叔",
  ["illustrator:ofl__wenqin"] = "匠人绘-零二",

  ["ofl__jinfa"] = "矜伐",
  [":ofl__jinfa"] = "出牌阶段限一次，你可弃置一张牌并选择一名其他角色，令其选择一项：1.你获得其一张牌；2.交给你一张装备牌，若为♠，"..
  "其视为对你使用一张【杀】。",
  ["#ofl__jinfa"] = "矜伐：弃置一张牌，令一名角色选择你获得其一张牌或其交给你一张装备牌",
  ["ofl__jinfa_give"] = "矜伐：交给 %src 一张装备牌，否则其获得你一张牌",

  ["$ofl__jinfa1"] = "居功者，当自矜，为将者，当善伐。",
  ["$ofl__jinfa2"] = "此战伐敌所获，皆我之功。",
  ["~ofl__wenqin"] = "公休，汝这是何意，呃……",
}

local sunchen = General(extension, "ofl__sunchen", "wu", 4)
local ofl__shilus = fk.CreateTriggerSkill{
  name = "ofl__shilus",
  mute = true,
  events = {fk.GameStart, fk.Deathed, fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      if event == fk.EventPhaseStart then
        return player == target and player.phase == Player.Start and not player:isNude() and #player:getTableMark("@&massacre") > 0
      else
        return true
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if event == fk.EventPhaseStart then
      local x = #player:getMark("@&massacre")
      local cards = room:askForDiscard(player, 1, x, true, self.name, true, ".", "#ofl__shilus-cost:::"..tostring(x), true)
      if #cards > 0 then
        self.cost_data = cards
        return true
      end
    elseif event == fk.GameStart then
      return true
    else
      return player.room:askForSkillInvoke(player, self.name, nil, "#ofl__shilus-invoke::"..target.id)
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("shilus")
    if event == fk.EventPhaseStart then
      room:notifySkillInvoked(player, self.name, "drawcard")
      room:throwCard(self.cost_data, self.name, player, player)
      if not player.dead then
        room:drawCards(player, #self.cost_data, self.name)
      end
    else
      room:notifySkillInvoked(player, self.name, "special")
      local cards = {}
      if event == fk.GameStart then
        table.insertTableIfNeed(cards, room:getNGenerals(2))
      elseif event == fk.Deathed then
        room:doIndicate(player.id, {target.id})
        if target.general and target.general ~= "" and target.general ~= "hiddenone" then
          room:findGeneral(target.general)
          table.insert(cards, target.general)
        end
        if target.deputyGeneral and target.deputyGeneral ~= "" and target.deputyGeneral ~= "hiddenone" then
          room:findGeneral(target.deputyGeneral)
          table.insert(cards, target.deputyGeneral)
        end
        if data.damage and data.damage.from == player then
          table.insertTableIfNeed(cards, room:getNGenerals(2))
        end
      end
      if #cards > 0 then
        local generals = player:getTableMark("@&massacre")
        table.insertTableIfNeed(generals, cards)
        room:setPlayerMark(player, "@&massacre", generals)
      end
    end
  end,

  refresh_events = {fk.EventLoseSkill, fk.BuryVictim},
  can_refresh = function(self, event, target, player, data)
    if target == player and player:getMark("@&massacre") ~= 0 then
      if event == fk.EventLoseSkill then
        return data == self
      elseif event == fk.BuryVictim then
        return true
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:returnToGeneralPile(player:getTableMark("@&massacre"))
    room:setPlayerMark(player, "@&massacre", 0)
  end,
}
local ofl__xiongnve = fk.CreateTriggerSkill{
  name = "ofl__xiongnve",
  mute = true,
  events = {fk.EventPhaseStart, fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and player.phase == Player.Play then
      local n = #player:getTableMark("@&massacre")
      if event == fk.EventPhaseStart then
        return n > 0
      else
        return n > 1
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    if event == fk.EventPhaseStart then
      local result = player.room:askForCustomDialog(player, self.name,
        "packages/utility/qml/ChooseGeneralsAndChoiceBox.qml", {
          player:getMark("@&massacre"),
          {"ofl__xiongnve_choice1", "ofl__xiongnve_choice2", "ofl__xiongnve_choice3"},
          "#ofl__xiongnve-chooose",
          {"Cancel"}
        })
      if result ~= "" then
        local reply = json.decode(result)
        if reply.choice ~= "Cancel" then
          self.cost_data = {reply.cards, reply.choice}
          return true
        end
      end
    else
      local result = player.room:askForCustomDialog(player, self.name,
      "packages/utility/qml/ChooseGeneralsAndChoiceBox.qml", {
        player:getMark("@&massacre"),
        {"OK"},
        "#ofl__xiongnve-defence",
        {"Cancel"},
        2,
        2
      })
      if result ~= "" then
        local reply = json.decode(result)
        if reply.choice == "OK" then
          self.cost_data = {reply.cards}
          return true
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("xiongnve")
    if event == fk.EventPhaseStart then
      room:notifySkillInvoked(player, self.name, "offensive")
    else
      room:notifySkillInvoked(player, self.name, "defensive")
    end
    local generals = player:getTableMark("@&massacre")
    for _, name in ipairs(self.cost_data[1]) do
      table.removeOne(generals, name)
    end
    if #generals == 0 then
      room:setPlayerMark(player, "@&massacre", 0)
    else
      room:setPlayerMark(player, "@&massacre", generals)
    end
    room:returnToGeneralPile(self.cost_data[1])
    if event == fk.EventPhaseStart then
      room:setPlayerMark(player, "@ofl__xiongnve_choice-turn", "ofl__xiongnve_effect" .. string.sub(self.cost_data[2], 21, 21))
    elseif event == fk.EventPhaseEnd then
      room:setPlayerMark(player, "@@ofl__xiongnve", 1)
    end
  end,

  refresh_events = {fk.TurnStart},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@@ofl__xiongnve") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@ofl__xiongnve", 0)
  end,
}
local ofl__xiongnve_delay = fk.CreateTriggerSkill{
  name = "#ofl__xiongnve_delay",
  mute = true,
  events = {fk.DamageCaused, fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    if target == player and not player.dead then
      if event == fk.DamageCaused then
        if not data.to.dead then
          local effect_name = player:getMark("@ofl__xiongnve_choice-turn")
          if effect_name == "ofl__xiongnve_effect1" then
            return true
          elseif effect_name == "ofl__xiongnve_effect2" then
            return #data.to:getCardIds("e") > 0 or (not data.to:isKongcheng() and data.to ~= player)
          end
        end
      else
        return player:getMark("@@ofl__xiongnve") > 0 and data.from and data.from ~= player
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("xiongnve")
    if event == fk.DamageCaused then
      room:doIndicate(player.id, {data.to.id})
      local effect_name = player:getMark("@ofl__xiongnve_choice-turn")
      if effect_name == "ofl__xiongnve_effect1" then
        room:notifySkillInvoked(player, "ofl__xiongnve", "offensive")
        data.damage = data.damage + 1
      elseif effect_name == "ofl__xiongnve_effect2" then
        room:notifySkillInvoked(player, "ofl__xiongnve", "control")
        local flag =  data.to == player and "e" or "he"
        local card = room:askForCardChosen(player, data.to, flag, self.name)
        room:obtainCard(player.id, card, false, fk.ReasonPrey)
      end
    else
      room:notifySkillInvoked(player, "ofl__xiongnve", "defensive")
      data.damage = data.damage - 1
    end
  end,
}
local ofl__xiongnve_targetmod = fk.CreateTargetModSkill{
  name = "#ofl__xiongnve_targetmod",
  bypass_times = function(self, player, skill, scope, card, to)
    return card and player:getMark("@ofl__xiongnve_choice-turn") == "ofl__xiongnve_effect3"
  end,
}
ofl__xiongnve:addRelatedSkill(ofl__xiongnve_delay)
ofl__xiongnve:addRelatedSkill(ofl__xiongnve_targetmod)
sunchen:addSkill(ofl__shilus)
sunchen:addSkill(ofl__xiongnve)
Fk:loadTranslationTable{
  ["ofl__sunchen"] = "孙綝",
  ["#ofl__sunchen"] = "食髓的朝堂客",
  ["designer:ofl__sunchen"] = "逍遥鱼叔",
  ["illustrator:ofl__sunchen"] = "depp",

  ["ofl__shilus"] = "嗜戮",
  [":ofl__shilus"] = "游戏开始时，你从剩余武将牌堆获得两张“戮”；其他角色死亡时，你可将其武将牌置为“戮”；当你杀死其他角色时，你从剩余武将牌堆"..
  "额外获得两张“戮”。回合开始时，你可以弃置至多X张牌（X为“戮”数），摸等量的牌。",
  ["ofl__xiongnve"] = "凶虐",
  [":ofl__xiongnve"] = "出牌阶段开始时，你可以移去一张“戮”并选择一项：1.本回合造成伤害+1；2.本回合对其他角色造成伤害时，你获得其一张牌；"..
  "3.本回合使用牌无次数限制。<br>出牌阶段结束时，你可以移去两张“戮”，你受到其他角色的伤害-1直到你下回合开始。",

  ["@&massacre"] = "戮",
  ["#ofl__shilus-cost"] = "嗜戮：你可以弃置至多%arg张牌，摸等量的牌",
  ["#ofl__shilus-invoke"] = "嗜戮：是否将 %dest 的武将牌置为“戮”？",
  ["#ofl__xiongnve-chooose"] = "凶虐：你可以弃置一张“戮”，获得一项效果",
  ["ofl__xiongnve_choice1"] = "增加伤害",
  ["ofl__xiongnve_choice2"] = "造成伤害时拿牌",
  ["ofl__xiongnve_choice3"] = "用牌无次数限制",
  ["#ofl__xiongnve-defence"] = "凶虐：你可以弃置两张“戮”，受到伤害-1直到你下回合开始",
  ["@ofl__xiongnve_choice-turn"] = "凶虐",
  ["ofl__xiongnve_effect1"] = "增加伤害",
  ["ofl__xiongnve_effect2"] = "造伤拿牌",
  ["ofl__xiongnve_effect3"] = "无限用牌",
  ["@@ofl__xiongnve"] = "凶虐",

  ["$ofl__shilus1"] = "以杀立威，谁敢反我？",
  ["$ofl__shilus2"] = "将这些乱臣贼子，尽皆诛之！",
  ["$ofl__xiongnve1"] = "当今天子乃我所立，他敢怎样？",
  ["$ofl__xiongnve2"] = "我兄弟三人同掌禁军，有何所惧？",
  ["~ofl__sunchen"] = "愿陛下念臣昔日之功，陛下？陛下！！",
}

--官盗E14至宝：周姬
local zhouji = General(extension, "zhouji", "wu", 3, 3, General.Female)
local ofl__yanmouz = fk.CreateTriggerSkill{
  name = "ofl__yanmouz",
  anim_type = "drawcard",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      local dat = 1
      local ids = {}
      local room = player.room
      for _, move in ipairs(data) do
        if move.toArea == Card.DiscardPile then
          if move.moveReason == fk.ReasonDiscard and move.from and move.from ~= player.id then
            for _, info in ipairs(move.moveInfo) do
              if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
                (Fk:getCardById(info.cardId).name == "fire__slash" or Fk:getCardById(info.cardId).trueName == "fire_attack") and
                room:getCardArea(info.cardId) == Card.DiscardPile then
                table.insertIfNeed(ids, info.cardId)
              end
            end
          elseif move.moveReason == fk.ReasonJudge then
            local judge_event = room.logic:getCurrentEvent():findParent(GameEvent.Judge)
            if judge_event and judge_event.data[1].who ~= player then
              for _, info in ipairs(move.moveInfo) do
                if info.fromArea == Card.Processing and
                  (Fk:getCardById(info.cardId).name == "fire__slash" or Fk:getCardById(info.cardId).trueName == "fire_attack") and
                  room:getCardArea(info.cardId) == Card.DiscardPile then
                  table.insertIfNeed(ids, info.cardId)
                end
              end
            end
          end
        elseif move.to == player.id and move.toArea == Player.Hand then
          for _, info in ipairs(move.moveInfo) do
            if (Fk:getCardById(info.cardId).name == "fire__slash" or Fk:getCardById(info.cardId).trueName == "fire_attack") then
              table.insertIfNeed(ids, info.cardId)
              dat = 2
            end
          end
        end
      end
      ids = U.moveCardsHoldingAreaCheck(room, ids)
      if #ids > 0 then
        self.cost_data = {ids, dat}
        return true
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if self.cost_data[2] == 1 then
      return room:askForSkillInvoke(player, self.name, nil, "#ofl__yanmouz-invoke")
    else
      local use = U.askForUseRealCard(room, player, self.cost_data[1], ".", self.name, "#ofl__yanmouz-use",
      { bypass_times = true, extraUse = true }, true)
      if use then
        self.cost_data = {use, 2}
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if self.cost_data[2] == 1 then
      local ids = table.simpleClone(self.cost_data[1])
      if #ids == 0 then return end
      local cards, _ = U.askforChooseCardsAndChoice(player, ids, {"OK"}, self.name, "#ofl__yanmouz-choose", {"get_all"}, 1, #ids)
      if #cards > 0 then
        ids = cards
      end
      room:moveCardTo(ids, Card.PlayerHand, player, fk.ReasonPrey, self.name)
    else
      room:useCard(table.simpleClone(self.cost_data[1]))
    end
  end,
}
local ofl__zhanyan = fk.CreateActiveSkill{
  name = "ofl__zhanyan",
  anim_type = "offensive",
  card_num = 0,
  target_num = 0,
  prompt = function(self, card)
    return "#ofl__zhanyan-active"
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and
      table.find(Fk:currentRoom().alive_players, function(p) return player:inMyAttackRange(p) end)
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local targets = table.filter(room:getOtherPlayers(player), function(p)
      return player:inMyAttackRange(p) end)
    if #targets == 0 then return end
    room:doIndicate(player.id, table.map(targets, Util.IdMapper))
    local n1, n2 = 0, 0
    for _, target in ipairs(targets) do
      if not target.dead then
        local expand_pile = table.filter(room.discard_pile, function(id)
          return Fk:getCardById(id).name == "fire__slash" or Fk:getCardById(id).trueName == "fire_attack"
        end)
        local card = room:askForCard(target, 1, 1, false, self.name, true, ".|.|.|.|fire__slash;fire_attack",
          "#ofl__zhanyan-put", expand_pile)
        if #card == 1 then
          if table.contains(target:getCardIds(Player.Hand), card[1]) then
            n2 = n2 + 1
            room:moveCards({
              ids = card,
              from = target.id,
              toArea = Card.DrawPile,
              moveReason = fk.ReasonPut,
              skillName = self.name,
              proposer = target.id,
              moveVisible = true,
            })
          else
            room:moveCards({
              ids = card,
              toArea = Card.DrawPile,
              moveReason = fk.ReasonPut,
              skillName = self.name,
              proposer = target.id,
              moveVisible = true,
            })
          end
        else
          n1 = n1 + 1
          room:damage{
            from = player,
            to = target,
            damage = 1,
            damageType = fk.FireDamage,
            skillName = self.name,
          }
        end
      end
    end
    if not player.dead and n1 ~= 0 and n2 ~= 0 then
      player:drawCards(math.min(n1, n2), self.name)
    end
  end,
}
local ofl__yuhuo = fk.CreateTriggerSkill{
  name = "ofl__yuhuo",
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  events = {fk.DamageInflicted},
  can_trigger = function(self, _, target, player, data)
    return target == player and player:hasSkill(self) and data.damageType == fk.FireDamage
  end,
  on_use = Util.TrueFunc,
}
local ofl__yuhuo_maxcards = fk.CreateMaxCardsSkill{
  name = "#ofl__yuhuo_maxcards",
  main_skill = ofl__yuhuo,
  exclude_from = function(self, player, card)
    return player:hasSkill("ofl__yuhuo") and (card.name == "fire__slash" or card.trueName == "fire_attack")
  end,
}
ofl__yuhuo:addRelatedSkill(ofl__yuhuo_maxcards)
zhouji:addSkill(ofl__yanmouz)
zhouji:addSkill(ofl__zhanyan)
zhouji:addSkill(ofl__yuhuo)
Fk:loadTranslationTable{
  ["zhouji"] = "周姬",
  ["#zhouji"] = "江东的红莲",
  ["illustrator:zhouji"] = "xerez",

  ["ofl__yanmouz"] = "炎谋",
  [":ofl__yanmouz"] = "当其他角色的【火攻】、火【杀】因弃置或判定而置入弃牌堆后，你可以获得之；当你获得牌后，你可以使用其中一张【火攻】或火【杀】。",
  ["ofl__zhanyan"] = "绽焰",
  [":ofl__zhanyan"] = "出牌阶段限一次，你可以令你攻击范围内的所有角色依次选择一项：1.你对其造成1点火焰伤害；2.将手牌或弃牌堆中的一张"..
  "【火攻】或火【杀】置于牌堆顶。选择完成后，你摸X张牌（X为被选择次数较少的项被选择的次数）。",
  ["ofl__yuhuo"] = "驭火",
  [":ofl__yuhuo"] = "锁定技，防止你受到的火焰伤害；你手牌中的【火攻】和火【杀】不计入手牌上限。",

  ["#ofl__yanmouz-invoke"] = "炎谋：你可以获得其中的【火攻】和火【杀】",
  ["#ofl__yanmouz-use"] = "炎谋：你可以使用其中一张【火攻】或火【杀】",
  ["#ofl__yanmouz-choose"] = "炎谋：选择要获得的牌",
  ["#ofl__zhanyan-active"] = "绽焰：令攻击范围内的角色选择受到火焰伤害或将【火攻】或火【杀】置于牌堆顶",
  ["#ofl__zhanyan-put"] = "绽焰：将一张【火攻】或火【杀】置于牌堆顶，点“取消”则受到1点火焰伤害",
}

--官盗E9匡鼎炎汉：鄂焕
local ehuan = General(extension, "ehuan", "qun", 5)
ehuan.subkingdom = "shu"
local ofl__diwan = fk.CreateTriggerSkill{
  name = "ofl__diwan",
  anim_type = "drawcard",
  events = {fk.TargetSpecified},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryTurn) == 0 and
      data.card.trueName == "slash" and data.firstTarget and
      #AimGroup:getAllTargets(data.tos) > 0
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(#AimGroup:getAllTargets(data.tos), self.name)
  end,
}
local ofl__suiluan = fk.CreateTriggerSkill{
  name = "ofl__suiluan",
  anim_type = "offensive",
  events = {fk.AfterCardTargetDeclared},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and data.card.trueName == "slash" then
      local current_targets = TargetGroup:getRealTargets(data.tos)
      for _, p in ipairs(player.room.alive_players) do
        if not table.contains(current_targets, p.id) and not player:isProhibited(p, data.card) and
            data.card.skill:modTargetFilter(p.id, current_targets, data.from, data.card, true) then
          return true
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local current_targets = TargetGroup:getRealTargets(data.tos)
    local targets = {}
    for _, p in ipairs(room.alive_players) do
      if not table.contains(current_targets, p.id) and not player:isProhibited(p, data.card) and
          data.card.skill:modTargetFilter(p.id, current_targets, data.from, data.card, true) then
        table.insert(targets, p.id)
      end
    end
    local tos = room:askForChoosePlayers(player, targets, 1, 2, "#ofl__suiluan-choose:::"..data.card:toLogString(), self.name, true)
    if #tos > 0 then
      self.cost_data = tos
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    data.extra_data = data.extra_data or {}
    data.extra_data.ofl__suiluan = player.id
    table.insertTable(data.tos, table.map(self.cost_data, function(p) return {p} end))
  end,
}
local ofl__suiluan_delay = fk.CreateTriggerSkill{
  name = "#ofl__suiluan_delay",
  mute = true,
  events = {fk.CardUseFinished, fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    if target == player then
      if event == fk.CardUseFinished then
        return data.extra_data and data.extra_data.ofl__suiluan and data.extra_data.ofl__suiluan == player.id and
          #TargetGroup:getRealTargets(data.tos) > 0 and table.find(TargetGroup:getRealTargets(data.tos), function(id)
            return not player.room:getPlayerById(id).dead and player.room:getPlayerById(id):canUseTo(Fk:cloneCard("slash"), player)
          end)
      elseif data.card and player.kingdom ~= "shu" then
        local room = player.room
        local card_event = room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
        if not card_event then return false end
        local use = card_event.data[1]
        return use.extra_data and use.extra_data.ofl__suiluan_use and use.extra_data.ofl__suiluan_use == player.id
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.CardUseFinished then
      for _, id in ipairs(TargetGroup:getRealTargets(data.tos)) do
        if player.dead then return end
        local p = room:getPlayerById(id)
        if not p.dead and p:canUseTo(Fk:cloneCard("slash"), player) then
          local use = room:askForUseCard(p, "ofl__suiluan", "slash", "#ofl__suiluan-use:"..player.id, true, {must_targets = {player.id}})
          if use then
            use.extra_data = use.extra_data or {}
            use.extra_data.ofl__suiluan_use = player.id
            room:useCard(use)
          end
        end
      end
    else
      room:changeKingdom(player, "shu", true)
    end
  end,
}
local ofl__conghan = fk.CreateTriggerSkill{
  name = "ofl__conghan",
  events = {fk.Damage},
  can_trigger = function(self, event, target, player, data)
    return
      player:hasSkill(self) and
      target and
      target.seat == 1 and
      player:canUseTo(Fk:cloneCard("slash"), data.to, {bypass_distances = true, bypass_times = true})
  end,
  on_cost = function(self, event, target, player, data)
    local use = player.room:askForUseCard(player, self.name, "slash", "#ofl__conghan-use::"..data.to.id, true,
      { must_targets = {data.to.id}, bypass_distances = true, bypass_times = true })
    if use then
      self.cost_data = use
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:useCard(self.cost_data)
  end,
}
ofl__suiluan:addRelatedSkill(ofl__suiluan_delay)
ofl__suiluan:addAttachedKingdom("qun")
ofl__conghan:addAttachedKingdom("shu")
ehuan:addSkill(ofl__diwan)
ehuan:addSkill(ofl__suiluan)
ehuan:addSkill(ofl__conghan)
Fk:loadTranslationTable{
  ["ehuan"] = "鄂焕",
  ["#ehuan"] = "牙门汉将",
  ["illustrator:ehuan"] = "小强",

  ["ofl__diwan"] = "敌万",
  [":ofl__diwan"] = "每回合限一次，当你使用【杀】指定目标后，你可以摸X张牌（X为此牌的目标数）。",
  ["ofl__suiluan"] = "随乱",
  [":ofl__suiluan"] = "群势力技，你使用【杀】可以多指定至多两个目标，若如此做，此【杀】结算后，所有目标角色依次可以对你使用一张【杀】，"..
  "当你以此法受到伤害后，你变更势力至蜀。",
  ["ofl__conghan"] = "从汉",
  [":ofl__conghan"] = "蜀势力技，当一号位造成伤害后，你可以对受到此伤害的角色使用一张【杀】。",

  ["#ofl__suiluan-choose"] = "随乱：你可以为此%arg额外指定至多两个目标",
  ["#ofl__suiluan-use"] = "随乱：你可以对 %src 使用一张【杀】",
  ["#ofl__conghan-use"] = "从汉：你可以对 %dest 使用一张【杀】",
}

--官盗E7决战巅峰：钟会
local ofl__zhonghui = General(extension, "ofl__zhonghui", "wei", 4)
local mouchuan = fk.CreateTriggerSkill{
  name = "mouchuan",
  anim_type = "drawcard",
  events = {fk.RoundStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(2, self.name)
    if player.dead or player:isKongcheng() or #room.alive_players == 1 then return end
    local to, card = room:askForChooseCardAndPlayers(player, table.map(room:getOtherPlayers(player), Util.IdMapper), 1, 1,
      ".|.|.|hand", "#mouchuan-choose", self.name, false)
    to = room:getPlayerById(to[1])
    room:moveCardTo(card, Card.PlayerHand, to, fk.ReasonGive, self.name, nil, false, player.id)
    local color1
    if not player.dead and not player:isKongcheng() then
      local card1 = room:askForCard(player, 1, 1, false, self.name, false, ".|.|.|hand", "#mouchuan1-show")
      color1 = Fk:getCardById(card1[1]):getColorString()
      player:showCards(card1)
    end
    if not to.dead and not to:isKongcheng() then
      local card2 = room:askForCard(to, 1, 1, false, self.name, false, ".|.|.|hand", "#mouchuan2-show:"..player.id.."::"..color1)
      local color2 = Fk:getCardById(card2[1]):getColorString()
      to:showCards(card2)
      if color1 == "nocolor" or color2 == "nocolor" or player.dead then return end
      local skill = "daohe"
      if color1 ~= color2 then
        skill = "zhiyiz"
      end
      room:setPlayerMark(player, self.name, skill)
      room:handleAddLoseSkills(player, skill, nil, true, false)
    end
  end,

  refresh_events = {fk.RoundEnd},
  can_refresh = function(self, event, target, player, data)
    return player:getMark(self.name) ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local skill = player:getMark(self.name)
    room:setPlayerMark(player, self.name, 0)
    room:handleAddLoseSkills(player, "-"..skill, nil, true, false)
  end,
}
local zizhong = fk.CreateTriggerSkill{
  name = "zizhong",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.CardUsing, fk.CardResponding},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and data.card.type ~= Card.TypeEquip and
      #table.filter(player.player_skills, function(skill)
        return skill:isPlayerSkill(player) and skill.visible
      end) > 2 then
      local room = player.room
      local logic = room.logic
      local current_event = logic:getCurrentEvent()
      local mark_name = "zizhong_" .. data.card.trueName .. "-round"
      local mark = player:getMark(mark_name)
      if mark == 0 then
        logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
          local use = e.data[1]
          if use.from == player.id and use.card.trueName == data.card.trueName then
            mark = e.id
            room:setPlayerMark(player, mark_name, mark)
            return true
          end
          return false
        end, Player.HistoryRound)
        logic:getEventsOfScope(GameEvent.RespondCard, 1, function (e)
          local use = e.data[1]
          if use.from == player.id and use.card.trueName == data.card.trueName then
            mark = math.max(e.id, mark)
            room:setPlayerMark(player, mark_name, mark)
            return true
          end
          return false
        end, Player.HistoryRound)
      end
      return mark == current_event.id
    end
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(#table.filter(player.player_skills, function(skill) return skill:isPlayerSkill(player) end) - 2, self.name)
  end,
}
local zizhong_maxcards = fk.CreateMaxCardsSkill{
  name = "#zizhong_maxcards",
  main_skill = zizhong,
  correct_func = function(self, player)
    if player:hasSkill("zizhong") then
      return #table.filter(player.player_skills, function(skill)
        return skill:isPlayerSkill(player) and skill.visible
      end)
    else
      return 0
    end
  end,
}
local jizun = fk.CreateTriggerSkill{
  name = "jizun",
  anim_type = "support",
  frequency = Skill.Wake,
  events = {fk.AfterDying},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if not player:hasSkill("qingsuan", true) then
      room:handleAddLoseSkills(player, "qingsuan", nil, true, false)
    elseif player:isWounded() then
      room:recover({
        who = player,
        num = player:getLostHp(),
        recoverBy = player,
        skillName = self.name,
      })
    end
  end,
}
local qingsuan = fk.CreateTargetModSkill{
  name = "qingsuan$",
  frequency = Skill.Compulsory,
  bypass_times = function(self, player, skill, scope, card, to)
    return card and player:hasSkill(self) and scope == Player.HistoryPhase and to and
      player.kingdom ~= to.kingdom and table.contains(player:getTableMark("qingsuan_enemy"), to.id)
  end,
  bypass_distances = function(self, player, skill, card, to)
    return card and player:hasSkill(self) and to and
      player.kingdom ~= to.kingdom and table.contains(player:getTableMark("qingsuan_enemy"), to.id)
  end,

  on_acquire = function (self, player, is_start)
    local room = player.room
    local enemies = {}
    room.logic:getActualDamageEvents(1, function(e)
      local damage = e.data[1]
      if damage.from and damage.to == player then
        table.insertIfNeed(enemies, damage.from.id)
      end
    end,
    Player.HistoryGame)
    room:setPlayerMark(player, "qingsuan_enemy", enemies)
  end,
}
local qingsuan_record = fk.CreateTriggerSkill{
  name = "#qingsuan_record",

  refresh_events = {fk.BeforeHpChanged},
  can_refresh = function (self, event, target, player, data)
    return target == player and player:hasSkill(self, true) and
      data.reason == "damage" and data.damageEvent and data.damageEvent.from
  end,
  on_refresh = function (self, event, target, player, data)
    local enemies = player:getTableMark("qingsuan_enemy")
    table.insertIfNeed(enemies, data.damageEvent.from.id)
    player.room:setPlayerMark(player, "qingsuan_enemy", enemies)
  end,
}
local daohe = fk.CreateActiveSkill{
  name = "daohe",
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  prompt = "#daohe",
  can_use = function (self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and not Fk:currentRoom():getPlayerById(to_select):isKongcheng() and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local cards = room:askForCard(target, 1, 999, false, self.name, false, ".|.|.|hand", "#daohe_give:"..player.id)
    if #cards > 0 then
      room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonGive, self.name, nil, false, target.id)
      if not target.dead and target:isWounded() then
        room:recover{
          who = target,
          num = 1,
          recoverBy = player,
          skillName = self.name
        }
      end
    end
  end,
}
local zhiyiz = fk.CreateActiveSkill{
  name = "zhiyiz",
  anim_type = "offensive",
  card_num = 0,
  target_num = 1,
  prompt = "#zhiyiz",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    return #selected == 0
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    target:drawCards(1, self.name)
    if not target.dead then
      room:damage{
        from = player,
        to = target,
        damage = 1,
        skillName = self.name,
      }
    end
  end,
}
zizhong:addRelatedSkill(zizhong_maxcards)
qingsuan:addRelatedSkill(qingsuan_record)
ofl__zhonghui:addSkill(mouchuan)
ofl__zhonghui:addSkill(zizhong)
ofl__zhonghui:addSkill(jizun)
ofl__zhonghui:addSkill(qingsuan)
ofl__zhonghui:addRelatedSkill(daohe)
ofl__zhonghui:addRelatedSkill(zhiyiz)
Fk:loadTranslationTable{
  ["ofl__zhonghui"] = "钟会",
  ["#ofl__zhonghui"] = "统定河山",
  --["designer:ofl__zhonghui"] = "",
  ["illustrator:ofl__zhonghui"] = "磐蒲",

  ["mouchuan"] = "谋川",
  [":mouchuan"] = "每轮开始时，你可以摸两张牌并交给一名其他角色一张牌，然后你与其依次展示一张手牌，若颜色：相同，你本轮获得技能〖道合〗；"..
  "不同，你本轮获得技能〖志异〗。",
  ["zizhong"] = "自重",
  [":zizhong"] = "锁定技，当你使用或打出一张你本轮未使用过的非装备牌时，你摸X-2张牌；你的手牌上限+X。（X为你的技能数）",
  ["jizun"] = "极尊",
  [":jizun"] = "觉醒技，当你脱离濒死状态时，你获得技能〖清算〗；若你已拥有〖清算〗，则改为回复体力至体力上限。",
  ["qingsuan"] = "清算",
  [":qingsuan"] = "主公技，锁定技，你对与你势力不同且本局游戏对你造成过伤害的角色使用牌无距离和次数限制。",
  ["daohe"] = "道合",
  [":daohe"] = "出牌阶段限一次，你可以令一名其他角色交给你至少一张手牌，然后其回复1点体力。",
  ["zhiyiz"] = "志异",
  [":zhiyiz"] = "出牌阶段限一次，你可以令一名角色摸一张牌，然后你对其造成1点伤害。",
  ["#mouchuan-choose"] = "谋川：将一张手牌交给一名其他角色",
  ["#mouchuan1-show"] = "谋川：展示一张手牌",
  ["#mouchuan2-show"] = "展示一张手牌，根据是否为%arg，%src获得技能<br>"..
  "相同：%src获得〖道合〗出牌阶段限一次，你可以令一名其他角色交给你至少一张手牌，然后其回复1点体力。<br>"..
  "不同：%src获得〖志异〗出牌阶段限一次，你可以令一名角色摸一张牌，然后你对其造成1点伤害。",

  ["#daohe"] = "道合：令一名其他角色交给你至少一张手牌，然后其回复1点体力",
  ["#daohe_give"] = "道合：交给 %src 任意张手牌，然后你回复1点体力",
  ["#zhiyiz"] = "志异：令一名角色摸一张牌，然后你对其造成1点伤害。",
}

--官盗E5荆襄风云：周瑜 神刘表 神曹仁
local zhouyu = General(extension, "ofl__zhouyu", "wu", 3)
local xiongzi = fk.CreateTriggerSkill{
  name = "ofl__xiongzi",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.DrawNCards},
  on_use = function(self, event, target, player, data)
    data.n = data.n + player.hp
  end,
}
local xiongzi_maxcards = fk.CreateMaxCardsSkill{
  name = "#ofl__xiongzi_maxcards",
  main_skill = xiongzi,
  correct_func = function (self, player)
    if player:hasSkill(xiongzi) and player.hp > 0 then
      return player.hp
    end
  end,
}
local zhanyanz = fk.CreateActiveSkill{
  name = "ofl__zhanyanz",
  anim_type = "offensive",
  card_num = 0,
  target_num = 1,
  prompt = "#ofl__zhanyanz",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  card_filter = Util.FalseFunc,
  target_filter = function (self, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local choices = {}
    for i = 0, player:getHandcardNum(), 1 do
      table.insert(choices, tostring(i))
    end
    local choice = room:askForChoice(target, choices, self.name, "#ofl__zhanyanz-choice:"..player.id)
    choice = tonumber(choice)
    local cards = table.filter(player:getCardIds("h"), function (id)
      return Fk:getCardById(id).color == Card.Red
    end)
    player:showCards(player:getCardIds("h"))
    if target.dead then return end
    local ids = table.filter(cards, function (id)
      return table.contains(player:getCardIds("h"), id)
    end)
    if #ids > 0 then
      room:moveCardTo(ids, Card.PlayerHand, target, fk.ReasonGive, self.name, nil, true, player.id)
      if target.dead then return end
    end
    local n = math.min(math.abs(choice - #cards), 3)
    if n > 0 then
      room:damage{
        from = player,
        to = target,
        damage = n,
        damageType = fk.FireDamage,
        skillName = self.name,
      }
    end
  end,
}
xiongzi:addRelatedSkill(xiongzi_maxcards)
zhouyu:addSkill(xiongzi)
zhouyu:addSkill(zhanyanz)
Fk:loadTranslationTable{
  ["ofl__zhouyu"] = "周瑜",
  ["#ofl__zhouyu"] = "雄姿英发",
  ["illustrator:ofl__zhouyu"] = "魔奇士",

  ["ofl__xiongzi"] = "雄姿",
  [":ofl__xiongzi"] = "锁定技，摸牌阶段，你额外摸X张牌；你的手牌上限+X（X为你当前体力值）。",
  ["ofl__zhanyanz"] = "绽焱",
  [":ofl__zhanyanz"] = "出牌阶段限一次，你可以令一名其他角色猜测你的红色手牌数，然后你展示手牌并将其中所有红色牌交给其，然后你对其造成X点火焰伤害"..
  "（X为其猜测数与你的红色手牌数之差，至多为3）。",
  ["#ofl__zhanyanz"] = "绽焱：令一名角色猜测你的红色手牌数，你将所有红色手牌交给其，并对其造成猜错差值的火焰伤害！",
  ["#ofl__zhanyanz-choice"] = "绽焱：请猜测 %src 的红色手牌数",
}

--local godliubiao = General(extension, "godliubiao", "god", 4)
Fk:loadTranslationTable{
  ["godliubiao"] = "神刘表",
  ["#godliubiao"] = "称雄荆襄",
  ["illustrator:godliubiao"] = "六道目",

  ["xiongju"] = "雄踞",
  [":xiongju"] = "锁定技，游戏开始时，你从游戏外获得两张【荆襄盛世】，然后加X点体力上限，回复X点体力；你的起始手牌数+X、手牌上限+X"..
  "（X为场上势力数）。",
  ["fujing"] = "富荆",
  [":fujing"] = "锁定技，你跳过摸牌阶段，改为使用一张【荆襄盛世】。以此法获得牌的其他角色本轮首次使用牌指定你为目标后，其需弃置一张牌。",
  ["yongrong"] = "雍容",
  [":yongrong"] = "每回合限一次，当你造成/受到伤害时，若受伤角色/伤害来源的手牌数小于你，你可以交给其一张牌，令此伤害+1/-1。",
}

local godcaoren = General(extension, "godcaoren", "god", 4)
local jushou = fk.CreateTriggerSkill{
  name = "ofl__jushou",
  anim_type = "defensive",
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Finish
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(#room.alive_players, self.name)
    if player.dead then return end
    player:turnOver()
    if player.dead then return end
    if room:askForSkillInvoke(player, self.name, nil, "#ofl__jushou-invoke") then
      room:doIndicate(player.id, table.map(room.alive_players, Util.IdMapper))
      for _, p in ipairs(room:getAlivePlayers()) do
        if not p.dead then
          p:turnOver()
        end
      end
      for _, p in ipairs(room:getAlivePlayers()) do
        if not p.dead then
          p:drawCards(3, self.name)
        end
      end
      for _, p in ipairs(room:getAlivePlayers()) do
        if not p.dead then
          p:throwAllCards("e", self.name)
        end
      end
      if player.dead then return end
      room:handleAddLoseSkills(player, "-ofl__jushou|ofl__tuwei", nil, true, false)
    end
  end,
}
local tuwei = fk.CreateActiveSkill{
  name = "ofl__tuwei",
  anim_type = "control",
  card_num = 1,
  target_num = 1,
  prompt = "#ofl__tuwei",
  expand_pile = function (self)
    return table.filter(Fk:currentRoom().discard_pile, function (id)
      return Fk:getCardById(id).type == Card.TypeEquip
    end)
  end,
  can_use = function(self, player)
    return table.find(Fk:currentRoom().discard_pile, function (id)
        return Fk:getCardById(id).type == Card.TypeEquip
      end)
  end,
  card_filter = function (self, to_select, selected)
    return #selected == 0 and table.contains(Fk:currentRoom().discard_pile, to_select)
  end,
  target_filter = function (self, to_select, selected, selected_cards)
    if #selected == 0 and #selected_cards == 1 then
      return Fk:currentRoom():getPlayerById(to_select):hasEmptyEquipSlot(Fk:getCardById(selected_cards[1]).sub_type) and
        not table.contains(Self:getTableMark(self.name), to_select)
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:addTableMark(player, self.name, target.id)
    room:moveCardIntoEquip(target, effect.cards, self.name, false, player.id)
    if player.dead or target.dead or target == player then return end
    local choice = room:askForChoice(player, {"ofl__tuwei_draw", "ofl__tuwei_damage", "Cancel"}, self.name,
      "#ofl__tuwei-choice::"..target.id)
    if choice == "ofl__tuwei_draw" then
      target:drawCards(1, self.name)
    elseif choice == "ofl__tuwei_damage" then
      room:damage{
        from = player,
        to = target,
        damage = 1,
        skillName = self.name,
      }
    end
  end,
}
godcaoren:addSkill(jushou)
godcaoren:addRelatedSkill(tuwei)
Fk:loadTranslationTable{
  ["godcaoren"] = "神曹仁",
  ["#godcaoren"] = "征南将军",
  ["illustrator:godcaoren"] = "凡果",

  ["ofl__jushou"] = "据守",
  [":ofl__jushou"] = "结束阶段，你可以翻面并摸X张牌（X为存活角色数），然后你可以令所有角色翻面并各摸三张牌，若如此做，你弃置场上所有装备牌，"..
  "失去〖据守〗，获得〖突围〗。",
  ["ofl__tuwei"] = "突围",
  [":ofl__tuwei"] = "每名角色限一次，出牌阶段，你可以将弃牌堆中一张装备牌置入一名角色的装备区，若不为你，你可以令其摸一张牌或对其造成1点伤害。",
  ["#ofl__jushou-invoke"] = "据守：是否令所有角色翻面、摸三张牌、弃置装备，然后你失去“据守”获得“突围”？",
  ["#ofl__tuwei"] = "突围：将弃牌堆中一张装备置入一名角色装备区，若不为你，你可以令其摸牌或对其造成伤害",
  ["#ofl__tuwei-choice"] = "突围：你可以对 %dest 执行一项",
  ["ofl__tuwei_draw"] = "令其摸一张牌",
  ["ofl__tuwei_damage"] = "对其造成1点伤害",
}

--官盗E10全武将尊享：田钏
local tianchuan = General(extension, "tianchuan", "qun", 3, 3, General.Female)
local huying = fk.CreateTriggerSkill{
  name = "huying",
  frequency = Skill.Compulsory,
  events = {fk.GameStart, fk.Deathed},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = {}
    if event == fk.GameStart then
      for i = 1, 2, 1 do
        local card = room:printCard("caning_whip", Card.Spade, 9)
        table.insert(cards, card)
      end
    else
      cards = room:printCard("caning_whip", Card.Spade, 9)
    end
    room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonJustMove, self.name, nil, true, player.id)
  end,
}
local huying_maxcards = fk.CreateMaxCardsSkill{
  name = "#huying_maxcards",
  frequency = Skill.Compulsory,
  main_skill = huying,
  exclude_from = function(self, player, card)
    return player:hasSkill(huying) and card.name == "caning_whip"
  end,
}
local huying_distance = fk.CreateDistanceSkill{
  name = "#huying_distance",
  frequency = Skill.Compulsory,
  main_skill = huying,
  correct_func = function(self, from, to)
    if to:hasSkill(huying) then
      return #table.filter(to:getCardIds("e"), function (id)
        return Fk:getCardById(id).name == "caning_whip"
      end)
    end
    return 0
  end,
}
local qianjing = fk.CreateViewAsSkill{
  name = "qianjing",
  pattern = "slash",
  anim_type = "offensive",
  prompt = "#qianjing",
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).name == "caning_whip"
  end,
  view_as = function(self, cards)
    local card = Fk:cloneCard("slash")
    if #cards == 1 then
      card:addSubcards(cards)
    end
    card.skillName = self.name
    return card
  end,
  before_use = function(self, player, use)
    if #use.card.subcards == 0 then
      local room = player.room
      local targets = table.map(table.filter(room.alive_players, function(p)
        return table.find(p:getCardIds("e"), function (id)
          return Fk:getCardById(id).name == "caning_whip"
        end) end), Util.IdMapper)
      if #targets == 0 then return "" end
      local to = room:askForChoosePlayers(player, targets, 1, 1, "#qianjing_use-choose", self.name, false)
      if #to == 0 then return "" end
      to = room:getPlayerById(to[1])
      local cards = table.filter(to:getCardIds("e"), function (id)
        return Fk:getCardById(id).name == "caning_whip"
      end)
      if #cards == 1 then
        use.card:addSubcard(cards[1])
      else
        local card = U.askforChooseCardsAndChoice(player, cards, {"OK"}, self.name, "#qianjing_use-card::"..to.id)
        use.card:addSubcard(card[1])
      end
    end
    use.extraUse = true
  end,
  enabled_at_response = function (self, player, response)
    return not response
  end,
}
local qianjing_trigger = fk.CreateTriggerSkill{
  name = "#qianjing_trigger",
  mute = true,
  events = {fk.Damage, fk.Damaged},
  main_skill = qianjing,
  can_trigger = function(self, event, target, player, data)
    return target and target == player and player:hasSkill(qianjing) and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local success, dat = player.room:askForUseActiveSkill(player, "qianjing_active", "#qianjing-put", true, nil, false)
    if success and dat then
      self.cost_data = dat
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = Fk:getCardById(self.cost_data.cards[1])
    local mapper = {
      ["WeaponSlot"] = "weapon",
      ["ArmorSlot"] = "armor",
      ["OffensiveRideSlot"] = "offensive_horse",
      ["DefensiveRideSlot"] = "defensive_horse",
      ["TreasureSlot"] = "treasure",
    }
    room:setCardMark(card, "@caning_whip", Fk:translate(mapper[self.cost_data.interaction]))
    Fk.printed_cards[self.cost_data.cards[1]].sub_type = Util.convertSubtypeAndEquipSlot(self.cost_data.interaction)
    local to = room:getPlayerById(self.cost_data.targets[1])
    room:moveCardIntoEquip(to, self.cost_data.cards, "qianjing", false, player)
    if to == player and not player.dead then
      player:drawCards(1, "qianjing")
    end
  end,
}
local qianjing_active = fk.CreateActiveSkill{
  name = "qianjing_active",
  card_num = 1,
  target_num = 1,
  interaction = function ()
    return UI.ComboBox {choices = {"WeaponSlot", "ArmorSlot", "OffensiveRideSlot", "DefensiveRideSlot", "TreasureSlot"}}
  end,
  card_filter = function(self, to_select, selected, targets)
    return #selected == 0 and Fk:getCardById(to_select).name == "caning_whip" and
      Fk:currentRoom():getCardArea(to_select) == Card.PlayerHand
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and #selected_cards == 1 and self.interaction.data and
      Fk:currentRoom():getPlayerById(to_select):hasEmptyEquipSlot(Util.convertSubtypeAndEquipSlot(self.interaction.data))
  end,
}
local bianchi = fk.CreateTriggerSkill{
  name = "bianchi",
  anim_type = "offensive",
  frequency = Skill.Limited,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Finish and
      table.find(player.room.alive_players, function(p)
        return table.find(p:getCardIds("e"), function (id)
          return Fk:getCardById(id).name == "caning_whip"
        end)
      end) and
      player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getAlivePlayers(), function(p)
      return table.find(p:getCardIds("e"), function (id)
        return Fk:getCardById(id).name == "caning_whip"
      end)
    end)
    room:doIndicate(player.id, table.map(targets, Util.IdMapper))
    for _, p in ipairs(targets) do
      if not p.dead then
        local cards = table.filter(p:getCardIds("e"), function (id)
          return Fk:getCardById(id).name == "caning_whip"
        end)
        if #cards > 0 then
          room:throwCard(cards, self.name, p, player)
        end
      end
    end
    for _, p in ipairs(targets) do
      if p ~= player and not p.dead then
        if player.dead then
          room:loseHp(p, 2, self.name)
        else
          local choice = room:askForChoice(p, {"bianchi1:"..player.id, "bianchi2"}, self.name)
          if choice == "bianchi2" then
            room:loseHp(p, 2, self.name)
          else
            player:control(p)
            room:setPlayerMark(p, "bianchi-tmp", 1)
            p:gainAnExtraPhase(Player.Play, false)
            room:setPlayerMark(p, "bianchi-tmp", 0)
            p:control(p)
          end
        end
      end
    end
  end,

  refresh_events = {fk.PreCardUse},
  can_refresh = function(self, event, target, player, data)
    return target == player and player.phase == Player.Play and player:getMark("bianchi-tmp") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "bianchi-phase", 1)
  end,
}
local bianchi_prohibit = fk.CreateProhibitSkill{
  name = '#bianchi_prohibit',
  prohibit_use = function(self, player)
    return player:getMark("bianchi-tmp") > 0 and player.phase == Player.Play and player:getMark("bianchi-phase") > 1
  end,
}
huying:addRelatedSkill(huying_maxcards)
huying:addRelatedSkill(huying_distance)
qianjing:addRelatedSkill(qianjing_trigger)
Fk:addSkill(qianjing_active)
bianchi:addRelatedSkill(bianchi_prohibit)
tianchuan:addSkill(huying)
tianchuan:addSkill(qianjing)
tianchuan:addSkill(bianchi)
Fk:loadTranslationTable{
  ["tianchuan"] = "田钏",
  ["#tianchuan"] = "潜行之狐",
  ["illustrator:tianchuan"] = "苍月白龙",

  ["huying"] = "狐影",
  [":huying"] = "锁定技，游戏开始时/其他角色死亡后，你从游戏外获得两张/一张<a href=':caning_whip'>【刑鞭】</a>，【刑鞭】不计入你的手牌上限，"..
  "你场上每有一张【刑鞭】，其他角色计算与你的距离便+1。",
  ["qianjing"] = "潜荆",
  [":qianjing"] = "当你造成或受到伤害后，你可以将手牌中一张<a href=':caning_whip'>【刑鞭】</a>置于一名角色的任意一个装备栏，若为你则摸一张牌。"..
  "你可以将场上或手牌中的一张【刑鞭】当不计入次数的【杀】使用。",
  ["bianchi"] = "鞭笞",
  [":bianchi"] = "限定技，结束阶段，你可以弃置场上所有<a href=':caning_whip'>【刑鞭】</a>，然后令所有因此弃置【刑鞭】的其他角色依次选择一项："..
  "1.你操纵其执行一个额外的出牌阶段，此阶段内其至多使用两张牌；2.失去2点体力。",
  ["#qianjing_trigger"] = "潜荆",
  ["qianjing_active"] = "潜荆",
  ["#qianjing-put"] = "潜荆：你可以将手牌中一张【刑鞭】置入一名角色任意装备栏，若为你则摸一张牌",
  ["#qianjing"] = "潜荆：选择你的一张【刑鞭】当【杀】使用（或先指定【杀】的目标，再选择一名角色场上的一张【刑鞭】）",
  ["#qianjing_use-choose"] = "潜荆：选择一名角色，将其场上的【刑鞭】当【杀】使用",
  ["#qianjing_use-card"] = "潜荆：选择 %dest 场上一张【刑鞭】当【杀】使用",
  ["bianchi1"] = "%src 操纵你执行一个额外出牌阶段！",
  ["bianchi2"] = "失去2点体力",
}

--太平天书：姜子牙 南极仙翁 申公豹
local jiangziya = General(extension, "wm__jiangziya", "god", 3)
local xingzhou = fk.CreateTriggerSkill{
  name = "xingzhou",
  anim_type = "offensive",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and data.from and not data.from.dead and data.from ~= player and
      player:getHandcardNum() > 1 and player:usedSkillTimes(self.name, Player.HistoryTurn) == 0 and
      table.every(player.room.alive_players, function (p)
        return p:getHandcardNum() >= target:getHandcardNum()
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local cards = player.room:askForDiscard(player, 2, 2, false, self.name, true, nil, "#xingzhou-invoke::"..data.from.id, true)
    if #cards == 2 then
      self.cost_data = cards
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(self.cost_data, self.name, player, player)
    if not data.from.dead then
      room:useVirtualCard("slash", nil, player, data.from, self.name, true)
    end
    if data.from.dead then
      player:setSkillUseHistory("lieshen", 0, Player.HistoryGame)
    end
  end,
}
local lieshen = fk.CreateActiveSkill{
  name = "lieshen",
  anim_type = "support",
  frequency = Skill.Limited,
  card_num = 0,
  target_num = 1,
  prompt = "#lieshen",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    return #selected == 0
  end,
  on_use = function(self, room, effect)
    local target = room:getPlayerById(effect.tos[1])
    local n1, n2 = Fk.generals[target.general].hp, 4
    if target:getMark(self.name) ~= 0 then
      local mark = target:getMark(self.name)
      n1, n2 = mark[1], mark[2]
    end
    target.hp = math.min(n1, target.maxHp)
    room:broadcastProperty(target, "hp")
    local n = target:getHandcardNum() - n2
    if n > 0 then
      room:askForDiscard(target, n2, n2, false, self.name, false)
    elseif n < 0 then
      target:drawCards(-n, self.name)
    end
  end,
}
local lieshen_trigger = fk.CreateTriggerSkill{
  name = "#lieshen_trigger",

  refresh_events = {fk.RoundStart},
  can_refresh = function(self, event, target, player, data)
    return player.room:getTag("RoundCount") == 1 and player.seat == 1
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room.alive_players) do
      room:setPlayerMark(p, "lieshen", {p.hp, p:getHandcardNum()})
    end
  end,
}
lieshen:addRelatedSkill(lieshen_trigger)
jiangziya:addSkill(xingzhou)
jiangziya:addSkill(lieshen)
Fk:loadTranslationTable{
  ["wm__jiangziya"] = "姜子牙",
  ["#wm__jiangziya"] = "武庙主祭",
  --["illustrator:wm__jiangziya"] = "",

  ["xingzhou"] = "兴周",
  [":xingzhou"] = "每回合限一次，当手牌数最少的角色受到伤害后，你可以弃置两张手牌，视为对伤害来源使用一张【杀】，然后若其死亡，〖列神〗"..
  "视为未发动过。",
  ["lieshen"] = "列神",
  [":lieshen"] = "限定技，出牌阶段，你可以令一名角色将体力值和手牌数调整至游戏开始时。",
  ["#xingzhou-invoke"] = "兴周：是否弃置两张手牌，视为对 %dest 使用【杀】？",
  ["#lieshen"] = "列神：令一名角色将体力值和手牌数调整至游戏开始时！",
}

local nanjixianweng = General(extension, "nanjixianweng", "god", 3)
local shoufaj = fk.CreateActiveSkill{
  name = "shoufaj",
  anim_type = "support",
  prompt = "#shoufaj",
  card_num = 0,
  target_num = 1,
  interaction = function(self)
    local choiceList = {}
    local cards = Self.player_cards[Player.Hand]
    for _, id in ipairs(cards) do
      table.insertIfNeed(choiceList, Fk:getCardById(id):getSuitString(true))
    end
    if #choiceList == 0 then return false end
    return UI.ComboBox { choices = choiceList, all_choices = {"log_spade", "log_heart", "log_club", "log_diamond"} }
  end,
  can_use = function(self, player)
    return not player:isKongcheng()
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local suit = self.interaction.data
    local cards = table.filter(player:getCardIds("h"), function (id)
      return Fk:getCardById(id):getSuitString(true) == suit
    end)
    if #cards == 0 then return end
    room:moveCardTo(cards, Card.PlayerHand, target, fk.ReasonGive, self.name, nil, true, player.id)
    if target.dead then return end
    local mapper = {
      ["log_spade"] = "tiandu",
      ["log_heart"] = "tianxiang",
      ["log_club"] = "qingguo",
      ["log_diamond"] = "ex__wusheng",
    }
    local skill = mapper[suit]
    if target:hasSkill(skill, true) then return end
    room:handleAddLoseSkills(target, skill, nil, true, false)
    if player.dead or target.dead then return end
    local mark = player:getTableMark(self.name)
    mark[string.format("%.0f", target.id)] = mark[string.format("%.0f", target.id)] or {}
    table.insertIfNeed(mark[string.format("%.0f", target.id)], skill)
    room:setPlayerMark(player, self.name, mark)
  end,
}
local shoufaj_trigger = fk.CreateTriggerSkill{
  name = "#shoufaj_trigger",

  refresh_events = {fk.BeforeTurnStart},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("shoufaj") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local mark = player:getTableMark("shoufaj")
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if mark[string.format("%.0f", p.id)] then
        room:handleAddLoseSkills(p, "-"..table.concat(mark[string.format("%.0f", p.id)], "|-"), nil, true, false)
      end
    end
    room:setPlayerMark(player, "shoufaj", 0)
  end,
}
local fuzhao = fk.CreateTriggerSkill{
  name = "fuzhao",
  anim_type = "support",
  events = {fk.EnterDying},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and not target.dead
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, data, "#fuzhao-invoke::"..target.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    local judge = {
      who = target,
      reason = self.name,
      pattern = ".|.|heart",
    }
    room:judge(judge)
    if target.dead then return end
    if judge.card.suit == Card.Heart and target:isWounded() and not target.dead then
      room:recover{
        who = target,
        num = 1,
        recoverBy = player,
        skillName = self.name,
      }
    end
  end,
}
shoufaj:addRelatedSkill(shoufaj_trigger)
nanjixianweng:addSkill(shoufaj)
nanjixianweng:addSkill(fuzhao)
nanjixianweng:addRelatedSkill("tiandu")
nanjixianweng:addRelatedSkill("tianxiang")
nanjixianweng:addRelatedSkill("qingguo")
nanjixianweng:addRelatedSkill("ex__wusheng")
Fk:loadTranslationTable{
  ["nanjixianweng"] = "南极仙翁",
  ["#nanjixianweng"] = "阐教真君",
  --["illustrator:nanjixianweng"] = "",

  ["shoufaj"] = "授法",
  [":shoufaj"] = "出牌阶段，你可以将一种花色所有手牌展示并交给一名其他角色，根据花色，其获得对应的技能直到你下回合开始：<br>"..
  "♠-〖天妒〗；<font color='red'>♥</font>-〖天香〗；<br><font color='red'></font>♣-〖倾国〗；<font color='red'>♦</font>-〖武圣〗。",
  ["fuzhao"] = "福照",
  [":fuzhao"] = "当一名角色进入濒死状态时，你可以令其进行一次判定，若结果为<font color='red'>♥</font>，其回复1点体力。",
  ["#shoufaj"] = "授法：将一种花色所有手牌交给一名其他角色，其根据花色获得技能直到你下回合开始：<br>"..
  "♠-天妒；<font color='red'>♥</font>-天香；♣-倾国；<font color='red'>♦</font>-武圣",
  ["#fuzhao-invoke"] = "福照：是否令 %dest 判定？若为<font color='red'>♥</font>，其回复1点体力",
}

local shengongbao = General(extension, "shengongbao", "god", 3)
local zhuzhou = fk.CreateTriggerSkill{
  name = "zhuzhou",
  anim_type = "support",
  events = {fk.Damage},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target and not target.dead and target ~= data.to and
      player:usedSkillTimes(self.name, Player.HistoryTurn) == 0 and
      not data.to.dead and not data.to:isKongcheng() and
      table.every(player.room.alive_players, function (p)
        return p:getHandcardNum() <= target:getHandcardNum()
      end)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#zhuzhou-invoke:"..target.id..":"..data.to.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    room:delay(500)
    room:doIndicate(target.id, {data.to.id})
    local id = room:askForCardChosen(target, data.to, "h", self.name, "#zhuzhou-prey::"..data.to.id)
    room:moveCardTo(id, Card.PlayerHand, target, fk.ReasonPrey, self.name, nil, false, target.id)
  end,
}
local yaoxian = fk.CreateActiveSkill{
  name = "yaoxian",
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  prompt = "#yaoxian",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    return #selected == 0
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    target:drawCards(2, self.name)
    if player.dead or target.dead then return end
    local targets = table.filter(room:getOtherPlayers(target), function (p)
      return p ~= player
    end)
    if #targets == 0 then return end
    local to = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 1, "#yaoxian-choose::"..target.id,
      self.name, false, true)
    to = room:getPlayerById(to[1])
    room:doIndicate(player.id, {target.id})
    room:doIndicate(target.id, {to.id})
    local use = room:askForUseCard(target, self.name, "slash", "#yaoxian-slash::"..to.id, true,
      {bypass_times = true, must_targets = {to.id}})
    if use then
      use.extraUse = true
      room:useCard(use)
    else
      room:loseHp(target, 1, self.name)
    end
  end,
}
shengongbao:addSkill(zhuzhou)
shengongbao:addSkill(yaoxian)
Fk:loadTranslationTable{
  ["shengongbao"] = "申公豹",
  ["#shengongbao"] = "道友留步",
  --["illustrator:shengongbao"] = "",

  ["zhuzhou"] = "助纣",
  [":zhuzhou"] = "每回合限一次，当手牌数最多的角色造成伤害后，你可以令其获得受伤角色的一张手牌。",
  ["yaoxian"] = "邀仙",
  [":yaoxian"] = "出牌阶段限一次，你可以令一名角色摸两张牌，然后其需对你指定的另一名其他角色使用【杀】，否则其失去1点体力。",
  ["#zhuzhou-invoke"] = "助纣：是否令 %src 获得 %dest 一张手牌？",
  ["#zhuzhou-prey"] = "助纣：获得 %dest 一张手牌",
  ["#yaoxian"] = "邀仙：令一名角色摸两张牌，然后其需对你指定的角色使用【杀】或失去1点体力",
  ["#yaoxian-choose"] = "邀仙：选择一名角色，%dest 需对其使用【杀】或失去1点体力",
  ["#yaoxian-slash"] = "邀仙：对 %dest 使用一张【杀】，否则你失去1点体力",
}

--官盗S7幽燕烽火：曹叡 司马懿 公孙渊 公孙瓒 袁绍 文丑
local caorui = General(extension, "ofl__caorui", "wei", 3)
local mingjian = fk.CreateTriggerSkill{
  name = "ofl__mingjian",
  anim_type = "support",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(self) and target.phase == Player.Play and not target.dead and
      not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local listNames = {"log_spade", "log_club", "log_heart", "log_diamond"}
    local listCards = {{}, {}, {}, {}}
    for _, id in ipairs(player:getCardIds("h")) do
      local suit = Fk:getCardById(id).suit
      if suit ~= Card.NoSuit then
        table.insertIfNeed(listCards[suit], id)
      end
    end
    local choice = U.askForChooseCardList(room, player, listNames, listCards, 1, 1, self.name, "#ofl__mingjian-invoke::"..target.id)
    if #choice == 1 then
      self.cost_data = {tos = {target.id}, cards = listCards[U.ConvertSuit(choice[1], "sym", "int")]}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:showCards(player:getCardIds("h"))
    if target.dead then return end
    room:addPlayerMark(target, "@@ofl__mingjian-turn", 1)
    local cards = table.filter(self.cost_data.cards, function (id)
      return table.contains(player:getCardIds("h"), id)
    end)
    if #cards > 0 then
      room:moveCardTo(cards, Card.PlayerHand, target, fk.ReasonGive, self.name, nil, true, player.id)
    end
  end,
}
local mingjian_delay = fk.CreateTriggerSkill{
  name = "#ofl__mingjian_delay",

  refresh_events = {fk.CardUsing},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@@ofl__mingjian-turn") > 0
  end,
  on_refresh = function (self, event, target, player, data)
    local n = player:getMark("@@ofl__mingjian-turn")
    player.room:setPlayerMark(player, "@@ofl__mingjian-turn", 0)
    if (data.card.type == Card.TypeBasic or data.card:isCommonTrick()) and data.tos then
      data.additionalEffect = (data.additionalEffect or 0) + n
    end
  end,
}
mingjian:addRelatedSkill(mingjian_delay)
caorui:addSkill("huituo")
caorui:addSkill(mingjian)
caorui:addSkill("xingshuai")
Fk:loadTranslationTable{
  ["ofl__caorui"] = "曹叡",
  ["#ofl__caorui"] = "魏明帝",
  ["illustrator:ofl__caorui"] = "第七个桔子",

  ["ofl__mingjian"] = "明鉴",
  [":ofl__mingjian"] = "其他角色出牌阶段开始时，你可以展示手牌并将其中一种花色的所有牌交给该角色，然后其本回合使用的下一张牌额外结算一次。",
  ["#ofl__mingjian-invoke"] = "明鉴：你可以交给 %dest 一种花色的手牌，其本回合使用的下一张牌额外结算一次",
  ["@@ofl__mingjian-turn"] = "明鉴",
}

local simayi = General(extension, "ofl__simayi", "wei", 4)
local yanggu = fk.CreateViewAsSkill{
  name = "ofl__yanggu",
  switch_skill_name = "ofl__yanggu",
  anim_type = "switch",
  pattern = "diversion",
  prompt = "#ofl__yanggu-yin",
  card_filter = function(self, to_select, selected)
    return #selected == 0 and table.contains(Self:getHandlyIds(true), to_select)
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard("diversion")
    card.skillName = self.name
    card:addSubcard(cards[1])
    return card
  end,
  enabled_at_play = function (self, player)
    return player:getSwitchSkillState(self.name, false) == fk.SwitchYin
  end,
  enabled_at_response = function (self, player, response)
    return not response and player:getSwitchSkillState(self.name, false) == fk.SwitchYin
  end,
}
local yanggu_trigger = fk.CreateTriggerSkill{
  name = "#ofl__yanggu_trigger",
  anim_type = "switch",
  main_skill = yanggu,
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yanggu) and player:getSwitchSkillState("ofl__yanggu", false) == fk.SwitchYang and
      player:isWounded()
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askForSkillInvoke(player, "ofl__yanggu", nil, "#ofl__yanggu-yang")
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(target, MarkEnum.SwithSkillPreName.."ofl__yanggu", player:getSwitchSkillState("ofl__yanggu", true))
    player:addSkillUseHistory("ofl__yanggu")
    room:recover{
      who = player,
      num = 1,
      recoverBy = player,
      skillName = "ofl__yanggu",
    }
  end,
}
local zuifu = fk.CreateTriggerSkill{
  name = "ofl__zuifu",
  anim_type = "offensive",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryTurn) == 0 and
      not table.find(player.room.alive_players, function (p)
        return p.dying
      end) then
      for _, move in ipairs(data) do
        if move.to and move.toArea == Player.Hand and player.room:getPlayerById(move.to).phase ~= Player.Draw then
          return true
        end
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    local room = player.room
    local targets = {}
    for _, move in ipairs(data) do
      if move.to and move.toArea == Player.Hand and room:getPlayerById(move.to).phase ~= Player.Draw then
        table.insertIfNeed(targets, move.to)
      end
    end
    for _, id in ipairs(targets) do
      if not player:hasSkill(self) or player:usedSkillTimes(self.name, Player.HistoryTurn) > 0 or
        table.find(room.alive_players, function (p)
          return p.dying
        end) then return end
      local p = room:getPlayerById(id)
      if not p.dead then
        self:doCost(event, p, player, data)
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    if player.room:askForSkillInvoke(player, self.name, nil, "#ofl__zuifu-invoke::"..target.id) then
      self.cost_data = {tos = {target.id}}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:damage{
      from = player,
      to = target,
      damage = 1,
      skillName = self.name,
    }
  end,
}
yanggu:addRelatedSkill(yanggu_trigger)
simayi:addSkill(yanggu)
simayi:addSkill(zuifu)
Fk:loadTranslationTable{
  ["ofl__simayi"] = "司马懿",
  ["#ofl__simayi"] = "总齐八荒",
  ["illustrator:ofl__simayi"] = "木美人",

  ["ofl__yanggu"] = "佯固",
  [":ofl__yanggu"] = "转换技，阳：当你受到伤害后，你可以回复1点体力；阴：你可以将一张手牌当【声东击西】使用。",
  ["ofl__zuifu"] = "罪缚",
  [":ofl__zuifu"] = "每回合限一次，当一名角色于其摸牌阶段外获得牌后，若没有角色处于濒死状态，你可以对其造成1点伤害。",
  ["#ofl__yanggu-yang"] = "佯固：是否回复1点体力？",
  ["#ofl__yanggu-yin"] = "佯固：你可以将一张手牌当【声东击西】使用",
  ["#ofl__yanggu_trigger"] = "佯固",
  ["#ofl__zuifu-invoke"] = "罪缚：是否对 %dest 造成1点伤害？",
}

local gongsunyuan = General(extension, "ofl__gongsunyuan", "qun", 4)
local xuanshi = fk.CreateActiveSkill{
  name = "ofl__xuanshi",
  anim_type = "control",
  card_num = 0,
  target_num = 0,
  prompt = "#ofl__xuanshi",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) < 2 and
      #table.filter(Self:getCardIds("h"), function (id)
        return Fk:getCardById(id).color == Card.Red
      end) == #table.filter(Self:getCardIds("h"), function (id)
        return Fk:getCardById(id).color == Card.Black
      end)
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    if not player:isKongcheng() then
      player:showCards(player:getCardIds("h"))
      if player.dead then return end
    end
    local targets = table.filter(room:getOtherPlayers(player), function (p)
      return not p:isNude()
    end)
    if #targets == 0 then return end
    local to = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 1,
      "#ofl__xuanshi-choose", self.name, false)
    to = room:getPlayerById(to[1])
    local card = room:askForCardChosen(player, to, "he", self.name, "#ofl__xuanshi-prey::"..to.id)
    room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonPrey, self.name, nil, false, player.id)
  end,
}
local xiongye = fk.CreateActiveSkill{
  name = "ofl__xiongye$",
  anim_type = "offensive",
  card_num = 1,
  target_num = 1,
  prompt = "#ofl__xiongye",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and table.contains(Self:getCardIds("h"), to_select)
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id and Fk:currentRoom():getPlayerById(to_select).kingdom == "qun"
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local list = {}
    list[target.id] = effect.cards
    local targets = table.map(table.filter(room:getOtherPlayers(player), function (p)
      return p ~= target and target.kingdom == "qun"
    end), Util.IdMapper)
    local cards = table.filter(player:getCardIds("h"), function (id)
      return id ~= effect.cards[1]
    end)
    room:setCardMark(Fk:getCardById(effect.cards[1]), "@DistributionTo", Fk:translate(target.general))
    while #targets > 0 and #cards > 0 do
      local to, id = room:askForChooseCardAndPlayers(player, targets, 1, 1, tostring(Exppattern{ id = cards }),
        "#ofl__xiongye-choose", self.name, true)
      if #to > 0 then
        table.removeOne(targets, to[1])
        table.removeOne(cards, id)
        list[to[1]] = {id}
        room:setCardMark(Fk:getCardById(id), "@DistributionTo", Fk:translate(room:getPlayerById(to[1]).general))
      else
        break
      end
    end
    for _, id in ipairs(player:getCardIds("h")) do
      room:setCardMark(Fk:getCardById(id), "@DistributionTo", 0)
    end
    targets = {}
    for id, _ in pairs(list) do
      if list[id] then
        table.insert(targets, id)
      end
    end
    room:sortPlayersByAction(targets)
    room:doYiji(list, player.id, self.name)
    for _, id in ipairs(targets) do
      local p = room:getPlayerById(id)
      if not p.dead then
        room:damage{
          from = player,
          to = p,
          damage = 1,
          skillName = self.name,
        }
      end
    end
  end,
}
gongsunyuan:addSkill(xuanshi)
gongsunyuan:addSkill(xiongye)
Fk:loadTranslationTable{
  ["ofl__gongsunyuan"] = "公孙渊",
  ["#ofl__gongsunyuan"] = "无节燕主",
  ["illustrator:ofl__gongsunyuan"] = "第七个桔子",

  ["ofl__xuanshi"] = "旋势",
  [":ofl__xuanshi"] = "出牌阶段限两次，若你的手牌中黑色牌和红色牌数量相同，你可以展示手牌，然后获得一名其他角色的一张牌。",
  ["ofl__xiongye"] = "凶业",
  [":ofl__xiongye"] = "主公技，出牌阶段限一次，你可以交给任意名其他群势力角色各一张手牌，然后对这些角色各造成1点伤害。",
  ["#ofl__xuanshi"] = "旋势：你可以展示手牌，获得一名其他角色的一张牌",
  ["#ofl__xuanshi-choose"] = "旋势：选择一名角色，获得其一张牌",
  ["#ofl__xuanshi-prey"] = "旋势：获得 %dest 一张牌",
  ["#ofl__xiongye"] = "凶业：交给任意名群势力角色各一张手牌，然后对这些角色各造成1点伤害（先选择一张牌和一名目标）",
  ["#ofl__xiongye-choose"] = "凶业：是否继续选择目标？",
  ["@DistributionTo"] = "",
}

local gongsunzan = General(extension, "ofl__gongsunzan", "qun", 4)
local qizhen = fk.CreateTriggerSkill{
  name = "ofl__qizhen",
  mute = true,
  events = {fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and data.card.trueName == "slash" then
      if data.damageDealt then
        return true
      else
        return table.find(TargetGroup:getRealTargets(data.tos), function (id)
          local p = player.room:getPlayerById(id)
          return not p.dead and #p:getCardIds("e") > 0
        end)
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(self.name)
    if data.damageDealt then
      room:notifySkillInvoked(player, self.name, "drawcard")
      local n = 0
      for _, num in pairs(data.damageDealt) do
        n = n + num
      end
      player:drawCards(n, self.name)
    else
      room:notifySkillInvoked(player, self.name, "control")
      local targets = table.filter(TargetGroup:getRealTargets(data.tos), function (id)
        local p = room:getPlayerById(id)
        return not p.dead and #p:getCardIds("e") > 0
      end)
      room:doIndicate(player.id, targets)
      room:sortPlayersByAction(targets)
      for _, id in ipairs(targets) do
        if player.dead then return end
        local p = room:getPlayerById(id)
        if not p.dead and #p:getCardIds("e") > 0 then
          local card = room:askForCardChosen(player, p, "e", self.name, "#ofl__qizhen-discard::"..p.id)
          room:throwCard(card, self.name, p, player)
        end
      end
    end
  end,
}
local mujun = fk.CreateActiveSkill{
  name = "ofl__mujun$",
  anim_type = "support",
  card_num = 0,
  target_num = 1,
  prompt = "#ofl__mujun",
  frequency = Skill.Limited,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected, selected_cards)
    local target = Fk:currentRoom():getPlayerById(to_select)
    return #selected == 0 and target.kingdom == "qun" and not target:hasSkill("yicong", true)
  end,
  on_use = function(self, room, effect)
    local target = room:getPlayerById(effect.tos[1])
    room:handleAddLoseSkills(target, "yicong", nil, true, false)
  end,
}
gongsunzan:addSkill(qizhen)
gongsunzan:addSkill("yicong")
gongsunzan:addSkill(mujun)
Fk:loadTranslationTable{
  ["ofl__gongsunzan"] = "公孙瓒",
  ["#ofl__gongsunzan"] = "白马将军",
  ["illustrator:ofl__gongsunzan"] = "沉睡千年",

  ["ofl__qizhen"] = "骑阵",
  [":ofl__qizhen"] = "当你使用【杀】结算后，若此【杀】造成伤害，你摸造成伤害值的牌；若未造成伤害，你弃置每名目标角色装备区的一张牌。",
  ["ofl__mujun"] = "募军",
  [":ofl__mujun"] = "主公技，限定技，出牌阶段，你可以令一名群势力角色获得〖义从〗。",
  ["#ofl__qizhen-discard"] = "骑阵：弃置 %dest 装备区一张牌",
  ["#ofl__mujun"] = "募军：你可以令一名群势力角色获得“义从”！",
}

local yuanshao = General(extension, "ofl__yuanshao", "qun", 4)
local sudi = fk.CreateTriggerSkill{
  name = "ofl__sudi",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.CardUseFinished, fk.CardRespondFinished},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target:inMyAttackRange(player) and data.responseToEvent and data.responseToEvent.from == player.id
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
  end,
}
local qishe = fk.CreateTriggerSkill{
  name = "ofl__qishe",
  anim_type = "drawcard",
  events = {fk.GameStart, fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      if event == fk.GameStart then
        return true
      elseif event == fk.EventPhaseStart then
        return target == player and player.phase == Player.Finish and
          table.find(player.room.discard_pile, function (id)
            return Fk:getCardById(id).trueName == "archery_attack"
          end)
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    if event == fk.GameStart then
      return true
    elseif event == fk.EventPhaseStart then
      return player.room:askForSkillInvoke(player, self.name, nil, "#ofl__qishe-invoke")
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card
    if event == fk.GameStart then
      card = room:printCard("archery_attack", Card.Heart, 1)
    elseif event == fk.EventPhaseStart then
      card = room:getCardsFromPileByRule("archery_attack", 1, "discardPile")
    end
    room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonJustMove, self.name, nil, true, player.id)
  end,
}
local linzhen = fk.CreateAttackRangeSkill{
  name = "ofl__linzhen$",
  frequency = Skill.Compulsory,
  within_func = function (self, from, to)
    return to:hasSkill(self) and from.kingdom == "qun" and from ~= to
  end,
}
yuanshao:addSkill(sudi)
yuanshao:addSkill(qishe)
yuanshao:addSkill(linzhen)
Fk:loadTranslationTable{
  ["ofl__yuanshao"] = "袁绍",
  ["#ofl__yuanshao"] = "一往无前",
  ["illustrator:ofl__yuanshao"] = "铁杵文化",

  ["ofl__sudi"] = "肃敌",
  [":ofl__sudi"] = "锁定技，攻击范围内包含你的角色响应你使用的牌后，你摸一张牌。",
  ["ofl__qishe"] = "齐射",
  [":ofl__qishe"] = "游戏开始时，你从游戏外获得一张【万箭齐发】；结束阶段，你可以从弃牌堆获得一张【万箭齐发】。",
  ["ofl__linzhen"] = "临阵",
  [":ofl__linzhen"] = "主公技，锁定技，你视为在其他群势力角色的攻击范围内。",
  ["#ofl__qishe-invoke"] = "齐射：是否从弃牌堆获得一张【万箭齐发】？",
}

local wenchou = General(extension, "ofl__wenchou", "qun", 4)
local xuezhan = fk.CreateTriggerSkill{
  name = "ofl__xuezhan",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.AfterCardUseDeclared},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card.trueName == "duel"
  end,
  on_use = function(self, event, target, player, data)
    data.unoffsetableList = table.map(player.room.alive_players, Util.IdMapper)
  end,
}
local xuezhan_filter = fk.CreateFilterSkill{
  name = "#ofl__xuezhan_filter",
  frequency = Skill.Compulsory,
  main_skill = xuezhan,
  card_filter = function(self, to_select, player)
    return player:hasSkill(xuezhan) and to_select.type == Card.TypeTrick and table.contains(player:getCardIds("h"), to_select.id)
  end,
  view_as = function(self, to_select)
    local card = Fk:cloneCard("duel", to_select.suit, to_select.number)
    card.skillName = self.name
    return card
  end,
}
local lizhen = fk.CreateViewAsSkill{
  name = "ofl__lizhen",
  anim_type = "offensive",
  pattern = "slash",
  prompt = "#ofl__lizhen",
  card_filter = function(self, to_select, selected)
    return #selected == 0 and table.contains(Self:getCardIds("e"), to_select)
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard("slash")
    card.skillName = self.name
    card:addSubcard(cards[1])
    return card
  end,
}
xuezhan:addRelatedSkill(xuezhan_filter)
wenchou:addSkill(xuezhan)
wenchou:addSkill(lizhen)
Fk:loadTranslationTable{
  ["ofl__wenchou"] = "文丑",
  ["#ofl__wenchou"] = "一夫之勇",
  ["illustrator:ofl__wenchou"] = "错落宇宙",

  ["ofl__xuezhan"] = "血战",
  [":ofl__xuezhan"] = "锁定技，你的锦囊牌均视为【决斗】；你使用【决斗】不能被【无懈可击】响应。",
  ["ofl__lizhen"] = "历阵",
  [":ofl__lizhen"] = "你可以将装备区内的牌当【杀】使用或打出。",
  ["#ofl__xuezhan_filter"] = "血战",
  ["#ofl__lizhen"] = "历阵：你可以将装备区内的牌当【杀】使用或打出",
}

--官盗E24侠客行：彭虎 彭绮 罗厉 祖郎 崔廉 单福
local function JoinInsurrectionary(player)
  local room = player.room
  room:setPlayerMark(player, "@!insurrectionary", 1)
  local tag = room:getBanner("insurrectionary") or {}
  table.insert(tag, player.id)
  room:setBanner("insurrectionary", tag)
  room:setBanner("@[:]insurrectionary", "insurrectionary_banner")
  room:sendLog{
    type = "#JoinInsurrectionary",
    from = player.id,
    toast = true,
  }
  room.logic:trigger("fk.JoinInsurrectionary", player, nil, false)
end
local function IsInsurrectionary(player)
  return table.contains(Fk:currentRoom():getBanner("insurrectionary") or {}, player.id)
end
local insurrectionary = fk.CreateTriggerSkill{
  name = "insurrectionary&",
  anim_type = "negative",
  frequency = Skill.Compulsory,
  events = {fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    return target == player and IsInsurrectionary(player) and not player.dead and  --仅考虑回合结束时的起义军状态
      #player.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function(e)
        local use = e.data[1]
        return use.from == player.id and use.card.trueName == "slash" and
          table.find(TargetGroup:getRealTargets(use.tos), function (id)
            return IsInsurrectionary(player.room:getPlayerById(id))
          end)
      end, Player.HistoryTurn) == 0 and
      #player.room.logic:getActualDamageEvents(1, function(e)
        local damage = e.data[1]
        return damage.from == player and not IsInsurrectionary(damage.to)
      end) == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choice = room:askForChoice(player, {"QuitInsurrectionary", "loseHp"}, self.name)
    if choice == "QuitInsurrectionary" then
      room:setPlayerMark(player, "@!insurrectionary", 0)
      local tag = room:getBanner("insurrectionary") or {}
      table.removeOne(tag, player.id)
      if #tag == 0 then
        room:setBanner("insurrectionary", nil)
        room:setBanner("@[:]insurrectionary", nil)
      else
        room:setBanner("insurrectionary", tag)
      end
      room:sendLog{
        type = "#QuitInsurrectionary",
        from = player.id,
        toast = true,
      }
      room.logic:trigger("fk.QuitInsurrectionary", player, nil, false)
      if not player:isKongcheng() then
        player:throwAllCards("h")
      end
    else
      room:loseHp(player, 1, self.name)
    end
  end,
}
local insurrectionary_targetmod = fk.CreateTargetModSkill{
  name = "#insurrectionary_targetmod",
  frequency = Skill.Compulsory,
  residue_func = function(self, player, skill, scope, card, to)
    if Fk:currentRoom():getBanner("insurrectionary") and skill.trueName == "slash_skill" and scope == Player.HistoryPhase then
      if IsInsurrectionary(player) then
        return 1
      elseif IsInsurrectionary(to) then
        return 1
      end
    end
  end,
}
insurrectionary:addRelatedSkill(insurrectionary_targetmod)
Fk:loadTranslationTable{
  ["insurrectionary&"] = "起义军",
  [":insurrectionary&"] = "锁定技，<br>起义军出牌阶段使用【杀】次数上限+1。<br>起义军的回合结束时，若本回合未对起义军角色使用过【杀】且"..
  "未对非起义军角色造成过伤害，需选择一项：1.失去起义军标记并弃置所有手牌；2.失去1点体力。<br>非起义军角色对起义军角色使用【杀】次数上限+1。",
  ["@[:]insurrectionary"] = "",
  ["insurrectionary_banner"] = "起义军",
  [":insurrectionary_banner"] = "锁定技，<br>起义军出牌阶段使用【杀】次数上限+1。<br>起义军的回合结束时，若本回合未对起义军角色使用过【杀】且"..
  "未对非起义军角色造成过伤害，需选择一项：1.失去起义军标记并弃置所有手牌；2.失去1点体力。<br>非起义军角色对起义军角色使用【杀】次数上限+1。",
  ["#JoinInsurrectionary"] = "%from 加入了起义军",
  ["#QuitInsurrectionary"] = "%from 退出了起义军",
  ["QuitInsurrectionary"] = "退出起义军并弃置所有手牌",
}

local penghu = General(extension, "penghu", "qun", 5)
local juqian = fk.CreateTriggerSkill{
  name = "juqian",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.GameStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self)
  end,
    on_use = function(self, event, target, player, data)
    local room = player.room
    if not IsInsurrectionary(player) then
      JoinInsurrectionary(player)
      room:handleAddLoseSkills(player, "insurrectionary&|-insurrectionary&", nil, false, true)  --迅速加载一下技能
    end
    local targets = table.filter(room.alive_players, function (p)
      return p.seat ~= 1 and not IsInsurrectionary(p)
    end)
    if #targets == 0 then return end
    local tos = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 2, "#juqian-choose", self.name, true)
    if #tos > 0 then
      room:sortPlayersByAction(tos)
      for _, id in ipairs(tos) do
        local p = room:getPlayerById(id)
        if not p.dead then
          if not room:askForSkillInvoke(p, self.name, nil, "#juqian-ask:"..player.id) then
            room:damage{
              from = player,
              to = p,
              damage = 1,
              skillName = self.name,
            }
          else
            JoinInsurrectionary(p)
          end
        end
      end
    end
  end,
}
local zhepo = fk.CreateTriggerSkill{
  name = "zhepo",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.Damage},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and (data.extra_data or {}).zhepo and
      player:usedSkillTimes(self.name, Player.HistoryTurn) == 0 and
      table.find(player.room.alive_players, function (p)
        return IsInsurrectionary(p)
      end)
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(#table.filter(player.room.alive_players, function (p)
      return IsInsurrectionary(p)
    end), self.name)
  end,

  refresh_events = {fk.BeforeHpChanged},
  can_refresh = function(self, event, target, player, data)
    return data.damageEvent and player == data.damageEvent.from and player.hp >= target.hp
  end,
  on_refresh = function(self, event, target, player, data)
    data.damageEvent.extra_data = data.damageEvent.extra_data or {}
    data.damageEvent.extra_data.zhepo = true
  end,
}
local yizhongp = fk.CreateTriggerSkill{
  name = "yizhongp",
  anim_type = "support",
  frequency = Skill.Compulsory,
  events = {"fk.JoinInsurrectionary"},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    room:changeShield(target, 1)
  end,
}
penghu:addSkill(juqian)
penghu:addSkill(zhepo)
penghu:addSkill(yizhongp)
penghu:addRelatedSkill(insurrectionary)
Fk:loadTranslationTable{
  ["penghu"] = "彭虎",
  ["#penghu"] = "鄱阳风浪",
  ["illustrator:penghu"] = "花弟",

  ["juqian"] = "聚黔",
  [":juqian"] = "锁定技，游戏开始时，你获得起义军标记，然后令至多两名不为一号位且非起义军角色依次选择一项：1.获得起义军标记；"..
  "2.你对其造成1点伤害。",
  ["zhepo"] = "辄破",
  [":zhepo"] = "锁定技，每回合限一次，当你对体力值不大于你的角色造成伤害后，你摸X张牌（X为场上起义军数量）。",
  ["yizhongp"] = "倚众",
  [":yizhongp"] = "锁定技，当一名角色成为起义军后，其获得1点护甲。",
  ["#juqian-choose"]= "聚黔：你可以令至多两名角色选择成为起义军或你对其造成1点伤害",
  ["#juqian-ask"] = "聚黔：点“确定”加入起义军（起义军技能点击左上角查看），或点“取消” %src 对你造成1点伤害！",
}

local pengqi = General(extension, "pengqi", "qun", 3, 3, General.Female)  --惨遭失去牛子的山越领袖
local jushoup = fk.CreateTriggerSkill{
  name = "jushoup",
  anim_type = "control",
  frequency = Skill.Compulsory,
  events = {fk.GameStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if not IsInsurrectionary(player) then
      JoinInsurrectionary(player)
      room:handleAddLoseSkills(player, "insurrectionary&|-insurrectionary&", nil, false, true)
    end
    local targets = table.filter(room.alive_players, function (p)
      return p.seat ~= 1 and not IsInsurrectionary(p)
    end)
    if #targets == 0 then return end
    local tos = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 2, "#jushoup-choose", self.name, true)
    if #tos > 0 then
      room:sortPlayersByAction(tos)
      for _, id in ipairs(tos) do
        local p = room:getPlayerById(id)
        if not p.dead then
          if p:isKongcheng() or player.dead or room:askForSkillInvoke(p, self.name, nil, "#jushoup-ask:"..player.id) then
            JoinInsurrectionary(p)
          else
            local card = room:askForCardChosen(player, p, "h", self.name, "#jushoup-prey::"..p.id)
            room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonPrey, self.name, nil, false, player.id)
          end
        end
      end
    end
  end,
}
local liaoluan = fk.CreateActiveSkill{
  name = "liaoluan",
  anim_type = "offensive",
  card_num = 0,
  target_num = 1,
  prompt = "#liaoluan",
  can_use = function (self, player, card, extra_data)
    return IsInsurrectionary(player) and
      player:usedSkillTimes(self.name, Player.HistoryGame) + player:usedSkillTimes("liaoluan&", Player.HistoryGame) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected, selected_cards)
    local target = Fk:currentRoom():getPlayerById(to_select)
    return not IsInsurrectionary(target) and Self:inMyAttackRange(target)
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    player:turnOver()
    if not target.dead then
      room:damage{
        from = player,
        to = target,
        damage = 1,
        skillName = self.name,
      }
    end
  end,
}
local liaoluan_trigger = fk.CreateTriggerSkill{
  name = "#liaoluan_trigger",

  refresh_events = {"fk.JoinInsurrectionary", "fk.QuitInsurrectionary",
    fk.EventAcquireSkill, fk.EventLoseSkill, fk.Deathed},
  can_refresh = function(self, event, target, player, data)
    if event == "fk.JoinInsurrectionary" then
      return player:hasSkill(self, true) and not (target:hasSkill(self, true) or target:hasSkill("liaoluan&", true))
    elseif event == "fk.QuitInsurrectionary" then
      return target:hasSkill("liaoluan&", true)
    elseif event == fk.EventAcquireSkill or event == fk.EventLoseSkill then
      return target == player and data == self and
        not table.find(player.room:getOtherPlayers(player), function(p)
          return p:hasSkill(self, true)
        end)
    elseif event == fk.Deathed then
      return target == player and player:hasSkill(self, true, true) and
        not table.find(player.room:getOtherPlayers(player), function(p)
          return p:hasSkill(self, true)
        end)
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == "fk.JoinInsurrectionary" then
      room:handleAddLoseSkills(target, "liaoluan&", nil, false, true)
    elseif event == "fk.QuitInsurrectionary" then
      room:handleAddLoseSkills(target, "-liaoluan&", nil, false, true)
    elseif event == fk.EventAcquireSkill then
      for _, p in ipairs(room:getOtherPlayers(player)) do
        if IsInsurrectionary(p) then
          room:handleAddLoseSkills(p, "liaoluan&", nil, false, true)
        end
      end
    else
      for _, p in ipairs(room:getOtherPlayers(player, true, true)) do
        room:handleAddLoseSkills(p, "-liaoluan&", nil, false, true)
      end
    end
  end,
}
local liaoluan_active = fk.CreateActiveSkill{
  name = "liaoluan&",
  anim_type = "offensive",
  card_num = 0,
  target_num = 1,
  prompt = "#liaoluan",
  can_use = function (self, player, card, extra_data)
    return IsInsurrectionary(player) and
      player:usedSkillTimes(self.name, Player.HistoryGame) + player:usedSkillTimes("liaoluan", Player.HistoryGame) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected, selected_cards)
    local target = Fk:currentRoom():getPlayerById(to_select)
    return not IsInsurrectionary(target) and Self:inMyAttackRange(target)
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    player:turnOver()
    if not target.dead then
      room:damage{
        from = player,
        to = target,
        damage = 1,
        skillName = "liaoluan",
      }
    end
  end,
}
local huaying = fk.CreateTriggerSkill{
  name = "huaying",
  anim_type = "support",
  events = {fk.Deathed},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and (IsInsurrectionary(target) or
      (data.damage and data.damage.from and IsInsurrectionary(data.damage.from) and target ~= data.damage.from)) and
      table.find(player.room.alive_players, function (p)
        return IsInsurrectionary(p)
      end)
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function (p)
      return IsInsurrectionary(p)
    end)
    local to = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 1,
      "#huaying-choose", self.name, true)
    if #to > 0 then
      self.cost_data = {tos = to}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local to = player.room:getPlayerById(self.cost_data.tos[1])
    to:setSkillUseHistory("liaoluan", 0, Player.HistoryGame)
    to:setSkillUseHistory("liaoluan&", 0, Player.HistoryGame)
    to:reset()
  end,
}
local jizhongp = fk.CreateTriggerSkill{
  name = "jizhongp",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.DrawNCards},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and IsInsurrectionary(target)
  end,
  on_use = function(self, event, target, player, data)
    data.n = data.n + 1
  end,
}
local jizhongp_distance = fk.CreateDistanceSkill{
  name = "#jizhongp_distance",
  main_skill = jizhongp,
  frequency = Skill.Compulsory,
  correct_func = function(self, from, to)
    if IsInsurrectionary(from) then
      return -#table.filter(Fk:currentRoom().alive_players, function (p)
        return p:hasSkill(jizhongp)
      end)
    end
  end,
}
jizhongp:addRelatedSkill(jizhongp_distance)
liaoluan:addRelatedSkill(liaoluan_trigger)
Fk:addSkill(liaoluan_active)
pengqi:addSkill(jushoup)
pengqi:addSkill(liaoluan)
pengqi:addSkill(huaying)
pengqi:addSkill(jizhongp)
pengqi:addRelatedSkill("insurrectionary&")
Fk:loadTranslationTable{
  ["pengqi"] = "彭绮",
  ["#pengqi"] = "百花缭乱",
  ["illustrator:pengqi"] = "xerez",

  ["jushoup"] = "聚首",
  [":jushoup"] = "锁定技，游戏开始时，你获得起义军标记，然后令至多两名不为一号位且非起义军角色依次选择一项：1.获得起义军标记；"..
  "2.你获得其一张手牌。",
  ["liaoluan"] = "缭乱",
  [":liaoluan"] = "每名起义军限一次，出牌阶段，其可以翻面，对攻击范围内一名非起义军角色造成1点伤害。",
  ["liaoluan&"] = "缭乱",
  [":liaoluan&"] = "每局游戏限一次，出牌阶段，你可以翻面，对攻击范围内一名非起义军角色造成1点伤害。",
  ["huaying"] = "花影",
  [":huaying"] = "当一名起义军杀死除其以外的角色后或死亡后，你可以令一名起义军复原武将牌且视为其未发动过〖缭乱〗。",
  ["jizhongp"] = "集众",
  [":jizhongp"] = "锁定技，起义军摸牌阶段额外摸一张牌，计算与除其以外的角色距离-1。",
  ["#jushoup-choose"]= "聚首：你可以令至多两名角色选择成为起义军或你获得其一张手牌",
  ["#jushoup-ask"] = "聚首：点“确定”加入起义军（起义军技能点击左上角查看），或点“取消” %src 获得你一张手牌！",
  ["#jushoup-prey"] = "聚首：获得 %dest 一张手牌",
  ["#liaoluan"] = "缭乱：你可以翻面，对攻击范围内一名非起义军角色造成1点伤害（每局游戏限一次！）",
  ["#huaying-choose"] = "花影：你可以令一名起义军复原武将牌且视为其未发动过“缭乱”",
}

local luoli = General(extension, "luoli", "qun", 4)
local juluan = fk.CreateTriggerSkill{
  name = "juluan",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.GameStart, fk.DamageCaused, fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      if event == fk.GameStart then
        return true
      elseif event == fk.DamageCaused then
        return target == player and #player.room.logic:getActualDamageEvents(2, function (e)
          return e.data[1].from == player
        end, Player.HistoryTurn) == 1
      elseif event == fk.DamageInflicted then
        return target == player and #player.room.logic:getActualDamageEvents(2, function (e)
          return e.data[1].to == player
        end, Player.HistoryTurn) == 1
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    if event == fk.GameStart then
      local room = player.room
      if not IsInsurrectionary(player) then
        JoinInsurrectionary(player)
        room:handleAddLoseSkills(player, "insurrectionary&|-insurrectionary&", nil, false, true)
      end
      local targets = table.filter(room.alive_players, function (p)
        return p.seat ~= 1 and not IsInsurrectionary(p)
      end)
      if #targets == 0 then return end
      local tos = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 2, "#juluan-choose", self.name, true)
      if #tos > 0 then
        room:sortPlayersByAction(tos)
        for _, id in ipairs(tos) do
          local p = room:getPlayerById(id)
          if not p.dead then
            if p:isKongcheng() or player.dead or room:askForSkillInvoke(p, self.name, nil, "#juluan-ask:"..player.id) then
              JoinInsurrectionary(p)
            else
              local card = room:askForCardChosen(player, p, "h", self.name, "#juluan-discard::"..p.id)
              room:throwCard(card, self.name, p, player)
            end
          end
        end
      end
    else
      data.damage = data.damage + 1
    end
  end,
}
local xianxing = fk.CreateTriggerSkill{
  name = "xianxing",
  anim_type = "drawcard",
  events = {fk.TargetSpecifying},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card.is_damage_card and player.phase == Player.Play and
      #AimGroup:getAllTargets(data.tos) == 1 and data.to ~= player.id and player:getMark("@@xianxing-turn") == 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil,
      "#xianxing-invoke:::"..(player:usedSkillTimes(self.name, Player.HistoryTurn) + 1))
  end,
  on_use = function(self, event, target, player, data)
    data.extra_data = data.extra_data or {}
    data.extra_data.xianxing = player.id
    player:drawCards(player:usedSkillTimes(self.name, Player.HistoryTurn), self.name)
  end,
}
local xianxing_delay = fk.CreateTriggerSkill{
  name = "#xianxing_delay",
  anim_type = "negative",
  events = {fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:usedSkillTimes("xianxing", Player.HistoryTurn) > 1 and
      data.extra_data and data.extra_data.xianxing == player.id and not data.damageDealt
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = player:usedSkillTimes("xianxing", Player.HistoryTurn) - 1
    local choice = room:askForChoice(player, {"xianxing_loseHp:::"..n, "xianxing_invalid"}, "xianxing")
    if choice == "xianxing_invalid" then
      room:setPlayerMark(player, "@@xianxing-turn", 1)
    else
      room:loseHp(player, n, "xianxing")
    end
  end,
}
xianxing:addRelatedSkill(xianxing_delay)
luoli:addSkill(juluan)
luoli:addSkill(xianxing)
luoli:addRelatedSkill("insurrectionary&")
Fk:loadTranslationTable{
  ["luoli"] = "罗厉",
  ["#luoli"] = "庐江义寇",
  ["illustrator:luoli"] = "红字虾",

  ["juluan"] = "聚乱",
  [":juluan"] = "锁定技，游戏开始时，你获得起义军标记，然后令至多两名不为一号位且非起义军角色依次选择一项：1.获得起义军标记；"..
  "2.你弃置其一张手牌。当你每回合第二次造成伤害或受到伤害时，此伤害+1。",
  ["xianxing"] = "险行",
  [":xianxing"] = "出牌阶段，当你使用伤害类牌指定其他角色为唯一目标时，你可以摸X张牌，若如此做，此牌结算后，若此牌未造成伤害且X大于1，"..
  "你选择一项：1.失去X-1点体力；2.此技能本回合失效（X为你本回合发动此技能次数）。",
  ["#juluan-choose"]= "聚乱：你可以令至多两名角色选择成为起义军或你弃置其一张手牌",
  ["#juluan-ask"] = "聚乱：点“确定”加入起义军（起义军技能点击左上角查看），或点“取消” %src 弃置你一张手牌！",
  ["#juluan-discard"] = "聚乱：弃置 %dest 一张手牌",
  ["#xianxing-invoke"] = "险行：是否摸 %arg 张牌？",
  ["@@xianxing-turn"] = "险行失效",
  ["#xianxing_delay"] = "险行",
  ["xianxing_loseHp"] = "失去%arg点体力",
  ["xianxing_invalid"] = "“险行”本回合失效",
}

local zulang = General(extension, "zulang", "qun", 5)
zulang.subkingdom = "wu"
local haokou = fk.CreateTriggerSkill{
  name = "haokou",
  anim_type = "special",
  frequency = Skill.Compulsory,
  events = {fk.GameStart, "fk.QuitInsurrectionary"},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      if event == fk.GameStart then
        return not IsInsurrectionary(player)
      elseif event == "fk.QuitInsurrectionary" then
        return player.kingdom ~= "wu"
      end
    end
  end,
    on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.GameStart then
      JoinInsurrectionary(player)
      room:handleAddLoseSkills(player, "insurrectionary&|-insurrectionary&", nil, false, true)
    elseif event == "fk.QuitInsurrectionary" then
      room:changeKingdom(player, "wu", true)
    end
  end,
}
local ronggui = fk.CreateTriggerSkill{
  name = "ronggui",
  anim_type = "offensive",
  events = {fk.TargetSpecifying},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target.kingdom == "wu" and
      (data.card.trueName == "duel" or (data.card.trueName == "slash" and data.card.color == Card.Red)) and
      #player.room:getUseExtraTargets(data, false, true) > 0 and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cards = table.filter(player:getCardIds("he"), function(id)
      local card = Fk:getCardById(id)
      return card.type == Card.TypeBasic and not player:prohibitDiscard(card)
    end)
    local to, card = room:askForChooseCardAndPlayers(player, room:getUseExtraTargets(data, false, true), 1, 1,
      tostring(Exppattern{ id = cards }), "#ronggui-invoke:"..target.id.."::"..data.card:toLogString(), self.name, true, false)
    if #to == 1 and card then
      self.cost_data = {tos = to, cards = {card}}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    AimGroup:addTargets(room, data, self.cost_data.tos)
    room:throwCard(self.cost_data.cards, self.name, player, player)
  end,
}
local xijun = fk.CreateViewAsSkill{
  name = "xijun",
  anim_type = "offensive",
  pattern = "slash,duel",
  prompt = "#xijun",
  interaction = function(self)
    local all_names = {"slash", "duel"}
    local names = U.getViewAsCardNames(Self, self.name, all_names)
    if #names > 0 then
      return U.CardNameBox { choices = names, all_choices = all_names }
    end
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).color == Card.Black
  end,
  view_as = function(self, cards)
    if #cards ~= 1 or not self.interaction.data then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = self.name
    card:addSubcard(cards[1])
    return card
  end,
  before_use = function (self, player, use)
    player.room:addPlayerMark(player, "xijun-turn", 1)
  end,
  enabled_at_play = function (self, player)
    return player:getMark("xijun-turn") < 2
  end,
  enabled_at_response = function (self, player)
    return player:getMark("xijun-turn") < 2 and player.phase == Player.Play
  end,
}
local xijun_trigger = fk.CreateTriggerSkill{
  name = "#xijun_trigger",
  anim_type = "masochism",
  events = {fk.Damaged},
  main_skill = xijun,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xijun) and player:getMark("xijun-turn") < 2
  end,
  on_cost = function(self, event, target, player, data)
    local success, dat = player.room:askForUseActiveSkill(player, "xijun", "#xijun", true,
      {
        bypass_times = true,
        extraUse = true,
      })
    if success and dat then
      self.cost_data = dat
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(player, "xijun-turn", 1)
    local card = xijun:viewAs(self.cost_data.cards)
    room:useCard{
      from = player.id,
      tos = table.map(self.cost_data.targets, function(id) return {id} end),
      card = card,
    }
  end,
}
local xijun_delay = fk.CreateTriggerSkill{
  name = "#xijun_delay",
  mute = true,
  events = {fk.Damaged, fk.PreHpRecover},
  can_trigger = function(self, event, target, player, data)
    if target == player then
      if event == fk.Damaged then
        return data.card and table.contains(data.card.skillNames, "xijun") and not player.dead
      elseif event == fk.PreHpRecover then
        return player:getMark("@@xijun-turn") > 0
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    if event == fk.Damaged then
      player.room:setPlayerMark(player, "@@xijun-turn", 1)
    else
      return true
    end
  end,
}
xijun:addRelatedSkill(xijun_trigger)
xijun:addRelatedSkill(xijun_delay)
haokou:addAttachedKingdom("qun")
ronggui:addAttachedKingdom("wu")
zulang:addSkill(xijun)
zulang:addSkill(haokou)
zulang:addSkill(ronggui)
zulang:addRelatedSkill("insurrectionary&")
Fk:loadTranslationTable{
  ["zulang"] = "祖郎",
  ["#zulang"] = "抵力坚存",
  ["illustrator:zulang"] = "XXX",

  ["xijun"] = "袭军",
  [":xijun"] = "每回合限两次，出牌阶段或当你受到伤害后，你可以将一张黑色牌当【杀】或【决斗】使用或打出，当一名角色受到此牌造成的伤害后，"..
  "防止其本回合回复体力。",
  ["haokou"] = "豪寇",
  [":haokou"] = "群势力技，锁定技，游戏开始时，你获得起义军标记；当你失去起义军标记后，你变更势力至吴。",
  ["ronggui"] = "荣归",
  [":ronggui"] = "吴势力技，当一名吴势力角色使用【决斗】或红色【杀】指定目标时，你可以弃置一张基本牌，为此牌增加一个目标。",
  ["#xijun"] = "袭军：你可以将一张黑色牌当【杀】或【决斗】使用或打出，受到此牌伤害的角色本回合不能回复体力！",
  ["#xijun_trigger"] = "袭军",
  ["#xijun_delay"] = "袭军",
  ["@@xijun-turn"] = "禁止回复体力",
  ["#ronggui-invoke"] = "荣归：你可以弃置一张基本牌，为 %src 使用的%arg增加一个目标",
}

local cuilian = General(extension, "cuilian", "qun", 4)
local tanlu = fk.CreateTriggerSkill{
  name = "tanlu",
  anim_type = "offensive",
  events = {fk.TurnStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target ~= player and not target.dead
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#tanlu-invoke::"..target.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    local n = math.abs(player.hp - target.hp)
    if n == 0 or target:getHandcardNum() < n then
    else
      local cards = room:askForCard(target, n, n, false, self.name, true, nil, "#tanlu-give:"..player.id.."::"..n)
      if #cards > 0 then
        room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonGive, self.name, nil, false, target.id)
        return
      end
    end
    room:damage{
      from = player,
      to = target,
      damage = 1,
      skillName = self.name,
    }
    if not target.dead and not player.dead and not player:isKongcheng() then
      local card = room:askForCardChosen(target, player, "h", self.name, "#tanlu-discard:"..player.id)
      room:throwCard(card, self.name, player, target)
    end
  end,
}
local jubian = fk.CreateTriggerSkill{
  name = "jubian",
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  events = {fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.from and data.from ~= player and
      player:getHandcardNum() > player.hp
  end,
  on_use = function(self, event, target, player, data)
    local n = player:getHandcardNum() - player.hp
    player.room:askForDiscard(player, n, n, false, self.name, false)
    return true
  end,
}
cuilian:addSkill(tanlu)
cuilian:addSkill(jubian)
Fk:loadTranslationTable{
  ["cuilian"] = "崔廉",
  ["#cuilian"] = "缚树行鞭",
  ["illustrator:cuilian"] = "花花",

  ["tanlu"] = "贪赂",
  [":tanlu"] = "其他角色回合开始时，你可以令其选择一项：1.交给你X张手牌；2.你对其造成1点伤害，然后其弃置你一张手牌（X为你与其体力值之差）。",
  ["jubian"] = "惧鞭",
  [":jubian"] = "锁定技，当你受到其他角色造成的伤害时，若你的手牌数大于体力值，你将手牌弃至体力值，防止此伤害。",
  ["#tanlu-invoke"] = "贪赂：你可以令 %dest 选择交给你手牌或你对其造成1点伤害",
  ["#tanlu-give"] = "贪赂：请交给 %src %arg张手牌，否则其对你造成1点伤害，你弃置其一张手牌",
  ["#tanlu-discard"] = "贪赂：弃置 %src 一张手牌",
}

local shanfu = General(extension, "ofl__xushu", "qun", 3)
shanfu.subkingdom = "shu"
local bimeng = fk.CreateViewAsSkill{
  name = "bimeng",
  prompt = function (self, selected, selected_cards)
    return "#bimeng:::"..Self.hp
  end,
  interaction = function(self)
    local all_names = U.getAllCardNames("bt")
    local names = U.getViewAsCardNames(Self, self.name, all_names)
    if #names > 0 then
      return U.CardNameBox { choices = names, all_choices = all_names }
    end
  end,
  card_filter = function (self, to_select, selected)
    return #selected < Self.hp and not table.contains(Self:getCardIds("e"), to_select)
  end,
  view_as = function(self, cards)
    if #cards ~= Self.hp or not self.interaction.data then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = self.name
    card:addSubcards(cards)
    return card
  end,
  enabled_at_play = function (self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
}
local zhue = fk.CreateTriggerSkill{
  name = "zhue",
  anim_type = "support",
  events = {fk.CardUsing},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target.kingdom == "qun" and data.card.type ~= Card.TypeEquip and
      player:usedSkillTimes(self.name, Player.HistoryTurn) == 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#zhue-invoke:"..target.id.."::"..data.card:toLogString())
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    data.extra_data = data.extra_data or {}
    data.extra_data.zhue = player.id
    data.disresponsiveList = table.map(room.alive_players, Util.IdMapper)
    target:drawCards(1, self.name)
  end,
}
local zhue_delay = fk.CreateTriggerSkill{
  name = "#zhue_delay",
  anim_type = "special",
  events = {fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    return data.extra_data and data.extra_data.zhue == player.id and data.damageDealt and player.kingdom ~= "shu"
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:changeKingdom(player, "shu", true)
  end,
}
local fuzhux = fk.CreateTriggerSkill{
  name = "fuzhux",
  anim_type = "support",
  events = {fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and data.card:isVirtual() and #data.card.subcards > 0 and
      player:usedSkillTimes(self.name, Player.HistoryTurn) == 0 and not player:isNude()
  end,
  on_cost = function (self, event, target, player, data)
    local card = player.room:askForCard(player, 1, 1, true, self.name, true, nil, "#fuzhux-invoke::"..target.id)
    if #card > 0 then
      self.cost_data = {tos = {target.id}, cards = card}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:moveCards({
      ids = self.cost_data.cards,
      from = player.id,
      toArea = Card.DrawPile,
      moveReason = fk.ReasonPut,
      skillName = self.name,
      drawPilePosition = 1,
      moveVisible = true,
    })
    local cards = room:getNCards(4)
    room:moveCardTo(cards, Card.Processing, nil, fk.ReasonJustMove, self.name, nil, true, player.id)
    room:delay(1000)
    if not target.dead then
      local ids = table.filter(cards, function (id)
        return Fk:getCardById(id).type == Card.TypeTrick
      end)
      if #ids > 0 then
        room:moveCardTo(ids, Card.PlayerHand, target, fk.ReasonJustMove, self.name, nil, true, target.id)
      end
    end
    cards = table.filter(cards, function (id)
      return room:getCardArea(id) == Card.Processing
    end)
    if #cards > 0 then
      if player.dead then
        room:moveCardTo(cards, Card.DiscardPile, nil, fk.ReasonJustMove)
      else
        local result = room:askForGuanxing(player, cards, nil, nil, self.name, true, {"Top", "Bottom"})
        local moves = {}
        if #result.top > 0 then
          table.insert(moves, {
            ids = result.top,
            toArea = Card.DrawPile,
            moveReason = fk.ReasonPut,
            skillName = self.name,
            drawPilePosition = 1,
            moveVisible = false,
          })
        end
        if #result.bottom > 0 then
          table.insert(moves, {
            ids = result.bottom,
            toArea = Card.DrawPile,
            moveReason = fk.ReasonPut,
            skillName = self.name,
            drawPilePosition = -1,
            moveVisible = false,
          })
        end
        room:moveCards(table.unpack(moves))
        room:sendLog{
          type = "#GuanxingResult",
          from = player.id,
          arg = #result.top,
          arg2 = #result.bottom,
        }
      end
    end
  end,
}
zhue:addRelatedSkill(zhue_delay)
zhue:addAttachedKingdom("qun")
fuzhux:addAttachedKingdom("shu")
shanfu:addSkill(bimeng)
shanfu:addSkill(zhue)
shanfu:addSkill(fuzhux)
Fk:loadTranslationTable{
  ["ofl__xushu"] = "单福",
  ["#ofl__xushu"] = "忠孝万全",
  ["illustrator:ofl__xushu"] = "木美人",

  ["bimeng"] = "蔽蒙",
  [":bimeng"] = "出牌阶段限一次，你可以将X张手牌当任意一张基本牌或普通锦囊牌使用（X为你的体力值）。",
  ["zhue"] = "诛恶",
  [":zhue"] = "群势力技，每回合限一次，当一名群势力角色使用非装备牌时，你可以令其摸一张牌，令此牌不能被响应；此牌结算后，若此牌造成过伤害，"..
  "你变更势力至蜀。",
  ["fuzhux"] = "辅主",
  [":fuzhux"] = "蜀势力技，每回合限一次，当一名角色使用转化牌结算后，你可以将一张牌置于牌堆顶，然后亮出牌堆顶四张牌，其获得这些牌中"..
  "所有锦囊牌，你将其余牌以任意顺序置于牌堆顶或牌堆底。",
  ["#bimeng"] = "蔽蒙：你可以将%arg张手牌当任意基本牌或普通锦囊牌使用",
  ["#zhue-invoke"] = "诛恶：是否令 %src 摸一张牌且其使用的%arg不能被响应？若此牌造成伤害，你变更势力为蜀",
  ["#zhue_delay"] = "诛恶",
  ["#fuzhux-invoke"] = "辅主：你可以将一张牌置于牌堆顶，令 %dest 亮出牌堆顶四张牌并获得其中的锦囊牌",
}

return extension
