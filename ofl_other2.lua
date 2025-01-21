local extension = Package("ofl_other2")
extension.extensionName = "offline"

local U = require "packages/utility/utility"

Fk:loadTranslationTable{
  ["ofl_other2"] = "线下-综合2",
}

--官盗E5：风云志·汉末风云
local godzhangjiao = General(extension, "ofl__godzhangjiao", "god", 4)
local sanshou = fk.CreateTriggerSkill{
  name = "ofl__sanshou",
  anim_type = "special",
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseChanging},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and table.contains({Player.Start, Player.Finish}, data.to)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    data.to = Player.Play
    local isDeputy = true
    if player.general == "ofl__godzhangjiao" then
      isDeputy = false
    end
    room:setPlayerMark(player, "ofl__sanshou-phase", isDeputy and 2 or 1)
    local result = room:askForCustomDialog(
      player, self.name,
      "packages/utility/qml/ChooseSkillFromGeneralBox.qml",
      {
        {"ofl__godzhangbao", "ofl__godzhangliang"},
        {Fk.generals["ofl__godzhangbao"]:getSkillNameList(), Fk.generals["ofl__godzhangliang"]:getSkillNameList()},
        "#ofl__sanshou-choose",
      }
    )
    if result == "" then
      result = "ofl__godzhangbao"
    else
      result = table.unpack(json.decode(result))
    end
    room:changeHero(player, result, false, isDeputy, true, false, false)
  end,

  refresh_events = {fk.EventPhaseEnd},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("ofl__sanshou-phase") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:changeHero(player, "ofl__godzhangjiao", false, player:getMark("ofl__sanshou-phase") == 2, true, false, false)
  end,
}
local mingdao_mapper = {"weapon", "armor", "defensive_horse", "offensive_horse"}
local mingdao = fk.CreateTriggerSkill{
  name = "ofl__mingdao",
  anim_type = "special",
  events = {fk.GameStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and
      table.find({3, 4, 5, 6}, function (sub_type)
        return player:hasEmptyEquipSlot(sub_type)
      end)
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if not room:getBanner(self.name) then
      room:setBanner(self.name, {
        room:printCard("weapon1__populace", Card.Heart, 1).id,
        room:printCard("armor1__populace", Card.Diamond, 1).id,
        room:printCard("defensive_horse1__populace", Card.Club, 1).id,
        room:printCard("offensive_horse1__populace", Card.Spade, 1).id,
      })
    end
    local success, dat = room:askForUseActiveSkill(player, "ofl__mingdao_active", "#ofl__mingdao-invoke", true)
    if success and dat then
      self.cost_data = dat
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local index = table.indexOf(mingdao_mapper, string.sub(self.cost_data.interaction, 6))
    local skill = string.split(Fk:getCardById(self.cost_data.cards[1]).name, "1")[1]
    local name = skill..tostring(index).."__populace"
    local suit
    if skill == "weapon" then
      suit = Card.Heart
    elseif skill == "armor" then
      suit = Card.Diamond
    elseif skill == "defensive_horse" then
      suit = Card.Club
    elseif skill == "offensive_horse" then
      suit = Card.Spade
    end
    local tag = room.tag[self.name] or {}
    local card = table.find(tag, function (id)
      local c = Fk:getCardById(id)
      return room:getCardArea(id) == Card.Void and c.name == name and c.suit == suit
    end)
    if card == nil then
      local id = room:printCard(name, suit, 1).id
      table.insert(tag, id)
      room:setTag(self.name, tag)
      card = id
    end
    room:setCardMark(Fk:getCardById(card), MarkEnum.DestructOutMyEquip, 1)
    room:moveCardIntoEquip(player, card, self.name, false, player.id)
  end,
}
local mingdao_active = fk.CreateActiveSkill{
  name = "ofl__mingdao_active",
  card_num = 1,
  target_num = 0,
  expand_pile = function (self)
    return table.filter(Fk:currentRoom():getBanner("ofl__mingdao"), function (id)
      return not table.find(Self:getCardIds("e"), function (id2)
        return Fk:getCardById(id2).trueName == "populace" and Fk:getCardById(id2).name[1] == Fk:getCardById(id).name[1]
      end)
    end)
  end,
  interaction = function()
    local choices = {}
    for _, sub_type in ipairs({3, 4, 5, 6}) do
      if Self:hasEmptyEquipSlot(sub_type) then
        for i = 1, #Self:getAvailableEquipSlots(sub_type) - #Self:getEquipments(sub_type), 1 do
          table.insert(choices, "type_"..mingdao_mapper[sub_type - 2])
        end
      end
    end
    return UI.ComboBox { choices = choices }
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and table.contains(Fk:currentRoom():getBanner("ofl__mingdao"), to_select)
  end,
}
local zhongfu = fk.CreateTriggerSkill{
  name = "ofl__zhongfu",
  anim_type = "support",
  events = {fk.RoundStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self)
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local choice = room:askForChoice(player, {"log_spade", "log_heart", "log_club", "log_diamond", "Cancel"}, self.name,
      "#ofl__zhongfu-choice")
    if choice ~= "Cancel" then
      local targets = table.filter(room.alive_players, function (p)
        return table.every(room.alive_players, function (q)
          return p:getHandcardNum() <= q:getHandcardNum()
        end)
      end)
      self.cost_data = {tos = table.map(targets, Util.IdMapper), choice = choice}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@ofl__zhongfu-round", self.cost_data.choice)
    for _, id in ipairs(self.cost_data.tos) do
      local p = room:getPlayerById(id)
      if not p.dead then
        if p:isNude() then
          p:drawCards(1, self.name, "bottom")
        else
          local card = room:askForCard(p, 1, 1, true, self.name, true, nil, "#ofl__zhongfu-ask:"..player.id)
          if #card > 0 then
            if not player.dead then
              room:addTableMark(player, "ofl__zhongfu-round", id)
              room:setPlayerMark(p, "@@ofl__zhongfu_target-round", 1)
            end
            room:moveCards({
              ids = card,
              from = id,
              toArea = Card.DrawPile,
              moveReason = fk.ReasonPut,
              skillName = self.name,
              drawPilePosition = 1,
            })
          else
            p:drawCards(1, self.name, "bottom")
          end
        end
      end
    end
  end,
}
local zhongfu_delay = fk.CreateTriggerSkill{
  name = "#ofl__zhongfu_delay",
  anim_type = "support",
  events = {fk.Damage},
  can_trigger = function(self, event, target, player, data)
    return target and table.contains(player:getTableMark("ofl__zhongfu-round"), target.id) and
      table.find({3, 4, 5, 6}, function (sub_type)
        return player:hasEmptyEquipSlot(sub_type)
      end)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    mingdao:doCost(event, target, player, data)
  end,
}
local dangjing = fk.CreateTriggerSkill{
  name = "ofl__dangjing",
  anim_type = "offensive",
  events = {fk.AfterSkillEffect},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and (data.name == "ofl__zhongfu" or data.name == "#ofl__zhongfu_delay") and
      table.every(player.room.alive_players, function (p)
        return #player:getCardIds("e") >= #p:getCardIds("e")
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askForChoosePlayers(player, table.map(room.alive_players, Util.IdMapper), 1, 1,
      "#ofl__dangjing-choose", self.name, true)
    if #to > 0 then
      self.cost_data = {tos = to}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data.tos[1])
    local mark = player:getMark("@ofl__zhongfu-round")
    local pattern
    if mark == 0 then
      pattern = "false"
    else
      pattern = ".|.|"..U.ConvertSuit(mark, "sym", "str")
    end
    local judge = {
      who = to,
      reason = self.name,
      pattern = pattern,
    }
    room:judge(judge)
    if judge.card.suit == U.ConvertSuit(mark, "sym", "int") then
      if not to.dead then
        room:damage{
          from = player,
          to = to,
          damage = 1,
          damageType = fk.ThunderDamage,
          skillName = self.name,
        }
      end
      if not player.dead then
        self:doCost(event, target, player, data)
      end
    end
  end,
}
Fk:addSkill(mingdao_active)
zhongfu:addRelatedSkill(zhongfu_delay)
godzhangjiao:addSkill(mingdao)
godzhangjiao:addSkill(zhongfu)
godzhangjiao:addSkill(dangjing)
godzhangjiao:addSkill(sanshou)
Fk:loadTranslationTable{
  ["ofl__godzhangjiao"] = "神张角",
  ["#ofl__godzhangjiao"] = "庇佑万千",
  ["illustrator:ofl__godzhangjiao"] = "鬼画府",

  ["ofl__mingdao"] = "瞑道",
  [":ofl__mingdao"] = "游戏开始时，你可以将一张<a href='populace_href'>【众】</a>置入你的装备区，【众】进入离开你的装备区时销毁。",
  ["ofl__zhongfu"] = "众附",
  [":ofl__zhongfu"] = "每轮开始时，你可以声明一种花色，然后令手牌最少的角色依次选择一项：1.将一张牌置于牌堆顶；2.从牌堆底摸一张牌。"..
  "本轮当以此法失去牌的角色造成伤害后，你可以发动一次〖瞑道〗。",
  ["ofl__dangjing"] = "荡京",
  [":ofl__dangjing"] = "当你发动〖众附〗后，若你装备区内的牌为全场最多，你可以令一名角色进行一次判定，若为你〖众附〗声明的花色，你对其造成1点"..
  "雷电伤害且可以重复此流程。",
  ["ofl__sanshou"] = "三首",
  [":ofl__sanshou"] = "锁定技，你的准备阶段和结束阶段改为出牌阶段，并在此阶段将武将牌改为张宝或张梁。此阶段结束后把武将牌替换回张角。",
  ["populace_href"] = "【众】共有四张，均为装备牌，可以置入武器/防具/坐骑栏",
  ["ofl__mingdao_active"] = "瞑道",
  ["#ofl__mingdao-invoke"] = "瞑道：将一张“众”置入你的装备区（选择一种“众”及副类别，右键/长按可查看技能）",
  ["#ofl__zhongfu-choice"] = "众附：你可以声明本轮生效的“众附”花色，然后令手牌数最少的角色依次选择一项",
  ["@ofl__zhongfu-round"] = "众附",
  ["#ofl__zhongfu-ask"] = "众附：点“取消”摸一张牌；或将一张牌置于牌堆顶，本轮你造成伤害后 %src 可发动“瞑道”",
  ["#ofl__zhongfu_delay"] = "众附",
  ["@@ofl__zhongfu_target-round"] = "信众",
  ["#ofl__dangjing-choose"] = "荡京：令一名角色进行判定，若为“众附”花色，对其造成1点雷电伤害且可以再次发动！",
  ["#ofl__sanshou-choose"] = "三首：选择此阶段要变为的武将",
}

local godzhangbao = General(extension, "ofl__godzhangbao", "god", 4)
godzhangbao.hidden = true
local zhouyuan = fk.CreateActiveSkill{
  name = "ofl__zhouyuan",
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  prompt = "#ofl__zhouyuan",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected, cards)
    return #selected == 0 and to_select ~= Self.id and not Fk:currentRoom():getPlayerById(to_select):isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local choices = {}
    for _, id in ipairs(target:getCardIds("h")) do
      local color = Fk:getCardById(id):getColorString()
      if color ~= "nocolor" then
        table.insertIfNeed(choices, color)
      end
    end
    local color1 = room:askForChoice(target, choices, self.name, "#ofl__zhouyuan-choice:"..player.id, false, {"red", "black"})
    local color2 = color1 == "black" and "red" or "black"
    local cards = table.filter(target:getCardIds("h"), function (id)
      return Fk:getCardById(id):getColorString() == color1
    end)
    target:addToPile("ofl__zhoubing", cards, false, self.name, target.id)
    if not player.dead and not player:isKongcheng() then
      cards = table.filter(player:getCardIds("h"), function (id)
        return Fk:getCardById(id):getColorString() == color2
      end)
      if #cards > 0 then
        player:addToPile("ofl__zhoubing", cards, false, self.name, player.id)
      end
    end
  end,
}
local zhouyuan_delay = fk.CreateTriggerSkill{
  name = "#ofl__zhouyuan_delay",
  mute = true,
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    return #player:getPile("ofl__zhoubing") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:moveCardTo(player:getPile("ofl__zhoubing"), Card.PlayerHand, player, fk.ReasonJustMove, "ofl__zhouyuan")
  end,
}
local zhaobing = fk.CreateFilterSkill{
  name = "ofl__zhaobing",
  handly_cards = function (self, player)
    if player:hasSkill(self) and player.phase == Player.Play then
      local ids = {}
      for _, p in ipairs(Fk:currentRoom().alive_players) do
        table.insertTableIfNeed(ids, p:getPile("ofl__zhoubing"))
      end
      return ids
    end
  end,
}
zhouyuan:addRelatedSkill(zhouyuan_delay)
godzhangbao:addSkill(zhouyuan)
godzhangbao:addSkill(zhaobing)
godzhangbao:addSkill("ofl__sanshou")
Fk:loadTranslationTable{
  ["ofl__godzhangbao"] = "神张宝",
  ["#ofl__godzhangbao"] = "庇佑万千",
  ["illustrator:ofl__godzhangbao"] = "NOVART",

  ["ofl__zhouyuan"] = "咒怨",
  [":ofl__zhouyuan"] = "出牌阶段限一次，你可以选择一名其他角色，其将所有黑色/红色手牌扣置于其武将牌上，你将所有红色/黑色手牌置于武将牌上，"..
  "这些牌称为“咒兵”。出牌阶段结束时，你与其收回“咒兵”。",
  ["ofl__zhaobing"] = "诏兵",
  [":ofl__zhaobing"] = "出牌阶段，你可以将“咒兵”如手牌般使用或打出。",
  ["#ofl__zhouyuan"] = "咒怨：令一名角色选择颜色，其将此颜色、你将另一种颜色的手牌置于武将牌上",
  ["#ofl__zhouyuan-choice"] = "咒怨：请选择一种颜色，你将此颜色、%src 将另一种颜色手牌分别置于武将牌上",
  ["#ofl__zhouyuan_delay"] = "咒怨",
  ["ofl__zhoubing"] = "咒兵",

  ["$ofl__zhouyuan1"] = "习得一道新符，试试看吧！",
  ["$ofl__zhouyuan2"] = "这事，你管不了！",
  ["$ofl__zhaobing1"] = "此计成矣！",
  ["$ofl__zhaobing2"] = "哈哈，中招了吧！",
  ["~ofl__godzhangbao"] = "这咒不管用了吗……？",
}

