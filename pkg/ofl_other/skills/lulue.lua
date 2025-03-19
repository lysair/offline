local lulue = fk.CreateSkill {
  name = "chaos__lulue"
}

Fk:loadTranslationTable{
  ['chaos__lulue'] = '掳掠',
  [':chaos__lulue'] = '出牌阶段限一次，你可选择一名装备区里有牌的其他角色并弃置X张牌（X为其装备区里的牌数），对其造成1点伤害。',
}

lulue:addEffect('active', {
  anim_type = "offensive",
  can_use = function(self, player)
    return player:usedSkillTimes(lulue.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, player, to_select, selected)
    return not player:prohibitDiscard(Fk:getCardById(to_select))
  end,
  target_filter = function(self, player, to_select, selected, cards)
    if #cards == 0 or to_select == player.id then return false end
    local target = Fk:currentRoom():getPlayerById(to_select)
    return #cards == #target:getCardIds(Player.Equip)
  end,
  target_num = 1,
  min_card_num = 1,
  max_card_num = 999,
  on_use = function(self, room, effect)
    local from = room:getPlayerById(effect.from)
    local to = room:getPlayerById(effect.tos[1])
    from:broadcastSkillInvoke("lueming")
    room:throwCard(effect.cards, lulue.name, from, from)
    if not from.dead and not to.dead then
      room:damage{
        from = from,
        to = to,
        damage = 1,
        skillName = lulue.name,
      }
    end
  end,
})

return lulue
