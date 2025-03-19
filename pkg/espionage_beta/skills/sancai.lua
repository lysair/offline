local sancai = fk.CreateSkill {
  name = "sancai"
}

Fk:loadTranslationTable{
  ['sancai'] = '散财',
  ['#sancai'] = '散财：展示所有手牌，若均为同一类别，你可以将其中一张赠予其他角色',
  ['#sancai-choose'] = '散财：你可以将其中一张牌赠予其他角色',
  [':sancai'] = '出牌阶段限一次，你可以展示所有手牌，若均为同一类别，你可以将其中一张牌赠予其他角色。',
}

sancai:addEffect('active', {
  anim_type = "support",
  card_num = 0,
  target_num = 0,
  prompt = "#sancai",
  can_use = function(self, player)
    return player:usedSkillTimes(sancai.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local cards = player:getCardIds("h")
    player:showCards(cards)
    if table.every(cards, function(id) return Fk:getCardById(id).type == Fk:getCardById(cards[1]).type end) then
      cards = table.filter(cards, function(id) return table.contains(player:getCardIds("h"), id) end)
      if #cards > 0 and #room.alive_players > 1 then
        local to, card = room:askToChooseCardsAndPlayers(player, {
          min_card_num = 1,
          max_card_num = 1,
          targets = table.map(room:getOtherPlayers(player, false), Util.IdMapper),
          pattern = ".|.|.|.|.|.|"..table.concat(cards, ","),
          prompt = "#sancai-choose",
          skill_name = sancai.name,
        })
        if #to > 0 and card then
          U.presentCard(player, room:getPlayerById(to[1]), Fk:getCardById(card))
        end
      end
    end
  end,
})

return sancai
