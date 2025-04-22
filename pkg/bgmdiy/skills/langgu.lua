local langgu = fk.CreateSkill {
  name = "langgu",
}

Fk:loadTranslationTable{
  ["langgu"] = "狼顾",
  [":langgu"] = "当你受到1点伤害后，你可以进行判定且你可以打出一张手牌代替此判定牌，然后你观看伤害来源的所有手牌，你可以弃置其中任意张"..
  "与判定结果花色相同的牌。 ",

  ["#langgu-ask"] = "狼顾：你可以打出一张手牌代替判定牌%arg",
  ["#langgu-discard"] = "狼顾：选择要弃置的牌",
}

Fk:addPoxiMethod{
  name = "langgu",
  prompt = "#langgu-discard",
  card_filter = function(to_select, selected, data, extra_data)
    return Fk:getCardById(to_select).suit == extra_data.suit
  end,
  feasible = Util.TrueFunc,
}

langgu:addEffect(fk.Damaged, {
  anim_type = "masochism",
  trigger_times = function(self, event, target, player, data)
    return data.damage
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local judge = {
      who = player,
      reason = langgu.name,
      pattern = ".|.|^nosuit",
    }
    room:judge(judge)
    if player.dead or not data.from or data.from:isKongcheng() or data.from.dead then return end
    room:doIndicate(player, {data.from})
    if data.from == player then
      room:askToDiscard(player, {
        min_num = 1,
        max_num = 1,
        include_equip = false,
        skill_name = langgu.name,
        cancelable = true,
        pattern = ".|.|"..data.card:getSuitString(),
        prompt = "#langgu-discard",
      })
    else
      local result = room:askToPoxi(player, {
        poxi_type = langgu.name,
        data = { { data.from.general, data.from:getCardIds("h") } },
        extra_data = {
          suit = judge.card.suit,
        },
        cancelable = true,
      })
      if #result > 0 then
        room:throwCard(result, langgu.name, data.from, player)
      end
    end
  end,
})

langgu:addEffect(fk.AskForRetrial, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return data.reason == langgu.name and player == data.who and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local ids = table.filter(player:getCardIds("h"), function (id)
      return not player:prohibitResponse(Fk:getCardById(id))
    end)
    local cards = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      skill_name = langgu.name,
      pattern = tostring(Exppattern{ id = ids }),
      prompt = "#langgu-ask:::" .. data.card:toLogString(),
      cancelable = true,
    })
    if #cards > 0 then
      event:setCostData(self, {cards = cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:changeJudge{
      card = Fk:getCardById(event:getCostData(self).cards[1]),
      player = player,
      data = data,
      skillName = langgu.name,
      response = true,
    }
  end,
})

return langgu
