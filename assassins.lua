local extension = Package("assassins")
extension.extensionName = "offline"

Fk:loadTranslationTable{
  ["assassins"] = "铜雀台",
  ["tqt"] = "铜雀台",
}

local fuwan = General(extension, "tqt__fuwan", "qun", 3)
local fengyin = fk.CreateTriggerSkill{
  name = "fengyin",
  anim_type = "control",
  events = {fk.TurnStart},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and target ~= player and target.hp >= player.hp then
      return not player:isKongcheng()
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local card = room:askForCard(player, 1, 1, false, self.name, true, 'slash',
      '#fengyin::' .. target.id)
    if #card > 0 then
      self.cost_data = card[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = self.cost_data
    room:moveCardTo(card, Player.Hand, target, fk.ReasonGive, self.name, nil, true, player.id)
    target:skip(Player.Play)
    target:skip(Player.Discard)
  end
}
local chizhong = fk.CreateTriggerSkill{
  name = "chizhong",
  anim_type = "support",
  frequency = Skill.Compulsory,
  events = {fk.Deathed},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, 1)
  end,
}
local chizhongMax = fk.CreateMaxCardsSkill{
  name = "#chizhong_maxcards",
  fixed_func = function(self, player)
    if player:hasSkill(chizhong) then
      return player.maxHp
    end
  end
}
chizhong:addRelatedSkill(chizhongMax)
fuwan:addSkill(fengyin)
fuwan:addSkill(chizhong)

Fk:loadTranslationTable{
  ["#tqt__fuwan"] = "沉毅的国丈",
  ["tqt__fuwan"] = "伏完",
  ["designer:tqt__fuwan"] = "凌天翼",
  ["illustrator:tqt__fuwan"] = "LiuHeng",
  ["fengyin"] = "奉印",
  [":fengyin"] = "其他角色的回合开始时，若其当前的体力值不小于你，你可以交给其一张【杀】，令其跳过其出牌阶段和弃牌阶段。",
  ["#fengyin"] = "奉印: 你可以交给 %dest 一张【杀】，跳过其出牌阶段和弃牌阶段",
  ["chizhong"] = "持重",
  [":chizhong"] = "锁定技，你的手牌上限等于你的体力上限；有角色死亡时，你加1点体力上限。",
}


local jiben = General(extension, "tqt__jiping", "qun", 3)

local duyi = fk.CreateActiveSkill{
  name = "duyi",
  anim_type = "control",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_num = 0,
  card_filter = Util.FalseFunc,
  target_num = 0,
  prompt = "#duyi",
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local cards = room:getNCards(1)
    room:moveCards({
      ids = cards,
      toArea = Card.Processing,
      moveReason = fk.ReasonJustMove,
      skillName = self.name,
      proposer = player.id,
    })
    local card = Fk:getCardById(cards[1])
    local isBlack = card.color == Card.Black
    local tos = room:askForChoosePlayers(player, table.map(room.alive_players, Util.IdMapper), 1, 1,
    "#duyi-choose:::"..card:toLogString(), self.name, false)
    local to = room:getPlayerById(tos[1])
    room:moveCardTo(cards, Player.Hand, to, fk.ReasonGive, self.name, nil, true, player.id)
    if not to.dead and isBlack then
      room:setPlayerMark(to, "@@duyi-turn", 1)
    end
  end,
}
local duyi_prohibit = fk.CreateProhibitSkill{
  name = "#duyi_prohibit",
  prohibit_use = function(self, player, card)
    if player:getMark("@@duyi-turn") > 0 then
      local subcards = Card:getIdList(card)
      return #subcards > 0 and table.every(subcards, function(id)
        return table.contains(player:getCardIds(Player.Hand), id)
      end)
    end
  end,
  prohibit_response = function(self, player, card)
    if player:getMark("@@duyi-turn") > 0 then
      local subcards = Card:getIdList(card)
      return #subcards > 0 and table.every(subcards, function(id)
        return table.contains(player:getCardIds(Player.Hand), id)
      end)
    end
  end,
}
duyi:addRelatedSkill(duyi_prohibit)
jiben:addSkill(duyi)

local duanzhi = fk.CreateTriggerSkill{
  name = "duanzhi",
  anim_type = "offensive",
  events = {fk.TargetConfirmed},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.from ~= player.id and
      not player.room:getPlayerById(data.from).dead
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askForSkillInvoke(player, self.name, nil, "#duanzhi-invoke:" .. data.from) then
      room:doIndicate(player.id, {data.from})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local from = room:getPlayerById(data.from)
    if not from:isNude() then
      local cards = room:askForCardsChosen(player, from, 0, 2, "he", self.name)
      if #cards > 0 then
        room:throwCard(cards, self.name, from, player)
      end
    end
    if not player.dead then
      room:loseHp(player, 1, self.name)
    end
  end,
}
jiben:addSkill(duanzhi)

Fk:loadTranslationTable{
  ["tqt__jiping"] = "吉本",
  ["#tqt__jiping"] = "誓死除奸恶",
  ["designer:tqt__jiping"] = "凌天翼",
  ["illustrator:tqt__jiping"] = "Aimer彩三",

  ["duyi"] = "毒医",
  [":duyi"] = "出牌阶段限一次，你可以亮出牌堆顶的一张牌并交给一名角色，若此牌为黑色，该角色不能使用或打出其手牌，直到回合结束。",
  ["#duyi"] = "毒医: 你可以亮出牌堆顶的一张牌并交给一名角色",
  ["#duyi-choose"] = "毒医: 将 %arg 交给一名角色",
  ["@@duyi-turn"] = "毒医",
  ["duanzhi"] = "断指",
  [":duanzhi"] = "当你成为其他角色使用的牌的目标后，你可以弃置其至多两张牌，然后你失去1点体力。",
  ["#duanzhi-invoke"] = "断指：你可以弃置 %src 至多两张牌，然后失去1点体力",
}

