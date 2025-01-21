local extension = Package:new("ofl_token", Package.CardPack)
extension.extensionName = "offline"

Fk:loadTranslationTable{
  ["ofl_token"] = "线下衍生牌",
}

local U = require "packages/utility/utility"

local jingxiangGoldenAgeSkill = fk.CreateActiveSkill{
  name = "jingxiang_golden_age_skill",
  prompt = function (self, selected_cards, selected_targets)
    local kingdoms = {}
    for _, p in ipairs(Fk:currentRoom().alive_players) do
      table.insertIfNeed(kingdoms, p.kingdom)
    end
    return "#jingxiang_golden_age_skill:::"..#kingdoms
  end,
  can_use = Util.CanUse,
  target_num = function ()
    local kingdoms = {}
    for _, p in ipairs(Fk:currentRoom().alive_players) do
      table.insertIfNeed(kingdoms, p.kingdom)
    end
    return #kingdoms
  end,
  mod_target_filter = function(self, to_select, selected, player, card)
    return to_select ~= player.id
  end,
  target_filter = Util.TargetFilter,
  on_action = function(self, room, use, finished)
    if not finished then
      local toDisplay = room:getNCards(#room.alive_players)
      room:moveCards({
        ids = toDisplay,
        toArea = Card.Processing,
        moveReason = fk.ReasonPut,
        proposer = use.from,
      })

      table.forEach(room.players, function(p)
        room:fillAG(p, toDisplay)
      end)

      use.extra_data = use.extra_data or {}
      use.extra_data.jingxiangGoldenAgeFilled = toDisplay
      use.extra_data.jingxiangGoldenAgeResult = {}
    else
      if use.extra_data and use.extra_data.jingxiangGoldenAgeFilled then
        table.forEach(room.players, function(p)
          room:closeAG(p)
        end)

        local toDiscard = table.filter(use.extra_data.jingxiangGoldenAgeFilled, function(id)
          return room:getCardArea(id) == Card.Processing
        end)

        if #toDiscard > 0 then
          local from = room:getPlayerById(use.from)
          if not from.dead then
            room:moveCardTo(toDiscard, Card.PlayerHand, from, fk.ReasonPrey, self.name, nil, true, from.id)
          else
            room:moveCards({
              ids = toDiscard,
              toArea = Card.DiscardPile,
              moveReason = fk.ReasonPutIntoDiscardPile,
            })
          end
        end
      end

      use.extra_data.jingxiangGoldenAgeFilled = nil
    end
  end,
  on_effect = function(self, room, effect)
    local to = room:getPlayerById(effect.to)
    if not (effect.extra_data and effect.extra_data.jingxiangGoldenAgeFilled) then
      return
    end

    local chosen = room:askForAG(to, effect.extra_data.jingxiangGoldenAgeFilled, false, self.name)
    room:takeAG(to, chosen, room.players)
    table.insert(effect.extra_data.jingxiangGoldenAgeResult, {effect.to, chosen})
    room:moveCardTo(chosen, Card.PlayerHand, effect.to, fk.ReasonPrey, self.name, nil, true, effect.to)
    table.removeOne(effect.extra_data.jingxiangGoldenAgeFilled, chosen)
  end,
}

local jingxiangGoldenAge = fk.CreateTrickCard{
  name = "&jingxiang_golden_age",
  skill = jingxiangGoldenAgeSkill,
  multiple_targets = true,
  suit = Card.Heart,
  number = 5,
}
extension:addCard(jingxiangGoldenAge)
Fk:loadTranslationTable{
  ["jingxiang_golden_age"] = "荆襄盛世",
  ["jingxiang_golden_age_skill"] = "荆襄盛世",
  [":jingxiang_golden_age"] = "锦囊牌<br/><b>时机</b>：出牌阶段<br/><b>目标</b>：X名其他角色（X为场上势力数）<br/><b>效果</b>："..
  "你亮出牌堆顶存活角色张数的牌，目标角色依次获得其中一张牌，你获得其余的牌。",
  ["#jingxiang_golden_age_skill"] = "指定%arg名其他角色，亮出牌堆顶存活角色数的牌，目标角色依次获得其中一张牌，你获得其余的牌",
}

local caningWhipSkill = fk.CreateTriggerSkill{
  name = "#caning_whip_skill",
  attached_equip = "caning_whip",
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseStart, fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    if target == player then
      if event == fk.EventPhaseStart and player:hasSkill(self) and player.phase == Player.Play and #player.room.alive_players > 1 then
        return table.find(player.room.alive_players, function (p)
          return (p.general == "tianchuan" or p.deputyGeneral == "tianchuan")
        end)
      elseif event == fk.EventPhaseEnd and player.phase == Player.Finish and player:getMark("caning_whip-turn") ~= 0 then
        local room = player.room
        local n = 0
        for _, id in ipairs(player:getMark("caning_whip-turn")) do
          local yes = false
          local p = room:getPlayerById(id)
          if #room.logic:getActualDamageEvents(1, function(e)
            local damage = e.data[1]
            return damage.from == player and damage.to == p
          end, Player.HistoryTurn) == 0 then
            yes = true
          end
          if not yes and #room.logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
            local use = e.data[1]
            return use.card.trueName == "slash" and use.from == player.id and TargetGroup:includeRealTargets(use.tos, p.id)
          end, Player.HistoryTurn) == 0 then
            yes = true
          end
          if yes then
            n = n + 1
          end
        end
        if n > 0 then
          self.cost_data = n
          return true
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.EventPhaseStart then
      local tos = {}
      for _, p in ipairs(room:getAllPlayers()) do
        if (p.general == "tianchuan" or p.deputyGeneral == "tianchuan") and not p.dead then
          local to = room:askForChoosePlayers(p, table.map(room:getOtherPlayers(player, false), Util.IdMapper), 1, 1,
            "#caning_whip-choose:"..player.id, "caning_whip", false)
          room:notifySkillInvoked(p, self.name, "control")
          table.insertIfNeed(tos, to[1])
          room:setPlayerMark(room:getPlayerById(to[1]), "@@caning_whip-turn", 1)
        end
      end
      room:setPlayerMark(player, "caning_whip-turn", tos)
    elseif event == fk.EventPhaseEnd then
      room:notifySkillInvoked(player, self.name, "negative")
      room:damage{
        from = player,
        to = player,
        damage = self.cost_data,
        skillName = self.name,
      }
    end
  end,
}
local caningWhip_attackrange = fk.CreateAttackRangeSkill{
  name = "#caning_whip_attackrange",
  frequency = Skill.Compulsory,
  main_skill = caningWhipSkill,
  correct_func = function (self, from, to)
    if from:hasSkill(caningWhipSkill) then
      return #table.filter(from:getCardIds("e"), function (id)
        return Fk:getCardById(id).name == "caning_whip"
      end)
    end
  end,
}
local sub_types = {"weapon", "armor", "defensive_horse", "offensive_horse", "treasure"}
local changeWhipSubtype = fk.CreateActiveSkill{
  name = "changeWhipSubtype",
  card_num = 1,
  target_num = 0,
  prompt = "#changeWhipSubtype",
  card_filter = function(self, to_select, selected, targets)
    return #selected == 0 and Fk:getCardById(to_select).type == Card.TypeEquip and
      Fk:currentRoom():getCardArea(to_select) ~= Player.Equip
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local choice = room:askForChoice(player, sub_types)
    local card = Fk:getCardById(effect.cards[1])
    room:setCardMark(card, "@caning_whip", Fk:translate(choice))
    Fk.printed_cards[effect.cards[1]].sub_type = table.indexOf(sub_types, choice) + 2
  end
}
Fk:addSkill(changeWhipSubtype)
caningWhipSkill:addRelatedSkill(caningWhip_attackrange)
Fk:addSkill(caningWhipSkill)
local caningWhip = fk.CreateTreasure{
  name = "&caning_whip",
  suit = Card.Spade,
  number = 9,
  equip_skill = caningWhipSkill,
  special_skills = {"changeWhipSubtype"},
}
extension:addCard(caningWhip)
Fk:loadTranslationTable{
  ["caning_whip"] = "刑鞭",
  ["#caning_whip_skill"] = "刑鞭",
  [":caning_whip"] = "装备牌·任一类别<br/><b>装备技能</b>：锁定技，你的装备区内每有一张【刑鞭】，你的攻击范围便+1；出牌阶段开始时，田钏指定"..
  "除你以外的一名角色，本回合结束阶段开始时，若你本回合未对该角色使用过【杀】或未对该角色造成过伤害，你对自己造成1点伤害。<br>"..
  "<font color='grey'>注：【刑鞭】的UI默认为宝物，一名角色装备多张【刑鞭】时UI仅显示一张，不影响实际效果，请勿反馈显示问题。</font>",
  ["changeWhipSubtype"] = "指定类别",
  [":changeWhipSubtype"] = "出牌阶段，你可以为手牌中的【刑鞭】指定副类别。",
  ["#caning_whip-choose"] = "刑鞭：为 %src 指定一名角色，若其未对指定角色使用【杀】或造成伤害，本回合结束阶段其对自己造成1点伤害",
  ["@@caning_whip-turn"] = "刑鞭",
  ["#changeWhipSubtype"] = "指定【刑鞭】的副类别",
  ["@caning_whip"] = "",
}

