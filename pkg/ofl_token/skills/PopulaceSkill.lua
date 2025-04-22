local populaceSkill = fk.CreateSkill {
  name = "#populace_skill"
}

Fk:loadTranslationTable{
  ['#populace_skill'] = '众',
  ['populace'] = '众',
  ['@populace_distance'] = '距离±',
}

populaceSkill:addEffect(fk.Damaged, {
  attached_equip = "weapon1__populace",
  frequency = Skill.Compulsory,
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
          player:drawCards(2, populaceSkill.name)
        elseif equip.name:startsWith("defensive_horse") then
          room:addPlayerMark(player, MarkEnum.AddMaxCards, 1)
        elseif equip.name:startsWith("offensive_horse") then
          room:addPlayerMark(player, "@populace_distance", 1)
        end
      end
    end
  end,
})

populaceSkill:addEffect('targetmod', {
  frequency = Skill.Compulsory,
  bypass_distances = function(self, player, skill, card, to)
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
  residue_func = function(self, player, skill, scope, card, to)
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
})

populaceSkill:addEffect('distance', {
  frequency = Skill.Compulsory,
  correct_func = function(self, from, to)
    return to:getMark("@populace_distance") - from:getMark("@populace_distance")
  end,
})

return populaceSkill