local godzhangliang = General(extension, "ofl__godzhangliang", "god", 4)
godzhangliang.hidden = true
local jijun = fk.CreateTriggerSkill{
  name = "ofl__jijun",
  anim_type = "drawcard",
  events = {fk.TargetSpecified},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.to == player.id
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local judge = {
      who = player,
      reason = self.name,
      pattern = ".",
    }
    room:judge(judge)
    if room:getCardArea(judge.card) == Card.DiscardPile then
      local choice = room:askForChoice(player, {"ofl__jijun1", "ofl__jijun2"}, self.name)
      if choice == "ofl__jijun1" then
        room:moveCardTo(judge.card, Card.PlayerHand, player, fk.ReasonJustMove, self.name, nil, true, player.id)
      else
        player:addToPile("ofl__godzhangliang_fang", judge.card, true, self.name, player.id)
      end
    end
  end,
}
local fangtong = fk.CreateTriggerSkill{
  name = "ofl__fangtong",
  anim_type = "offensive",
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Play and
      #player:getPile("ofl__godzhangliang_fang") > 0 and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local card = player.room:askForCard(player, 1, 1, false, self.name, true, nil, "#ofl__fangtong-invoke")
    if #card > 0 then
      self.cost_data = {cards = card}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = 36 - Fk:getCardById(self.cost_data.cards[1]).number
    room:recastCard(self.cost_data.cards, player, self.name)
    if player.dead or #player:getPile("ofl__godzhangliang_fang") == 0 then return end
    room:setPlayerMark(player, "ofl__fangtong-tmp", n)
    local success, dat = room:askForUseActiveSkill(player, "ofl__fangtong_active", "#ofl__fangtong-damage:::"..n, true, nil, false)
    room:setPlayerMark(player, "ofl__fangtong-tmp", 0)
    if success and dat then
      room:moveCardTo(dat.cards, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, self.name, nil, true, player.id)
      local to = room:getPlayerById(dat.targets[1])
      if not to.dead then
        room:damage {
          from = player,
          to = to,
          damage = 3,
          damageType = fk.ThunderDamage,
          skillName = self.name,
        }
      end
    end
  end,
}
local fangtong_active = fk.CreateActiveSkill{
  name = "ofl__fangtong_active",
  min_card_num = 1,
  target_num = 1,
  expand_pile = "ofl__godzhangliang_fang",
  card_filter = function (self, to_select, selected)
    if table.contains(Self:getPile("ofl__godzhangliang_fang"), to_select) then
      local num = 0
      for _, id in ipairs(selected) do
        num = num + Fk:getCardById(id).number
      end
      return num + Fk:getCardById(to_select).number <= Self:getMark("ofl__fangtong-tmp")
    end
  end,
  target_filter = function(self, to_select, selected, cards)
    return #selected == 0 and to_select ~= Self.id
  end,
  feasible = function (self, selected, selected_cards)
    if #selected == 1 and #selected_cards > 0 then
      local num = 0
      for _, id in ipairs(selected_cards) do
        num = num + Fk:getCardById(id).number
      end
      return num == Self:getMark("ofl__fangtong-tmp")
    end
  end,
}
Fk:addSkill(fangtong_active)
godzhangliang:addSkill(jijun)
godzhangliang:addSkill(fangtong)
godzhangliang:addSkill("ofl__sanshou")
Fk:loadTranslationTable{
  ["ofl__godzhangliang"] = "神张梁",
  ["#ofl__godzhangliang"] = "庇佑万千",
  ["illustrator:ofl__godzhangliang"] = "王强",

  ["ofl__jijun"] = "集军",
  [":ofl__jijun"] = "当你使用牌指定你为目标后，你可以进行判定，然后选择一项：1.获得此牌；2.将判定牌置于武将牌上，称为“方”。",
  ["ofl__fangtong"] = "方统",
  [":ofl__fangtong"] = "出牌阶段结束时，若有“方”，你可以重铸一张手牌，若你重铸的牌与你的任意“方”点数之和为36，你可以将对应的“方”置入弃牌堆，"..
  "然后对一名其他角色造成3点雷电伤害。",
  ["ofl__godzhangliang_fang"] = "方",
  ["ofl__jijun1"] = "获得判定牌",
  ["ofl__jijun2"] = "将判定牌置为“方”",
  ["#ofl__fangtong-invoke"] = "方统：你可以重铸一张手牌，然后移去与此牌点数之和为36的“方”，对一名角色造成3点雷电伤害！",
  ["ofl__fangtong_active"] = "方统",
  ["#ofl__fangtong-damage"] = "方统：移去点数之和为%arg的“方”，对一名角色造成3点雷电伤害！",

  ["$ofl__jijun1"] = "民军虽散，也可撼树。",
  ["$ofl__jijun2"] = "集天下万民，成百姓万军。",
  ["$ofl__fangtong1"] = "三十六方，雷电烁。",
  ["$ofl__fangtong2"] = "合方三十六统，散太平大道。",
  ["~ofl__godzhangliang"] = "黄天之道，哥哥我们错了吗？",
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
    local to = room:askForChoosePlayers(player, table.map(room:getOtherPlayers(player, false), Util.IdMapper), 1, 1,
      "#ofl__xianxiang-invoke::"..target.id, self.name, false)
    room:moveCardTo(target:getCardIds("hej"), Card.PlayerHand, to[1], fk.ReasonJustMove, self.name, nil, false, player.id)
  end,
}
Fk:addSkill(dishi_viewas)
yanzhengh:addSkill(dishi)
yanzhengh:addSkill(xianxiang)
Fk:loadTranslationTable{
  ["yanzhengh"] = "严政",
  ["#yanzhengh"] = "献首投降",
  ["illustrator:yanzhengh"] = "Xiaoi",

  ["ofl__dishi"] = "地逝",
  [":ofl__dishi"] = "限定技，出牌阶段开始时，若你已受伤，你可以将所有手牌当一张无距离限制且伤害为X的【杀】使用（X为你的手牌数）。",
  ["ofl__xianxiang"] = "献降",
  [":ofl__xianxiang"] = "锁定技，当你杀死一名角色时，你令一名其他角色获得死亡角色区域内的所有牌。",
  ["ofl__dishi_viewas"] = "地逝",
  ["#ofl__dishi-invoke"] = "地逝：你可以将所有手牌当一张无距离限制的【杀】使用，伤害为牌数！",
  ["#ofl__xianxiang-invoke"] = "献降：令一名其他角色获得 %dest 区域内所有牌",
}

