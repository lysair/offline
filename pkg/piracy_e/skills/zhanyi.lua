local zhanyi = fk.CreateSkill {
  name = "ofl__zhanyi"
}

Fk:loadTranslationTable{
  ["ofl__zhanyi"] = "战意",
  [":ofl__zhanyi"] = "出牌阶段限一次，你可以失去1点体力并弃置一张基本牌或普通锦囊牌，然后你本回合该类别的牌额外结算一次。",

  ["#ofl__zhanyi"] = "战意：弃置一张牌并失去1点体力，本回合此类别牌额外结算一次",
  ["@ofl__zhanyi-turn"] = "战意",
}

zhanyi:addEffect("active", {
  anim_type = "masochism",
  prompt = "#ofl__zhanyi",
  can_use = function(self, player)
    return player:usedSkillTimes(zhanyi.name, Player.HistoryPhase) == 0
  end,
  card_num = 1,
  target_num = 0,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and not player:prohibitDiscard(to_select) and
      (Fk:getCardById(to_select).type == Card.TypeBasic or Fk:getCardById(to_select):isCommonTrick())
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local type = Fk:getCardById(effect.cards[1]):getTypeString()
    room:throwCard(effect.cards, zhanyi.name, player, player)
    if not player:isAlive() then return end
    room:loseHp(player, 1, zhanyi.name)
    if player.dead then return end
    room:addTableMark(player, "@ofl__zhanyi-turn", type.."_char")
  end,
})

zhanyi:addEffect(fk.CardUsing, {
  anim_type = "offensive",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and table.contains(player:getTableMark("@ofl__zhanyi-turn"), data.card:getTypeString().."_char")
  end,
  on_use = function(self, event, target, player, data)
    data.additionalEffect = (data.additionalEffect or 0) + 1
  end,
})

return zhanyi
