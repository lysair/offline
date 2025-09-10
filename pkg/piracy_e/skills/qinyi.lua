local qinyi = fk.CreateSkill {
  name = "ofl__qinyi",
}

Fk:loadTranslationTable{
  ["ofl__qinyi"] = "勤艺",
  [":ofl__qinyi"] = "当你每回合首次造成或受到伤害后，你可以视为使用一张未以此法使用过的基本牌或普通锦囊牌。",

  ["#ofl__qinyi-invoke"] = "勤艺：你可以视为使用一张基本牌或普通锦囊牌",
}

local spec = {
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local use = room:askToUseVirtualCard(player, {
      name = table.filter(Fk:getAllCardNames("bt"), function (name)
        return not table.contains(player:getTableMark(qinyi.name), name)
      end),
      skill_name = qinyi.name,
      prompt = "#ofl__qinyi-invoke",
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
    local room = player.room
    local use = event:getCostData(self).extra_data
    room:addTableMark(player, qinyi.name, use.card.name)
    room:useCard(use)
  end,
}

qinyi:addEffect(fk.Damage, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(qinyi.name) and
      table.find(Fk:getAllCardNames("bt"), function (name)
        return not table.contains(player:getTableMark(qinyi.name), name) and
          player:canUse(Fk:cloneCard(name))
      end) then
      local damage_events = player.room.logic:getActualDamageEvents(1, function (e)
        return e.data.from == player
      end, Player.HistoryTurn)
      return #damage_events > 0 and damage_events[1].data == data
    end
  end,
  on_cost = spec.on_cost,
  on_use = spec.on_use,
})

qinyi:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(qinyi.name) and
      table.find(Fk:getAllCardNames("bt"), function (name)
        return not table.contains(player:getTableMark(qinyi.name), name) and
          player:canUse(Fk:cloneCard(name))
      end) then
      local damage_events = player.room.logic:getActualDamageEvents(1, function (e)
        return e.data.to == player
      end, Player.HistoryTurn)
      return #damage_events > 0 and damage_events[1].data == data
    end
  end,
  on_cost = spec.on_cost,
  on_use = spec.on_use,
})

qinyi:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, qinyi.name, 0)
end)

return qinyi
