local beirong = fk.CreateSkill {
  name = "ofl__beirong",
}

Fk:loadTranslationTable{
  ["ofl__beirong"] = "备戎",
  [":ofl__beirong"] = "出牌阶段限一次，你可以重铸任意张手牌，若花色数不小于你的体力值，你进入连环状态。",

  ["#ofl__beirong"] = "备戎：重铸任意张手牌，若花色数不小于体力值则进入连环状态",
}

beirong:addEffect("active", {
  anim_type = "drawcard",
  prompt = "#ofl__beirong",
  max_phase_use_time = 1,
  target_num = 0,
  min_card_num = 1,
  card_filter = function(self, player, to_select)
    return table.contains(player:getCardIds("h"), to_select)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local suits = {}
    for _, id in ipairs(effect.cards) do
      table.insertIfNeed(suits, Fk:getCardById(id).suit)
    end
    table.removeOne(suits, Card.NoSuit)
    room:recastCard(effect.cards, player, beirong.name)
    if #suits >= player.hp and not player.dead and not player.chained then
      player:setChainState(true)
    end
  end,
})

return beirong
