local shanji = fk.CreateSkill {
  name = "ofl_tx__shanji",
}

Fk:loadTranslationTable{
  ["ofl_tx__shanji"] = "闪击",
  [":ofl_tx__shanji"] = "当你于一回合第二次使用一种花色的牌结算结束后，你可以视为对一名角色依次使用【过河拆桥】和【顺手牵羊】。"..
  "<a href='os__override'>凌越·阵营</a>：然后与你距离为1的其他友方角色依次视为对其使用【过河拆桥】。",

  ["@ofl_tx__shanji-turn"] = "闪击",
  ["#ofl_tx__shanji-choose"] = "闪击：视为对一名角色使用【过河拆桥】【顺手牵羊】，若凌越则距离1的友方角色也视为对其使用【过河拆桥】",
}

Fk:addTargetTip{
  name = shanji.name,
  target_tip = function(self, player, to_select, selected, selected_cards, card, selectable)
    if not selectable then return end
    if #player:getFriends() > #to_select:getFriends() then
      return "override"
    end
  end,
}

shanji:addEffect(fk.CardUseFinished, {
  anim_type = "control",
  can_trigger = function (self, event, target, player, data)
    if target == player and player:hasSkill(shanji.name) and data.card.suit ~= Card.NoSuit then
      local suits, yes = {}, false
      player.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
        local use = e.data
        if use.from == player and use.card.suit ~= Card.NoSuit then
          suits[use.card:getSuitString(true)] = (suits[use.card:getSuitString(true)] or 0) + 1
          if e.data == data and suits[use.card:getSuitString(true)] == 2 then
            yes = true
          end
        end
      end, Player.HistoryTurn)
      local mark = ""
      for k, v in pairs(suits) do
        mark = mark..Fk:translate(k)..v
      end
      player.room:setPlayerMark(player, "@ofl_tx__shanji-turn", mark)
      return yes and table.find(player.room:getOtherPlayers(player, false), function (p)
        return player:canUseTo(Fk:cloneCard("dismantlement"), p) or
          player:canUseTo(Fk:cloneCard("snatch"), p, { bypass_distances = true })
      end)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player, false), function (p)
      return player:canUseTo(Fk:cloneCard("dismantlement"), p) or
        player:canUseTo(Fk:cloneCard("snatch"), p, { bypass_distances = true })
    end)
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = shanji.name,
      prompt = "#ofl_tx__shanji-choose",
      cancelable = true,
      target_tip_name = shanji.name,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local yes = #player:getFriends() > #to:getFriends()
    for _, name in ipairs({"dismantlement", "snatch"}) do
      room:useVirtualCard(name, nil, player, to, shanji.name, true)
      if player.dead or to.dead then return end
    end
    if yes then
      for _, p in ipairs(room:getOtherPlayers(player, false)) do
        if p:isFriend(player) and p:distanceTo(player) == 1 and not p.dead then
          room:useVirtualCard("dismantlement", nil, player, p, shanji.name, true)
          if player.dead or to.dead then return end
        end
      end
    end
  end,
})

return shanji
