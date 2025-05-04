local daifa = fk.CreateSkill {
  name = "daifa",
}

Fk:loadTranslationTable{
  ["daifa"] = "待发",
  [":daifa"] = "其他角色回合结束时，若其本回合获得过除其以外角色的牌，你可以将一张牌当无距离限制的刺【杀】对其使用。",

  ["#daifa-invoke"] = "待发：你可以将一张牌当无距离限制的刺【杀】对 %dest 使用",
}

daifa:addEffect(fk.TurnEnd, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(daifa.name) and target ~= player and
      not target.dead and (#player:getHandlyIds() > 0 or #player:getCardIds("e") > 0) and
      #player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
        for _, move in ipairs(e.data) do
          if move.to == target and move.from and move.from ~= move.to then
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
      skill_name = daifa.name,
      prompt = "#daifa-invoke::"..target.id,
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

return daifa