local bairao = General(extension, "bairao", "qun", 5)
local huoyin = fk.CreateTriggerSkill{
  name = "ofl__huoyin",
  anim_type = "control",
  frequency = Skill.Compulsory,
  events = {fk.Damage},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and (data.extra_data or {}).ofl__huoyin
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(1, self.name)
    if not data.to.dead then
      U.askForPlayCard(room, data.to, nil, nil, self.name, "#ofl__huoyin-use", {
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
    data.damageEvent.extra_data.ofl__huoyin = true
  end,
}
local huoyin_targetmod = fk.CreateTargetModSkill{
  name = "#ofl__huoyin_targetmod",
  frequency = Skill.Compulsory,
  main_skill = huoyin,
  bypass_times = function(self, player, skill, scope, card, to)
    return player:hasSkill(huoyin) and card and card.trueName == "slash" and
      to and player:inMyAttackRange(to) and to:inMyAttackRange(player)
  end,
}
huoyin:addRelatedSkill(huoyin_targetmod)
bairao:addSkill(huoyin)
Fk:loadTranslationTable{
  ["bairao"] = "白绕",
  ["#bairao"] = "黑山寇首",
  ["illustrator:bairao"] = "君桓文化",

  ["ofl__huoyin"] = "祸引",
  [":ofl__huoyin"] = "锁定技，你对攻击范围内含有你且你攻击范围内有其的其他角色：使用【杀】无次数限制；当你对这些角色造成伤害后，你摸一张牌，"..
  "然后其选择是否使用一张牌。",
  ["#ofl__huoyin-use"] = "祸引：你可以使用一张牌",
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
  ["#busi"] = "黄巾渠帅",
  ["illustrator:busi"] = "千秋秋千秋",

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
local tunquan = fk.CreateTriggerSkill{
  name = "ofl__tunquan",
  anim_type = "special",
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Start
  end,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "@ofl__tunquan", 1)
  end,
}
local tunquan_delay = fk.CreateTriggerSkill{
  name = "#ofl__tunquan_delay",
  mute = true,
  frequency = Skill.Compulsory,
  events = {fk.DrawNCards, fk.DamageInflicted},
  can_trigger = function (self, event, target, player, data)
    if target == player and player:getMark("@ofl__tunquan") > 0 then
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
    player:broadcastSkillInvoke("ofl__tunquan")
    if event == fk.DrawNCards then
      room:notifySkillInvoked(player, "ofl__tunquan", "drawcard")
      data.n = data.n + player:getMark("@ofl__tunquan")
    elseif event == fk.DamageInflicted then
      room:notifySkillInvoked(player, "ofl__tunquan", "negative")
      data.damage = data.damage + player:getMark("@ofl__tunquan")
    end
  end,
}
local tunquan_maxcards = fk.CreateMaxCardsSkill{
  name = "#ofl__tunquan_maxcards",
  correct_func = function(self, player)
    return player:getMark("@ofl__tunquan")
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
    room:setPlayerMark(player, "@ofl__tunquan", 0)
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
tunquan:addRelatedSkill(tunquan_delay)
tunquan:addRelatedSkill(tunquan_maxcards)
suigu:addSkill(tunquan)
suigu:addSkill(qianjun)
suigu:addRelatedSkill("luanji")
Fk:loadTranslationTable{
  ["suigu"] = "眭固",
  ["#suigu"] = "兔入犬城",
  ["illustrator:suigu"] = "君桓文化",

  ["ofl__tunquan"] = "屯犬",
  [":ofl__tunquan"] = "锁定技，准备阶段，你令你本局游戏摸牌阶段的摸牌数，手牌上限和每回合首次受到的伤害+1，直到你发动〖迁军〗。",
  ["ofl__qianjun"] = "迁军",
  [":ofl__qianjun"] = "限定技，出牌阶段，你可以交给一名其他角色装备区里的所有牌并与其交换座次，然后你回复1点体力并获得〖乱击〗。",
  ["@ofl__tunquan"] = "屯犬",
  ["#ofl__tunquan_delay"] = "屯犬",
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
    if player.dead or not table.contains(player:getCardIds("h"), card) or #room:getOtherPlayers(player, false) == 0 then return end
    local to = room:askForChoosePlayers(player, table.map(room:getOtherPlayers(player, false), Util.IdMapper), 1, 1,
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
  ["#yudu"] = "劫富济贫",
  ["illustrator:yudu"] = "MUMU1",

  ["ofl__dafu"] = "打富",
  [":ofl__dafu"] = "当你使用伤害牌指定目标后，你可以令目标角色摸一张牌，然后其不能响应此牌。",
  ["ofl__jipin"] = "济贫",
  [":ofl__jipin"] = "当你对手牌数大于你的角色造成伤害后，你可以获得其一张手牌，然后可以将之交给一名其他角色。",
  ["#ofl__dafu-invoke"] = "打富：是否令 %dest 摸一张牌，其不能响应此%arg？",
  ["#ofl__jipin-invoke"] = "济贫：是否获得 %dest 一张手牌？",
  ["#ofl__jipin-prey"] = "济贫：获得 %dest 一张手牌",
  ["#ofl__jipin-give"] = "济贫：你可以将这张%arg交给一名其他角色",
}

local tangzhou = General(extension, "tangzhou", "qun", 4)
local jukou = fk.CreateActiveSkill{
  name = "ofl__jukou",
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  prompt = function (self)
    return "#"..self.interaction.data
  end,
  interaction = function ()
    return UI.ComboBox {choices = {"ofl__jukou1", "ofl__jukou2"}}
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected, cards)
    if #selected == 0 then
      if self.interaction.data == "ofl__jukou1" then
        return true
      elseif self.interaction.data == "ofl__jukou2" then
        for _, ids in pairs(Fk:currentRoom():getPlayerById(to_select).special_cards) do
          if #ids > 0 then
            return true
          end
        end
      end
    end
  end,
  on_use = function(self, room, effect)
    local target = room:getPlayerById(effect.tos[1])
    room:setPlayerMark(target, "@@"..self.interaction.data.."-turn", 1)
    if self.interaction.data == "ofl__jukou1" then
      target:drawCards(1, self.name)
    elseif self.interaction.data == "ofl__jukou2" then
      local cards = {}
      for _, ids in pairs(target.special_cards) do
        table.insertTableIfNeed(cards, ids)
      end
      room:moveCardTo(cards, Card.PlayerHand, target, fk.ReasonJustMove, self.name, nil, false, target.id)
    end
  end,
}
local jukou_prohibit = fk.CreateProhibitSkill{
  name = "#ofl__jukou_prohibit",
  prohibit_use = function(self, player, card)
    if player:getMark("@@ofl__jukou1-turn") > 0 and card.trueName == "slash" then
      return true
    end
    if player:getMark("@@ofl__jukou2-turn") > 0 then
      local subcards = card:isVirtual() and card.subcards or {card.id}
      return #subcards > 0 and table.every(subcards, function(id)
        return table.contains(player:getCardIds("h"), id)
      end)
    end
  end,
}
local shupan = fk.CreateActiveSkill{
  name = "ofl__shupan",
  anim_type = "control",
  frequency = Skill.Limited,
  card_num = 0,
  target_num = 2,
  prompt = "#ofl__shupan",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    if #selected > 1 or to_select == Self.id then return end
    if #selected == 0 then
      return not Fk:currentRoom():getPlayerById(to_select):isKongcheng()
    elseif #selected == 1 then
      return true
    end
  end,
  feasible = function (self, selected, selected_cards)
    return #selected == 2 and not Fk:currentRoom():getPlayerById(selected[1]):isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target1 = room:getPlayerById(effect.tos[1])
    local target2 = room:getPlayerById(effect.tos[2])
    target1:showCards(target1:getCardIds("h"))
    if not player.dead then
      player:drawCards(3, self.name)
    end
    if not target2.dead then
      target2:drawCards(3, self.name)
    end
    if target1.dead or target2.dead then return end
    room:addTableMark(target1, "@@ofl__shupan", target2.id)
    room:addTableMark(target2, "@@ofl__shupan", target1.id)
    local cards = table.filter(target2:getCardIds("h"), function (id)
      return Fk:getCardById(id).is_damage_card
    end)
    while not target1.dead and not target2.dead do
      cards = table.filter(cards, function (id)
        local card = Fk:getCardById(id)
        return table.contains(target2:getCardIds("h"), id) and card.is_damage_card and
          target2:canUseTo(card, target1, {bypass_distances = true, bypass_times = true})
      end)
      if #cards > 0 then
        local card = Fk:getCardById(cards[1])
        table.remove(cards, 1)
        room:useCard{
          from = target2.id,
          tos = {{target1.id}},
          card = card,
        }
      else
        break
      end
    end
  end,
}
local shupan_targetmod = fk.CreateTargetModSkill{
  name = "#ofl__shupan_targetmod",
  bypass_times = function(self, player, skill, scope, card, to)
    return card and table.contains(player:getTableMark("@@ofl__shupan"), to.id)
  end,
}
jukou:addRelatedSkill(jukou_prohibit)
shupan:addRelatedSkill(shupan_targetmod)
tangzhou:addSkill(jukou)
tangzhou:addSkill(shupan)
Fk:loadTranslationTable{
  ["tangzhou"] = "唐周",
  ["#tangzhou"] = "叛门高足",
  ["illustrator:tangzhou"] = "sky",

  ["ofl__jukou"] = "举寇",
  [":ofl__jukou"] = "出牌阶段限一次，你可以令一名角色摸一张牌/获得其武将牌上的所有牌，然后其本回合不能使用【杀】/手牌。",
  ["ofl__shupan"] = "述叛",
  [":ofl__shupan"] = "限定技，出牌阶段，你可以选择两名其他角色：展示第一名角色的所有手牌，你与第二名角色各摸三张牌，然后其对第一名角色依次使用"..
  "手牌中所有伤害牌；这两名角色互相使用牌无次数限制直到游戏结束。",
  ["#ofl__jukou1"] = "举寇：令一名角色摸一张牌，其本回合不能使用【杀】",
  ["#ofl__jukou2"] = "举寇：令一名角色获得其武将牌上的牌，其本回合不能使用手牌",
  ["ofl__jukou1"] = "摸一张牌",
  ["ofl__jukou2"] = "获得武将牌上的牌",
  ["@@ofl__jukou1-turn"] = "禁止使用杀",
  ["@@ofl__jukou2-turn"] = "禁止使用手牌",
  ["#ofl__shupan"] = "述叛：选择两名角色，展示第一名角色的手牌，你与第二名角色各摸三张牌，然后后者对前者使用伤害牌！",
  ["@@ofl__shupan"] = "述叛",
}

local bocai = General(extension, "bocai", "qun", 5)
local kunjun = fk.CreateTriggerSkill{
  name = "ofl__kunjun",
  mute = true,
  frequency = Skill.Compulsory,
  events = {fk.DrawInitialCards, fk.CardUsing},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      if event == fk.DrawInitialCards then
        return target == player
      elseif event == fk.CardUsing and (data.card.trueName == "slash" or data.card:isCommonTrick()) then
        if target == player then
          return table.find(player.room.alive_players, function (p)
            return player:getHandcardNum() > p:getHandcardNum()
          end) ~= nil
        else
          return target:getHandcardNum() > player:getHandcardNum()
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(self.name)
    if event == fk.DrawInitialCards then
      room:notifySkillInvoked(player, self.name, "drawcard")
      data.num = data.num + 4
    elseif event == fk.CardUsing then
      data.disresponsiveList = data.disresponsiveList or {}
      if target == player then
        room:notifySkillInvoked(player, self.name, "offensive")
        for _, p in ipairs(room.alive_players) do
          if player:getHandcardNum() > p:getHandcardNum() then
            table.insertIfNeed(data.disresponsiveList, p.id)
          end
        end
      else
        room:notifySkillInvoked(player, self.name, "negative")
        table.insertIfNeed(data.disresponsiveList, player.id)
      end
    end
  end,
}
local yingzhan = fk.CreateTriggerSkill{
  name = "ofl__yingzhan",
  mute = true,
  frequency = Skill.Compulsory,
  events = {fk.DamageCaused, fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.damageType ~= fk.NormalDamage
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(self.name)
    if event == fk.DamageCaused then
      room:notifySkillInvoked(player, self.name, "offensive")
    elseif event == fk.DamageInflicted then
      room:notifySkillInvoked(player, self.name, "negative")
    end
    data.damage = data.damage + 1
  end,
}
local cuiji = fk.CreateTriggerSkill{
  name = "ofl__cuiji",
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target ~= player and target.phase == Player.Play and not target.dead and
      player:getHandcardNum() > target:getHandcardNum() and
      player:canUseTo(Fk:cloneCard("thunder__slash"), target, {bypass_distances = true})
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local success, dat = room:askForUseActiveSkill(player, "ofl__cuiji_viewas",
      "#ofl__cuiji-invoke::"..target.id, true, {
        bypass_distances = true,
        bypass_times = true,
        must_targets = {target.id},
      })
    if success and dat then
      self.cost_data = {cards = dat.cards}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local use = room:useVirtualCard("thunder__slash", self.cost_data.cards, player, target, self.name, true)
    if use and use.damageDealt and not player.dead then
      player:drawCards(#self.cost_data.cards, self.name)
    end
  end,
}
local cuiji_viewas = fk.CreateViewAsSkill{
  name = "ofl__cuiji_viewas",
  card_filter = function (self, to_select, selected)
    return table.contains(Self:getHandlyIds(), to_select)
  end,
  view_as = function(self, cards)
    if #cards == 0 then return end
    local card = Fk:cloneCard("thunder__slash")
    card.skillName = "ofl__cuiji"
    card:addSubcards(cards)
    return card
  end,
}
Fk:addSkill(cuiji_viewas)
bocai:addSkill(kunjun)
bocai:addSkill(yingzhan)
bocai:addSkill(cuiji)
Fk:loadTranslationTable{
  ["bocai"] = "波才",
  ["#bocai"] = "黄巾执首",
  ["illustrator:bocai"] = "HOOO",

  ["ofl__kunjun"] = "困军",
  [":ofl__kunjun"] = "锁定技，你的初始手牌数+4，手牌数小于你的角色不能响应你使用的牌，你不能响应手牌数大于你的角色使用的牌。",
  ["ofl__yingzhan"] = "营战",
  [":ofl__yingzhan"] = "锁定技，你造成或受到的属性伤害+1。",
  ["ofl__cuiji"] = "摧击",
  [":ofl__cuiji"] = "其他角色的出牌阶段开始时，若你手牌数大于其，你可以将任意张手牌当一张雷【杀】对其使用，若你以此法造成了伤害，你摸等量的牌。",
  ["ofl__cuiji_viewas"] = "摧击",
  ["#ofl__cuiji-invoke"] = "摧击：你可以将任意张手牌当雷【杀】对 %dest 使用，若造成伤害你摸等量牌",
}

local chengyuanzhi = General(extension, "chengyuanzhi", "qun", 5)
local wuxiao = fk.CreateTriggerSkill{
  name = "ofl__wuxiao",
  anim_type = "special",
  frequency = Skill.Compulsory,
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryTurn) == 0 then
      local turn_event = player.room.logic:getCurrentEvent():findParent(GameEvent.Turn)
      if turn_event == nil then return end
      for _, move in ipairs(data) do
        if move.toArea == Card.DiscardPile then
          for _, info in ipairs(move.moveInfo) do
            if Fk:getCardById(info.cardId).color == Card.Red then
              return true
            end
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "@@ofl__wuxiao-turn", 1)
  end,
}
local wuxiao_delay = fk.CreateTriggerSkill{
  name = "#ofl__wuxiao_delay",
  mute = true,
  frequency = Skill.Compulsory,
  events = {fk.DamageCaused, fk.DamageInflicted},
  can_trigger = function (self, event, target, player, data)
    return target == player and player:getMark("@@ofl__wuxiao-turn") > 0
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("ofl__wuxiao")
    if event == fk.DamageCaused then
      room:notifySkillInvoked(player, "ofl__wuxiao", "offensive")
    elseif event == fk.DamageInflicted then
      room:notifySkillInvoked(player, "ofl__wuxiao", "negative")
    end
    data.damage = data.damage + player:getMark("@@ofl__wuxiao-turn")
    room:setPlayerMark(player, "@@ofl__wuxiao-turn", 0)
  end,
}
local qianhu = fk.CreateViewAsSkill{
  name = "ofl__qianhu",
  anim_type = "offensive",
  prompt = "#ofl__qianhu",
  card_filter = function(self, to_select, selected)
    return #selected < 2 and Fk:getCardById(to_select).color == Card.Red and not Self:prohibitDiscard(to_select)
  end,
  view_as = function(self, cards)
    if #cards ~= 2 then return end
    local card = Fk:cloneCard("duel")
    card.skillName = self.name
    self.cost_data = cards
    return card
  end,
  before_use = function(self, player, use)
    player.room:throwCard(self.cost_data, self.name, player, player)
  end,
  after_use = function (self, player, use)
    if not player.dead then
      if use.damageDealt and
        table.find(player.room:getOtherPlayers(player, false, true), function (p)
          return use.damageDealt[p.id] ~= nil
        end) ~= nil then
        player:drawCards(1, self.name)
      end
    end
  end,
}
wuxiao:addRelatedSkill(wuxiao_delay)
chengyuanzhi:addSkill(wuxiao)
chengyuanzhi:addSkill(qianhu)
Fk:loadTranslationTable{
  ["chengyuanzhi"] = "程远志",
  ["#chengyuanzhi"] = "逆流而动",
  ["illustrator:chengyuanzhi"] = "HOOO",

  ["ofl__wuxiao"] = "武嚣",
  [":ofl__wuxiao"] = "锁定技，当每回合首次有红色牌进入弃牌堆后，你本回合下次造成或受到的伤害+1。",
  ["ofl__qianhu"] = "前呼",
  [":ofl__qianhu"] = "出牌阶段，你可以弃置两张红色牌视为使用一张【决斗】，若你造成了伤害，你摸一张牌。",
  ["@@ofl__wuxiao-turn"] = "造成/受到伤害+1",
  ["#ofl__wuxiao_delay"] = "武嚣",
  ["#ofl__qianhu"] = "前呼：弃置两张红色牌视为使用【决斗】，若你造成伤害则摸一张牌",
}

local dengmao = General(extension, "dengmao", "qun", 5)
local paoxi = fk.CreateTriggerSkill{
  name = "ofl__paoxi",
  anim_type = "special",
  frequency = Skill.Compulsory,
  events = {fk.TargetSpecified},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and data.firstTarget then
      local turn_event = player.room.logic:getCurrentEvent():findParent(GameEvent.Turn)
      if turn_event == nil then return end
      local info = {}
      local events = player.room.logic:getEventsByRule(GameEvent.UseCard, 2, function (e)
        info = {e.data[1].from, e.data[1].tos}
        return true
      end, turn_event.id)
      if #events < 2 or #info == 0 then return end
      self.cost_data = {}
      if player:getMark("ofl__paoxi1-turn") == 0 then
        if table.contains(AimGroup:getAllTargets(data.tos), player.id) and info[2] and
          table.contains(TargetGroup:getRealTargets(info[2]), player.id) then
          table.insert(self.cost_data, 1)
        end
      end
      if player:getMark("ofl__paoxi2-turn") == 0 then
        if target == player and info[1] == player.id and info[2] then
          table.insert(self.cost_data, 2)
        end
      end
      return #self.cost_data > 0
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for i = 1, 2, 1 do
      if table.contains(self.cost_data, i) then
        room:setPlayerMark(player, "ofl__paoxi"..i.."-turn", 1)
        room:addPlayerMark(player, "@@ofl__paoxi"..i.."-turn", 1)
      end
    end
  end,
}
local paoxi_delay = fk.CreateTriggerSkill{
  name = "#ofl__paoxi_delay",
  mute = true,
  frequency = Skill.Compulsory,
  events = {fk.DamageCaused, fk.DamageInflicted},
  can_trigger = function (self, event, target, player, data)
    if target == player then
      if event == fk.DamageCaused then
        return player:getMark("@@ofl__paoxi2-turn") > 0
      elseif event == fk.DamageInflicted then
        return player:getMark("@@ofl__paoxi1-turn") > 0
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("ofl__paoxi")
    if event == fk.DamageCaused then
      room:notifySkillInvoked(player, "ofl__paoxi", "offensive")
      data.damage = data.damage + player:getMark("@@ofl__paoxi2-turn")
      room:setPlayerMark(player, "@@ofl__paoxi2-turn", 0)
    elseif event == fk.DamageInflicted then
      room:notifySkillInvoked(player, "ofl__paoxi", "negative")
      data.damage = data.damage + player:getMark("@@ofl__paoxi1-turn")
      room:setPlayerMark(player, "@@ofl__paoxi1-turn", 0)
    end
  end,
}
local houying = fk.CreateViewAsSkill{
  name = "ofl__houying",
  anim_type = "offensive",
  prompt = "#ofl__houying",
  card_filter = function(self, to_select, selected)
    return #selected < 2 and Fk:getCardById(to_select).color == Card.Black and not Self:prohibitDiscard(to_select)
  end,
  view_as = function(self, cards)
    if #cards ~= 2 then return end
    local card = Fk:cloneCard("slash")
    card.skillName = self.name
    self.cost_data = cards
    return card
  end,
  before_use = function(self, player, use)
    use.extraUse = true
    player.room:throwCard(self.cost_data, self.name, player, player)
  end,
  after_use = function (self, player, use)
    if not player.dead then
      if use.damageDealt and
        table.find(player.room:getOtherPlayers(player, false, true), function (p)
          return use.damageDealt[p.id] ~= nil
        end) ~= nil then
        player:drawCards(1, self.name)
      end
    end
  end,
}
local houying_targetmod = fk.CreateTargetModSkill{
  name = "#ofl__houying_targetmod",
  bypass_times = function(self, player, skill, scope, card)
    return skill.trueName == "slash_skill" and scope == Player.HistoryPhase and card and table.contains(card.skillNames, "ofl__houying")
  end,
}
houying:addRelatedSkill(houying_targetmod)
paoxi:addRelatedSkill(paoxi_delay)
dengmao:addSkill(paoxi)
dengmao:addSkill(houying)
Fk:loadTranslationTable{
  ["dengmao"] = "邓茂",
  ["#dengmao"] = "逆势而行",
  ["illustrator:dengmao"] = "HOOO",

  ["ofl__paoxi"] = "咆袭",
  [":ofl__paoxi"] = "锁定技，每回合各限一次，当你连续成为牌/使用牌指定目标后，你本回合下次受到/造成的伤害+1。",
  ["ofl__houying"] = "后应",
  [":ofl__houying"] = "出牌阶段，你可以弃置两张黑色牌并视为使用一张无次数限制的【杀】，若你造成了伤害，你摸一张牌。",
  ["@@ofl__paoxi1-turn"] = "受到伤害+1",
  ["@@ofl__paoxi2-turn"] = "造成伤害+1",
  ["#ofl__houying"] = "后应：弃置两张黑色牌视为使用【杀】，若你造成伤害则摸一张牌",
}

local gaosheng = General(extension, "gaosheng", "qun", 5)
local xiongshi = fk.CreateActiveSkill{
  name = "ofl__xiongshi",
  anim_type = "support",
  card_num = 1,
  target_num = 1,
  prompt = "#ofl__xiongshi",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name) == 0
  end,
  card_filter = function(self, to_select, selected, targets)
    return #selected == 0 and table.contains(Self:getCardIds("h"), to_select)
  end,
  target_filter = function(self, to_select, selected, cards)
    return #selected == 0 and Fk:currentRoom():getPlayerById(to_select):hasSkill(self)
  end,
  on_use = function(self, room, effect)
    local target = room:getPlayerById(effect.tos[1])
    target:addToPile(self.name, effect.cards, false, self.name, effect.from)
  end,

  attached_skill_name = "ofl__xiongshi&",
}
local xiongshi_active = fk.CreateActiveSkill{
  name = "ofl__xiongshi&",
  anim_type = "support",
  card_num = 1,
  target_num = 1,
  prompt = "#ofl__xiongshi&",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name) == 0
  end,
  card_filter = function(self, to_select, selected, targets)
    return #selected == 0 and table.contains(Self:getCardIds("h"), to_select)
  end,
  target_filter = function(self, to_select, selected, cards)
    return #selected == 0 and Fk:currentRoom():getPlayerById(to_select):hasSkill(xiongshi)
  end,
  on_use = function(self, room, effect)
    local target = room:getPlayerById(effect.tos[1])
    target:addToPile("ofl__xiongshi", effect.cards, false, "ofl__xiongshi", effect.from)
  end,
}
local difeng = fk.CreateTriggerSkill{
  name = "ofl__difeng",
  mute = true,
  frequency = Skill.Compulsory,
  events = {fk.AfterCardsMove, fk.DamageCaused, fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      if event == fk.AfterCardsMove then
        local targets = {}
        for _, move in ipairs(data) do
          if move.toArea == Card.PlayerSpecial and move.proposer then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea ~= Card.PlayerSpecial then
                table.insert(targets, move.proposer)
              end
            end
          end
        end
        if #targets > 0 then
          self.cost_data = targets
          return true
        end
      else
        if target == player and data.from and not data.from.dead then
          for _, ids in pairs(player.special_cards) do
            if #ids > 0 then
              return true
            end
          end
        end
      end
    end
  end,
  on_trigger = function (self, event, target, player, data)
    if event == fk.AfterCardsMove then
      for _, id in ipairs(self.cost_data) do
        if not player:hasSkill(self) then return end
        self:doCost(event, player.room:getPlayerById(id), player, data)
      end
    else
      self:doCost(event, target, player, data)
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(self.name)
    if event == fk.AfterCardsMove then
      room:notifySkillInvoked(player, self.name, "drawcard")
      player:drawCards(1, self.name)
      if not target.dead then
        target:drawCards(1, self.name)
      end
    else
      local cards = {}
      for _, ids in pairs(player.special_cards) do
        table.insertTableIfNeed(cards, ids)
      end
      local card = room:askForCard(data.from, 1, 1, false, self.name, true, tostring(Exppattern{ id = cards }),
        "#ofl__difeng-invoke:"..player.id..":"..data.to.id, cards)
      if #card > 0 then
        if event == fk.DamageCaused then
        room:notifySkillInvoked(player, self.name, "offensive")
        elseif event == fk.DamageInflicted then
          room:notifySkillInvoked(player,self.name, "negative")
        end
        data.damage = data.damage + 1
        room:moveCardTo(card, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, self.name, nil, true, data.from.id)
      end
    end
  end,
}
Fk:addSkill(xiongshi_active)
gaosheng:addSkill(xiongshi)
gaosheng:addSkill(difeng)
Fk:loadTranslationTable{
  ["gaosheng"] = "高升",
  ["#gaosheng"] = "地公之锋",
  ["illustrator:gaosheng"] = "livsinno",

  ["ofl__xiongshi"] = "凶势",
  [":ofl__xiongshi"] = "每名角色出牌阶段限一次，其可以将一张手牌置于你武将牌上。",
  ["ofl__difeng"] = "地锋",
  [":ofl__difeng"] = "锁定技，当一名角色将牌置于武将牌后，你与其各摸一张牌；你造成或受到伤害时，伤害来源可以弃置你武将牌上一张牌，令此伤害+1。",
  ["ofl__xiongshi&"] = "凶势",
  [":ofl__xiongshi&"] = "出牌阶段限一次，你可以将一张手牌置于高升的武将牌上。",
  ["#ofl__xiongshi"] = "凶势：你可以将一张手牌置于你武将牌上",
  ["#ofl__xiongshi&"] = "凶势：你可以将一张手牌置于高升的武将牌上",
  ["#ofl__difeng-invoke"] = "地锋：是否移去 %src 武将牌上一张牌，令你对 %dest 造成的伤害+1？",
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

local taosheng = General(extension, "taosheng", "qun", 5)
local zainei = fk.CreateActiveSkill{
  name = "ofl__zainei",
  anim_type = "offensive",
  frequency = Skill.Limited,
  card_num = 0,
  target_num = 1,
  prompt = "#ofl__zainei",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected, cards)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:addTableMark(player, self.name, effect.tos[1])
  end,
}
local zainei_distance = fk.CreateDistanceSkill{
  name = "#ofl__zainei_distance",
  fixed_func = function(self, from, to)
    if table.contains(from:getTableMark("ofl__zainei"), to.id) then
      return 1
    end
  end,
}
local zainei_delay = fk.CreateTriggerSkill{
  name = "#ofl__zainei_delay",

  refresh_events = {fk.EnterDying},
  can_refresh = function(self, event, target, player, data)
    return target == player
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "ofl__zainei", 0)
  end,
}
local hanwei = fk.CreateActiveSkill{
  name = "ofl__hanwei",
  anim_type = "support",
  min_card_num = 1,
  target_num = 1,
  prompt = "#ofl__hanwei",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function (self, to_select, selected)
    return not Fk:getCardById(to_select).is_damage_card
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    return Self:distanceTo(Fk:currentRoom():getPlayerById(to_select)) == 1
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    player:showCards(effect.cards)
    local cards = table.filter(effect.cards, function (id)
      return table.contains(player:getCardIds("he"), id)
    end)
    if #cards > 0 and not target.dead then
      room:moveCardTo(cards, Card.PlayerHand, target, fk.ReasonGive, self.name, nil, true, player.id)
    end
    if not player.dead then
      player:drawCards(#effect.cards, self.name)
    end
    cards = table.filter(cards, function (id)
      return table.contains(target:getCardIds("h"), id)
    end)
    while #cards > 0 and not target.dead do
      local use = U.askForUseRealCard(room, target, cards, nil, self.name, "#ofl__hanwei-use", {bypass_times = true}, false, true)
      if use then
        table.removeOne(cards, use.card.id)
      else
        return
      end
    end
  end,
}
zainei:addRelatedSkill(zainei_distance)
zainei:addRelatedSkill(zainei_delay)
taosheng:addSkill(zainei)
taosheng:addSkill(hanwei)
Fk:loadTranslationTable{
  ["taosheng"] = "陶升",
  ["#taosheng"] = "平汉将军",
  ["illustrator:taosheng"] = "佚名",

  ["ofl__zainei"] = "载内",
  [":ofl__zainei"] = "限定技，出牌阶段，你可以选择一名其他角色，然后你与其距离视为1，直到你进入濒死状态。",
  ["ofl__hanwei"] = "扞卫",
  [":ofl__hanwei"] = "出牌阶段限一次，你可以展示并交给距离为1的一名其他角色任意张非伤害类牌并摸等量的牌，然后其可以使用你交给其的任意张牌。",
  ["#ofl__zainei"] = "载内：选择一名角色，你与其距离视为1直到你进入濒死状态！",
  ["#ofl__hanwei"] = "扞卫：交给距离1一名角色任意张非伤害牌，摸等量牌，其可以使用交给其的牌",
  ["#ofl__hanwei-use"] = "扞卫：你可以使用这些牌",
}

local godhuangfusong = General(extension, "godhuangfusong", "god", 4)
local shice = fk.CreateTriggerSkill{
  name = "ofl__shice",
  switch_skill_name = "ofl__shice",
  anim_type = "switch",
  events = {fk.DamageInflicted, fk.TargetSpecified},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) then
      if event == fk.DamageInflicted then
        if player:getSwitchSkillState(self.name, false) == fk.SwitchYang and
          data.damageType ~= fk.NormalDamage and
          data.from then
          local getSkills = function (p)
            local skills = {}
            for _, s in ipairs(p.player_skills) do
              if s:isPlayerSkill(p) and s.visible then
                table.insertIfNeed(skills, s.name)
              end
            end
            return skills
          end
          return #getSkills(player) <= #getSkills(data.from)
        end
      elseif event == fk.TargetSpecified then
        if player:getSwitchSkillState(self.name, false) == fk.SwitchYin and
          #TargetGroup:getRealTargets(data.tos) == 1 and not table.contains(data.card.skillNames, self.name) then
          local to = player.room:getPlayerById(data.to)
          return not to.dead and #to:getCardIds("e") > 0
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if event == fk.DamageInflicted then
      local use = U.askForUseVirtualCard(room, player, "fire_attack", nil, self.name,
        "#ofl__shice-yang", true, false, false, false, nil, true)
      if use then
        self.cost_data = use
        return true
      end
    elseif event == fk.TargetSpecified then
      if room:askForSkillInvoke(player, self.name, nil, "#ofl__shice-yin::"..data.to..":"..data.card:toLogString()) then
        self.cost_data = {tos = {data.to}}
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.DamageInflicted then
      room:useCard(self.cost_data)
      return true
    elseif event == fk.TargetSpecified then
      local to = room:getPlayerById(data.to)
      room:askForDiscard(to, 1, 10, true, self.name, true, ".|.|.|equip", "#ofl__shice-discard:::"..data.card:toLogString())
      local n = #to:getCardIds("e")
      if n > 0 then
        data.additionalEffect = (data.additionalEffect or 0) + n
      end
    end
  end,
}
local podai = fk.CreateTriggerSkill{
  name = "ofl__podai",
  anim_type = "offensive",
  events = {fk.TurnStart, fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and not target.dead then
      local choices = {}
      if player:getMark("ofl__podai2-round") == 0 then
        table.insert(choices, "ofl__podai2")
      end
      if player:getMark("ofl__podai1-round") == 0 then
        for _, card in pairs(Fk.all_card_types) do
          if card.type == Card.TypeBasic then
            for _, s in ipairs(target.player_skills) do
              if s:isPlayerSkill(target) and s.visible and target:hasSkill(s) then
                if string.find(Fk:translate(":"..s.name, "zh_CN"), "【"..Fk:translate(card.trueName, "zh_CN").."】") then
                  table.insert(choices, "ofl__podai1")
                  if #choices > 0 then
                    self.cost_data = choices
                    return true
                  end
                end
              end
            end
          end
        end
        for _, s in ipairs(target.player_skills) do
          if s:isPlayerSkill(target) and s.visible and target:hasSkill(s) then
            if table.find({"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"}, function (str)
              return string.find(Fk:translate(":"..s.name, "zh_CN"), str) ~= nil
            end) then
              table.insert(choices, "ofl__podai1")
              if #choices > 0 then
                self.cost_data = choices
                return true
              end
            end
          end
        end
      end
      if #choices > 0 then
        self.cost_data = choices
        return true
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    local choices = self.cost_data
    table.insert(choices, "Cancel")
    local choice = player.room:askForChoice(player, choices, self.name,
      "#ofl__podai-invoke::"..target.id, false, {"ofl__podai1", "ofl__podai2", "Cancel"})
    if choice ~= "Cancel" then
      self.cost_data = {tos = {target.id}, choice = choice}
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, self.cost_data.choice.."-round", 1)
    if self.cost_data.choice == "ofl__podai1" then
      local skills = {}
      for _, card in pairs(Fk.all_card_types) do
        if card.type == Card.TypeBasic then
          for _, s in ipairs(target.player_skills) do
            if s:isPlayerSkill(target) and s.visible and target:hasSkill(s) then
              if string.find(Fk:translate(":"..s.name, "zh_CN"), "【"..Fk:translate(card.trueName, "zh_CN").."】") then
                table.insertIfNeed(skills, s.name)
              end
            end
          end
        end
      end
      for _, s in ipairs(target.player_skills) do
        if s:isPlayerSkill(target) and s.visible and target:hasSkill(s) then
          if table.find({"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"}, function (str)
            return string.find(Fk:translate(":"..s.name, "zh_CN"), str) ~= nil
          end) then
            table.insertIfNeed(skills, s.name)
          end
        end
      end
      if #skills > 0 then
        local choice = room:askForCustomDialog(player, self.name,
        "packages/utility/qml/ChooseSkillBox.qml", {
          skills, 1, 1, "#ofl__podai-skill::"..target.id, {},
        })
        if choice == "" then
          choice = table.random(skills)
        else
          choice = json.decode(choice)[1]
        end
        room:sendLog{
          type = "#ofl__podai",
          from = player.id,
          to = { target.id },
          arg = choice,
          toast = true,
        }
        room:invalidateSkill(target, choice)
      end
    else
      target:drawCards(3, self.name)
      if not target.dead then
        room:damage{
          from = player,
          to = target,
          damage = 1,
          damageType = fk.FireDamage,
          skillName = self.name,
        }
      end
    end
  end,
}
godhuangfusong:addSkill(shice)
godhuangfusong:addSkill(podai)
Fk:loadTranslationTable{
  ["godhuangfusong"] = "神皇甫嵩",
  ["#godhuangfusong"] = "厥功至伟",
  ["illustrator:godhuangfusong"] = "王宁",

  ["ofl__shice"] = "势策",
  [":ofl__shice"] = "转换技，①当你受到属性伤害时，若你的技能数不大于伤害来源，你可以防止此伤害并视为使用一张【火攻】；②当你不因此技能使用牌"..
  "指定唯一目标后，你可以令其弃置装备区任意张牌，然后此牌额外结算X次（X为其装备区的牌数）。",
  ["ofl__podai"] = "破怠",
  [":ofl__podai"] = "每轮各限一次，一名角色的回合开始或结束时，你可以选择一顶：1.令其描述中含有基本牌名或数字的一个技能失效；2.令其摸三张牌，"..
  "然后对其造成1点火焰伤害。",
  ["#ofl__shice-yang"] = "势策：你可以防止你受到的伤害，视为使用一张【火攻】",
  ["#ofl__shice-yin"] = "势策：是否令 %dest 弃置任意张装备并使%arg额外结算？",
  ["#ofl__shice-discard"] = "势策：弃置任意张装备，然后此%arg将额外结算你装备区牌数的次数！",
  ["#ofl__podai-invoke"] = "破怠：是否对 %dest 执行一项？",
  ["ofl__podai1"] = "令其一个描述中含有基本牌名或数字的技能失效",
  ["ofl__podai2"] = "令其摸三张牌，对其造成1点火焰伤害",
  ["#ofl__podai-skill"] = "破怠：令 %dest 的一个技能失效！",
  ["#ofl__podai"] = "%from 令 %to 的技能“%arg”失效！"
}

