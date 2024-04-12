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
    return target == player and player:hasSkill(self) and data.card.trueName == "slash" and
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
    if to:isNude() then
      data.disresponsiveList = data.disresponsiveList or {}
      table.insert(data.disresponsiveList, data.to)
    else
      local card = room:askForCard(to, 1, 1, true, self.name, true, ".|.|.|.|.|"..self.cost_data,
        "#conqueror-give:"..player.id.."::"..self.cost_data)
      if #card > 0 then
        room:obtainCard(player.id, card[1], true, fk.ReasonGive)
        return true
      else
        data.disresponsiveList = data.disresponsiveList or {}
        table.insert(data.disresponsiveList, data.to)
      end
    end
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
  card_filter = function(self, to_select, selected)
    return false
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    return false
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local cards = room:getNCards(2)
    room:moveCards({
      ids = cards,
      toArea = Card.Processing,
      moveReason = fk.ReasonJustMove,
      skillName = self.name,
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
        local dummy = Fk:cloneCard("dilu")
        dummy:addSubcards(cards)
        room:obtainCard(player, dummy, true, fk.ReasonJustMove)
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
        room:moveCards({
          ids = cards,
          toArea = Card.DiscardPile,
          moveReason = fk.ReasonJustMove,
          skillName = self.name,
        })
      end
    else
      room:fillAG(player, cards)
      local id = room:askForAG(player, cards, false, self.name)
      room:closeAG(player)
      if not id then return false end
      table.removeOne(cards, id)
      room:obtainCard(player, id, true, fk.ReasonJustMove)
      room:moveCards({
        ids = cards,
        toArea = Card.DiscardPile,
        moveReason = fk.ReasonJustMove,
        skillName = self.name,
      })
    end
  end,
}
local miaojian = fk.CreateViewAsSkill{
  name = "miaojian",
  prompt = function (self, selected, selected_cards)
    if Self:getMark("@miaojian") == 0 then
      return "#miaojian1"
    elseif Self:getMark("@miaojian") == "status2" then
      return "#miaojian2"
    elseif Self:getMark("@miaojian") == "status3" then
      return "#miaojian3"
    end
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
  on_cost = function(self, event, target, player, data)
    return true
  end,
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

Fk:loadTranslationTable{
  ["ofl__wangyun"] = "王允",
  ["ofl__lianji"] = "连计",
  [":ofl__lianji"] = "出牌阶段结束时，若你本阶段使用牌类别数不小于：1，你可以令一名角色摸一张牌；2.你可以回复1点体力；3.你可以令一名其他角色"..
  "代替你执行本回合剩余阶段。",
  ["ofl__moucheng"] = "谋逞",
  [":ofl__moucheng"] = "每回合限一次，你可以将一张黑色牌当【借刀杀人】使用。",
}
--国战转身份的官盗：钟会 孟达 孙綝 文钦

Fk:loadTranslationTable{
  ["ofl__caoanmin"] = "曹安民",
  ["kuishe"] = "窥舍",
  [":kuishe"] = "出牌阶段限一次，你可以选择一名其他角色一张牌，将此牌交给另一名角色，然后失去牌的角色可以对你使用一张【杀】。",
}

Fk:loadTranslationTable{
  ["longyufei"] = "龙羽飞",
  ["longyi"] = "龙裔",
  [":longyi"] = "你可以将所有手牌当任意一张基本牌使用或打出，若其中有：锦囊牌，你摸一张牌；装备牌，此牌不可被响应。",
  ["zhenjue"] = "阵绝",
  [":zhenjue"] = "一名角色结束阶段，若你没有手牌，你可以令其选择一项：1.弃置一张牌；2.你摸一张牌。",
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
        return table.contains(U.getMark(player, "@lianpoj"), "lianpoj1")
      elseif event == fk.Deathed then
        return #U.getMark(player, "@lianpoj") > 1
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
      if table.contains({"aaa_role_mode", "aab_role_mode", "vanished_dragon"}, room.settings.gameMode) then
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

  refresh_events = {fk.GameStart, fk.EventAcquireSkill, fk.BeforeGameOverJudge, fk.AfterPlayerRevived, fk.RoundEnd, fk.EventLoseSkill},
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
      if table.contains(U.getMark(p, "@lianpoj"), "lianpoj2") and p ~= player then
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
        if table.contains(U.getMark(p, "@lianpoj"), "lianpoj2") then
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
      if table.contains(U.getMark(p, "@lianpoj"), "lianpoj2") then
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
        return table.contains(U.getMark(p, "@lianpoj"), "lianpoj1") and p ~= from
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
    return player:getMark(self.name) ~= 0 and player:getMark("zhaoluan-phase") == 0 and --这里不能用usedSkillTimes
      not Fk:currentRoom():getPlayerById(player:getMark(self.name)).dead
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:setPlayerMark(player, "zhaoluan-phase", 1)
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
      if not (s.attached_equip or s.name[#s.name] == "&") and s.frequency ~= Skill.Compulsory and s.frequency ~= Skill.Wake then
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
  ["cv:godjiaxu"] = "酉良",
  ["lianpoj"] = "炼魄",
  [":lianpoj"] = "锁定技，若场上的最大阵营为：<br>反贼，其他角色手牌上限-1，所有角色出牌阶段使用【杀】次数上限+1、攻击范围+1；<br>"..
  "主忠，其他角色不能对除其以外的角色使用【桃】；<br>多个最大阵营，其他角色死亡后，伤害来源摸两张牌或回复1点体力。<br>"..
  "每轮开始时，你展示一张未加入游戏的身份牌或一张已死亡角色的身份牌，本轮视为该阵营角色数+1。",
  ["zhaoluan"] = "兆乱",
  [":zhaoluan"] = "限定技，一名角色濒死结算后，若其仍处于濒死状态，你可以令其加3点体力上限并失去所有非锁定技，回复体力至3并摸四张牌。"..
  "出牌阶段限一次，你可以令该角色减1点体力上限，其对一名你选择的角色造成1点伤害。",
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
    local result = U.askForArrangeCards(player, self.name, {cards, "Top", target.general, player.general}, "#ofl__yuqi",
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
    if #cards > 0 then
      for i = #cards, 1, -1 do
        table.insert(room.draw_pile, 1, cards[i])
      end
    end
    room:moveCards(table.unpack(moveInfos))
  end,

  refresh_events = {fk.EventLoseSkill, fk.EventAcquireSkill},
  can_refresh = function(self, event, target, player, data)
    return player == target and data == self
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.EventAcquireSkill then
      room:setPlayerMark(player, "ofl__yuqi1", 0)
      room:setPlayerMark(player, "ofl__yuqi2", 3)
      room:setPlayerMark(player, "ofl__yuqi3", 1)
      room:setPlayerMark(player, "ofl__yuqi4", 1)
      room:setPlayerMark(player, "@" .. self.name, string.format("%d-%d-%d-%d", 0, 3, 1, 1))
    else
      room:setPlayerMark(player, "ofl__yuqi1", 0)
      room:setPlayerMark(player, "ofl__yuqi2", 0)
      room:setPlayerMark(player, "ofl__yuqi3", 0)
      room:setPlayerMark(player, "ofl__yuqi4", 0)
      room:setPlayerMark(player, "@" .. self.name, 0)
    end
  end,
}
local function AddYuqi(player, skillName, num)
  local room = player.room
  local choices = {}
  for i = 1, 4, 1 do
    if player:getMark("ofl__yuqi" .. tostring(i)) < 5 then
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
    if target:getMark(self.name) == 0 and player:isWounded() then
      room:recover{
        who = player,
        num = 1,
        skillName = self.name,
      }
    end
  end,
  refresh_events = {fk.DamageCaused},
  can_refresh = function(self, event, target, player, data)
    return target == player and target:hasSkill(self) and data.to:getMark(self.name) == 0
  end,
  on_refresh = function(self, event, target, player, data)
      player.room:setPlayerMark(data.to, self.name, 1)
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
    return table.contains(card.skillNames, "ofl__shouli")
  end,
  bypass_distances = function(self, player, skill, card)
    return table.contains(card.skillNames, "ofl__shouli")
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

local caoren = General(extension, "ofl__caoren", "wei", 4)
local lizhong_nullification = fk.CreateViewAsSkill{
  name = "lizhong&",
  anim_type = "defensive",
  pattern = "nullification",
  prompt = "#lizhong-viewas",
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:currentRoom():getCardArea(to_select) == Player.Equip
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then return end
    local c = Fk:cloneCard("nullification")
    c.skillName = self.name
    c:addSubcard(cards[1])
    return c
  end,
  enabled_at_play = Util.FalseFunc,
  enabled_at_response = function (self, player)
    return #player.player_cards[Player.Equip] > 0
  end,
}
local lizhong_active = fk.CreateActiveSkill{
  name = "lizhong_active",
  card_num = 1,
  target_num = 1,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).type == Card.TypeEquip
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and #selected_cards == 1 and
    U.canMoveCardIntoEquip(Fk:currentRoom():getPlayerById(to_select), selected_cards[1], false)
  end,
}
local lizhong = fk.CreateTriggerSkill{
  name = "lizhong",
  anim_type = "support",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player.phase == Player.Finish and player:hasSkill(self)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local lizhong_use = true
    while true do
      local success, dat = room:askForUseActiveSkill(player, "lizhong_active", "#lizhong-put")
      if success then
        room:moveCardTo(dat.cards[1], Card.PlayerEquip, room:getPlayerById(dat.targets[1]), fk.ReasonPut, self.name, "", true, player.id)
        lizhong_use = false
      else
        break
      end
      if player.dead then return false end
    end
    local _, ret = room:askForUseActiveSkill(player, "choose_players_skill", "#lizhong-choose", true, {
      targets = table.map(table.filter(room.alive_players, function (p)
        return #p.player_cards[Player.Equip] > 0
      end), Util.IdMapper),
      num = 2,
      min_num = 0,
      pattern = "",
      skillName = self.name
    }, false)
    if ret then
      local tos = ret.targets
      if #tos == 0 then
        table.insert(tos, player.id)
      else
        room:sortPlayersByAction(tos)
      end
      for _, pid in ipairs(tos) do
        local p = room:getPlayerById(pid)
        if not p.dead then
          p:drawCards(1, self.name)
          if not p.dead then
            if p:getMark("@@lizhong-round") == 0 then
              room:setPlayerMark(p, "@@lizhong-round", 1)
              room:addPlayerMark(p, "AddMaxCards-round", 2)
            end
            if not p:hasSkill("lizhong&") then
              room:handleAddLoseSkills(p, "lizhong&", nil, false, true)
              room.logic:getCurrentEvent():findParent(GameEvent.Round):addCleaner(function()
                room:handleAddLoseSkills(player, "-lizhong&", nil, false, true)
              end)
            end
          end
        end
      end
    end
    if lizhong_use then
      while true do
        local success, dat = room:askForUseActiveSkill(player, "lizhong_active", "#lizhong-put")
        if success then
          room:moveCardTo(dat.cards[1], Card.PlayerEquip, room:getPlayerById(dat.targets[1]), fk.ReasonPut, self.name, "", true, player.id)
        else
          break
        end
        if player.dead then return false end
      end
    end
  end,
}
local juesui_slash = fk.CreateViewAsSkill{
  name = "juesui&",
  anim_type = "offensive",
  pattern = "slash",
  prompt = "#juesui-viewas",
  card_filter = function(self, to_select, selected)
    if #selected == 0 then
      local card = Fk:getCardById(to_select)
      return card.color == Card.Black and card.type ~= Card.TypeBasic
    end
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard("slash")
    card.skillName = self.name
    card:addSubcard(cards[1])
    return card
  end,
}
local juesui_targetmod = fk.CreateTargetModSkill{
  name = "#juesui_targetmod",
  bypass_times = function(self, player, skill, scope, card)
    return table.contains(card.skillNames, "juesui&")
  end,
}
local juesui = fk.CreateTriggerSkill{
  name = "juesui",
  anim_type = "support",
  events = {fk.EnterDying},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and not target.dead and not table.contains(U.getMark(player, "juesui_used"), target.id) and
    #target:getAvailableEquipSlots() > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askForSkillInvoke(player, self.name, nil, "#juesui-invoke::"..target.id) then
      room:doIndicate(player.id, {target.id})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local mark = U.getMark(player, "juesui_used")
    table.insert(mark, target.id)
    room:setPlayerMark(player, "juesui_used", mark)
    if player ~= target and not room:askForSkillInvoke(target, self.name, nil, "#juesui-accept") then return false end
    room:recover({
      who = target,
      num = 1 - target.hp,
      recoverBy = player,
      skillName = self.name
    })
    if target.dead then return false end
    local eqipSlots = target:getAvailableEquipSlots()
    if #eqipSlots > 0 then
      room:abortPlayerArea(target, eqipSlots)
    end
    if target.dead then return false end
    room:setPlayerMark(target, "@@juesui", 1)
    room:handleAddLoseSkills(target, "juesui&", nil, false, true)
  end,
}
Fk:addSkill(lizhong_active)
Fk:addSkill(lizhong_nullification)
juesui_slash:addRelatedSkill(juesui_targetmod)
Fk:addSkill(juesui_slash)
caoren:addSkill(lizhong)
caoren:addSkill(juesui)

Fk:loadTranslationTable{
  ["ofl__caoren"] = "曹仁",
  ["lizhong"] = "厉众",
  [":lizhong"] = "结束阶段，你可选择任意项：1.将任意张装备牌置入任意名角色的装备区；2.令你或任意名装备区里有牌的角色各摸一张牌，"..
  "以此法摸牌的角色本轮内手牌上限+2且可以将装备区里的牌当【无懈可击】使用。",
  ["juesui"] = "玦碎",
  [":juesui"] = "当一名角色进入濒死状态时，若你未对其发动过此技能，你可以令其选择是否回复体力至1点并废除所有装备栏。"..
  "若其如此做，其本局游戏内可以将黑色非基本牌当无次数限制的【杀】使用或打出。",
  ["lizhong_active"] = "厉众",
  ["#lizhong-put"] = "厉众：将装备牌置入一名角色的装备区",
  ["#lizhong-choose"] = "厉众：选择任意名装备区里有牌的角色各摸一张牌，若不选角色则为你",
  ["@@lizhong-round"] = "厉众",
  ["#juesui-invoke"] = "是否对 %dest 发动 玦碎，令其可以回复体力至1点并废除所有装备栏",
  ["#juesui-accept"] = "玦碎：是否将体力值回复体力至1点并废除所有装备栏",
  ["@@juesui"] = "玦碎",
  ["lizhong&"] = "厉众",
  [":lizhong&"] = "你本轮内可以将装备区里的牌当【无懈可击】使用。",
  ["juesui&"] = "玦碎",
  [":juesui&"] = "你可以将黑色非基本牌当无次数限制的【杀】使用或打出。",
  ["#lizhong-viewas"] = "发动 厉众，将装备区里的牌当【无懈可击】使用",
  ["#juesui-viewas"] = "发动 玦碎，将黑色非基本牌当无次数限制的【杀】使用或打出",
}
local guanyu = General:new(extension, "ofl__guanyu", "shu", 4)
local chaojue = fk.CreateTriggerSkill{
  name = "chaojue",
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Start and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local card = player.room:askForDiscard(player, 1, 1, false, self.name, true, ".", "#chaojue-invoke", true)
    if #card > 0 then
      self.cost_data = card[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(self.cost_data, self.name, player, player)
    if player.dead then return end
    local mark = player:getNextAlive():getMark("@chaojue-turn")
    if mark == 0 then mark = {} end
    if Fk:getCardById(self.cost_data).suit ~= Card.NoSuit then
      table.insertIfNeed(mark, Fk:getCardById(self.cost_data):getSuitString(true))
    end
    for _, p in ipairs(room:getOtherPlayers(player)) do
      room:doIndicate(player.id, {p.id})
      room:setPlayerMark(p, "@chaojue-turn", mark)
    end
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if player.dead then return end
      local cards = room:askForCard(p, 1, 1, false, self.name, true, ".|.|"..Fk:getCardById(self.cost_data):getSuitString(), "#chaojue-cost::"..player.id..":"..Fk:getCardById(self.cost_data):getSuitString(), true)
      if #cards > 0 then
        room:obtainCard(player, cards, true, fk.ReasonPrey)
      else
        room:addPlayerMark(p, "@@chaojue-turn")
        room:addPlayerMark(p, MarkEnum.UncompulsoryInvalidity .. "-turn")
      end
    end
  end,
}
local chaojuejue_prohibit = fk.CreateProhibitSkill{
  name = "#chaojuejue_prohibit",
  prohibit_use = function(self, player, card)
    return player:getMark("@chaojue-turn") ~= 0 and table.contains(player:getMark("@chaojue-turn"), card:getSuitString(true))
  end,
  prohibit_response = function(self, player, card)
    return player:getMark("@chaojue-turn") ~= 0 and table.contains(player:getMark("@chaojue-turn"), card:getSuitString(true))
  end,
}
local junshen_targetmod = fk.CreateTargetModSkill{
  name = "#junshen_targetmod",
  bypass_distances = function (self, player, skill, card, to)
    return player:hasSkill("junshen") and skill.trueName == "slash_skill" and card.suit == Card.Diamond
  end,
  extra_target_func = function(self, player, skill, card)
    if player:hasSkill("junshen") and skill.trueName == "slash_skill" and card.suit == Card.Heart then
      return 1
    end
  end,
}
local junshen_trigger = fk.CreateTriggerSkill{
  name = "#junshen_trigger",
  anim_type = "offensive",
  events = {fk.DamageCaused},
  on_cost = Util.TrueFunc,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill("junshen") and data.card and data.card.trueName == "slash" and table.contains(data.card.skillNames, "junshen") and not data.chain 
  end,
  on_use = function(self, event, target, player, data) 
    local room = player.room
    if #data.to:getCardIds("e") == 0 then
      data.damage = data.damage + 1
    else
    
      local choices = {"junshen_choice1","junshen_choice2"}
      local choice = room:askForChoice(data.to, choices, self.name, "#junshen-choice:" .. player.id)
      if choice == "junshen_choice1" then
         data.damage = data.damage + 1
      elseif choice == "junshen_choice2" then
        data.to:throwAllCards("e")
      end
    end
  end,
}
local junshen = fk.CreateViewAsSkill{
  name = "junshen",
  anim_type = "offensive",
  pattern = "slash",
  card_filter = function(self, to_select, selected)
    if #selected == 1 then return false end
    return Fk:getCardById(to_select).color == Card.Red
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then
      return nil
    end
    local c = Fk:cloneCard("slash")
    c.skillName = self.name
    c:addSubcard(cards[1])
    return c
  end,
}
junshen:addRelatedSkill(junshen_trigger)
junshen:addRelatedSkill(junshen_targetmod)
chaojue:addRelatedSkill(chaojuejue_prohibit)
guanyu:addSkill(chaojue)
guanyu:addSkill(junshen)
Fk:loadTranslationTable{
  ["ofl__guanyu"] = "关羽",
  ["chaojue"] = "超绝",
  [":chaojue"] = "准备阶段，你可以弃置一张手牌，令所有其他角色本回合不能使用或打出与此牌花色相同的牌，然后这些角色依次选择一项:1.展示并交给你一张相同花色的手牌; 2.其本回合内所有非锁定技失效。",
  ["@@chaojue-turn"] ="被超绝",
  ["@chaojue-turn"] = "超绝",
  ["#chaojue-invoke"] = "超绝:是否弃置一张手牌，令所有其他角色本回合不能使用或打出该花色的牌?",
  ["#chaojue-cost"] = "超绝：你需交给%dest一张%arg手牌，否则本回合你的非锁定技失效",
  ["junshen"] = "军神",
  ["#junshen_trigger"] = "军神",
  [":junshen"] = "你可以将一张红色牌当做【杀】使用或打出。;当你以此法使用【杀】对一名角色造成伤害时，其需选择一项:1.弃置装备区内的所有牌; 2.令此伤害+1。; 你使用<font color='red'>♦</font>【杀】无距离限制，<font color='red'> ♥️</font>【杀】可以多选择一个目标。",
 ["#junshen-choice"] = "军神: 弃置装备区的所有牌或者令%src 对你造成的伤害+1。",
 ["junshen_choice1"] = "弃置装备",
 ["junshen_choice2"] = "受伤+1"
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
        local dummy = Fk:cloneCard("dilu")
        dummy:addSubcards(cards)
        room:moveCardTo(dummy, Card.PlayerHand, player, fk.ReasonGive, self.name, nil, true, target.id)
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

local sgsh__jiangwei = General(extension, "sgsh__jiangwei", "shu", 4)
local sgsh__zhijij = fk.CreateViewAsSkill{
  name = "sgsh__zhijij",
  anim_type = "control",
  pattern = "nullification",
  prompt = "#sgsh__zhijij",
  card_filter = Util.FalseFunc,
  view_as = function(self, cards)
    local card = Fk:cloneCard("nullification")
    card.skillName = self.name
    return card
  end,
  before_use = function (self, player, use)
    player.room:loseHp(player, 1, self.name)
  end,
}
sgsh__jiangwei:addSkill("tiaoxin")
sgsh__jiangwei:addSkill(sgsh__zhijij)
Fk:loadTranslationTable{
  ["sgsh__jiangwei"] = "姜维",
  ["sgsh__zhijij"] = "智继",
  [":sgsh__zhijij"] = "当你需要使用【无懈可击】时，你可以失去1点体力，视为使用【无懈可击】。",
  ["#sgsh__zhijij"] = "智继：你可以失去1点体力，视为使用【无懈可击】",
}

local sgsh__luxun = General(extension, "sgsh__luxun", "wu", 3)
local sgsh__lianying = fk.CreateTriggerSkill{
  name = "sgsh__lianying",
  anim_type = "drawcard",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self.name) and player:isKongcheng() and player:usedSkillTimes(self.name, Player.HistoryTurn) == 0 then
      for _, move in ipairs(data) do
        if move.from == player.id then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand then
              return true
            end
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(player.maxHp, self.name)
  end,
}
sgsh__luxun:addSkill("qianxun")
sgsh__luxun:addSkill(sgsh__lianying)
Fk:loadTranslationTable{
  ["sgsh__luxun"] = "陆逊",
  ["sgsh__lianying"] = "连营",
  [":sgsh__lianying"] = "每回合限一次，当你失去最后一张手牌后，你可以将手牌摸至体力上限。",

  ["$sgsh__lianying1"] = "失之东隅，收之桑榆。",
  ["$sgsh__lianying2"] = "天下万物生于有，有生于无。",
  ["~sgsh__luxun"] = "我何以……至此？",
}

local sgsh__lvbu = General(extension, "sgsh__lvbu", "qun", 4)
local sgsh__qingjiao = fk.CreateTriggerSkill{
  name = "sgsh__qingjiao",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Finish and
      #player.room.logic:getEventsOfScope(GameEvent.ChangeHp, 1, function(e)
        local damage = e.data[5]
        if damage and player == damage.from and damage.to.kingdom == "qun" and damage.to ~= player then
          return true
        end
      end, Player.HistoryTurn) > 0
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
  end,
}
sgsh__lvbu:addSkill("wushuang")
sgsh__lvbu:addSkill(sgsh__qingjiao)
Fk:loadTranslationTable{
  ["sgsh__lvbu"] = "吕布",
  ["sgsh__qingjiao"] = "轻狡",
  [":sgsh__qingjiao"] = "主公技，锁定技，结束阶段，若你本回合对其他群势力角色造成过伤害，你摸一张牌。",
}

Fk:loadTranslationTable{
  ["sgsh__zuoci"] = "左慈",
  ["sgsh__huanshen"] = "化身",
  [":sgsh__huanshen"] = "出牌阶段限一次，你可以选择一名其他角色，声明其武将牌上的一个技能，你获得此技能直到回合结束。",
  ["sgsh__xinsheng"] = "新生",
  [":sgsh__xinsheng"] = "主将技，准备阶段，你可以移除一张副将，然后随机获得一张未加入游戏的武将牌作为副将。",
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

Fk:loadTranslationTable{
  ["sgsh__nanhualaoxian"] = "南华老仙",
  ["sgsh__jidao"] = "祭祷",
  [":sgsh__jidao"] = "主将技，当一名角色的武将牌被移除时，你可以摸一张牌。",
  ["sgsh__feisheng"] = "飞升",
  [":sgsh__feisheng"] = "副将技，当此武将牌被移除时，你可以回复1点体力或摸两张牌。",
  ["sgsh__jinghe"] = "经合",
  [":sgsh__jinghe"] = "当一名其他角色获得随机副将武将牌前，你可以令其改为观看两张未加入游戏的武将牌并选择一张作为副将。",
}

return extension