local shzj__dragon_phoenix_skill = fk.CreateTriggerSkill{
  name = "#shzj__dragon_phoenix_skill",
  attached_equip = "shzj__dragon_phoenix",
  events = {fk.TargetSpecified},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card.trueName == "slash" and
      player:usedSkillTimes(self.name, Player.HistoryTurn) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local all_choices = {"draw1", "shzj__dragon_phoenix_skill_discard::"..data.to, "Cancel"}
    local choices = table.simpleClone(all_choices)
    local to = player.room:getPlayerById(data.to)
    if to.dead or to:isNude() then
      table.remove(choices, 2)
    end
    local choice = player.room:askForChoice(player, choices, self.name, nil, false, all_choices)
    if choice ~= "Cancel" then
      self.cost_data = choice
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    -- room:setEmotion(player, "./packages/hegemony/image/anim/dragon_phoenix")
    if self.cost_data == "draw1" then
      player:drawCards(1, self.name)
    else
      local to = player.room:getPlayerById(data.to)
      room:askForDiscard(to, 1, 1, true, self.name, false, ".", "#dragon_phoenix-invoke")
    end
  end,
}
Fk:addSkill(shzj__dragon_phoenix_skill)
local shzj__dragon_phoenix = fk.CreateWeapon{
  name = "&shzj__dragon_phoenix",
  suit = Card.Spade,
  number = 2,
  attack_range = 2,
  equip_skill = shzj__dragon_phoenix_skill,
}
extension:addCard(shzj__dragon_phoenix)
Fk:loadTranslationTable{
  ["shzj__dragon_phoenix"] = "飞龙夺凤",
  ["#shzj__dragon_phoenix_skill"] = "飞龙夺凤",
  [":shzj__dragon_phoenix"] = "装备牌·武器<br/><b>攻击范围</b>：2<br/><b>武器技能</b>：每回合限一次，当你使用【杀】指定一个目标后，你可以"..
  "摸一张牌或令其弃置一张牌。",
  ["shzj__dragon_phoenix_skill_discard"] = "令%dest弃置一张牌",
}

