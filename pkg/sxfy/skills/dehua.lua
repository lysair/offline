local dehua = fk.CreateSkill {
  name = "sxfy__dehua",
}

Fk:loadTranslationTable{
  ["sxfy__dehua"] = "德化",
  [":sxfy__dehua"] = "你仅失去过两张牌的回合结束时，你可以视为使用一张基本牌。",

  ["#sxfy__dehua-use"] = "德化：你可以视为使用一张基本牌",
}

local U = require "packages/utility/utility"

dehua:addEffect(fk.TurnEnd, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(dehua.name) and
      #player:getViewAsCardNames(dehua.name, Fk:getAllCardNames("b"), nil, nil, { bypass_times = true }) then
        local n = 0
        player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
        for _, move in ipairs(e.data) do
          if move.from == player and move.to ~= player then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
                n = n + 1
                return n > 2
              end
            end
          end
        end
      end, Player.HistoryTurn)
      return n == 2
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cards = U.getUniversalCards(room, "b")
    local use = room:askToUseRealCard(player, {
      pattern = cards,
      skill_name = dehua.name,
      prompt = "#sxfy__dehua-use",
      cancelable = true,
      extra_data = {
        bypass_times = true,
        expand_pile = cards,
      },
      skip = true,
    })
    if use then
      event:setCostData(self, {extra_data = use})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:useCard(event:getCostData(self).extra_data)
  end,
})

return dehua