local godluzhi = General(extension, "godluzhi", "god", 4)
local zhengan = fk.CreateTriggerSkill{
  name = "ofl__zhengan",
  anim_type = "support",
  events = {fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      local room = player.room
      local targets = {}
      if #room.logic:getEventsOfScope(GameEvent.Death, 1, Util.TrueFunc, Player.HistoryTurn) > 0 then
        targets = table.map(room.alive_players, Util.IdMapper)
      else
        room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
          for _, move in ipairs(e.data) do
            if move.from and move.to and move.toArea == Card.PlayerHand and move.moveReason == fk.ReasonGive and
              not room:getPlayerById(move.from).dead then
              for _, info in ipairs(move.moveInfo) do
                if info.fromArea == Card.PlayerHand then
                  table.insertIfNeed(targets, move.from)
                end
              end
            end
          end
        end, Player.HistoryTurn)
        if player:getMark("ofl__zhengan-turn") ~= 0 then
          for _, mark in ipairs(player:getMark("ofl__zhengan-turn")) do
            local p = room:getPlayerById(mark[1])
            for _, info in ipairs(mark[2]) do
              local q = room:getPlayerById(info[1])
              if p:distanceTo(q) ~= info[2] then
                table.insertIfNeed(targets, mark[1])
                break
              end
            end
          end
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
    local tos = room:askForChoosePlayers(player, self.cost_data, 1, 2, "#ofl__zhengan-choose", self.name, true)
    if #tos > 0 then
      room:sortPlayersByAction(tos)
      self.cost_data = {tos = tos}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = U.getUniversalCards(room, "b")
    for _, id in ipairs(self.cost_data.tos) do
      local p = room:getPlayerById(id)
      if not p.dead then
      local use = U.askForUseRealCard(room, p, cards, nil, self.name, "#ofl__zhengan-use",
        {
          expand_pile = cards,
          bypass_times = true,
          extraUse = true
        }, true, true)
        if use then
          use = {
            card = Fk:cloneCard(use.card.name),
            from = p.id,
            tos = use.tos,
          }
          use.card.skillName = self.name
          room:useCard(use)
        end
      end
    end
  end,

  refresh_events = {fk.TurnStart},
  can_refresh = function (self, event, target, player, data)
    return player:hasSkill(self, true)
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room.alive_players) do
      local info = {}
      for _, q in ipairs(room:getOtherPlayers(p)) do
        table.insert(info, {q.id, p:distanceTo(q)})
      end
      room:addTableMark(player, "ofl__zhengan-turn", {p.id, info})
    end
  end,
}
local weizhu = fk.CreateActiveSkill{
  name = "ofl__weizhu",
  anim_type = "support",
  min_card_num = 1,
  target_num = 0,
  prompt = "#ofl__weizhu",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function (self, to_select, selected)
    return table.contains(Self:getCardIds("h"), to_select)
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local n = #effect.cards
    room:recastCard(effect.cards, player, self.name)
    if player.dead then return end
    local cards = table.filter(room.discard_pile, function (id)
      return Fk:getCardById(id).type == Card.TypeEquip
    end)
    if #cards > 0 then
      if #cards > n then
        cards = U.askforChooseCardsAndChoice(player, cards, {"OK"}, self.name, "#ofl__weizhu-prey:::"..n, nil, n, n)
      end
      room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonJustMove, self.name, nil, true, player.id)
      if player.dead then return end
    end
    n = math.min(n, #room:getOtherPlayers(player, false), #player:getCardIds("he"))
    if n == 0 then return end
    local result =  room:askForYiji(player, player:getCardIds("he"), room:getOtherPlayers(player, false), self.name, n, n,
      "#ofl__weizhu-give:::"..n, nil, false, 1)
    for id, ids in pairs(result) do
      if #ids > 0 then
        local p = room:getPlayerById(id)
        if not p.dead then
          room:addPlayerMark(p, "@ofl__weizhu-round", 1)
        end
      end
    end
  end,
}
local weizhu_distance = fk.CreateDistanceSkill{
  name = "#ofl__weizhu_distance",
  correct_func = function(self, from, to)
    return -from:getMark("@ofl__weizhu-round")
  end,
}
local zequan = fk.CreateViewAsSkill{
  name = "ofl__zequan",
  pattern = ".|.|.|.|.|trick",
  prompt = "#ofl__zequan",
  interaction = function(self)
    local all_names = U.getAllCardNames("t")
    return U.CardNameBox {
      choices = U.getViewAsCardNames(Self, self.name, all_names, nil, Self:getTableMark("@$ofl__zequan")),
      all_choices = all_names,
      default_choice = self.name,
    }
  end,
  handly_pile = true,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).type == Card.TypeEquip and Fk.all_card_types[self.interaction.data] ~= nil
  end,
  view_as = function(self, cards)
    if #cards ~= 1 or Fk.all_card_types[self.interaction.data] == nil then return end
    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcard(cards[1])
    card.skillName = self.name
    return card
  end,
  before_use = function(self, player, use)
    player.room:addTableMark(player, "@$ofl__zequan", use.card.trueName)
  end,
  enabled_at_play = Util.TrueFunc,
  enabled_at_response = function(self, player, response)
    if response then return end
    for _, id in ipairs(Fk:getAllCardIds()) do
      local card = Fk:getCardById(id)
      if card:isCommonTrick() and not card.is_derived and not card.is_passive and
        Exppattern:Parse(Fk.currentResponsePattern):match(card) and
        not table.contains(Self:getTableMark("@$ofl__zequan"), card.trueName) then
        return true
      end
    end
  end,

  on_lose = function (self, player)
    player.room:setPlayerMark(player, "@$ofl__zequan", 0)
  end,
}
local zequan_prohibit = fk.CreateProhibitSkill{
  name = "#ofl__zequan_prohibit",
  is_prohibited = function(self, from, to, card)
    return table.contains(card.skillNames, "ofl__zequan") and (from == to or from.hp > to.hp)
  end,
}
weizhu:addRelatedSkill(weizhu_distance)
zequan:addRelatedSkill(zequan_prohibit)
godluzhi:addSkill(zhengan)
godluzhi:addSkill(weizhu)
godluzhi:addSkill(zequan)
Fk:loadTranslationTable{
  ["godluzhi"] = "神卢植",
  ["#godluzhi"] = "鏖战广宗",
  ["illustrator:godluzhi"] = "聚一_L.M.YANG",

  ["ofl__zhengan"] = "桢干",
  [":ofl__zhengan"] = "每个回合结束时，若本回合有角色交给过其他角色手牌，或计算距离与回合开始时不同，你可以令其中至多两名角色依次可以视为使用"..
  "一张基本牌。",
  ["ofl__weizhu"] = "围铸",
  [":ofl__weizhu"] = "出牌阶段限一次，你可以重铸任意张手牌，获得弃牌堆中等量张装备牌，然后你交给等量名其他角色各一张牌，以此法获得牌的角色"..
  "本轮计算与除其以外的角色距离-1。",
  ["ofl__zequan"] = "责权",
  [":ofl__zequan"] = "你可以将一张装备牌当未以此法使用过的锦囊牌对体力不小于你的其他角色使用。",
  ["#ofl__zhengan-choose"] = "桢干：你可以令其中至多两名角色依次视为使用一张基本牌",
  ["#ofl__zhengan-use"] = "桢干：你可以视为使用一张基本牌",
  ["#ofl__weizhu"] = "围铸：重铸任意张手牌，获得弃牌堆中等量装备牌，然后分配等量的手牌",
  ["#ofl__weizhu-prey"] = "围铸：获得其中%arg张牌",
  ["#ofl__weizhu-give"] = "围铸：请分配给%arg名角色各一张牌，这些角色本轮计算距离-1",
  ["@ofl__weizhu-round"] = "围铸",
  ["#ofl__zequan"] = "责权：将一张装备牌当任意锦囊牌对体力不小于你的其他角色使用",
  ["@$ofl__zequan"] = "责权",
}

