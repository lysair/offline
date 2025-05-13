local skill = fk.CreateSkill {
  name = "cure_poison_with_poison_skill",
}

Fk:loadTranslationTable{
  ["#cure_poison_with_poison-discard"] = "弃置其中一张【毒】，双方各摸两张牌",
}

Fk:addPoxiMethod{
  name = "cure_poison_with_poison",
  prompt = "#cure_poison_with_poison-discard",
  card_filter = function(to_select, selected, data, extra_data)
    return not extra_data.cancelable and #selected == 0 and
      Fk:getCardById(to_select).trueName == "poison" and not Self:prohibitDiscard(to_select)
  end,
  feasible = function(selected)
    return #selected == 1
  end,
  default_choice = function (data, extra_data)
    if extra_data.cancelable then
      return {}
    else
      for _, id in ipairs(data[1][2]) do
        if Fk:getCardById(id).trueName == "poison" then
          return { id }
        end
      end
    end
  end,
}

skill:addEffect("cardskill", {
  prompt = "#cure_poison_with_poison_skill",
  target_num = 1,
  mod_target_filter = function(self, _, to_select, _, _, _)
    return to_select:isWounded()
  end,
  target_filter = Util.CardTargetFilter,
  on_effect = function(self, room, effect)
    local player = effect.from
    local target = effect.to
    local yes = table.find(target:getCardIds("h"), function (id)
      return Fk:getCardById(id).trueName == "poison"
    end) and
    table.find(player:getCardIds("h"), function (id)
      return Fk:getCardById(id).trueName == "poison"
    end)
    if not target:isKongcheng() then
      local result = room:askToPoxi(player, {
        poxi_type = "cure_poison_with_poison",
        data = {
          { target.general, target:getCardIds("h") },
          { player.general, player:getCardIds("h") },
        },
        cancelable = not yes,
        extra_data = {
          cancelable = not yes,
        }
      })
      if #result > 0 then
        room:throwCard(result, skill.name, room:getCardOwner(result[1]), player)
      end
      if yes then
        if not player.dead then
          player:drawCards(2, skill.name)
        end
        if not target.dead then
          target:drawCards(2, skill.name)
        end
      end
    end
    if not yes then
      if not player.dead then
        room:damage{
          from = nil,
          to = player,
          damage = 1,
          card = effect.card,
          skillName = skill.name,
        }
      end
      if not target.dead then
        room:damage{
          from = nil,
          to = target,
          damage = 1,
          card = effect.card,
          skillName = skill.name,
        }
      end
    end
  end,
})

return skill
