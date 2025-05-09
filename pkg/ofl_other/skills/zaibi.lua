local zaibi = fk.CreateSkill {
  name = "zaibi",
}

Fk:loadTranslationTable {
  ["zaibi"] = "载笔",
  [":zaibi"] = "出牌阶段限一次，你可以重铸至少两张点数连续的牌，从游戏外将<a href=':chunqiu_brush'>【春秋笔】</a>置入你的装备区。",

  ["#zaibi"] = "围铸：重铸至少两张点数连续的牌，将【春秋笔】置入装备区",
}

zaibi:addEffect("active", {
  anim_type = "drawcard",
  prompt = "#zaibi",
  min_card_num = 2,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(zaibi.name, Player.HistoryPhase) == 0
  end,
  card_filter = function (self, player, to_select, selected)
    if Fk:getCardById(to_select).number > 0 then
      if #selected == 0 then
        return true
      else
    return not table.find(selected, function (id)
      return Fk:getCardById(id).number == Fk:getCardById(to_select).number
    end) and
    table.find(selected, function (id)
      return math.abs(Fk:getCardById(id).number - Fk:getCardById(to_select).number) == 1
    end)
      end
    end
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    room:recastCard(effect.cards, player, zaibi.name)
    if player.dead then return end
    local id = room:getBanner(zaibi.name)[1]
    if room:getCardArea(id) == Card.Void and player:canMoveCardIntoEquip(id, false) then
      room:moveCardIntoEquip(player, id, zaibi.name, false, player)
    end
  end,
})

zaibi:addAcquireEffect(function (self, player, is_start)
  local room = player.room
  if not room:setBanner(zaibi.name) then
    local card = room:printCard("chunqiu_brush", Card.Heart, 5)
    room:setCardMark(card, MarkEnum.DestructOutMyEquip, 1)
    room:setBanner(zaibi.name, {card.id})
  end
end)

return zaibi