local godzhujun = General(extension, "godzhujun", "god", 4)
local cheji = fk.CreateActiveSkill{
  name = "ofl__cheji",
  anim_type = "offensive",
  min_card_num = 1,
  target_num = 0,
  prompt = "#ofl__cheji",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.TrueFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local n = #effect.cards
    room:recastCard(effect.cards, player, self.name)
    if player.dead then return end
    local targets = table.filter(room:getOtherPlayers(player, false), function (p)
      return p:getHandcardNum() >= n
    end)
    if #targets == 0 then return end
    local target = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 1,
      "#ofl__cheji-choose:::"..n, self.name, false)
      target = room:getPlayerById(target[1])
    local cards = room:askForCard(target, n, n, false, self.name, false, nil, "#ofl__cheji-recast:::"..n)
    local names = table.map(cards, function (id)
      return Fk:getCardById(id).trueName
    end)
    room:recastCard(cards, target, self.name)
    if table.contains(names, "slash") and not target.dead then
      room:damage{
        from = player,
        to = target,
        damage = 1,
        damageType = fk.FireDamage,
        skillName = self.name,
      }
    end
    if table.contains(names, "jink") and not player.dead and not target.dead then
      local tos = table.filter(room:getOtherPlayers(target), function (p)
        return target:canUseTo(Fk:cloneCard("slash"), p, {bypass_distances = true, bypass_times = true})
      end)
      if #tos > 0 then
        local to = room:askForChoosePlayers(player, table.map(tos, Util.IdMapper), 1, 1,
          "#ofl__cheji-slash::"..target.id, self.name, false)
        room:useVirtualCard("slash", nil, target, room:getPlayerById(to[1]), self.name, true)
      end
    end
    if table.contains(names, "peach") then
      if not player.dead then
        player:drawCards(2, self.name)
      end
      if not target.dead then
        target:drawCards(2, self.name)
      end
    end
  end,
}
local jicui = fk.CreateTriggerSkill{
  name = "ofl__jicui",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.TargetSpecified},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and data.card.trueName == "slash" and not table.contains({"slash", "stab__slash"}, data.card.name) then
      local turn_event = player.room.logic:getCurrentEvent():findParent(GameEvent.Turn)
      if turn_event and turn_event.data[1] == player then
        local n = 0
        player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
          for _, move in ipairs(e.data) do
            if move.toArea == Card.DiscardPile then
              n = n + #move.moveInfo
            end
          end
        end, Player.HistoryTurn)
        return n > 0
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    data.additionalDamage = (data.additionalDamage or 0) + 1
    local n = 0
    room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
      for _, move in ipairs(e.data) do
        if move.toArea == Card.DiscardPile then
          n = n + #move.moveInfo
        end
      end
    end, Player.HistoryTurn)
    local to = room:getPlayerById(data.to)
    if not to:isNude() then
      local cards
      if #to:getCardIds("he") > n then
        cards = room:askForCard(to, n, n, true, self.name, false, nil, "#ofl__jicui-put:::"..n)
      else
        cards = to:getCardIds("he")
      end
      to:addToPile("$ofl__jicui", cards, false, self.name, to.id)
    end
  end,
}
local jicui_delay = fk.CreateTriggerSkill{
  name = "#ofl__jicui_delay",
  mute = true,
  events = {fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    return #player:getPile("$ofl__jicui") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    player.room:moveCardTo(player:getPile("$ofl__jicui"), Card.PlayerHand, player, fk.ReasonJustMove, "ofl__jicui", nil, false, player.id)
  end,
}
local kuixiang = fk.CreateTriggerSkill{
  name = "ofl__kuixiang",
  anim_type = "offensive",
  events = {fk.AfterDying},
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(self) and not target.dead and
      not table.contains(player:getTableMark(self.name), target.id)
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askForSkillInvoke(player, self.name, nil, "#ofl__kuixiang-invoke::"..target.id) then
      self.cost_data = {tos = {target.id}}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:addTableMark(player, self.name, target.id)
    room:damage{
      from = player,
      to = target,
      damage = 1,
      skillName = self.name,
    }
  end,
}
local kuixiang_delay = fk.CreateTriggerSkill{
  name = "#ofl__kuixiang_delay",
  mute = true,
  events = {fk.Death},
  can_trigger = function(self, event, target, player, data)
    return not player.dead and data.damage and data.damage.from and data.damage.from == player and
      data.damage.skillName == "ofl__kuixiang"
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player:drawCards(3, "ofl__kuixiang")
  end,
}
jicui:addRelatedSkill(jicui_delay)
kuixiang:addRelatedSkill(kuixiang_delay)
godzhujun:addSkill(cheji)
godzhujun:addSkill(jicui)
godzhujun:addSkill(kuixiang)
Fk:loadTranslationTable{
  ["godzhujun"] = "神朱儁",
  ["#godzhujun"] = "围师必阙",
  ["illustrator:godzhujun"] = "鱼仔",

  ["ofl__cheji"] = "撤击",
  [":ofl__cheji"] = "出牌阶段限一次，你可以重铸任意张牌，然后令一名其他角色重铸等量张手牌，若其重铸的牌包含：【杀】，你对其造成1点火焰伤害；"..
  "【闪】，其对你指定的角色视为使用一张【杀】；【桃】，你与其各摸两张牌。",
  ["ofl__jicui"] = "急摧",
  [":ofl__jicui"] = "锁定技，你的回合内，当一名角色使用属性【杀】指定目标后，目标角色需将其X张牌置于武将牌上直到回合结束，此【杀】伤害+1"..
  "（X为本回合进入过弃牌堆的牌数）。",
  ["ofl__kuixiang"] = "溃降",
  [":ofl__kuixiang"] = "每名角色限一次，其他角色脱离濒死状态时，你可以对其造成1点伤害，若因此杀死该角色，你摸三张牌。",
  ["#ofl__cheji"] = "撤击：重铸任意张牌，然后令一名角色重铸等量张手牌，根据其重铸的基本牌执行效果",
  ["#ofl__cheji-choose"] = "撤击：令一名角色重铸%arg张手牌，根据其重铸的基本牌执行效果",
  ["#ofl__cheji-recast"] = "撤击：请重铸%arg张手牌，若包含：<br>【杀】你受到火焰伤害；【闪】你视为对指定角色使用【杀】；【桃】双方摸牌",
  ["#ofl__cheji-slash"] = "撤击：选择 %dest 视为使用【杀】的目标",
  ["#ofl__jicui-put"] = "急摧：你需将%arg张牌置于武将牌上直到回合结束",
  ["$ofl__jicui"] = "急摧",
  ["#ofl__jicui_delay"] = "急摧",
  ["#ofl__kuixiang-invoke"] = "溃降：是否对 %dest 造成1点伤害？若杀死其你摸三张牌",
  ["#ofl__kuixiang_delay"] = "溃降",
}

--官盗E10：蛇年限定礼盒
local changshi = fk.CreateTriggerSkill{
  name = "changshi",
  anim_type = "special",
  events = {fk.GameStart, "fk.ChangshiInvoke"},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      if event == fk.GameStart then
        return true
      elseif event == "fk.ChangshiInvoke" then
        return target == player
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.GameStart then
      room:setPlayerMark(player, "@@changshi", 1)
    elseif event == "fk.ChangshiInvoke" then
      room:changeMaxHp(player, -1)
    end
  end,
}
local changshi_trigger = fk.CreateTriggerSkill{
  name = "#changshi_trigger",
  mute = true,
  events = {fk.EventPhaseStart, fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    if player:getMark("@@changshi") > 0 then
      if event == fk.EventPhaseStart then
        return target.seat == 1 and target.phase == Player.Discard
      elseif event == fk.DamageInflicted then
        return target == player and data.damage >= player.hp + player.shield and
          table.find(player.room:getOtherPlayers(player, false), function (p)
            return p:getMark("@@changshi") > 0
          end) ~= nil
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if event == fk.EventPhaseStart then
      if room:askForSkillInvoke(player, self.name, nil, "#changshi-invoke::"..target.id) then
        self.cost_data = {tos = {target.id}}
        return true
      end
    elseif event == fk.DamageInflicted then
      local targets = table.filter(room:getOtherPlayers(player, false), function (p)
        return p:getMark("@@changshi") > 0
      end)
      local to = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 1, "#changshi-choose", self.name, true)
      if #to > 0 then
        self.cost_data = {tos = to}
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("changshi")
    if event == fk.EventPhaseStart then
      room:notifySkillInvoked(player, self.name, "drawcard")
      room:addPlayerMark(target, MarkEnum.AddMaxCards, 1)
      player:drawCards(1, self.name)
    elseif event == fk.DamageInflicted then
      room:notifySkillInvoked(player, self.name, "defensive")
      local to = room:getPlayerById(self.cost_data.tos[1])
      room:setPlayerMark(player, "@@changshi", 0)
      room.logic:trigger("fk.ChangshiInvoke", player, {})
      if not to.dead then
        room:damage{
          from = data.from,
          to = to,
          damage = data.damage,
          damageType = data.damageType,
          skillName = data.skillName,
          chain = data.chain,
          card = data.card,
        }
      end
      return true
    end
  end,
}
changshi:addRelatedSkill(changshi_trigger)
Fk:loadTranslationTable{
  ["changshi"] = "常侍",
  [":changshi"] = "游戏开始时，你获得一张<a href='changshi_href'>“常侍”标记</a>，当你失去“常侍”标记时，你减1点体力上限。",
  ["changshi_href"] = "拥有“常侍”标记的角色拥有以下技能：<br>1号位的弃牌阶段开始时，你可以摸一张牌，令其手牌上限+1。当你受到致命伤害时，"..
  "你可以弃置“常侍”标记，将此伤害转移给另一名有“常侍”标记的角色。",
  ["@@changshi"] = "常侍",
  ["#changshi_trigger"] = "常侍",
  ["#changshi-invoke"] = "常侍：是否摸一张牌，令 %dest 手牌上限+1？",
  ["#changshi-choose"] = "常侍：是否弃置“常侍”标记，将你受到的致命伤害转移给另一名常侍？",
}

local zhangrang = General(extension, "ofl__zhangrang", "qun", 4)
local taoluan = fk.CreateViewAsSkill{
  name = "ofl__taoluan",
  prompt = "#ofl__taoluan",
  times = function(self)
    return Self.phase == Player.Play and
    #table.filter(Fk:currentRoom().alive_players, function (p)
      return p:getMark("@@changshi") > 0
    end) - Self:usedSkillTimes(self.name, Player.HistoryPhase) or -1
  end,
  interaction = function(self)
    local all_names = U.getAllCardNames("bt")
    return U.CardNameBox {
      choices = U.getViewAsCardNames(Self, self.name, all_names, nil, Self:getTableMark("ofl__taoluan-turn")),
      all_choices = all_names,
      default_choice = self.name,
    }
  end,
  handly_pile = true,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk.all_card_types[self.interaction.data] ~= nil
  end,
  view_as = function(self, cards)
    if #cards ~= 1 or Fk.all_card_types[self.interaction.data] == nil then return end
    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcard(cards[1])
    card.skillName = self.name
    return card
  end,
  before_use = function(self, player, use)
    player.room:addTableMark(player, "ofl__taoluan-turn", use.card.trueName)
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) <
      #table.filter(Fk:currentRoom().alive_players, function (p)
        return p:getMark("@@changshi") > 0
      end)
  end,
}
zhangrang:addSkill(taoluan)
zhangrang:addSkill(changshi)
Fk:loadTranslationTable{
  ["ofl__zhangrang"] = "张让",
  ["#ofl__zhangrang"] = "妄尊帝父",
  ["illustrator:ofl__zhangrang"] = "凡果",

  ["ofl__taoluan"] = "滔乱",
  [":ofl__taoluan"] = "出牌阶段限X次，你可以将一张牌当任意基本牌或普通锦囊牌使用（X为场上有“常侍”标记的角色数，每种牌名每回合限一次）。",
  ["#ofl__taoluan"] = "滔乱：你可以将一张牌当任意基本牌或普通锦囊牌使用",

  ["$ofl__taoluan1"] = "罗绮朱紫，皆若吾等手中傀儡。",
  ["$ofl__taoluan2"] = "吾乃当今帝父，汝岂配与我同列？",
}

