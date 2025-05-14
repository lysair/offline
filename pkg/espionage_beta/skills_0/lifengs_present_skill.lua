local skel = fk.CreateSkill {
  name = "lifengs_present_skill&"
}

Fk:loadTranslationTable{
  ['lifengs_present_skill&'] = '赠予',
  ['#lifengs_present_skill&'] = '将一张有“赠”标记的牌或一张装备牌赠予其他角色',
  [':lifengs_present_skill&'] = '出牌阶段，你可以将一张有“赠”标记的手牌或一张装备牌正面向上赠予其他角色。若此牌不是装备牌，则进入该角色手牌区；若此牌是装备牌，则进入该角色装备区且替换已有装备。',
}

skel:addEffect('active', {
  name = "lifengs_present_skill&",
  prompt = "#lifengs_present_skill&",
  anim_type = "support",
  card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    return table.find(player:getCardIds("h"), function(id)
      return Fk:getCardById(id):getMark("@@present") > 0
    end) or (player:hasSkill(lifengs) and
      table.find(player:getCardIds("he"), function(id)
        return Fk:getCardById(id).type == Card.TypeEquip
      end))
  end,
  card_filter = function(self, player, to_select, selected)
    if #selected == 0 then
      if Fk:getCardById(to_select):getMark("@@present") > 0 and table.contains(player:getCardIds("h"), to_select) then
        return true
      end
      if player:hasSkill(lifengs) then
        if Fk:getCardById(to_select).type == Card.TypeEquip then
          return true
        end
      end
    end
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select.id ~= player.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    U.presentCard(player, target, Fk:getCardById(effect.cards[1]))
  end,
})

return skel
