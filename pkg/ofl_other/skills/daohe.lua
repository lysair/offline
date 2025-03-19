local daohe = fk.CreateSkill {
  name = "daohe"
}

Fk:loadTranslationTable{
  ['daohe'] = '道合',
  ['#daohe'] = '道合：令一名其他角色交给你至少一张手牌，然后其回复1点体力',
  ['#daohe_give'] = '道合：交给 %src 任意张手牌，然后你回复1点体力',
  [':daohe'] = '出牌阶段限一次，你可以令一名其他角色交给你至少一张手牌，然后其回复1点体力。',
  ['$daohe1'] = '故旧交集何纷纷？片言道合唯有君。',
  ['$daohe2'] = '一言一笑，拂袖蜀山，吾志与君同。',
}

daohe:addEffect('active', {
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  prompt = "#daohe",
  can_use = function (self, player)
    return player:usedSkillTimes(daohe.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and not Fk:currentRoom():getPlayerById(to_select):isKongcheng() and to_select ~= player.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local cards = room:askToCards(target, {
      min_num = 1,
      max_num = 999,
      include_equip = false,
      pattern = ".|.|.|hand",
      prompt = "#daohe_give:" .. player.id
    })
    if #cards > 0 then
      room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonGive, daohe.name, nil, false, target.id)
      if not target.dead and target:isWounded() then
        room:recover{
          who = target,
          num = 1,
          recoverBy = player,
          skillName = daohe.name
        }
      end
    end
  end,
})

return daohe
