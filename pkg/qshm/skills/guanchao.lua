local guanchao = fk.CreateSkill {
  name = "qshm__guanchao",
}

Fk:loadTranslationTable{
  ["qshm__guanchao"] = "观潮",
  [":qshm__guanchao"] = "当你于出牌阶段使用牌时，若你此阶段使用过的所有牌点数均为严格递增或严格递减，你可以摸一张牌或弃置一名角色一张牌。",

  ["@qshm__guanchao-phase"] = "观潮",
  ["qshm__guanchao_discard"] = "弃置一名角色一张牌",
  ["#qshm__guanchao-choose"] = "观潮：你可以弃置一名角色一张牌",
}

guanchao:addEffect(fk.CardUsing, {
  anim_type = "control",
  can_trigger = function (self, event, target, player, data)
    if target == player and player:hasSkill(guanchao.name) and player.phase == Player.Play and
      player:getMark("qshm__guanchao_fail-phase") == 0 then
      local nums = {}
      player.room.logic:getEventsByRule(GameEvent.UseCard, 999, function (e)
        if e.data.from == player then
          table.insert(nums, e.data.card.number)
        end
      end, nil, Player.HistoryPhase)
      if #nums > 1 then
        local gap = {}
        for i = 2, #nums do
          table.insert(gap, nums[i] - nums[i - 1])
        end
        if #gap == 1 then
          if gap[1] == 0 then
            player.room:setPlayerMark(player, "qshm__guanchao_fail-phase", 1)
            player.room:setPlayerMark(player, "@qshm__guanchao-phase", 0)
            return false
          else
            return true
          end
        else
          for i = 2, #gap do
            if gap[i] * gap[i - 1] <= 0 then
              player.room:setPlayerMark(player, "qshm__guanchao_fail-phase", 1)
              player.room:setPlayerMark(player, "@qshm__guanchao-phase", 0)
              return false
            end
          end
          return true
        end
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local choices = {"draw1", "Cancel"}
    local targets = table.filter(room:getOtherPlayers(player, false), function (p)
      return not p:isNude()
    end)
    if table.find(player:getCardIds("he"), function (id)
      return not player:prohibitDiscard(id)
    end) then
      table.insert(targets, player)
    end
    if #targets > 0 then
      table.insert(choices, 2, "qshm__guanchao_discard")
    end
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = guanchao.name,
    })
    if choice ~= "Cancel" then
      if choice == "qshm__guanchao_discard" then
        local to = room:askToChoosePlayers(player, {
          min_num = 1,
          max_num = 1,
          targets = targets,
          skill_name = guanchao.name,
          prompt = "#qshm__guanchao-choose",
          cancelable = true,
        })
        if #to > 0 then
          event:setCostData(self, {tos = to, choice = choice})
          return true
        end
      else
        event:setCostData(self, {choice = choice})
        return true
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local choice = event:getCostData(self).choice
    if choice == "draw1" then
      player:drawCards(1, guanchao.name)
    elseif choice == "qshm__guanchao_discard" then
      local to = event:getCostData(self).tos[1]
      if to == player then
        room:askToDiscard(player, {
          min_num = 1,
          max_num = 1,
          include_equip = true,
          skill_name = guanchao.name,
          cancelable = false,
        })
      else
        local card = room:askToChooseCard(player, {
          target = to,
          flag = "he",
          skill_name = guanchao.name,
        })
        room:throwCard(card, guanchao.name, to, player)
      end
    end
  end,

  can_refresh = function (self, event, target, player, data)
    return target == player and player:hasSkill(guanchao.name, true) and player.phase == Player.Play and
      player:getMark("qshm__guanchao_fail-phase") == 0
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    if data.card.number == 0 then
      room:setPlayerMark(player, "qshm__guanchao_fail-phase", 1)
    end
    room:setPlayerMark(player, "@qshm__guanchao-phase", data.card.number)
  end,
})

return guanchao
