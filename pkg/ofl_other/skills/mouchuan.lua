local mouchuan = fk.CreateSkill {
  name = "mouchuan"
}

Fk:loadTranslationTable{
  ['mouchuan'] = '谋川',
  ['#mouchuan-choose'] = '谋川：将一张手牌交给一名其他角色',
  ['#mouchuan1-show'] = '谋川：展示一张手牌',
  ['#mouchuan2-show'] = '展示一张手牌，根据是否为%arg，%src获得技能<br>相同：%src获得〖道合〗出牌阶段限一次，你可以令一名其他角色交给你至少一张手牌，然后其回复1点体力。<br>不同：%src获得〖志异〗出牌阶段限一次，你可以令一名角色摸一张牌，然后你对其造成1点伤害。',
  ['daohe'] = '道合',
  ['zhiyiz'] = '志异',
  [':mouchuan'] = '每轮开始时，你可以摸两张牌并交给一名其他角色一张牌，然后你与其依次展示一张手牌，若颜色：相同，你本轮获得技能〖道合〗；不同，你本轮获得技能〖志异〗。',
  ['$mouchuan1'] = '吾欲推赤心于天下，安万物之反侧。',
  ['$mouchuan2'] = '此去如鱼入大海、鸟上青霄，再不受羁绊！',
}

mouchuan:addEffect(fk.RoundStart, {
  can_trigger = function(self, event, target, player)
    return player:hasSkill(mouchuan.name)
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    player:drawCards(2, mouchuan.name)
    if player.dead or player:isKongcheng() or #room.alive_players == 1 then return end

    local to, card = room:askToChooseCardsAndPlayers(player, {
      min_card_num = 1,
      max_card_num = 1,
      targets = table.map(room:getOtherPlayers(player, false), Util.IdMapper),
      pattern = ".|.|.|hand",
      prompt = "#mouchuan-choose",
    })
    to = room:getPlayerById(to[1])
    room:moveCardTo(card[1], Card.PlayerHand, to, fk.ReasonGive, mouchuan.name, nil, false, player.id)

    local color1
    if not player.dead and not player:isKongcheng() then
      local card1 = room:askToCards(player, {
        min_num = 1,
        max_num = 1,
        include_equip = false,
        pattern = ".|.|.|hand",
        prompt = "#mouchuan1-show"
      })
      color1 = Fk:getCardById(card1[1]):getColorString()
      player:showCards(card1)
    end

    if not to.dead and not to:isKongcheng() then
      local card2 = room:askToCards(to, {
        min_num = 1,
        max_num = 1,
        include_equip = false,
        pattern = ".|.|.|hand",
        prompt = "#mouchuan2-show:"..player.id.."::"..color1
      })
      local color2 = Fk:getCardById(card2[1]):getColorString()
      to:showCards(card2)

      if color1 == "nocolor" or color2 == "nocolor" or player.dead then return end

      local skill = "daohe"
      if color1 ~= color2 then
        skill = "zhiyiz"
      end

      room:setPlayerMark(player, mouchuan.name, skill)
      room:handleAddLoseSkills(player, skill, nil, true, false)
    end
  end,
})

mouchuan:addEffect(fk.RoundEnd, {
  can_refresh = function(self, event, target, player)
    return player:getMark(mouchuan.name) ~= 0
  end,
  on_refresh = function(self, event, target, player)
    local room = player.room
    local skill = player:getMark(mouchuan.name)
    room:setPlayerMark(player, mouchuan.name, 0)
    room:handleAddLoseSkills(player, "-"..skill, nil, true, false)
  end,
})

return mouchuan
