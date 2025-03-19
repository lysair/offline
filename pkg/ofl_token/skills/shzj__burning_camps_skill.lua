local shzj__burning_camps_skill = fk.CreateSkill {
  name = "shzj__burning_camps_skill"
}

Fk:loadTranslationTable{
  ['shzj__burning_camps_skill'] = '火烧连营',
  ['#shzj__burning_camps_skill'] = '选择一名有牌的角色，展示其一张牌，<br/>然后你可以弃置一张花色相同的手牌对其造成1点火焰伤害并弃置其展示牌',
  ['#shzj__burning_camps-show'] = '火烧连营：展示 %dest 一张牌',
  ['#shzj__burning_camps-discard'] = '你可弃置一张 %arg 手牌，对 %src 造成1点火属性伤害',
}

shzj__burning_camps_skill:addEffect('active', {
  name = "shzj__burning_camps_skill",
  prompt = "#shzj__burning_camps_skill",
  can_use = Util.CanUse,
  target_num = 1,
  mod_target_filter = function(self, to_select, _, player)
    return not Fk:currentRoom():getPlayerById(to_select):isNude()
  end,
  target_filter = Util.TargetFilter,
  on_action = function(self, room, use, finished)
    if finished and use.extra_data and use.extra_data.shzj__burning_camps then
      local from = room:getPlayerById(use.from)
      if not from.dead and room:getCardArea(use.card) == Card.Processing then
        room:moveCardTo(use.card, Card.PlayerHand, from, fk.ReasonJustMove, shzj__burning_camps_skill.name, nil, true, from.id)
      end
    end
  end,
  on_effect = function(self, room, effect, event)
    local from = room:getPlayerById(effect.from)
    local to = room:getPlayerById(effect.to)
    if to:isNude() then return end

    local id = room:askToChooseCard(from, {
      target = to,
      flag = "he",
      skill_name = shzj__burning_camps_skill.name,
      prompt = "#shzj__burning_camps-show::" .. to.id
    })
    to:showCards(id)

    local card = Fk:getCardById(id)
    local cards = room:askToDiscard(from, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = shzj__burning_camps_skill.name,
      cancelable = true,
      pattern = ".|.|" .. card:getSuitString(),
      prompt = "#shzj__burning_camps-discard:" .. to.id .. "::" .. card:getSuitString()
    })
    if #cards > 0 then
      if table.contains(to:getCardIds("he"), id) then
        room:throwCard(id, shzj__burning_camps_skill.name, to, from)
      end
      if not to.dead then
        if to.chained then
          local use_event = room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
          if use_event ~= nil then
            local use = use_event.data[1]
            event:setCostData(self, true)
            use.extra_data = use.extra_data or {}
            use.extra_data.shzj__burning_camps = event:getCostData(self)
          end
        end
        room:damage({
          from = from,
          to = to,
          card = effect.card,
          damage = 1,
          damageType = fk.FireDamage,
          skillName = shzj__burning_camps_skill.name,
        })
      end
    end
  end,
})

return shzj__burning_camps_skill
