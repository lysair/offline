
local chende = fk.CreateSkill{
  name = "chende",
}

Fk:loadTranslationTable{
  ["chende"] = "臣德",
  [":chende"] = "出牌阶段，你可以展示并交给其他角色至少两张手牌，然后你可以视为使用其中一张基本牌或普通锦囊牌。",

  ["#chende"] = "臣德：交给一名角色至少两张手牌，然后你可以视为使用其中一张牌",
  ["#chende-use"] = "臣德：你可以视为使用其中一张牌",
}

chende:addEffect("active", {
  anim_type = "support",
  min_card_num = 2,
  target_num = 1,
  prompt = "#chende",
  card_filter = function(self, player, to_select, selected)
    return table.contains(player:getCardIds("h"), to_select)
  end,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    player:showCards(effect.cards)
    if player.dead or target.dead then return end
    local cards = table.filter(effect.cards, function (id)
      return table.contains(player:getCardIds("h"), id)
    end)
    if #cards == 0 then return end
    room:moveCardTo(cards, Card.PlayerHand, target, fk.ReasonGive, chende.name, nil, true, player)
    if player.dead then return end
    cards = table.filter(room:getBanner(chende.name), function (id)
      return table.find(effect.cards, function (id2)
        return Fk:getCardById(id).name == Fk:getCardById(id2).name
      end) ~= nil
    end)
    if #cards > 0 then
      local use = room:askToUseRealCard(player, {
        pattern = cards,
        skill_name = chende.name,
        prompt = "#chende-use",
        extra_data = {
          bypass_times = true,
          expand_pile = cards,
        },
        skip = true,
      })
      if use then
        local card = Fk:cloneCard(use.card.name)
        card.skillName = chende.name
        room:useCard{
          card = card,
          from = player,
          tos = use.tos,
          extraUse = true,
        }
      end
    end
  end,
})

chende:addAcquireEffect(function (self, player, is_start)
  local room = player.room
  if room:getBanner(chende.name) == nil then
    local ids = {}
    for _, name in ipairs(Fk:getAllCardNames("bt", false, true)) do
      table.insert(ids, room:printCard(name).id)
    end
    room:setBanner(chende.name, ids)
  end
end)

return chende