local imperial_sword_skill = fk.CreateTriggerSkill{
  name = "#imperial_sword_skill",
  attached_equip = "imperial_sword",
  events = {fk.BeforeCardsMove, fk.TargetSpecified},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      if event == fk.BeforeCardsMove then
        for _, move in ipairs(data) do
          if move.from == player.id and move.moveReason == fk.ReasonDiscard then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.PlayerEquip and Fk:getCardById(info.cardId).name == "imperial_sword" then
                return true
              end
            end
          end
        end
      elseif event == fk.TargetSpecified then
        return target ~= player and target.kingdom == player.kingdom and data.card.trueName == "slash" and data.firstTarget and
          not (player:isKongcheng() and target:isKongcheng())
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    if event == fk.BeforeCardsMove then
      return true
    elseif event == fk.TargetSpecified then
      local room = player.room
      if player:isKongcheng() then
        if room:askForSkillInvoke(player, self.name, nil, "#imperial_sword_skill-prey::"..target.id) then
          self.cost_data = {}
          return true
        end
      elseif target:isKongcheng() then
        local card = room:askForCard(player, 1, 1, false, self.name, true, nil, "#imperial_sword_skill-give::"..target.id)
        if #card > 0 then
          self.cost_data = card
          return true
        end
      else
        local extra_data = {
          num = 1,
          min_num = 0,
          include_equip = false,
          skillName = self.name,
          pattern = ".",
        }
        local success, dat = player.room:askForUseActiveSkill(player, "choose_cards_skill",
          "#imperial_sword_skill-invoke::"..target.id, true, extra_data)
        if success then
          self.cost_data = dat.cards or {}
          return true
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    if event == fk.BeforeCardsMove then
      for _, move in ipairs(data) do
        if move.from == player.id and move.moveReason == fk.ReasonDiscard then
          local move_info = {}
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea ~= Card.PlayerEquip or Fk:getCardById(info.cardId).name ~= "imperial_sword" then
              table.insert(move_info, info)
            end
          end
          move.moveInfo = move_info
        end
      end
    elseif event == fk.TargetSpecified then
      local room = player.room
      if #self.cost_data == 0 then
        room:doIndicate(player.id, {target.id})
        local card = room:askForCardChosen(player, target, "h", self.name, "#imperial_sword-prey::"..target.id)
        room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonPrey, self.name, nil, false, player.id)
      else
        room:moveCardTo(self.cost_data, Card.PlayerHand, target, fk.ReasonGive, self.name, nil, false, player.id)
      end
    end
  end,
}
Fk:addSkill(imperial_sword_skill)
local imperial_sword = fk.CreateWeapon{
  name = "&imperial_sword",
  suit = Card.Spade,
  number = 5,
  attack_range = 2,
  equip_skill = imperial_sword_skill,
}
extension:addCard(imperial_sword)
Fk:loadTranslationTable{
  ["imperial_sword"] = "尚方宝剑",
  ["#imperial_sword_skill"] = "尚方宝剑",
  [":imperial_sword"] = "装备牌·武器<br/><b>攻击范围</b>：2<br/><b>武器技能</b>：当装备区内的此牌被弃置时，防止之。与你势力相同的角色使用"..
  "【杀】指定目标后，你可以交给其一张手牌或获得其一张手牌。",
  ["#imperial_sword_skill-prey"] = "尚方宝剑：是否获得 %dest 一张手牌？",
  ["#imperial_sword_skill-give"] = "尚方宝剑：是否交给 %dest 一张手牌？",
  ["#imperial_sword_skill-invoke"] = "尚方宝剑：交给 %dest 一张手牌，或点“确定”获得 %dest 一张手牌",
  ["#imperial_sword-prey"] = "尚方宝剑：获得 %dest 一张手牌",
}

