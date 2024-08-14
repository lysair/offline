local extension = Package:new("ofl_token", Package.CardPack)
extension.extensionName = "offline"

Fk:loadTranslationTable{
  ["ofl_token"] = "线下衍生牌",
}

local U = require "packages/utility/utility"

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
          if #U.getActualDamageEvents(room, 1, function(e)
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
          local to = room:askForChoosePlayers(p, table.map(room:getOtherPlayers(player), Util.IdMapper), 1, 1,
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


local shzj__burning_camps_skill = fk.CreateActiveSkill{
  name = "shzj__burning_camps_skill",
  prompt = "#shzj__burning_camps_skill",
  target_num = 1,
  mod_target_filter = function(_, to_select, _, _, _, _)
    return not Fk:currentRoom():getPlayerById(to_select):isNude()
  end,
  target_filter = function(self, to_select, selected, _, card)
    if #selected < self:getMaxTargetNum(Self, card) then
      return self:modTargetFilter(to_select, selected, Self.id, card)
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
      if table.contains(to:getCardIds("h"), id) then
        room:throwCard(id, self.name, to, from)
      end
      if not to.dead then
        room:damage({
          from = from,
          to = to,
          card = effect.card,
          damage = 1,
          damageType = fk.FireDamage,
          skillName = self.name,
        })
      end
      if to.chained and not to.dead and not from.dead and room:getCardArea(id) == Card.DiscardPile then
        room:moveCardTo(id, Card.PlayerHand, from, fk.ReasonJustMove, self.name, nil, true, from.id)
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
  "然后你可以弃置一张与展示牌花色相同的手牌，若如此做，你弃置展示的牌并对其造成1点火焰伤害，然后若其处于横置状态，你获得弃牌堆中其展示的牌。",
  ["#shzj__burning_camps-discard"] = "你可弃置一张 %arg 手牌，对 %src 造成1点火属性伤害",
  ["#shzj__burning_camps_skill"] = "选择一名有牌的角色，展示其一张牌，<br/>然后你可以弃置一张花色相同的手牌对其造成1点火焰伤害并弃置其展示牌",
  ["#shzj__burning_camps-show"] = "火烧连营：展示 %dest 一张牌",
}

return extension
