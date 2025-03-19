local tuwei = fk.CreateSkill {
  name = "ofl__tuwei"
}

Fk:loadTranslationTable{
  ['ofl__tuwei'] = '突围',
  ['#ofl__tuwei'] = '突围：将弃牌堆中一张装备置入一名角色装备区，若不为你，你可以令其摸牌或对其造成伤害',
  ['ofl__tuwei_draw'] = '令其摸一张牌',
  ['ofl__tuwei_damage'] = '对其造成1点伤害',
  ['#ofl__tuwei-choice'] = '突围：你可以对 %dest 执行一项',
  [':ofl__tuwei'] = '每名角色限一次，出牌阶段，你可以将弃牌堆中一张装备牌置入一名角色的装备区，若不为你，你可以令其摸一张牌或对其造成1点伤害。',
}

tuwei:addEffect('active', {
  anim_type = "control",
  card_num = 1,
  target_num = 1,
  prompt = "#ofl__tuwei",
  expand_pile = function (self)
    return table.filter(Fk:currentRoom().discard_pile, function (id)
      return Fk:getCardById(id).type == Card.TypeEquip
    end)
  end,
  can_use = function(self, player)
    return table.find(Fk:currentRoom().discard_pile, function (id)
      return Fk:getCardById(id).type == Card.TypeEquip
    end)
  end,
  card_filter = function (self, player, to_select, selected)
    return #selected == 0 and table.contains(Fk:currentRoom().discard_pile, to_select)
  end,
  target_filter = function (self, player, to_select, selected, selected_cards)
    if #selected == 0 and #selected_cards == 1 then
      return Fk:currentRoom():getPlayerById(to_select):hasEmptyEquipSlot(Fk:getCardById(selected_cards[1]).sub_type) and
        not table.contains(Self:getTableMark(tuwei.name), to_select)
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:addTableMark(player, tuwei.name, target.id)
    room:moveCardIntoEquip(target, effect.cards, tuwei.name, false, player.id)
    if player.dead or target.dead or target == player then return end
    local choice = room:askToChoice(player, {
      choices = {"ofl__tuwei_draw", "ofl__tuwei_damage"},
      skill_name = tuwei.name,
      prompt = "#ofl__tuwei-choice::"..target.id
    })
    if choice == "ofl__tuwei_draw" then
      target:drawCards(1, tuwei.name)
    elseif choice == "ofl__tuwei_damage" then
      room:damage{
        from = player,
        to = target,
        damage = 1,
        skillName = tuwei.name,
      }
    end
  end,
})

return tuwei