local ironBudSkill = fk.CreateTriggerSkill{
  name = "#iron_bud_skill",
  attached_equip = "iron_bud",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Start and player.hp ~= 2
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#iron_bud_skill-invoke:::"..player.hp)
  end,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "iron_bud-turn", player.hp)
  end,
}
Fk:addSkill(ironBudSkill)
local ironBud = fk.CreateWeapon{
  name = "&iron_bud",
  suit = Card.Spade,
  number = 5,
  dynamic_attack_range = function(self, player)
    if player then
      local mark = player:getMark("iron_bud-turn")
      return mark > 0 and mark or 2
    end
    return 2
  end,
  equip_skill = ironBudSkill,
  on_uninstall = function(self, room, player)
    Weapon.onUninstall(self, room, player)
    room:setPlayerMark(player, "iron_bud-turn", 0)
  end,
}
extension:addCard(ironBud)
Fk:loadTranslationTable{
  ["iron_bud"] = "铁蒺藜骨朵",
  ["#iron_bud_skill"] = "铁蒺藜骨朵",
  [":iron_bud"] = "装备牌·武器<br/><b>攻击范围</b>：2<br/><b>武器技能</b>：准备阶段，你可以将此牌的攻击范围改为X直到回合结束或此牌离开装备区"..
  "（X为你的体力值）。",
  ["#iron_bud_skill-invoke"] = "是否将【铁蒺藜骨朵】本回合的攻击范围改为%arg？",
}

