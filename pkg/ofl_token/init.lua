-- SPDX-License-Identifier: GPL-3.0-or-later

local extension = Package:new("ofl_token", Package.CardPack)
extension.extensionName = "offline"

extension:loadSkillSkelsByPath("./packages/offline/pkg/ofl_token/skills")

Fk:loadTranslationTable{
  ["ofl_token"] = "线下衍生牌",
}

local jingxiang_golden_age = fk.CreateCard{
  name = "&jingxiang_golden_age",
  type = Card.TypeTrick,
  skill = "jingxiang_golden_age_skill",
  multiple_targets = true,
}
extension:addCardSpec("jingxiang_golden_age", Card.Heart, 5)
Fk:loadTranslationTable{
  ["jingxiang_golden_age"] = "荆襄盛世",
  [":jingxiang_golden_age"] = "锦囊牌<br/>"..
  "<b>时机</b>：出牌阶段<br/>"..
  "<b>目标</b>：X名其他角色（X为场上势力数）<br/>"..
  "<b>效果</b>：你亮出牌堆顶存活角色张数的牌，目标角色依次获得其中一张牌，你获得其余的牌。",
}

local caning_whip = fk.CreateCard{
  name = "&caning_whip",
  type = Card.TypeEquip,
  sub_type = Card.SubtypeWeapon,
  attack_range = 1,
  equip_skill = "#caning_whip_skill",
  special_skills = {"change_whip_subtype"},
}
extension:addCardSpec("caning_whip", Card.Spade, 9)
Fk:loadTranslationTable{
  ["caning_whip"] = "刑鞭",
  [":caning_whip"] = "装备牌·任一类别<br/>"..
  "<b>装备技能</b>：锁定技，你的装备区内每有一张【刑鞭】，你的攻击范围便+1；<br>出牌阶段开始时，田钏指定除你以外的一名角色，"..
  "本回合结束阶段开始时，若你本回合未对该角色使用过【杀】或未对该角色造成过伤害，你对自己造成1点伤害。",
}

local shzj__dragon_phoenix = fk.CreateCard{
  name = "&shzj__dragon_phoenix",
  type = Card.TypeEquip,
  sub_type = Card.SubtypeWeapon,
  attack_range = 2,
  equip_skill = "#shzj__dragon_phoenix_skill",
  on_uninstall = function(self, room, player)
    Weapon.onUninstall(self, room, player)
    player:setSkillUseHistory("#shzj__dragon_phoenix_skill", 0, Player.HistoryTurn)
  end,
}
extension:addCardSpec("shzj__dragon_phoenix", Card.Spade, 2)
Fk:loadTranslationTable{
  ["shzj__dragon_phoenix"] = "飞龙夺凤",
  [":shzj__dragon_phoenix"] = "装备牌·武器<br/>"..
  "<b>攻击范围</b>：2<br/>"..
  "<b>武器技能</b>：每回合限一次，当你使用【杀】指定一个目标后，你可以摸一张牌或令其弃置一张牌。",
}

local imperial_sword = fk.CreateCard{
  name = "&imperial_sword",
  type = Card.TypeEquip,
  sub_type = Card.SubtypeWeapon,
  attack_range = 2,
  equip_skill = "#imperial_sword_skill",
}
extension:addCardSpec("imperial_sword", Card.Spade, 5)
Fk:loadTranslationTable{
  ["imperial_sword"] = "尚方宝剑",
  [":imperial_sword"] = "装备牌·武器<br/>"..
  "<b>攻击范围</b>：2<br/>"..
  "<b>武器技能</b>：当装备区内的此牌被弃置时，防止之。与你势力相同的角色使用【杀】指定目标后，你可以交给其一张手牌或获得其一张手牌。",
}

local iron_bud = fk.CreateCard{
  name = "&iron_bud",
  type = Card.TypeEquip,
  sub_type = Card.SubtypeWeapon,
  dynamic_attack_range = function(self, player)
    if player then
      local mark = player:getMark("iron_bud-turn")
      return mark > 0 and mark or 2
    end
    return 2
  end,
  equip_skill = "#iron_bud_skill",
  on_uninstall = function(self, room, player)
    Weapon.onUninstall(self, room, player)
    room:setPlayerMark(player, "iron_bud-turn", 0)
  end,
}
extension:addCardSpec("iron_bud", Card.Spade, 5)
Fk:loadTranslationTable{
  ["iron_bud"] = "铁蒺藜骨朵",
  [":iron_bud"] = "装备牌·武器<br/>"..
  "<b>攻击范围</b>：2<br/>"..
  "<b>武器技能</b>：准备阶段，你可以将此牌的攻击范围改为X直到回合结束或此牌离开装备区（X为你的体力值）。",
}

