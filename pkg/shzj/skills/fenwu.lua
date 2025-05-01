local fenwu = fk.CreateSkill {
  name = "fenwu",
}

Fk:loadTranslationTable{
  ["fenwu"] = "奋武",
  [":fenwu"] = "准备阶段，你可以摸一张牌并展示之，然后你可以将此牌当【决斗】或牌名字数相同与此牌相同的基本牌使用。",

  ["#fenwu-use"] = "奋武：你可以将%arg当【决斗】或基本牌使用",
}

fenwu:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(fenwu.name) and player.phase == Player.Start
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = player:drawCards(1, fenwu.name)
    if player.dead or #card < 1 then return end
    card = table.filter(card, function (id)
      return table.contains(player:getCardIds("h"), id)
    end)
    if #card == 0 then return end
    player:showCards(card)
    card = table.filter(card, function (id)
      return table.contains(player:getCardIds("h"), id)
    end)
    if player.dead or #card < 1 then return end
    local id = card[1]
    local n = Fk:translate(Fk:getCardById(id).trueName, "zh_CN"):len()
    local names = table.filter(Fk:getAllCardNames("b", false), function (name)
      return Fk:translate(Fk:cloneCard(name).trueName, "zh_CN"):len() == n
    end)
    table.insert(names, "duel")
    room:askToUseVirtualCard(player, {
      name = names,
      skill_name = fenwu.name,
      prompt = "#fenwu-use:::"..Fk:getCardById(id):toLogString(),
      cancelable = true,
      extra_data = {
        bypass_times = true,
        extraUse = true,
      },
      subcards = {id},
    })
  end,
})


return fenwu
