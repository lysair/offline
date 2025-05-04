local siji = fk.CreateSkill {
  name = "siji",
}

Fk:loadTranslationTable{
  ["siji"] = "伺机",
  [":siji"] = "其他角色回合结束时，若其本回合不因使用和打出失去过牌，你可以将一张牌当无距离限制的刺【杀】对其使用。",

  ["#siji-invoke"] = "伺机：你可以将一张牌当无距离限制的刺【杀】对 %dest 使用",
}

siji:addEffect(fk.TurnEnd, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(siji.name) and target ~= player and
      not target.dead and (#player:getHandlyIds() > 0 or #player:getCardIds("e") > 0) and
      #player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
        for _, move in ipairs(e.data) do
          if move.from == target and move.moveReason ~= fk.ReasonUse and move.moveReason ~= fk.ReasonResponse then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
                return true
              end
            end
          end
        end
      end, Player.HistoryTurn) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local use = room:askToUseVirtualCard(player, {
      name = "stab__slash",
      skill_name = siji.name,
      prompt = "#siji-invoke::"..target.id,
      cancelable = true,
      extra_data = {
        bypass_distances = true,
        bypass_times = true,
        extraUse = true,
        exclusive_targets = {target.id},
      },
      card_filter = {
        n = 1,
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

return siji
