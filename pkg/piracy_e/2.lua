
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
Fk:loadTranslationTable{
  ["ofl__mingdao"] = "瞑道",
  [":ofl__mingdao"] = "游戏开始时，你可以将一张<a href='populace_href'>【众】</a>置入你的装备区，【众】进入离开你的装备区时销毁。",
  ["ofl__zhongfu"] = "众附",
  [":ofl__zhongfu"] = "每轮开始时，你可以声明一种花色，然后令手牌最少的角色依次选择一项：1.将一张牌置于牌堆顶；2.从牌堆底摸一张牌。"..
  "本轮当以此法失去牌的角色造成伤害后，你可以发动一次〖瞑道〗。",
  ["ofl__dangjing"] = "荡京",
  [":ofl__dangjing"] = "当你发动〖众附〗后，若你装备区内的牌为全场最多，你可以令一名角色进行一次判定，若为你〖众附〗声明的花色，你对其造成1点"..
  "雷电伤害且可以重复此流程。",
  ["populace_href"] = "【众】共有四张，均为装备牌，可以置入武器/防具/坐骑栏",
  ["ofl__mingdao_active"] = "瞑道",
  ["#ofl__mingdao-invoke"] = "瞑道：将一张“众”置入你的装备区（选择一种“众”及副类别，右键/长按可查看技能）",
  ["#ofl__zhongfu-choice"] = "众附：你可以声明本轮生效的“众附”花色，然后令手牌数最少的角色依次选择一项",
  ["@ofl__zhongfu-round"] = "众附",
  ["#ofl__zhongfu-ask"] = "众附：点“取消”摸一张牌；或将一张牌置于牌堆顶，本轮你造成伤害后 %src 可发动“瞑道”",
  ["#ofl__zhongfu_delay"] = "众附",
  ["@@ofl__zhongfu_target-round"] = "信众",
  ["#ofl__dangjing-choose"] = "荡京：令一名角色进行判定，若为“众附”花色，对其造成1点雷电伤害且可以再次发动！",
}
