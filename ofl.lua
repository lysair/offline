local extension = Package("ofl")
extension.extensionName = "offline"

local U = require "packages/utility/utility"

Fk:loadTranslationTable{
  ["ofl"] = "线下",
  ["rom"] = "风花雪月",
  ["chaos"] = "文和乱武",
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
local function UpdateLianpo(player)
  local room = player.room
  local roles = player:getMark("lianpoj_exist_roles")
  if roles[1] > roles[2] and roles[1] > roles[3] then
    room:setPlayerMark(player, "@lianpoj", "lord+loyalist")
  elseif roles[2] > roles[1] and roles[2] > roles[3] then
    room:setPlayerMark(player, "@lianpoj", "rebel")
  elseif roles[3] > roles[1] and roles[3] > roles[2] then
    room:setPlayerMark(player, "@lianpoj", "renegade")
  elseif roles[1] == roles[2] and roles[1] > roles[3] then
    room:setPlayerMark(player, "@lianpoj", "lianpoj12")
  elseif roles[1] == roles[3] and roles[1] > roles[2] then
    room:setPlayerMark(player, "@lianpoj", "lianpoj13")
  elseif roles[2] == roles[3] and roles[2] > roles[1] then
    room:setPlayerMark(player, "@lianpoj", "lianpoj23")
  else
    room:setPlayerMark(player, "@lianpoj", "lianpoj123")
  end
end
local function LianpoJudge(player, role)
  if player:getMark("@lianpoj") == 0 then return false end
  if role == "loyalist" then
    return table.contains({"lord+loyalist", "lianpoj12", "lianpoj13", "lianpoj123"}, player:getMark("@lianpoj"))
  elseif role == "rebel" then
    return table.contains({"rebel", "lianpoj12", "lianpoj23", "lianpoj123"}, player:getMark("@lianpoj"))
  end
  return false
end
local lianpoj = fk.CreateTriggerSkill{
  name = "lianpoj",
  anim_type = "special",
  frequency = Skill.Compulsory,
  events = {fk.RoundStart, fk.EnterDying, fk.Deathed},
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(self) then
      if event == fk.RoundStart then
        return player:getMark("lianpoj_extra_roles") ~= {0, 0, 0}
      elseif event == fk.EnterDying then
        return LianpoJudge(player, "loyalist")
      elseif event == fk.Deathed then
        return table.contains({"lianpoj12", "lianpoj13", "lianpoj23", "lianpoj123"}, player:getMark("@lianpoj")) and
          data.damage and data.damage.from and not data.damage.from.dead
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if event == fk.RoundStart then
      local exist_roles, extra_roles = U.getMark(player, "lianpoj_exist_roles"), U.getMark(player, "lianpoj_extra_roles")
      local roles = {"loyalist", "rebel", "renegade"}
      local choices = {}
      for i = 1, 3, 1 do
        if extra_roles[i] > 0 then
          table.insert(choices, roles[i])
        end
      end
      if #choices == 0 then return end
      local choice = room:askForChoice(player, choices, self.name, "#lianpoj-choice", false, {"lord", "loyalist", "rebel", "renegade"})
      local new_role = table.indexOf(roles, choice)
      local extra = player:getMark(self.name)
      if extra == 0 then
        exist_roles[new_role] = exist_roles[new_role] + 1
        extra_roles[new_role] = extra_roles[new_role] - 1
      else
        local orig_role = table.indexOf(roles, extra)
        exist_roles[new_role] = exist_roles[new_role] + 1
        exist_roles[orig_role] = exist_roles[orig_role] - 1
        extra_roles[new_role] = extra_roles[new_role] - 1
        extra_roles[orig_role] = extra_roles[orig_role] + 1
      end
      room:doBroadcastNotify("ShowToast", Fk:translate("lianpoj_choice")..Fk:translate(choice))
      room:setPlayerMark(player, self.name, choice)
      room:setPlayerMark(player, "lianpoj_exist_roles", exist_roles)
      room:setPlayerMark(player, "lianpoj_extra_roles", extra_roles)
      UpdateLianpo(player)
    elseif event == fk.EnterDying then
      player:broadcastSkillInvoke("wansha")
      room:notifySkillInvoked(player, self.name)
    elseif event == fk.Deathed then
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

  refresh_events = {fk.GameStart, fk.EventAcquireSkill, fk.BeforeGameOverJudge},
  can_refresh = function(self, event, target, player, data)
    if player:hasSkill(self, true) then
      if event == fk.EventAcquireSkill then
        return target == player and data == self
      else
        return true
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.GameStart or event == fk.EventAcquireSkill then
      local exist_roles, extra_roles = {0, 0, 0}, {0, 0, 0}
      if room.settings.gameMode == "aaa_role_mode" or room.settings.gameMode == "vanished_dragon" then
        local loyalist, rebel, renegade = 0, 0, 0
        for _, p in ipairs(room.players) do
          if p.role == "lord" or p.role == "loyalist" then
            loyalist = loyalist + 1
          elseif p.role == "rebel" then
            rebel = rebel + 1
          elseif p.role == "renegade" then
            renegade = renegade + 1
          end
        end
        exist_roles = {loyalist, rebel, renegade}
        extra_roles = {4 - loyalist, 4 - rebel, 2 - renegade}
      elseif room.settings.gameMode == "m_1v2_mode" then
        exist_roles = {1, 2, 0}
        extra_roles = {0, 0, 0}
      elseif room.settings.gameMode == "m_2v2_mode" then
        exist_roles = {2, 2, 0}
        extra_roles = {0, 0, 0}
      else
        exist_roles = {0, 0, 0}
        extra_roles = {0, 0, 0}
      end
      room:setPlayerMark(player, "lianpoj_exist_roles", exist_roles)
      room:setPlayerMark(player, "lianpoj_extra_roles", extra_roles)
      UpdateLianpo(player)
    else
      local exist_roles, extra_roles = player:getMark("lianpoj_exist_roles"), player:getMark("lianpoj_extra_roles")
      if target.role == "lord" or target.role == "loyalist" then
        exist_roles[1] = exist_roles[1] - 1
        extra_roles[1] = extra_roles[1] + 1
      elseif target.role == "rebel" then
        exist_roles[2] = exist_roles[2] - 1
        extra_roles[2] = extra_roles[2] + 1
      elseif target.role == "renegade" then
        exist_roles[3] = exist_roles[3] - 1
        extra_roles[3] = extra_roles[3] + 1
      end
      room:setPlayerMark(player, "lianpoj_exist_roles", exist_roles)
      room:setPlayerMark(player, "lianpoj_extra_roles", extra_roles)
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
      if LianpoJudge(p, "rebel") and p ~= player then
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
        if LianpoJudge(p, "rebel") then
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
      if LianpoJudge(p, "rebel") then
        n = n + 1
      end
    end
    return n
  end,
}
local lianpoj_prohibit = fk.CreateProhibitSkill{
  name = "#lianpoj_prohibit",
  is_prohibited = function (self, from, to, card)
    if card and card.name == "peach" and from ~= to then
      return table.find(Fk:currentRoom().alive_players, function(p)
        return LianpoJudge(p, "loyalist") and p ~= from
      end)
    end
  end,
  prohibit_use = function(self, player, card)
    if card and card.name == "peach" and not player.dying and
      table.find(Fk:currentRoom().alive_players, function(p) return LianpoJudge(p, "loyalist") and p ~= player end) then
      for _, p in ipairs(Fk:currentRoom().alive_players) do
        if p.dying then
          return true
        end
      end
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
  card_filter = function(self, to_select, selected)
    return false
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:setPlayerMark(player, "zhaoluan-phase", 1)
    local src = room:getPlayerById(player:getMark(self.name))
    player:broadcastSkillInvoke(self.name)
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
    room:changeMaxHp(target, 3)
    local skills = {}
    for _, s in ipairs(target.player_skills) do
      if not (s.attached_equip or s.name[#s.name] == "&") and s.frequency ~= Skill.Compulsory then
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
    if not target.dead and target.hp < 3 then
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
  ["lianpoj"] = "炼魄",
  [":lianpoj"] = "锁定技，若场上的最大阵营为：<br>反贼，其他角色手牌上限-1，所有角色出牌阶段使用【杀】次数上限+1、攻击范围+1；<br>"..
  "主忠，其他角色不能对除其以外的角色使用【桃】；<br>多个最大阵营，其他角色死亡后，伤害来源摸两张牌或回复1点体力。<br>"..
  "每轮开始时，你展示一张未加入游戏的身份牌或一张已死亡角色的身份牌，本轮视为该阵营角色数+1。",
  ["zhaoluan"] = "兆乱",
  [":zhaoluan"] = "限定技，一名角色濒死结算后，若其仍处于濒死状态，你可以令其加3点体力上限并失去所有非锁定技，回复体力至3并摸四张牌。"..
  "出牌阶段限一次，你可以令该角色减1点体力上限，其对一名你选择的角色造成1点伤害。",
  ["@lianpoj"] = "大阵营",
  ["lianpoj_multi"] = "多个",
  ["#lianpoj-choice"] = "炼魄：选择本轮视为增加的一个身份",
  ["lianpoj_choice"] = "本轮视为人数+1的身份是：",
  ["loyalist"] = "忠臣",
  ["rebel"] = "反贼",
  ["renegade"] = "内奸",
  ["lianpoj12"] = "主忠 反",
  ["lianpoj13"] = "主忠 内",
  ["lianpoj23"] = "反 内",
  ["lianpoj123"] = "主忠 反 内",
  ["#zhaoluan_trigger"] = "兆乱",
  ["#zhaoluan-invoke"] = "兆乱：%dest 即将死亡，你可以令其复活并操纵其进行攻击！",
  ["#zhaoluan-damage"] = "兆乱：你可以令 %dest 减1点体力上限，其对你指定的一名角色造成1点伤害！",
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
    local result = room:askForCustomDialog(player, self.name,
    "packages/tenyear/qml/YuqiBox.qml", {
      cards,
      target.general, n2,
      player.general, n3,
    })
    local top, bottom
    if result ~= "" then
      local d = json.decode(result)
      top = d[2]
      bottom = d[3]
    else
      top = {cards[1]}
      bottom = {cards[2]}
    end
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
  ["#ofl__yuqi"] = "隅泣：请分配卡牌，余下的牌以原顺序置于牌堆顶",

  ["$ofl__yuqi1"] = "玉儿摔倒了，要阿娘抱抱。",
  ["$ofl__yuqi2"] = "这么漂亮的雪花，为什么只能在寒冬呢？",
  ["$ofl__shanshen1"] = "人家只想做安安静静的小淑女。",
  ["$ofl__shanshen2"] = "雪花纷飞，独存寒冬。",
  ["$ofl__xianjing1"] = "得父母之爱，享公主之礼遇。",
  ["$ofl__xianjing2"] = "哼，可不要小瞧女孩子啊。",
  ["~ofl__caojinyu"] = "娘亲，雪人不怕冷吗？",
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
  name = "lulue",
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
    from:broadcastSkillInvoke("lveming")
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
  ["lulue"] = "掳掠",
  [":lulue"] = "出牌阶段限一次，你可选择一名装备区里有牌的其他角色并弃置X张牌（X为其装备区里的牌数），对其造成1点伤害。",
}

return extension