local shzj__burning_camps_skill = fk.CreateActiveSkill{
  name = "shzj__burning_camps_skill",
  prompt = "#shzj__burning_camps_skill",
  can_use = Util.CanUse,
  target_num = 1,
  mod_target_filter = function(_, to_select, _, _, _, _)
    return not Fk:currentRoom():getPlayerById(to_select):isNude()
  end,
  target_filter = Util.TargetFilter,
  on_action = function(self, room, use, finished)
    if finished and use.extra_data and use.extra_data.shzj__burning_camps then
      local from = room:getPlayerById(use.from)
      if not from.dead and room:getCardArea(use.card) == Card.Processing then
        room:moveCardTo(use.card, Card.PlayerHand, from, fk.ReasonJustMove, self.name, nil, true, from.id)
      end
    end
  end,
  on_effect = function(self, room, effect)
    local from = room:getPlayerById(effect.from)
    local to = room:getPlayerById(effect.to)
    if to:isNude() then return end

    local id = room:askForCardChosen(from, to, "he", self.name, "#shzj__burning_camps-show::"..to.id)
    to:showCards(id)

    local card = Fk:getCardById(id)
    local cards = room:askForDiscard(from, 1, 1, false, self.name, true,
      ".|.|" .. card:getSuitString(), "#shzj__burning_camps-discard:"..to.id.."::"..card:getSuitString())
    if #cards > 0 then
      if table.contains(to:getCardIds("he"), id) then
        room:throwCard(id, self.name, to, from)
      end
      if not to.dead then
        if to.chained then
          local use_event = room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
          if use_event ~= nil then
            local use = use_event.data[1]
            if use.card == effect.card then
              use.extra_data = use.extra_data or {}
              use.extra_data.shzj__burning_camps = true
            end
          end
        end
        room:damage({
          from = from,
          to = to,
          card = effect.card,
          damage = 1,
          damageType = fk.FireDamage,
          skillName = self.name,
        })
      end
    end
  end,
}
local shzj__burning_camps = fk.CreateTrickCard{
  name = "&shzj__burning_camps",
  skill = shzj__burning_camps_skill,
  is_damage_card = true,
}
extension:addCards{
  shzj__burning_camps:clone(Card.Heart, 3),
}
Fk:loadTranslationTable{
  ["shzj__burning_camps"] = "火烧连营",
  ["shzj__burning_camps_skill"] = "火烧连营",
  [":shzj__burning_camps"] = "锦囊牌<br/><b>时机</b>：出牌阶段<br/><b>目标</b>：一名有牌的角色<br/><b>效果</b>：你展示目标角色的一张牌，"..
  "然后你可以弃置一张与展示牌花色相同的手牌，若如此做，你弃置展示的牌并对其造成1点火焰伤害。若其受到伤害前处于横置状态，此牌结算后，你获得"..
  "此【火烧连营】。",
  ["#shzj__burning_camps-discard"] = "你可弃置一张 %arg 手牌，对 %src 造成1点火属性伤害",
  ["#shzj__burning_camps_skill"] = "选择一名有牌的角色，展示其一张牌，<br/>然后你可以弃置一张花色相同的手牌对其造成1点火焰伤害并弃置其展示牌",
  ["#shzj__burning_camps-show"] = "火烧连营：展示 %dest 一张牌",
}

local PopulaceSkill = fk.CreateTriggerSkill{
  name = "#populace_skill",
  attached_equip = "weapon1__populace",
  frequency = Skill.Compulsory,
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    if target == player then
      for _, id in ipairs(player:getCardIds("e")) do
        if Fk:getCardById(id).trueName == "populace" then
          return true
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, id in ipairs(player:getCardIds("e")) do
      if player.dead then return end
      local equip = Fk:getCardById(id)
      if equip.trueName == "populace" then
        if equip.name:startsWith("armor") then
          player:drawCards(2, self.name)
        elseif equip.name:startsWith("defensive_horse") then
          room:addPlayerMark(player, MarkEnum.AddMaxCards, 1)
        elseif equip.name:startsWith("offensive_horse") then
          room:addPlayerMark(player, "@populace_distance", 1)
        end
      end
    end
  end,
}
local populace_targetmod = fk.CreateTargetModSkill{
  name = "#populace_targetmod",
  frequency = Skill.Compulsory,
  bypass_distances = function (self, player, skill, card, to)
    if skill.trueName == "slash_skill" then
      for _, id in ipairs(player:getCardIds("e")) do
        local equip = Fk:getCardById(id)
        if equip.trueName == "populace" then
          if equip.name:startsWith("weapon") then
            return true
          end
        end
      end
    end
  end,
  residue_func = function (self, player, skill, scope, card, to)
    if skill.trueName == "slash_skill" then
      local n = 0
      for _, id in ipairs(player:getCardIds("e")) do
        local equip = Fk:getCardById(id)
        if equip.trueName == "populace" then
          if equip.name:startsWith("weapon") then
            n = n + 1
          end
        end
      end
      return n
    end
  end,
}
local populace_distance = fk.CreateDistanceSkill{
  name = "#populace_distance",
  frequency = Skill.Compulsory,
  correct_func = function(self, from, to)
    return to:getMark("@populace_distance") - from:getMark("@populace_distance")
  end,
}
PopulaceSkill:addRelatedSkill(populace_targetmod)
PopulaceSkill:addRelatedSkill(populace_distance)
Fk:addSkill(PopulaceSkill)

