local yaozhuo = fk.CreateSkill {
  name = "ofl__yaozhuo"
}

Fk:loadTranslationTable{
  ['ofl__yaozhuo'] = '谣诼',
  ['#ofl__yaozhuo'] = '谣诼：与一名角色拼点，若赢，其本回合手牌上限-2；若没赢，你回复1点体力',
  ['#ofl__yaozhuo_trigger'] = '谣诼',
  [':ofl__yaozhuo'] = '出牌阶段限一次或当你受到伤害后，你可以与一名角色拼点：若你赢，其本回合手牌上限-2；若你没赢，你回复1点体力。当你拼点结算完成后，你获得对方的拼点牌。',
  ['$ofl__yaozhuo1'] = '上蔽天听，下诓朝野！',
  ['$ofl__yaozhuo2'] = '贪财好贿，其罪尚小，不敬不逊，却为大逆！',
}

yaozhuo:addEffect('active', {
  anim_type = "control",
  prompt = "#ofl__yaozhuo",
  card_num = 0,
  target_num = 1,
  can_use = function (self, player)
    return player:getMark("ofl__yaozhuo-phase") == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and player:canPindian(Fk:currentRoom():getPlayerById(to_select))
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:addPlayerMark(player, "ofl__yaozhuo-phase", 1)
    local pindian = player:pindian({target}, yaozhuo.name)
    if pindian.results[target.id].winner == player then
      if not target.dead then
        room:addPlayerMark(target, MarkEnum.MinusMaxCards.."-turn", 2)
      end
    elseif player:isWounded() and not player.dead then
      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = yaozhuo.name,
      }
    end
  end,
})

yaozhuo:addEffect(fk.Damaged, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(yaozhuo) then
      return target == player and
        table.find(player.room:getOtherPlayers(player, false), function (p)
          return player:canPindian(p)
        end) ~= nil
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player, false), function (p)
      return player:canPindian(p)
    end)
    local to = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      skill_name = "ofl__yaozhuo",
      cancelable = true
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("ofl__yaozhuo")
    room:notifySkillInvoked(player, "ofl__yaozhuo", "masochism")
    yaozhuo:onUse(room, {
      from = player.id,
      cards = {},
      tos = event:getCostData(self).tos,
    })
    room:removePlayerMark(player, "ofl__yaozhuo-phase", 1)
  end,
})

yaozhuo:addEffect(fk.PindianFinished, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(yaozhuo) then
      if target == player then
        for _, result in pairs(data.results) do
          if player.room:getCardArea(result.toCard) == Card.Processing then
            return true
          end
        end
      elseif data.results[player.id] then
        return player.room:getCardArea(data.fromCard) == Card.Processing
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    event:setCostData(self, nil)
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, "ofl__yaozhuo", "drawcard")
    if data.from == player then
      local cards = {}
      for _, result in pairs(data.results) do
        if room:getCardArea(result.toCard) == Card.Processing then
          table.insertTableIfNeed(cards, Card:getIdList(result.toCard))
        end
      end
      if #cards > 0 then
        room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonJustMove, "ofl__yaozhuo", nil, true, player.id)
      end
    elseif data.results[player.id] then
      room:moveCardTo(data.fromCard, Card.PlayerHand, player, fk.ReasonJustMove, "ofl__yaozhuo", nil, true, player.id)
    end
  end,
})

return yaozhuo