local zhaozhong = General(extension, "ofl__zhaozhong", "qun", 4)
local chiyan = fk.CreateTriggerSkill{
  name = "ofl__chiyan",
  anim_type = "drawcard",
  events = {fk.TargetSpecified},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card.trueName == "slash"
  end,
  on_cost = function (self, event, target, player, data)
    if player.room:askForSkillInvoke(player, self.name, nil, "#ofl__chiyan-invoke::"..data.to) then
      self.cost_data = {tos = {data.to}}
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(data.to)
    if not to:isNude() then
      local cards = room:askForCard(to, 1, 999, true, self.name, true, nil, "#ofl__chiyan1-put:"..player.id)
      if #cards > 0 then
        to:addToPile("$ofl__chiyan", cards, false, self.name, to.id)
      end
    end
    if not player.dead and not player:isNude() then
      local cards = room:askForCard(player, 1, 999, true, self.name, true, nil, "#ofl__chiyan2-put::"..to.id)
      if #cards > 0 then
        player:addToPile("$ofl__chiyan", cards, false, self.name, player.id)
      end
    end
    if not to.dead then
      if to:getHandcardNum() <= player:getHandcardNum() then
        room:addPlayerMark(to, "@ofl__chiyan_damage-turn", 1)
      end
      if to:getHandcardNum() >= player:getHandcardNum() then
        room:setPlayerMark(to, "@@ofl__chiyan_hand-turn", 1)
      end
    end
  end,
}
local chiyan_delay = fk.CreateTriggerSkill{
  name = "#ofl__chiyan_delay",
  mute = true,
  events = {fk.DamageInflicted, fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    if event == fk.DamageInflicted then
      return target == player and player:getMark("@ofl__chiyan_damage-turn") > 0
    elseif event == fk.TurnEnd then
      return #player:getPile("$ofl__chiyan") > 0
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.DamageInflicted then
      room:notifySkillInvoked(player, "ofl__chiyan", "negative")
      data.damage = data.damage + player:getMark("@ofl__chiyan_damage-turn")
    elseif event == fk.TurnEnd then
      room:moveCardTo(player:getPile("$ofl__chiyan"), Card.PlayerHand, player, fk.ReasonJustMove, "ofl__chiyan", nil, false, player.id)
    end
  end,
}
local chiyan_prohibit = fk.CreateProhibitSkill{
  name = "#ofl__chiyan_prohibit",
  prohibit_use = function(self, player, card)
    if player:getMark("@@ofl__chiyan_hand-turn") > 0 then
      local subcards = card:isVirtual() and card.subcards or {card.id}
      return #subcards > 0 and table.every(subcards, function(id)
        return table.contains(player:getCardIds("h"), id)
      end)
    end
  end,
}
chiyan:addRelatedSkill(chiyan_delay)
chiyan:addRelatedSkill(chiyan_prohibit)
zhaozhong:addSkill(chiyan)
zhaozhong:addSkill("changshi")
Fk:loadTranslationTable{
  ["ofl__zhaozhong"] = "赵忠",
  ["#ofl__zhaozhong"] = "宦刑啄心",
  ["illustrator:ofl__zhaozhong"] = "凡果",

  ["ofl__chiyan"] = "鸱嚥",
  [":ofl__chiyan"] = "当你使用【杀】指定一个目标后，你可以令目标角色和你依次将任意张牌置于各自的武将牌上直到回合结束，若其手牌数"..
  "不大于你，其本回合受到的伤害+1；不小于你，其本回合不能使用手牌。",
  ["#ofl__chiyan-invoke"] = "鸱嚥：是否令 %dest 和你依次将任意张牌置于武将牌上直到回合结束？",
  ["#ofl__chiyan1-put"] = "鸱嚥：将任意张牌置于武将牌上，若手牌数不大于 %src 则受伤+1，若不小于则不能使用手牌",
  ["#ofl__chiyan2-put"] = "鸱嚥：将任意张牌置于武将牌上，若手牌数不小于 %dest 则其受伤+1，若不大于则其不能使用手牌",
  ["$ofl__chiyan"] = "鸱嚥",
  ["#ofl__chiyan_delay"] = "鸱嚥",
  ["@ofl__chiyan_damage-turn"] = "受到伤害+",
  ["@@ofl__chiyan_hand-turn"] = "不能使用手牌",

  ["$ofl__chiyan1"] = "逆臣乱党，都要受这啄心之刑。",
  ["$ofl__chiyan2"] = "汝此等语，何不以溺自照？",
}

local sunzhang = General(extension, "ofl__sunzhang", "qun", 4)
local zimou = fk.CreateTriggerSkill{
  name = "ofl__zimou",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseStart},
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Play and
      #player.room:getOtherPlayers(player, false) > 0
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, table.map(room.alive_players, Util.IdMapper))
    for _, p in ipairs(room:getOtherPlayers(player, false)) do
      if player.dead then return end
      if not p.dead then
        if player:isNude() then
          if not p:isNude() then
            local card = room:askForCard(p, 1, 1, true, self.name, false, nil, "#ofl__zimou1-give:"..player.id)
            room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonGive, self.name, nil, false, p.id)
          end
        else
          if p:isNude() then
            local card =  room:askForCardChosen(p, player, "he", self.name, "#ofl__zimou-discard:"..player.id)
            room:throwCard(card, self.name, player, p)
            if not p.dead then
              room:damage{
                from = player,
                to = p,
                damage = 1,
                skillName = self.name,
              }
            end
          else
            local card = room:askForCard(p, 1, 1, true, self.name, true, nil, "#ofl__zimou2-give:"..player.id)
            if #card > 0 then
              room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonGive, self.name, nil, false, p.id)
            else
              card = room:askForCardChosen(p, player, "he", self.name, "#ofl__zimou-discard:"..player.id)
              room:throwCard(card, self.name, player, p)
              if not p.dead then
                room:damage{
                  from = player,
                  to = p,
                  damage = 1,
                  skillName = self.name,
                }
              end
            end
          end
        end
      end
    end
  end,
}
sunzhang:addSkill(zimou)
sunzhang:addSkill("changshi")
Fk:loadTranslationTable{
  ["ofl__sunzhang"] = "孙璋",
  ["#ofl__sunzhang"] = "唯利是从",
  ["illustrator:ofl__sunzhang"] = "鬼画府",

  ["ofl__zimou"] = "自谋",
  [":ofl__zimou"] = "锁定技，出牌阶段开始时，你令所有其他角色依次选择一项：1.交给你一张牌；2.弃置你一张牌，然后你对其造成1点伤害。",
  ["#ofl__zimou1-give"] = "自谋：请交给 %src 一张牌",
  ["#ofl__zimou2-give"] = "自谋：交给 %src 一张牌，或点“取消”弃置其一张牌并受到其造成的1点伤害",
  ["#ofl__zimou-discard"] = "自谋：弃置 %src 一张牌",

  ["$ofl__zimou1"] = "在宫里当差，还不是为这利字！",
  ["$ofl__zimou2"] = "闻谤而怒，见誉而喜，汝万万不能啊！",
}

