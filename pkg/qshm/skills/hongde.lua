local hongde = fk.CreateSkill{
  name = "qshm__hongde",
}

Fk:loadTranslationTable{
  ["qshm__hongde"] = "弘德",
  [":qshm__hongde"] = "当你一次获得或失去至少两张牌后，你可以令一名本回合未选择过的其他角色摸等量张牌。",

  ["#qshm__hongde-choose"] = "弘德：你可以令一名其他角色摸%arg张牌",
}

hongde:addEffect(fk.AfterCardsMove, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(hongde.name) then
      local n = 0
      for _, move in ipairs(data) do
        if ((move.from == player and move.to ~= player) or
          (move.to == player and move.toArea == Card.PlayerHand)) then
          n = n + #move.moveInfo
        end
      end
      if n > 1 and
        table.find(player.room:getOtherPlayers(player, false), function (p)
          return not table.contains(player:getTableMark("qshm__hongde-turn"), p.id)
        end) then
        event:setCostData(self, {choice = n})
        return true
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player, false), function (p)
      return not table.contains(player:getTableMark("qshm__hongde-turn"), p.id)
    end)
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = hongde.name,
      prompt = "#qshm__hongde-choose:::"..event:getCostData(self).choice,
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to, choice = event:getCostData(self).choice})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local n = event:getCostData(self).choice
    room:addTableMark(player, "qshm__hongde-turn", to.id)
    to:drawCards(n, hongde.name)
  end,
})

return hongde
