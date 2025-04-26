local skill = fk.CreateSkill {
  name = "shzj__burning_camps_skill",
}

Fk:loadTranslationTable{
  ["#shzj__burning_camps-show"] = "火烧连营：展示 %dest 一张牌",
  ["#shzj__burning_camps-discard"] = "你可以弃置一张%arg手牌，对 %src 造成1点火属性伤害",
}

skill:addEffect("cardskill", {
  prompt = "#shzj__burning_camps_skill",
  target_num = 1,
  mod_target_filter = function(self, _, to_select, _, _, _)
    return not to_select:isNude()
  end,
  target_filter = Util.CardTargetFilter,
  on_action = function(self, room, use, finished)
    if finished and use.extra_data and use.extra_data.shzj__burning_camps then
      local from = use.from
      if not from.dead and room:getCardArea(use.card) == Card.Processing then
        room:moveCardTo(use.card, Card.PlayerHand, from, fk.ReasonJustMove, skill.name, nil, true, from)
      end
    end
  end,
  on_effect = function(self, room, effect)
    local from = effect.from
    local to = effect.to
    if to:isNude() then return end

    local id = room:askToChooseCard(from, {
      target = to,
      flag = "he",
      skill_name = skill.name,
      prompt = "#shzj__burning_camps-show::" .. to.id,
    })
    to:showCards(id)

    local card = Fk:getCardById(id)
    local cards = room:askToDiscard(from, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = skill.name,
      cancelable = true,
      pattern = ".|.|" .. card:getSuitString(),
      prompt = "#shzj__burning_camps-discard:" .. to.id .. "::" .. card:getSuitString(true),
    })
    if #cards > 0 then
      if table.contains(to:getCardIds("he"), id) then
        room:throwCard(id, skill.name, to, from)
      end
      if not to.dead then
        if to.chained then
          local use_event = room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
          if use_event ~= nil then
            local use = use_event.data
            use.extra_data = use.extra_data or {}
            use.extra_data.shzj__burning_camps = true
          end
        end
        room:damage{
          from = from,
          to = to,
          card = effect.card,
          damage = 1,
          damageType = fk.FireDamage,
          skillName = skill.name,
        }
      end
    end
  end,
})

return skill
