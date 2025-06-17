local quanmou = fk.CreateSkill{
  name = "ofl__quanmou",
}

Fk:loadTranslationTable{
  ["ofl__quanmou"] = "全谋",
  [":ofl__quanmou"] = "当一名其他角色对你使用的锦囊牌结算后，你可以弃置一张与此牌颜色相同的手牌，然后获得之。",

  ["#ofl__quanmou-invoke"] = "全谋：你可以弃置一张%arg手牌，获得%arg2",
}

quanmou:addEffect(fk.CardUseFinished, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(quanmou.name) and target ~= player and
      data.card.type == Card.TypeTrick and data.card.color ~= Card.NoColor and table.contains(data.tos, player) and
      table.contains({Card.Processing, Card.PlayerJudge}, player.room:getCardArea(data.card)) and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local pattern = data.card.color == Card.Red and ".|.|heart,diamond" or ".|.|spade,club"
    local card = room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = quanmou.name,
      pattern = pattern,
      prompt = "#ofl__quanmou-invoke:::"..data.card:getColorString()..":"..data.card:toLogString(),
      cancelable = true,
      skip = true,
    })
    if #card > 0 then
      event:setCostData(self, {cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(event:getCostData(self).cards, quanmou.name, player, player)
    if player.dead then return end
    if table.contains({Card.Processing, Card.PlayerJudge}, room:getCardArea(data.card)) then
      room:obtainCard(player, data.card, true, fk.ReasonPrey, player, quanmou.name)
    end
  end,
})

return quanmou
