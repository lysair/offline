local tongkai = fk.CreateSkill {
  name = "tongkai",
}

Fk:loadTranslationTable{
  ["tongkai"] = "同忾",
  [":tongkai"] = "当一名角色成为伤害的目标后，若你与其距离不大于1，你可以摸一张牌，然后交给其一张牌并令其展示之，若为装备牌，其可以使用此牌。",

  ["#tongkai-self"] = "同忾：你可以摸一张牌",
  ["#tongkai-invoke"] = "同忾：你可以摸一张牌，然后交给 %dest 一张牌",
  ["#tongkai-give"] = "同忾：交给 %dest 一张牌，若为装备牌其可以使用",
  ["#tongkai-use"] = "同忾：你可以使用%arg",
}

tongkai:addEffect(fk.TargetConfirmed, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(tongkai.name) and data.card.is_damage_card and player:distanceTo(target) <= 1
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if target == player then
      return room:askToSkillInvoke(player, {
        skill_name = tongkai.name,
        prompt = "#tongkai-self",
      })
    elseif room:askToSkillInvoke(player, {
      skill_name = tongkai.name,
      prompt = "#tongkai-invoke::"..target.id,
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(1, tongkai.name)
    if target == player or player:isNude() or player.dead or target.dead then return end
    local cards = room:askToCards(player, {
      skill_name = tongkai.name,
      min_num = 1,
      max_num = 1,
      include_equip = true,
      prompt = "#tongkai-give::"..target.id,
      cancelable = false,
    })
    room:moveCardTo(cards, Card.PlayerHand, target, fk.ReasonGive, tongkai.name, nil, true, player)
    if not table.contains(target:getCardIds("h"), cards[1]) or target.dead then return end
    target:showCards(cards)
    if not table.contains(target:getCardIds("h"), cards[1]) or target.dead then return end
    local card = Fk:getCardById(cards[1])
    if card.type == Card.TypeEquip and not target:isProhibited(target, card) and not target:prohibitUse(card) and
      room:askToSkillInvoke(target, {
        skill_name = tongkai.name,
        prompt = "#tongkai-use:::"..card:toLogString(),
      }) then
      room:useCard({
        from = target,
        tos = {target},
        card = card,
      })
    end
  end,
})

return tongkai
