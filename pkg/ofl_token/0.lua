
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