local bilan = General(extension, "ofl__bilan", "qun", 4)
local picai = fk.CreateActiveSkill{
  name = "ofl__picai",
  anim_type = "control",
  card_num = 0,
  min_target_num = 1,
  max_target_num = function ()
    return Self.hp
  end,
  prompt = function (self, selected_cards, selected_targets)
    return "#ofl__picai:::"..Self.hp
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    return #selected < Self.hp and not Fk:currentRoom():getPlayerById(to_select):isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:sortPlayersByAction(effect.tos)
    for _, id in ipairs(effect.tos) do
      local p = room:getPlayerById(id)
      if not p.dead and not p:isKongcheng() then
        local card = room:askForCard(p, 1, 1, false, self.name, false, nil, "#ofl__picai-put:"..player.id)
        room:moveCards({
          ids = card,
          from = p.id,
          toArea = Card.DrawPile,
          moveReason = fk.ReasonPut,
          skillName = self.name,
          moveVisible = false,
          drawPilePosition = 1,
        })
      end
    end
    if player.dead then return end
    local cards = room:getNCards(#effect.tos)
    room:moveCardTo(cards, Card.Processing, nil, fk.ReasonJustMove, self.name, nil, true, player.id)
    local types = {}
    for _, id in ipairs(cards) do
      table.insertIfNeed(types, Fk:getCardById(id).type)
    end
    if not player.dead then
      player:drawCards(#types, self.name)
      if #types == 3 then
        for _, id in ipairs(effect.tos) do
          local p = room:getPlayerById(id)
          if not p.dead then
            cards = table.filter(cards, function (i)
              return room:getCardArea(i) == Card.Processing
            end)
            if #cards > 0 then
              local card = U.askforChooseCardsAndChoice(p, cards, {"OK"}, self.name, "#ofl__picai-prey")
              table.removeOne(cards, card[1])
              room:moveCardTo(card, Card.PlayerHand, p, fk.ReasonJustMove, self.name, nil, true, p.id)
            else
              return
            end
          end
        end
      end
    end
    if #cards > 0 then
      room:cleanProcessingArea(cards)
    end
  end,
}
bilan:addSkill(picai)
bilan:addSkill("changshi")
Fk:loadTranslationTable{
  ["ofl__bilan"] = "毕岚",
  ["#ofl__bilan"] = "糜财广筑",
  ["illustrator:ofl__bilan"] = "鬼画府",

  ["ofl__picai"] = "庀材",
  [":ofl__picai"] = "出牌阶段限一次，你可以令至多X名角色依次将一张手牌置于牌堆顶，然后你亮出牌堆顶等量张牌：其中每有一种类型，你摸一张牌，"..
  "若你摸了三张牌，因此失去牌的角色依次从亮出的牌中选择一张获得（X为你的体力值）。",
  ["#ofl__picai"] = "庀材：令至多%arg名角色依次将一张手牌置于牌堆顶",
  ["#ofl__picai-put"] = "庀材：请将一张手牌置于牌堆顶，%src 将根据类别摸牌",
  ["#ofl__picai-prey"] = "庀材：获得其中一张牌",

  ["$ofl__picai1"] = "修得广厦千万，可庇汉室不倾。",
  ["$ofl__picai2"] = "吾虽鄙夫，亦远胜尔等狂叟！",
}

local xiayun = General(extension, "ofl__xiayun", "qun", 4)
local yaozhuo = fk.CreateActiveSkill{
  name = "ofl__yaozhuo",
  anim_type = "control",
  prompt = "#ofl__yaozhuo",
  card_num = 0,
  target_num = 1,
  can_use = function (self, player)
    return player:getMark("ofl__yaozhuo-phase") == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and Self:canPindian(Fk:currentRoom():getPlayerById(to_select))
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:addPlayerMark(player, "ofl__yaozhuo-phase", 1)
    local pindian = player:pindian({target}, self.name)
    if pindian.results[target.id].winner == player then
      if not target.dead then
        room:addPlayerMark(target, MarkEnum.MinusMaxCards.."-turn", 2)
      end
    elseif player:isWounded() and not player.dead then
      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = self.name,
      }
    end
  end,
}
local yaozhuo_trigger = fk.CreateTriggerSkill{
  name = "#ofl__yaozhuo_trigger",
  mute = true,
  events = {fk.Damaged, fk.PindianFinished},
  main_skill = yaozhuo,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(yaozhuo) then
      if event == fk.Damaged then
        return target == player and
          table.find(player.room:getOtherPlayers(player, false), function (p)
            return player:canPindian(p)
          end) ~= nil
      elseif event == fk.PindianFinished then
        if target == player then
          for _, result in pairs(data.results) do
            if player.room:getCardArea(result.toCard) == Card.Processing then
              return true
            end
          end
        elseif data.results[player.id] then
          return player.room:getCardArea(data.fromCard) == Card.Processing
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    if event == fk.Damaged then
      local room = player.room
      local targets = table.filter(room:getOtherPlayers(player, false), function (p)
        return player:canPindian(p)
      end)
      local to = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 1,
        "#ofl__yaozhuo", "ofl__yaozhuo", true)
      if #to > 0 then
        self.cost_data = {tos = to}
        return true
      end
    elseif event == fk.PindianFinished then
      self.cost_data = nil
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("ofl__yaozhuo")
    if event == fk.Damaged then
      room:notifySkillInvoked(player, "ofl__yaozhuo", "masochism")
      yaozhuo:onUse(room, {
        from = player.id,
        cards = {},
        tos = self.cost_data.tos,
      })
      room:removePlayerMark(player, "ofl__yaozhuo-phase", 1)
    elseif event == fk.PindianFinished then
      room:notifySkillInvoked(player, "ofl__yaozhuo", "drawcard")
      if data.from == player then
        local cards = {}
        for _, result in pairs(data.results) do
          if room:getCardArea(result.toCard) == Card.Processing then
            table.insertTableIfNeed(cards, Card:getIdList(result.toCard))
          end
        end
        if #cards > 0 then
          room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonJustMove, "ofl__yaozhuo", nil, true, player.id)
        end
      elseif data.results[player.id] then
        room:moveCardTo(data.fromCard, Card.PlayerHand, player, fk.ReasonJustMove, "ofl__yaozhuo", nil, true, player.id)
      end
    end
  end,
}
yaozhuo:addRelatedSkill(yaozhuo_trigger)
xiayun:addSkill(yaozhuo)
xiayun:addSkill("changshi")
Fk:loadTranslationTable{
  ["ofl__xiayun"] = "夏恽",
  ["#ofl__xiayun"] = "言蔽朝尊",
  ["illustrator:ofl__xiayun"] = "铁杵文化",

  ["ofl__yaozhuo"] = "谣诼",
  [":ofl__yaozhuo"] = "出牌阶段限一次或当你受到伤害后，你可以与一名角色拼点：若你赢，其本回合手牌上限-2；若你没赢，你回复1点体力。"..
  "当你拼点结算完成后，你获得对方的拼点牌。",
  ["#ofl__yaozhuo"] = "谣诼：与一名角色拼点，若赢，其本回合手牌上限-2；若没赢，你回复1点体力",
  ["#ofl__yaozhuo_trigger"] = "谣诼",

  ["$ofl__yaozhuo1"] = "上蔽天听，下诓朝野！",
  ["$ofl__yaozhuo2"] = "贪财好贿，其罪尚小，不敬不逊，却为大逆！",
}

local lisong = General(extension, "ofl__lisong", "qun", 4)
local kuiji = fk.CreateActiveSkill{
  name = "ofl__kuiji",
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  prompt = "#ofl__kuiji",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= Self.id and not Fk:currentRoom():getPlayerById(to_select):isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local cards = room:askForPoxi(player, "ofl__kuiji", {
      { player.general, player:getCardIds("h") },
      { target.general, target:getCardIds("h") },
    }, nil, true)
    if #cards == 0 then return end
    local cards1 = table.filter(cards, function(id) return table.contains(player:getCardIds("h"), id) end)
    local cards2 = table.filter(cards, function(id) return table.contains(target:getCardIds("h"), id) end)
    local moveInfos = {}
    if #cards1 > 0 then
      table.insert(moveInfos, {
        from = player.id,
        ids = cards1,
        toArea = Card.DiscardPile,
        moveReason = fk.ReasonDiscard,
        proposer = effect.from,
        skillName = self.name,
      })
    end
    if #cards2 > 0 then
      table.insert(moveInfos, {
        from = target.id,
        ids = cards2,
        toArea = Card.DiscardPile,
        moveReason = fk.ReasonDiscard,
        proposer = effect.from,
        skillName = self.name,
      })
    end
    room:moveCards(table.unpack(moveInfos))
    if #cards1 == #cards2 then return end
    local p1, p2 = player, target
    if #cards1 < #cards2 then
      p1, p2 = target, player
    end
    if not p1.dead then
      room:loseHp(p1, 1, self.name)
    end
    if not p2.dead and not p2:hasSkill("chouhai", true) then
      room:handleAddLoseSkills(p2, "chouhai", nil, true, false)
      room.logic:getCurrentEvent():findParent(GameEvent.Round):addCleaner(function()
        room:handleAddLoseSkills(p2, "-chouhai", nil, true, false)
      end)
    end
  end,
}
Fk:addPoxiMethod{
  name = "ofl__kuiji",
  card_filter = function(to_select, selected, data)
    local suit = Fk:getCardById(to_select).suit
    if suit == Card.NoSuit then return false end
    return not table.find(selected, function(id) return Fk:getCardById(id).suit == suit end)
    and not (Self:prohibitDiscard(Fk:getCardById(to_select)) and table.contains(data[1][2], to_select))
  end,
  feasible = function(selected)
    return #selected == 4
  end,
  prompt = "#ofl__kuiji-discard",
}
lisong:addSkill(kuiji)
lisong:addSkill("changshi")
lisong:addRelatedSkill("chouhai")
Fk:loadTranslationTable{
  ["ofl__lisong"] = "栗嵩",
  ["#ofl__lisong"] = "道察衕异",
  ["illustrator:ofl__lisong"] = "铁杵文化",

  ["ofl__kuiji"] = "窥机",
  [":ofl__kuiji"] = "出牌阶段限一次，你可以观看一名其他角色的手牌，然后你可以弃置你与其共计四张花色各不相同的手牌。若如此做，弃置牌数较多的"..
  "角色失去1点体力，弃置牌数较少的角色获得〖仇海〗直到本轮结束。",
  ["#ofl__kuiji"] = "窥机：你可以观看一名角色的手牌，弃置双方四种花色手牌",
  ["#ofl__kuiji-discard"] = "窥机：弃置双方四种花色的牌，弃牌多的角色失去体力，弃牌少的角色获得“仇海”",

  ["$ofl__kuiji1"] = "同道者为忠，殊途者为奸！",
  ["$ofl__kuiji2"] = "区区不才，可为帝之耳目，试问汝有何能？",
}

local duangui = General(extension, "ofl__duangui", "qun", 4)
local chihe = fk.CreateTriggerSkill{
  name = "ofl__chihe",
  anim_type = "drawcard",
  events = {fk.TargetSpecified, fk.TargetConfirmed},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card.trueName == "slash" and
      #AimGroup:getAllTargets(data.tos) == 1
  end,
  on_cost = function (self, event, target, player, data)
    local to
    if event == fk.TargetSpecified then
      to = data.to
    elseif event == fk.TargetConfirmed then
      to = data.from
    end
    if player.room:askForSkillInvoke(player, self.name, nil, "#ofl__chihe-invoke::"..to) then
      self.cost_data = {tos = {to}}
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    player:drawCards(2, self.name)
    if player.dead then return end
    if player:getHandcardNum() > 1 then
      local cards = room:askForCard(player, 2, 2, false, self.name, false, nil, "#ofl__chihe-show")
      player:showCards(cards)
      if player.dead then return end
    end
    local to
    if event == fk.TargetSpecified then
      to = room:getPlayerById(data.to)
    elseif event == fk.TargetConfirmed then
      to = room:getPlayerById(data.from)
    end
    if not to.dead and player:canPindian(to) then
      local pindian = player:pindian({to}, self.name)
      if pindian.results[to.id].winner == player then
        data.additionalDamage = (data.additionalDamage or 0) + 1
      elseif not player.dead then
        room:askForDiscard(player, 2, 2, true, self.name, false)
      end
    end
  end,
}
duangui:addSkill(chihe)
duangui:addSkill("changshi")
Fk:loadTranslationTable{
  ["ofl__duangui"] = "段珪",
  ["#ofl__duangui"] = "断途避圣",
  ["illustrator:ofl__duangui"] = "鬼画府",

  ["ofl__chihe"] = "叱吓",
  [":ofl__chihe"] = "当你使用【杀】指定唯一目标/成为【杀】的唯一目标后，你可以摸两张牌并展示两张手牌，然后你与目标角色/使用者拼点："..
  "若你赢，此【杀】伤害+1；若你没赢，你弃置两张牌。",
  ["#ofl__chihe-invoke"] = "叱吓：是否摸两张牌并与 %dest 拼点？若赢，此【杀】伤害+1；若没赢，你弃两张牌",
  ["#ofl__chihe-show"] = "叱吓：请展示两张手牌",

  ["$ofl__chihe1"] = "想见圣上？哼哼，你怕是没这个福分了！",
  ["$ofl__chihe2"] = "哼，不过襟裾牛马，衣冠狗彘尓！",
}

local guosheng = General(extension, "ofl__guosheng", "qun", 4)
local niqu = fk.CreateTriggerSkill{
  name = "ofl__niqu",
  anim_type = "offensive",
  events = {fk.CardUseFinished, fk.CardRespondFinished},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and data.card.trueName == "jink" and player:usedSkillTimes(self.name, Player.HistoryTurn) == 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, data, "#ofl__niqu-invoke::"..target.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(1, self.name)
    if target ~= player and not target.dead then
      room:useVirtualCard("slash", nil, player, target, self.name, true)
    end
  end,
}
guosheng:addSkill(niqu)
guosheng:addSkill("changshi")
Fk:loadTranslationTable{
  ["ofl__guosheng"] = "郭胜",
  ["#ofl__guosheng"] = "诱杀党朋",
  ["illustrator:ofl__guosheng"] = "鬼画府",

  ["ofl__niqu"] = "逆取",
  [":ofl__niqu"] = "每回合限一次，当一名角色使用或打出【闪】结算后，你可以摸一张牌，然后视为对其使用一张【杀】。",
  ["#ofl__niqu-invoke"] = "逆取：是否摸一张牌，视为对 %dest 使用【杀】？",

  ["$ofl__niqu1"] = "离心离德，为吾等所不容！",
  ["$ofl__niqu2"] = "此昏聩之徒，吾羞与为伍。",
}

