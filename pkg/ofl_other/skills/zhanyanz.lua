local zhanyanz = fk.CreateSkill {
  name = "ofl__zhanyanz"
}

Fk:loadTranslationTable{
  ['ofl__zhanyanz'] = '绽焱',
  ['#ofl__zhanyanz'] = '绽焱：令一名角色猜测你的红色手牌数，你将所有红色手牌交给其，并对其造成猜错差值的火焰伤害！',
  ['#ofl__zhanyanz-choice'] = '绽焱：请猜测 %src 的红色手牌数',
  [':ofl__zhanyanz'] = '出牌阶段限一次，你可以令一名其他角色猜测你的红色手牌数，然后你展示手牌并将其中所有红色牌交给其，然后你对其造成X点火焰伤害（X为其猜测数与你的红色手牌数之差，至多为3）。',
}

zhanyanz:addEffect('active', {
  anim_type = "offensive",
  card_num = 0,
  target_num = 1,
  prompt = "#ofl__zhanyanz",
  can_use = function(self, player)
    return player:usedSkillTimes(zhanyanz.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  card_filter = Util.FalseFunc,
  target_filter = function (self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select.id ~= player.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local choices = {}
    for i = 0, player:getHandcardNum(), 1 do
      table.insert(choices, tostring(i))
    end
    local choice = room:askToChoice(target, {
      choices = choices,
      skill_name = zhanyanz.name,
      prompt = "#ofl__zhanyanz-choice:"..player.id
    })
    choice = tonumber(choice)
    local cards = table.filter(player:getCardIds("h"), function (id)
      return Fk:getCardById(id).color == Card.Red
    end)
    player:showCards(player:getCardIds("h"))
    if target.dead then return end
    local ids = table.filter(cards, function (id)
      return table.contains(player:getCardIds("h"), id)
    end)
    if #ids > 0 then
      room:moveCardTo(ids, Card.PlayerHand, target, fk.ReasonGive, zhanyanz.name, nil, true, player.id)
      if target.dead then return end
    end
    local n = math.min(math.abs(choice - #cards), 3)
    if n > 0 then
      room:damage{
        from = player,
        to = target,
        damage = n,
        damageType = fk.FireDamage,
        skillName = zhanyanz.name,
      }
    end
  end,
})

return zhanyanz
