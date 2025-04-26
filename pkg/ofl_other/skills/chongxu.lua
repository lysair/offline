local chongxu = fk.CreateSkill {
  name = "ofl__chongxu",
}

Fk:loadTranslationTable {
  ["ofl__chongxu"] = "冲虚",
  [":ofl__chongxu"] = "出牌阶段限一次，你可以展示牌堆顶三张牌，获得其中一张牌，若此牌为：黑色，本回合你修改〖妙剑〗；红色，"..
  "直到你下回合开始，你修改〖莲华〗。",

  ["#ofl__chongxu"] = "冲虚：展示牌堆顶三张牌并获得其中一张，根据颜色修改“妙剑”或“莲华”",
  ["#ofl__chongxu-choice"] = "冲虚：获得其中一张牌，黑色修改“妙剑”，红色修改“莲华”",

  ["$ofl__chongxu1"] = "静则潜修至道，动则行善累功。",
  ["$ofl__chongxu2"] = "慧剑断情除旧妄，一心向道卫苍生。",
}

chongxu:addEffect("active", {
  anim_type = "drawcard",
  card_num = 0,
  target_num = 0,
  prompt = "#ofl__chongxu",
  can_use = function(self, player)
    return player:usedSkillTimes(chongxu.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    local cards = room:getNCards(3)
    room:showCards(cards)
    local card = room:askToChooseCard(player, {
      target = player,
      flag = { card_data = {{ "Top", cards }} },
      skill_name = chongxu.name,
      prompt = "#ofl__chongxu-choice",
    })
    card = Fk:getCardById(card)
    if card.color == Card.Black then
      room:setPlayerMark(player, "ofl__miaojian-turn", 1)
    elseif card.color == Card.Red then
      room:setPlayerMark(player, "ofl__lianhuas", 1)
    end
    room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonJustMove, chongxu.name, nil, true, player)
  end,
})

chongxu:addEffect(fk.TurnStart, {
  can_refresh = function (self, event, target, player, data)
    return target == player
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:setPlayerMark(player, "ofl__lianhuas", 0)
  end,
})

return chongxu
