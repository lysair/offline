local ofl_shiji__zuici = fk.CreateSkill {
  name = "ofl_shiji__zuici"
}

Fk:loadTranslationTable{
  ['ofl_shiji__zuici'] = '罪辞',
  ['ofl_shiji__dingyi'] = '定仪',
  ['#ofl_shiji__zuici-choose'] = '罪辞：你可以获得一名角色的“定仪”牌，然后从额外牌堆选择一张智囊牌令其获得',
  ['@$fhyx_extra_pile'] = '额外牌堆',
  ['#ofl_shiji__zuici-give'] = '罪辞：选择一张智囊牌令 %dest 获得',
  [':ofl_shiji__zuici'] = '当你受到伤害后，你可以获得一名角色的“定仪”牌，然后你从额外牌堆选择一张智囊牌令其获得。',
  ['$ofl_shiji__zuici1'] = '无争权柄之事，只望臣宰一心。',
  ['$ofl_shiji__zuici2'] = '折堕己名而得朝臣向主，邵无怨也。',
}

ofl_shiji__zuici:addEffect(fk.Damaged, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(ofl_shiji__zuici) and
      table.find(player.room.alive_players, function(p)
        return #p:getPile("ofl_shiji__dingyi") > 0
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local targets = table.map(table.filter(player.room.alive_players, function(p)
      return #p:getPile("ofl_shiji__dingyi") > 0
    end), Util.IdMapper)
    local to = player.room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#ofl_shiji__zuici-choose",
      skill_name = ofl_shiji__zuici.name
    })
    if #to > 0 then
      event:setCostData(skill, to[1].id)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(event:getCostData(skill))
    room:moveCardTo(to:getPile("ofl_shiji__dingyi"), Card.PlayerHand, player, fk.ReasonJustMove, ofl_shiji__zuici.name, "", true, player.id)
    if player.dead or to.dead then return end
    local cards = table.filter(player.room:getBanner("@$fhyx_extra_pile"), function(id)
      return table.contains({"ex_nihilo", "dismantlement", "nullification"}, Fk:getCardById(id).name)
    end)
    if #cards == 0 then return end
    local card = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      pattern = ".|.|.|.|.|." .. table.concat(cards, ","),
      prompt = "#ofl_shiji__zuici-give::" .. to.id,
      expand_pile = cards
    })
    room:moveCardTo(card[1], Card.PlayerHand, to, fk.ReasonJustMove, ofl_shiji__zuici.name, nil, true, player.id)
  end,
})

ofl_shiji__zuici:addEffect(fk.AfterCardsMove, {
  can_refresh = function(self, event, target, player, data)
    if player.seat == 1 then
      for _, move in ipairs(data) do
        for _, info in ipairs(move.moveInfo) do
          if player.room:getBanner("fhyx_extra_pile") and
            table.contains(player.room:getBanner("fhyx_extra_pile"), info.cardId) then
            return true
          end
        end
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    SetFhyxExtraPileBanner(player.room)
  end,
})

ofl_shiji__zuici:addEffect(fk.OnAcquireSkill, {
  on_acquire = function (self, player, is_start)
    PrepareExtraPile(player.room)
  end
})

return ofl_shiji__zuici
