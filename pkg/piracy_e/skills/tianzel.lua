local tianzel = fk.CreateSkill {
  name = "tianzel",
}

Fk:loadTranslationTable {
  ["tianzel"] = "天择",
  [":tianzel"] = "当你成为【杀】的目标时，你可以弃置两张手牌（不足则全弃，无牌则不弃）并观看牌堆顶四张牌，然后获得其中两张牌。若如此做，"..
  "你令一名体力值最大或手牌数最多的其他角色也如此做。",

  ["#tianzel-invoke"] = "天择：弃置两张手牌（不足则全弃，无牌则不弃），观看牌堆顶四张牌并获得其中两张",
  ["#tianzel-choose"] = "天择：令一名其他角色也如此做",

  ["$tianzel1"] = "朕祈上帝诸神，佑我汉室不衰！",
  ["$tianzel2"] = "朕乃天命所归，逆臣岂敢无礼！",
}

tianzel:addEffect(fk.TargetConfirmed, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(tianzel.name) and data.card.trueName == "slash"
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local ids = table.filter(player:getCardIds("h"), function(id)
      return not player:prohibitDiscard(id)
    end)
    if #ids <= 2 then
      if room:askToSkillInvoke(player, {
        skill_name = tianzel.name,
        prompt = "#tianzel-invoke"
      }) then
        event:setCostData(self, {cards = ids})
        return true
      end
    else
      local cards = room:askToDiscard(player, {
        min_num = 2,
        max_num = 2,
        include_equip = false,
        skill_name = tianzel.name,
        cancelable = true,
        prompt = "#tianzel-invoke",
        skip = true,
      })
      if #cards > 0 then
        event:setCostData(self, {cards = cards})
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if #event:getCostData(self).cards > 0 then
      room:throwCard(event:getCostData(self).cards, tianzel.name, player, player)
    end
    if player.dead then return end
    local cards = room:askToChooseCards(player, {
      target = player,
      min = 2,
      max = 2,
      flag = { card_data = {{ "Top", room:getNCards(4) }} },
      skill_name = tianzel.name,
    })
    room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonJustMove, tianzel.name, nil, false, player)
    if player.dead then return end
    local targets = table.filter(room.alive_players, function (p)
      return table.every(room.alive_players, function (q)
        return p.hp >= q.hp
      end)
    end)
    table.insertTableIfNeed(targets, table.filter(room.alive_players, function (p)
      return table.every(room.alive_players, function (q)
        return p:getHandcardNum() >= q:getHandcardNum()
      end)
    end))
    table.removeOne(targets, player)
    if #targets == 0 then return end
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = tianzel.name,
      prompt = "#tianzel-choose",
      cancelable = false,
    })[1]
    room:askToDiscard(to, {
      min_num = 2,
      max_num = 2,
      include_equip = false,
      skill_name = tianzel.name,
      cancelable = false,
      prompt = "#tianzel-invoke",
    })
    if to.dead then return end
    cards = room:askToChooseCards(to, {
      target = to,
      min = 2,
      max = 2,
      flag = { card_data = {{ "Top", room:getNCards(4) }} },
      skill_name = tianzel.name,
    })
    room:moveCardTo(cards, Card.PlayerHand, to, fk.ReasonJustMove, tianzel.name, nil, false, to)
  end,
})

return tianzel
