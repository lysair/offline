local liaozou = fk.CreateSkill {
  name = "ofl__liaozou",
}

Fk:loadTranslationTable{
  ["ofl__liaozou"] = "聊奏",
  [":ofl__liaozou"] = "出牌阶段，你可以展示所有手牌，若其中没有“杂音”花色的牌，你摸一张牌。",

  ["#ofl__liaozou"] = "聊奏：展示所有手牌，若没有“杂音”花色的牌则摸一张牌",
}

liaozou:addEffect("active", {
  anim_type = "drawcard",
  prompt = "#ofl__liaozou",
  card_num = 0,
  target_num = 0,
  can_use = function (self, player)
    return not player:isKongcheng() and #player:getPile("ofl__shiyin_pile") > 0 and
      player:getMark("ofl__liaozou_fail-phase") == 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    local yes = not table.find(player:getPile("ofl__shiyin_pile"), function (id)
      return table.find(player:getCardIds("h"), function (id2)
        return Fk:getCardById(id):compareSuitWith(Fk:getCardById(id2))
      end) ~= nil
    end)
    player:showCards(player:getCardIds("h"))
    if player.dead then return end
    if yes then
      player:drawCards(1, liaozou.name)
    else
      room:setPlayerMark(player, "ofl__liaozou_fail-phase", 1)
    end
  end,
})

liaozou:addEffect(fk.AfterCardsMove, {
  can_refresh = function(self, event, target, player, data)
    if player:getMark("ofl__liaozou_fail-phase") > 0 then
      for _, move in ipairs(data) do
        if move.from == player then
          return true
        end
      end
    end
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:setPlayerMark(player, "ofl__liaozou_fail-phase", 0)
  end,
})

return liaozou
