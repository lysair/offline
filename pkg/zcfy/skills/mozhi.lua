local mozhi = fk.CreateSkill {
  name = "sxfy__mozhi",
}

Fk:loadTranslationTable {
  ["sxfy__mozhi"] = "默识",
  [":sxfy__mozhi"] = "结束阶段，你可以视为使用一张本回合使用过的基本牌或普通锦囊牌。",

  ["#sxfy__mozhi-invoke"] = "默识：你可以视为使用一张本回合使用过的基本牌或普通锦囊牌",
}

mozhi:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(mozhi.name) and player.phase == Player.Finish then
      local names = {}
      player.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function(e)
        local use = e.data
        if use.card.type == Card.TypeBasic or use.card:isCommonTrick() then
          table.insertIfNeed(names, use.card.name)
        end
      end, Player.HistoryTurn)
      if #player:getViewAsCardNames(mozhi.name, names, nil, nil, { bypass_times = true }) > 0 then
        event:setCostData(self, {extra_data = names})
        return true
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local names = event:getCostData(self).extra_data
    local use = room:askToUseVirtualCard(player, {
      name = names,
      skill_name = mozhi.name,
      prompt = "#sxfy__mozhi-invoke",
      cancelable = true,
      extra_data = {
        bypass_times = true,
        extraUse = true,
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

return mozhi