local fuhuanghou = General(extension, "tqt__fuhuanghou", "qun", 3, 3, General.Female)

local mixin = fk.CreateActiveSkill{
  name = "mixin",
  anim_type = "offensive",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  prompt = "#mixin",
  card_num = 1,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and table.contains(Self.player_cards[Player.Hand], to_select)
  end,
  target_num = 2,
  target_filter = function(self, to_select, selected, cards)
    if #cards ~= 1 then return end
    if #selected == 0 then
      return to_select ~= Self.id
    elseif #selected == 1 then
      return selected[1] ~= Self.id
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local to = room:getPlayerById(effect.tos[1])
    local victim = room:getPlayerById(effect.tos[2])
    room:moveCardTo(effect.cards, Player.Hand, to, fk.ReasonGive, self.name, nil, false, player.id)
    if to.dead or victim.dead then return end
    local use = room:askForUseCard(to, "slash", "slash", "#mixin-slash:"..victim.id, true, {bypass_distances = true, exclusive_targets = {victim.id}})
    if use then
      use.extraUse = true
      room:useCard(use)
    elseif not victim.dead and not to:isKongcheng() then
      local card = room:askForCardChosen(victim, to, { card_data = { { "$Hand", to.player_cards[Player.Hand] } } }, self.name)
      room:moveCardTo(card, Player.Hand, victim, fk.ReasonPrey, self.name, nil, false, victim.id)
    end
  end,
}
fuhuanghou:addSkill(mixin)

local cangni = fk.CreateTriggerSkill{
  name = "cangni",
  anim_type = "defensive",
  events = {fk.EventPhaseStart, fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return end
    if event == fk.EventPhaseStart then
      return player.phase == Player.Discard
    else
      local current = player.room.current
      if current ~= player and not current.dead and not player.faceup then
        local choices = {}
        for _, move in ipairs(data) do
          if move.to == player.id and move.toArea == Player.Hand and player:getMark("cangni_draw-turn") == 0 then
            table.insertIfNeed(choices, "draw")
          end
          if move.from == player.id then
            for _, info in ipairs(move.moveInfo) do
              if (info.fromArea == Player.Equip and move.toArea ~= Player.Hand)
              or (info.fromArea == Player.Hand and move.toArea ~= Player.Equip) then
                table.insertIfNeed(choices, "discard")
              end
            end
          end
        end
        if #choices > 0 then
          if #choices == 1 and choices[1] == "discard" and current:isNude() then return end
          self.cost_data = choices
          return true
        end
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if event == fk.EventPhaseStart then
      return room:askForSkillInvoke(player, self.name)
    else
      local choices = {}
      for _, choice in ipairs(self.cost_data) do
        if room:askForSkillInvoke(player, self.name, nil, "#cangni-"..choice..":"..room.current.id) then
          table.insert(choices, choice)
        end
      end
      if #choices > 0 then
        self.cost_data = choices
        return true
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if event == fk.EventPhaseStart then
      if (player.hp == player.maxHp) or room:askForChoice(player, {"recover","draw2"}, self.name) == "draw2" then
        player:drawCards(2, self.name)
      else
        room:recover({
          who = player,
          num = 1,
          recoverBy = player,
          skillName = self.name
        })
      end
      if not player.dead then
        player:turnOver()
      end
    else
      if table.contains(self.cost_data, "draw") then
        room:setPlayerMark(player, "cangni_draw-turn", 1)
      end
      local current = room.current
      for _, choice in ipairs(self.cost_data) do
        if current.dead then break end
        if choice == "draw" then
          current:drawCards(1, self.name)
        else
          room:askForDiscard(current, 1, 1, true, self.name, false)
        end
      end
    end
  end,
}
fuhuanghou:addSkill(cangni)

Fk:loadTranslationTable{
  ["tqt__fuhuanghou"] = "伏皇后",
  ["#tqt__fuhuanghou"] = "誓死除奸恶",
  ["designer:tqt__fuhuanghou"] = "凌天翼",
  ["illustrator:tqt__fuhuanghou"] = "G.G.G.",

  ["mixin"] = "密信",
  [":mixin"] = "出牌阶段限一次，你可以将一张手牌交给一名其他角色，该角色须对你选择的另一名角色使用一张【杀】（无距离限制），否则你选择的角色观看其手牌并获得其中一张。",
  ["#mixin"] = "密信：先选交给牌的角色，再选其需要使用【杀】的目标",
  ["#mixin-slash"] = "密信：你需对 %src 使用一张【杀】，否则其观看你手牌并获得其中一张",
  ["@@duyi-turn"] = "毒医",

  ["cangni"] = "藏匿",
  [":cangni"] = "弃牌阶段开始时，你可以回复1点体力或摸两张牌，然后将你的武将牌翻面；其他角色的回合内，当你获得（每回合限一次）/失去一次牌时，若你的武将牌背面朝上，你可以令该角色摸/弃置一张牌。 ",
  ["#cangni-invoke"] = "藏匿：你可以回复1点体力或摸两张牌，然后将武将牌翻面",
  ["#cangni-draw"] = "藏匿：你可以令 %src 摸一张牌。",
  ["#cangni-discard"] = "藏匿：你可以令 %src 弃置一张牌。",
}



return extension