local shzj__burning_camps = fk.CreateCard{
  name = "&shzj__burning_camps",
  type = Card.TypeTrick,
  skill = "shzj__burning_camps_skill",
  is_damage_card = true,
}
extension:addCardSpec("shzj__burning_camps", Card.Heart, 3)
Fk:loadTranslationTable{
  ["shzj__burning_camps"] = "火烧连营",
  [":shzj__burning_camps"] = "锦囊牌<br/>"..
  "<b>时机</b>：出牌阶段<br/>"..
  "<b>目标</b>：一名有牌的角色<br/>"..
  "<b>效果</b>：你展示目标角色的一张牌，然后你可以弃置一张与展示牌花色相同的手牌，若如此做，你弃置展示的牌并对其造成1点火焰伤害。"..
  "若其受到伤害前处于横置状态，此牌结算后，你获得此【火烧连营】。",

  ["shzj__burning_camps_skill"] = "火烧连营",
  ["#shzj__burning_camps_skill"] = "选择一名有牌的角色，展示其一张牌，然后可以弃置一张花色相同的手牌对其造成1点火焰伤害并弃置其展示牌",
}

local populace1 = fk.CreateCard{
  name = "&spade__populace",
  type = Card.TypeEquip,
  sub_type = Card.SubtypeWeapon,
  dynamic_equip_skills = function (self, player)
    if player then
      local skill_name = "#"..self:getSuitString().."__populace_skill"
      if Fk.skills[skill_name] == nil then
        skill_name = "#spade__populace_skill"
      end
      return {Fk.skills[skill_name]}
    end
  end,
}
extension:addCardSpec("spade__populace", Card.Spade, 1)
Fk:loadTranslationTable{
  ["spade__populace"] = "众",
  [":spade__populace"] = "装备牌·武器/防具/坐骑<br/>"..
  "<b>装备技能</b>：锁定技，你造成的雷电伤害+1，你受到的雷电伤害-1。",
}

local populace2 = fk.CreateCard{
  name = "&heart__populace",
  type = Card.TypeEquip,
  sub_type = Card.SubtypeArmor,
  dynamic_equip_skills = function (self, player)
    if player then
      local skill_name = "#"..self:getSuitString().."__populace_skill"
      if Fk.skills[skill_name] == nil then
        skill_name = "#heart__populace_skill"
      end
      return {Fk.skills[skill_name]}
    end
  end,
}
extension:addCardSpec("heart__populace", Card.Heart, 1)
Fk:loadTranslationTable{
  ["heart__populace"] = "众",
  [":heart__populace"] = "装备牌·武器/防具/坐骑<br/>"..
  "<b>装备技能</b>：锁定技，你出牌阶段使用【杀】次数上限+1，你使用【杀】无距离限制。",
}

local populace3 = fk.CreateCard{
  name = "&club__populace",
  type = Card.TypeEquip,
  sub_type = Card.SubtypeDefensiveRide,
  dynamic_equip_skills = function (self, player)
    if player then
      local skill_name = "#"..self:getSuitString().."__populace_skill"
      if Fk.skills[skill_name] == nil then
        skill_name = "#club__populace_skill"
      end
      return {Fk.skills[skill_name]}
    end
  end,
}
extension:addCardSpec("club__populace", Card.Club, 1)
Fk:loadTranslationTable{
  ["club__populace"] = "众",
  [":club__populace"] = "装备牌·武器/防具/坐骑<br/>"..
  "<b>装备技能</b>：锁定技，摸牌阶段，你额外摸一张牌；你的手牌上限+1。",
}

local populace4 = fk.CreateCard{
  name = "&diamond__populace",
  type = Card.TypeEquip,
  sub_type = Card.SubtypeOffensiveRide,
  dynamic_equip_skills = function (self, player)
    if player then
      local skill_name = "#"..self:getSuitString().."__populace_skill"
      if Fk.skills[skill_name] == nil then
        skill_name = "#diamond__populace_skill"
      end
      return {Fk.skills[skill_name]}
    end
  end,
}
extension:addCardSpec("diamond__populace", Card.Diamond, 1)
Fk:loadTranslationTable{
  ["diamond__populace"] = "众",
  [":diamond__populace"] = "装备牌·武器/防具/坐骑<br/>"..
  "<b>装备技能</b>：锁定技，当你受到伤害后，你摸两张牌。",
}

local chunqiu_brush = fk.CreateCard{
  name = "&chunqiu_brush",
  type = Card.TypeEquip,
  sub_type = Card.SubtypeTreasure,
  equip_skill = "chunqiu_brush_skill&",
  on_uninstall = function(self, room, player)
    Treasure.onUninstall(self, room, player)
    player:setSkillUseHistory("chunqiu_brush_skill&", 0, Player.HistoryPhase)
  end,
}
extension:addCardSpec("chunqiu_brush", Card.Heart, 5)
Fk:loadTranslationTable{
  ["chunqiu_brush"] = "春秋笔",
  [":chunqiu_brush"] = "装备牌·宝物<br/>"..
  "<b>宝物技能</b>：出牌阶段限一次，你可以随机选择一项，然后你选择一名角色，其从此项开始正序或逆序执行以下效果：<br>"..
  "起：失去1点体力；<br>承：摸已损失体力值张牌；<br>转：回复1点体力；<br>合：弃置已损失体力值张手牌。<br>"..
  "此牌离开你的装备区后销毁。",
}

extension:loadCardSkels {
  jingxiang_golden_age,

  caning_whip,

  shzj__dragon_phoenix,
  imperial_sword,
  iron_bud,
  shzj__burning_camps,

  populace1,
  populace2,
  populace3,
  populace4,

  chunqiu_brush,
}

return extension
