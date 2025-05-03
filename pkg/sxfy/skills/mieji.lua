local mieji = fk.CreateSkill {
  name = "sxfy__mieji",
}

Fk:loadTranslationTable{
  ["sxfy__mieji"] = "灭计",
  [":sxfy__mieji"] = "出牌阶段限一次，你可以交给一名其他角色一张黑色锦囊牌，然后你可以弃置其至多两张牌。",

  ["#sxfy__mieji"] = "灭计：交给一名角色一张黑色锦囊牌，然后你可以弃置其至多两张牌",
  ["#sxfy__mieji-discard"] = "灭计：你可以弃置 %dest 至多两张牌",
}

mieji:addEffect("active", {
  anim_type = "control",
  prompt = "#sxfy__mieji",
  card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(mieji.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, player, to_select, selected)
    local card = Fk:getCardById(to_select)
    return #selected == 0 and card.type == Card.TypeTrick and card.color == Card.Black
  end,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    room:moveCardTo(effect.cards, Card.PlayerHand, target, fk.ReasonGive, mieji.name, nil, true, player)
    if player.dead or target.dead or target:isNude() then return end
    local cards = room:askToChooseCards(player, {
      target = target,
      min = 0,
      max = 2,
      flag = "he",
      skill_name = mieji.name,
      prompt = "#sxfy__mieji-discard::"..target.id,
    })
    if #cards > 0 then
      room:throwCard(cards, mieji.name, target, player)
    end
  end,
})

return mieji
