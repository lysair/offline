local shoufaj = fk.CreateSkill {
  name = "shoufaj"
}

Fk:loadTranslationTable{
  ['shoufaj'] = '授法',
  ['#shoufaj'] = '授法：将一种花色所有手牌交给一名其他角色，其根据花色获得技能直到你下回合开始：<br>♠-天妒；<font color=>♥</font>-天香；♣-倾国；<font color=>♦</font>-武圣',
  [':shoufaj'] = '出牌阶段，你可以将一种花色所有手牌展示并交给一名其他角色，根据花色，其获得对应的技能直到你下回合开始：<br>♠-〖天妒〗；<font color=>♥</font>-〖天香〗；<br><font color=></font>♣-〖倾国〗；<font color=>♦</font>-〖武圣〗。',
}

shoufaj:addEffect('active', {
  anim_type = "support",
  prompt = "#shoufaj",
  card_num = 0,
  target_num = 1,
  interaction = function(self)
    local choiceList = {}
    local cards = self.player_cards[Player.Hand]
    for _, id in ipairs(cards) do
      table.insertIfNeed(choiceList, Fk:getCardById(id):getSuitString(true))
    end
    if #choiceList == 0 then return false end
    return UI.ComboBox { choices = choiceList, all_choices = {"log_spade", "log_heart", "log_club", "log_diamond"} }
  end,
  can_use = function(self, player)
    return not player:isKongcheng()
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local suit = self.interaction.data
    local cards = table.filter(player:getCardIds("h"), function (id)
      return Fk:getCardById(id):getSuitString(true) == suit
    end)
    if #cards == 0 then return end
    room:moveCardTo(cards, Card.PlayerHand, target, fk.ReasonGive, shoufaj.name, nil, true, player.id)
    if target.dead then return end
    local mapper = {
      ["log_spade"] = "tiandu",
      ["log_heart"] = "tianxiang",
      ["log_club"] = "qingguo",
      ["log_diamond"] = "ex__wusheng",
    }
    local skill = mapper[suit]
    if target:hasSkill(skill, true) then return end
    room:handleAddLoseSkills(target, skill, nil, true, false)
    if player.dead or target.dead then return end
    local mark = player:getTableMark(shoufaj.name)
    mark[string.format("%.0f", target.id)] = mark[string.format("%.0f", target.id)] or {}
    table.insertIfNeed(mark[string.format("%.0f", target.id)], skill)
    room:setPlayerMark(player, shoufaj.name, mark)
  end,
})

shoufaj:addEffect(fk.BeforeTurnStart, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("shoufaj") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local mark = player:getTableMark(shoufaj.name)
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if mark[string.format("%.0f", p.id)] then
        room:handleAddLoseSkills(p, "-"..table.concat(mark[string.format("%.0f", p.id)], "|-"), nil, true, false)
      end
    end
    room:setPlayerMark(player, "shoufaj", 0)
  end,
})

return shoufaj
