local ruixi = fk.CreateSkill {
  name = "ruixi",
}

Fk:loadTranslationTable{
  ["ruixi"] = "锐袭",
  [":ruixi"] = "一名角色的结束阶段，若你本回合失去过牌，你可以将一张牌当无距离限制的【杀】使用。",

  ["#ruixi-use"] = "锐袭：你可以将一张牌当无距离限制的【杀】使用",
}

ruixi:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(ruixi.name) and target.phase == Player.Finish then
      if #player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
        for _, move in ipairs(e.data) do
          if move.from == player and move.to ~= player then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
                return true
              end
            end
          end
        end
      end, Player.HistoryTurn) == 0 then return end
      return player:canUse(Fk:cloneCard("slash"), { bypass_distances = true, bypass_times = true }) and
        not (player:isNude() and #player:getHandlyIds() == 0)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local use = room:askToUseVirtualCard(player, {
      name = "slash",
      skill_name = ruixi.name,
      prompt = "#ruixi-use",
      cancelable = true,
      extra_data = {
        bypass_distances = true,
        bypass_times = true,
        extraUse = true,
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

return ruixi