local gaowang = General(extension, "ofl__gaowang", "qun", 4)
local miaoyu = fk.CreateTriggerSkill{
  name = "ofl__miaoyu",
  anim_type = "offensive",
  events = {fk.HpRecover},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and not target.dead
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askForSkillInvoke(player, self.name, data, "#ofl__miaoyu-invoke::"..target.id) then
      self.cost_data = {tos = {target.id}}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(target, "@ofl__miaoyu-turn", player:usedSkillTimes(self.name, Player.HistoryTurn))
    for _, p in ipairs(room:getOtherPlayers(target)) do
      if p:getMark("@ofl__miaoyu-turn") > 0 then
        room:setPlayerMark(p, "@ofl__miaoyu-turn", player:usedSkillTimes(self.name, Player.HistoryTurn))
      end
    end
    room:moveCardTo(room:getNCards(1), Card.PlayerHand, target, fk.ReasonGive, self.name, nil, false, player.id)
  end,
}
local miaoyu_delay = fk.CreateTriggerSkill{
  name = "#ofl__miaoyu_delay",
  anim_type = "offensive",
  events = {fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    return player:usedSkillTimes("ofl__miaoyu", Player.HistoryTurn) > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room:getAlivePlayers()) do
      if not p.dead and p:getMark("@ofl__miaoyu-turn") > 0 then
        room:loseHp(p, player:usedSkillTimes("ofl__miaoyu", Player.HistoryTurn), "ofl__miaoyu")
      end
    end
  end,
}
miaoyu:addRelatedSkill(miaoyu_delay)
gaowang:addSkill(miaoyu)
gaowang:addSkill("changshi")
Fk:loadTranslationTable{
  ["ofl__gaowang"] = "高望",
  ["#ofl__gaowang"] = "蛇蝎为药",
  ["illustrator:ofl__gaowang"] = "鬼画府",

  ["ofl__miaoyu"] = "妙语",
  [":ofl__miaoyu"] = "当一名角色回复体力后，你可以将牌堆顶一张牌交给其，当前回合结束时，其失去X点体力（X为你本回合发动此技能次数）。",
  ["#ofl__miaoyu-invoke"] = "妙语：是否将牌堆顶牌交给 %dest？本回合结束时其失去体力",
  ["@ofl__miaoyu-turn"] = "妙语",
  ["#ofl__miaoyu_delay"] = "妙语",

  ["$ofl__miaoyu1"] = "小伤无碍，安心修养便可。",
  ["$ofl__miaoyu2"] = "若非吾之相助，汝安有今日？",
}

local hankui = General(extension, "ofl__hankui", "qun", 4)
local xiaolu = fk.CreateTriggerSkill{
  name = "ofl__xiaolu",
  attached_skill_name = "ofl__xiaolu&",
}
local xiaolu_active = fk.CreateActiveSkill{
  name = "ofl__xiaolu&",
  anim_type = "support",
  card_num = 1,
  target_num = 1,
  prompt = "#ofl__xiaolu&",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name) == 0
  end,
  card_filter = function(self, to_select, selected, targets)
    return #selected == 0
  end,
  target_filter = function(self, to_select, selected, cards)
    return #selected == 0 and to_select ~= Self.id and Fk:currentRoom():getPlayerById(to_select):hasSkill(xiaolu)
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    target:broadcastSkillInvoke("ofl__xiaolu")
    room:moveCardTo(effect.cards, Card.PlayerHand, target, fk.ReasonGive, self.name, nil, false, player.id)
    if player.dead then return end
    if not room:getBanner("ofl__xiaolu") then
      room:setBanner("ofl__xiaolu", U.getUniversalCards(room, "t"))
    end
    local success, dat = room:askForUseActiveSkill(player, "ofl__xiaolu_viewas",
      "#ofl__xiaolu-use", true,
      {
        expand_pile = room:getBanner("ofl__xiaolu"),
        exclusive_targets = table.map(room:getOtherPlayers(target), Util.IdMapper)
      }, false)
    if success and dat then
      local card = Fk:cloneCard(Fk:getCardById(dat.cards[1]).name)
      card.skillName = "ofl__xiaolu"
      room:useCard{
        from = player.id,
        tos = table.map(dat.targets, function(id) return {id} end),
        card = card,
      }
    end
  end,
}
local xiaolu_viewas = fk.CreateActiveSkill{
  name = "ofl__xiaolu_viewas",
  card_num = 1,
  min_target_num = 1,
  card_filter = function(self, to_select, selected, targets)
    return #selected == 0 and table.contains(Fk:currentRoom():getBanner("ofl__xiaolu"), to_select)
  end,
  target_filter = function(self, to_select, selected, selected_cards, card, extra_data, player)
    if #selected_cards == 1 then
      local c = Fk:cloneCard(Fk:getCardById(selected_cards[1]).name)
      c.skillName = "ofl__xiaolu"
      if #selected == 0 then
        return c.skill:modTargetFilter(to_select, {}, player, c, false)
      elseif #selected == 1 then
        if c.skill:modTargetFilter(selected[1], {}, player, c, false) then
          return c.skill:getMinTargetNum() > 1 and c.skill:targetFilter(to_select, selected, {}, c, extra_data, player)
        end
      end
    end
  end,
  feasible = function (self, selected, selected_cards, player)
    if #selected > 0 and #selected_cards == 1 then
      local card = Fk:cloneCard(Fk:getCardById(selected_cards[1]).name)
      card.skillName = "ofl__xiaolu"
      return card.skill:feasible(selected, {}, player, card)
    end
  end,
}
Fk:addSkill(xiaolu_active)
Fk:addSkill(xiaolu_viewas)
hankui:addSkill(xiaolu)
hankui:addSkill("changshi")
Fk:loadTranslationTable{
  ["ofl__hankui"] = "韩悝",
  ["#ofl__hankui"] = "贪财好贿",
  ["illustrator:ofl__hankui"] = "鬼画府",

  ["ofl__xiaolu"] = "宵赂",
  [":ofl__xiaolu"] = "每名其他角色的出牌阶段限一次，其可以交给你一张牌，然后其视为对另一名角色使用一张仅指定该角色为目标的普通锦囊牌。",
  ["ofl__xiaolu&"] = "宵赂",
  [":ofl__xiaolu&"] = "出牌阶段限一次，你可以交给韩悝一张牌，然后视为对另一名角色使用一张仅指定该角色为目标的普通锦囊牌。",
  ["#ofl__xiaolu&"] = "宵赂：你可以交给韩悝一张牌，然后视为对另一名角色使用一张普通锦囊牌",
  ["ofl__xiaolu_viewas"] = "宵赂",
  ["#ofl__xiaolu-use"] = "宵赂：视为对一名角色使用一张锦囊牌",

  ["$ofl__xiaolu1"] = "咱家上下打点，自是要费些银子。",
  ["$ofl__xiaolu2"] = "切！宁享短福，莫为汝等庸奴！",
}

local godsimayi = General(extension, "ofl__godsimayi", "god", 4)
local jilin = fk.CreateTriggerSkill{
  name = "jilin",
  anim_type = "special",
  events = {fk.GameStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    player:addToPile("$yingtian_ambition", player.room:getNCards(3), false, self.name, player.id)
  end,

  on_lose = function (self, player, is_death)
    if not player:hasSkill("yingyou", true) then
      local room = player.room
      room:setPlayerMark(player, "yingtian_ambition_shown", 0)
      room:moveCards({
        ids = player:getPile("$yingtian_ambition"),
        from = player.id,
        toArea = Card.DiscardPile,
        moveReason = fk.ReasonPutIntoDiscardPile,
      })
    end
  end,
}
local jilin_trigger = fk.CreateTriggerSkill{
  name = "#jilin_trigger",
  anim_type = "defensive",
  events = {fk.TargetConfirming},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jilin) and data.from ~= player.id and
      table.find(player:getPile("$yingtian_ambition"), function (id)
        return not table.contains(player:getTableMark("yingtian_ambition_shown"), id)
      end)
  end,
  on_cost = function (self, event, target, player, data)
    local cards = table.filter(player:getPile("$yingtian_ambition"), function (id)
      return not table.contains(player:getTableMark("yingtian_ambition_shown"), id)
    end)
    local card = player.room:askForCard(player, 1, 1, false, "jilin", true, tostring(Exppattern{ id = cards }),
      "#jilin-invoke::"..data.from..":"..data.card:toLogString(), player:getPile("$yingtian_ambition"))
    if #card > 0 then
      self.cost_data = {cards = card}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if data.card.type == Card.TypeEquip or data.card.subtype == Card.SubtypeDelayedTrick then
      data.tos = {}
    else
      table.insertIfNeed(data.nullifiedTargets, player.id)
    end
    room:addTableMark(player, "yingtian_ambition_shown", self.cost_data.cards[1])
  end,
}
local jilin_trigger2 = fk.CreateTriggerSkill{
  name = "#jilin_trigger2",
  anim_type = "special",
  events = {fk.TurnStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jilin) and not player:isKongcheng() and
      table.find(player:getPile("$yingtian_ambition"), function (id)
        return not table.contains(player:getTableMark("yingtian_ambition_shown"), id)
      end)
  end,
  on_cost = function (self, event, target, player, data)
    local cards = player.room:askForPoxi(player, "jilin", {
      { "$yingtian_ambition", player:getPile("$yingtian_ambition") },
      { "$Hand", player:getCardIds("h") },
    }, { shown = player:getTableMark("yingtian_ambition_shown") }, true)
    if #cards > 0 then
      self.cost_data = {cards = cards}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local cards1 = table.filter(self.cost_data.cards, function (id)
      return table.contains(player:getCardIds("h"), id)
    end)
    local cards2 = table.filter(self.cost_data.cards, function (id)
      return table.contains(player:getPile("$yingtian_ambition"), id)
    end)
    U.swapCardsWithPile(player, cards1, cards2, "jilin", "$yingtian_ambition", false, player.id)
  end,
}
Fk:addPoxiMethod{
  name = "jilin",
  prompt = function (data, extra_data)
    return "#jilin"
  end,
  card_filter = function(to_select, selected, data, extra_data)
    return not table.contains(extra_data.shown, to_select)
  end,
  feasible = function(selected, data, extra_data)
    return #selected > 0 and #selected % 2 == 0 and
      #table.filter(selected, function (id)
        return table.contains(data[1][2], id)
      end) * 2 == #selected
  end,
}
local jilin_visibility = fk.CreateVisibilitySkill{
  name = "#jilin_visibility",
  card_visible = function(self, player, card)
    if table.find(Fk:currentRoom().alive_players, function (p)
      return table.contains(p:getPile("$yingtian_ambition"), card.id) and
        table.contains(p:getTableMark("yingtian_ambition_shown"), card.id)
    end) then
      return true
    end
  end
}
local yingyou = fk.CreateTriggerSkill{
  name = "yingyou",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jilin) and player.phase == Player.Play and
      table.find(player:getPile("$yingtian_ambition"), function (id)
        return not table.contains(player:getTableMark("yingtian_ambition_shown"), id)
      end)
  end,
  on_cost = function (self, event, target, player, data)
    local cards = table.filter(player:getPile("$yingtian_ambition"), function (id)
      return not table.contains(player:getTableMark("yingtian_ambition_shown"), id)
    end)
    local card = player.room:askForCard(player, 1, 1, false, self.name, true, tostring(Exppattern{ id = cards }),
      "#yingyou-invoke", player:getPile("$yingtian_ambition"))
    if #card > 0 then
      self.cost_data = {cards = card}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:addTableMark(player, "yingtian_ambition_shown", self.cost_data.cards[1])
    local n = #table.filter(player:getPile("$yingtian_ambition"), function (id)
      return table.contains(player:getTableMark("yingtian_ambition_shown"), id)
    end)
    player:drawCards(n, self.name)
  end,

  on_lose = function (self, player, is_death)
    if not player:hasSkill("jilin", true) then
      local room = player.room
      room:setPlayerMark(player, "yingtian_ambition_shown", 0)
      room:moveCards({
        ids = player:getPile("$yingtian_ambition"),
        from = player.id,
        toArea = Card.DiscardPile,
        moveReason = fk.ReasonPutIntoDiscardPile,
      })
    end
  end,
}
local yingyou_trigger = fk.CreateTriggerSkill{
  name = "#yingyou_trigger",
  anim_type = "drawcard",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and #player:getPile("$yingtian_ambition") > 0 and player:getMark("yingtian_ambition_shown") ~= 0 then
      for _, move in ipairs(data) do
        if move.from == player.id then
          for _, info in ipairs(move.moveInfo) do
            if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
              table.find(player:getPile("$yingtian_ambition"), function (id)
                return table.contains(player:getTableMark("yingtian_ambition_shown"), id) and
                Fk:getCardById(id):compareSuitWith(Fk:getCardById(info.cardId))
              end) then
              return true
            end
          end
        end
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, "yingyou")
  end,
}
local yingtian = fk.CreateTriggerSkill{
  name = "yingtian",
  anim_type = "special",
  frequency = Skill.Wake,
  events = {fk.Deathed},
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  can_wake = function(self, event, target, player, data)
    local kingdoms = {}
    for _, p in ipairs(player.room.alive_players) do
      table.insertIfNeed(kingdoms, p.kingdom)
    end
    return #kingdoms < 3
  end,
  on_use = function (self, event, target, player, data)
    player.room:handleAddLoseSkills(player, "ex__guicai|wansha|lianpo|-yingyou", nil, true, false)
  end,
}
local yingtian_targetmod = fk.CreateTargetModSkill{
  name = "#yingtian_targetmod",
  bypass_distances =  function(self, player, skill, card)
    return card and player:usedSkillTimes("yingtian", Player.HistoryGame) > 0
  end,
}
jilin:addRelatedSkill(jilin_trigger)
jilin:addRelatedSkill(jilin_trigger2)
jilin:addRelatedSkill(jilin_visibility)
yingyou:addRelatedSkill(yingyou_trigger)
yingtian:addRelatedSkill(yingtian_targetmod)
godsimayi:addSkill(jilin)
godsimayi:addSkill(yingyou)
godsimayi:addSkill(yingtian)
godsimayi:addRelatedSkill("ex__guicai")
godsimayi:addRelatedSkill("wansha")
godsimayi:addRelatedSkill("lianpo")
Fk:loadTranslationTable{
  ["ofl__godsimayi"] = "神司马懿",
  ["#ofl__godsimayi"] = "鉴往知来",
  ["illustrator:ofl__godsimayi"] = "墨三千",

  ["jilin"] = "戢鳞",
  [":jilin"] = "游戏开始时，将牌堆顶三张牌暗置于你武将牌上，称为“志”；当你成为其他角色使用牌的目标时，你可以明置一张暗置的“志”令此牌对你无效；"..
  "回合开始时，你可以用任意张手牌替换等量暗置的“志”。",
  ["yingyou"] = "英猷",
  [":yingyou"] = "出牌阶段开始时，你可以明置一张“志”，然后摸X张牌（X为你明置的“志”数）。当你失去与明置的“志”花色相同的牌后，你摸一张牌。",
  ["yingtian"] = "应天",
  [":yingtian"] = "觉醒技，一名角色死亡后，若场上势力数不大于2，你获得〖鬼才〗〖完杀〗〖连破〗，本局游戏使用牌无距离限制，失去〖英猷〗。",
  ["$yingtian_ambition"] = "志",
  ["#jilin_trigger"] = "戢鳞",
  ["#jilin-invoke"] = "戢鳞：是否明置一张“志”，令 %dest 对你使用的%arg无效？",
  ["#jilin_trigger2"] = "戢鳞",
  ["#jilin"] = "戢鳞：你可以用手牌替换等量暗置的“志”",
  ["#yingyou-invoke"] = "英猷：你可以明置一张“志”，摸明置数的牌",
  ["#yingyou_trigger"] = "英猷",
}

return extension
