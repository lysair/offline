local xiaolu = fk.CreateSkill {
  name = "ofl__xiaolu&"
}

Fk:loadTranslationTable{
  ['ofl__xiaolu&'] = '宵赂',
  ['#ofl__xiaolu&'] = '宵赂：你可以交给韩悝一张牌，然后视为对另一名角色使用一张普通锦囊牌',
  ['ofl__xiaolu'] = '宵赂',
  ['ofl__xiaolu_viewas'] = '宵赂',
  ['#ofl__xiaolu-use'] = '宵赂：视为对一名角色使用一张锦囊牌',
  [':ofl__xiaolu&'] = '出牌阶段限一次，你可以交给韩悝一张牌，然后视为对另一名角色使用一张仅指定该角色为目标的普通锦囊牌。',
}

xiaolu:addEffect('active', {
  anim_type = "support",
  card_num = 1,
  target_num = 1,
  prompt = "#ofl__xiaolu&",
  can_use = function(self, player)
    return player:usedSkillTimes(xiaolu.name) == 0
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0
  end,
  target_filter = function(self, player, to_select, selected, cards)
    return #selected == 0 and to_select ~= player.id and Fk:currentRoom():getPlayerById(to_select):hasSkill(xiaolu.name)
  end,
  on_use = function(self, room, effect, event)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    target:broadcastSkillInvoke("ofl__xiaolu")
    room:moveCardTo(effect.cards, Card.PlayerHand, target, fk.ReasonGive, xiaolu.name, nil, false, player.id)
    if player.dead then return end
    if not room:getBanner("ofl__xiaolu") then
      room:setBanner("ofl__xiaolu", U.getUniversalCards(room, "t"))
    end
    local success, dat = room:askToUseActiveSkill(player, {
      skill_name = "ofl__xiaolu_viewas",
      prompt = "#ofl__xiaolu-use",
      cancelable = true,
      extra_data = {
        expand_pile = room:getBanner("ofl__xiaolu"),
        exclusive_targets = table.map(room:getOtherPlayers(target), Util.IdMapper)
      },
      no_indicate = false
    })
    if success and dat then
      local card = Fk:cloneCard(Fk:getCardById(dat.cards[1]).name)
      card.skillName = "ofl__xiaolu"
      room:useCard{
        from = player.id,
        tos = table.map(dat.targets, function(id) return {id} end),
        card = card,
      }
    end
  end,
})

return xiaolu
