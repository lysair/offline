local junweic = fk.CreateSkill {
  name = "junweic",
}

Fk:loadTranslationTable{
  ["junweic"] = "君威",
  [":junweic"] = "每回合限一次，你可以将两张相同颜色的牌当【无懈可击】使用，此【无懈可击】生效后，你可以为目标普通锦囊牌额外指定至多两个目标。",

  ["#junweic"] = "君威：将两张相同颜色的牌当【无懈可击】使用，若抵消普通锦囊则可为之增加两个目标",
  ["#junweic-choose"] = "君威：你可以为此%arg额外指定至多两个目标",
}

junweic:addEffect("viewas", {
  anim_type = "control",
  pattern = "nullification",
  prompt = "#junweic",
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    return #selected < 2 and
      table.every(selected, function(id)
        return Fk:getCardById(to_select):compareColorWith(Fk:getCardById(id))
      end)
  end,
  view_as = function(self, player, cards)
    if #cards ~= 2 then return end
    local card = Fk:cloneCard("nullification")
    card.skillName = junweic.name
    card:addSubcards(cards)
    return card
  end,
  enabled_at_response = function (self, player, response)
    return not response and player:usedSkillTimes(junweic.name, Player.HistoryTurn) == 0
  end,
})

junweic:addEffect(fk.CardEffectFinished, {
  anim_type = "control",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if data.from == player and table.contains(data.card.skillNames, junweic.name) and
      not data.isCancellOut and not data.nullified and
      data.responseToEvent and data.responseToEvent.isCancellOut and data.toCard and data.toCard:isCommonTrick() then
      local e = player.room.logic:getCurrentEvent().parent
      while e do
        if e.event == GameEvent.UseCard then
          local use = e.data
          if use.card == data.toCard and #use:getExtraTargets() > 0 then
            event:setCostData(self, {extra_data = e})
            return true
          end
        end
        e = e.parent
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local use = event:getCostData(self).extra_data.data
    local tos = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 2,
      targets = use:getExtraTargets(),
      skill_name = junweic.name,
      prompt = "#junweic-choose:::"..use.card:toLogString(),
      cancelable = true,
    })
    if #tos > 0 then
      room:sortByAction(tos)
      event:setCostData(self, {tos = tos, extra_data = use})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local tos = event:getCostData(self).tos
    local use = event:getCostData(self).extra_data
    use.tos = tos
    player.room:doCardUseEffect(use)
  end,
})

junweic:addAI(nil, "vs_skill")

return junweic