local WeaponPopulace = fk.CreateWeapon{
  name = "&weapon1__populace",
  suit = Card.Heart,
  number = 1,
  dynamic_equip_skills = function (self, player)
    if player then
      return {Fk.skills["#populace_skill"]}
    end
  end,
}
local ArmorPopulace = fk.CreateWeapon{
  name = "&armor1__populace",
  suit = Card.Diamond,
  number = 1,
  dynamic_equip_skills = function (self, player)
    if player then
      return {Fk.skills["#populace_skill"]}
    end
  end,
}
local DefensiveHorsePopulace = fk.CreateWeapon{
  name = "&defensive_horse1__populace",
  suit = Card.Club,
  number = 1,
  dynamic_equip_skills = function (self, player)
    if player then
      return {Fk.skills["#populace_skill"]}
    end
  end,
}
local OffensiveHorsePopulace = fk.CreateWeapon{
  name = "&offensive_horse1__populace",
  suit = Card.Spade,
  number = 1,
  dynamic_equip_skills = function (self, player)
    if player then
      return {Fk.skills["#populace_skill"]}
    end
  end,
}
extension:addCard(WeaponPopulace)
extension:addCard(ArmorPopulace)
extension:addCard(DefensiveHorsePopulace)
extension:addCard(OffensiveHorsePopulace)
for _, sub_type in ipairs({"weapon", "armor", "defensive_horse", "offensive_horse"}) do
  local APopulace = fk.CreateArmor{
    name = "&"..sub_type.."2__populace",
    number = 1,
    dynamic_equip_skills = function (self, player)
      if player then
        return {Fk.skills["#populace_skill"]}
      end
    end,
  }
  local DPopulace = fk.CreateDefensiveRide{
    name = "&"..sub_type.."3__populace",
    number = 1,
    dynamic_equip_skills = function (self, player)
      if player then
        return {Fk.skills["#populace_skill"]}
      end
    end,
  }
  local OPopulace = fk.CreateOffensiveRide{
    name = "&"..sub_type.."4__populace",
    number = 1,
    dynamic_equip_skills = function (self, player)
      if player then
        return {Fk.skills["#populace_skill"]}
      end
    end,
  }
  APopulace.package = extension
  DPopulace.package = extension
  OPopulace.package = extension
  Fk:addCard(APopulace)
  Fk:addCard(DPopulace)
  Fk:addCard(OPopulace)
end
Fk:loadTranslationTable{
  ["populace"] = "众",
  ["#populace_skill"] = "众",
  ["@populace_distance"] = "距离±",
}
for i = 1, 4, 1 do
  Fk:loadTranslationTable{
    ["weapon"..i.."__populace"] = "众",
    [":weapon"..i.."__populace"] = "装备牌·武器/防具/坐骑<br/><b>装备技能</b>：锁定技，你出牌阶段使用【杀】次数上限+1，使用【杀】无距离限制。",
    ["armor"..i.."__populace"] = "众",
    [":armor"..i.."__populace"] = "装备牌·武器/防具/坐骑<br/><b>装备技能</b>：锁定技，当你受到伤害后，你摸两张牌。",
    ["defensive_horse"..i.."__populace"] = "众",
    [":defensive_horse"..i.."__populace"] = "装备牌·武器/防具/坐骑<br/><b>装备技能</b>：锁定技，当你受到伤害后，你的手牌上限+1。",
    ["offensive_horse"..i.."__populace"] = "众",
    [":offensive_horse"..i.."__populace"] = "装备牌·武器/防具/坐骑<br/><b>装备技能</b>：锁定技，当你受到伤害后，其他角色计算与你距离+1，"..
    "你计算与其他角色距离-1。",
  }
end

return extension
