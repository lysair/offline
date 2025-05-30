local qifeng = fk.CreateSkill {
  name = "qifeng",
}

Fk:loadTranslationTable{
  ["qifeng"] = "齐锋",
  [":qifeng"] = "每个回合结束时，若你本回合失去过牌，你可以视为对其使用一张伤害基数值为X的【杀】（X为你本回合失去过的牌数）。",

  ["#qifeng-invoke"] = "齐锋：你可以视为对 %dest 使用一张伤害为%arg的【杀】！",
}

qifeng:addEffect(fk.TurnEnd, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(qifeng.name) and not target.dead and
      player:canUseTo(Fk:cloneCard("slash"), target, { bypass_distances = true, bypass_times = true }) and
      #player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
        for _, move in ipairs(e.data) do
          if move.from == player then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
                return true
              end
            end
          end
        end
      end, Player.HistoryTurn) > 0
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local n = 0
    room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
      for _, move in ipairs(e.data) do
        if move.from == player then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
              n = n + 1
            end
          end
        end
      end
    end, Player.HistoryTurn)
    if room:askToSkillInvoke(player, {
      skill_name = qifeng.name,
      prompt = "#qifeng-invoke::"..target.id..":"..n,
    }) then
      event:setCostData(self, {tos = {target}, choice = n})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = Fk:cloneCard("slash")
    card.skillName = qifeng.name
    local use = {
      from = player,
      tos = {target},
      card = card,
      additionalDamage = event:getCostData(self).choice - 1,
      extraUse = true,
    }
    room:useCard(use)
  end,
})

return qifeng
