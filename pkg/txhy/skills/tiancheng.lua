local tiancheng = fk.CreateSkill {
  name = "ofl_tx__tiancheng",
}

Fk:loadTranslationTable{
  ["ofl_tx__tiancheng"] = "天惩",
  [":ofl_tx__tiancheng"] = "当你使用非虚拟【万箭齐发】指定目标时，你可以改为仅指定其中一名角色为目标，取消其余目标。"..
  "此牌结算结束后，你视为对其使用X张【万箭齐发】（X为取消的目标数）。",

  ["#ofl_tx__tiancheng-choose"] = "天惩：你可以选择一名目标，取消其他目标，结算后视为对其使用%arg张【万箭齐发】",
}

tiancheng:addEffect(fk.TargetSpecifying, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(tiancheng.name) and data.firstTarget and
      data.card.name == "archery_attack" and #Card:getIdList(data.card) > 0 and
      #table.filter(data.use.tos, function (p)
        return not p.dead
      end) > 1
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local n = #table.filter(data.use.tos, function (p)
        return not p.dead
      end) - 1
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = data.use.tos,
      skill_name = tiancheng.name,
      prompt = "#ofl_tx__tiancheng-choose:::"..n,
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local n = 0
    for _, p in ipairs(room.alive_players) do
      if table.contains(data.use.tos, p) and not p.dead and p ~= to then
        n = n + 1
        data:cancelTarget(p)
      end
    end
    data.extra_data = data.extra_data or {}
    data.extra_data.ofl_tx__tiancheng = {player, to, n}
  end,
})

tiancheng:addEffect(fk.CardUseFinished, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and data.extra_data and data.extra_data.ofl_tx__tiancheng and
      data.extra_data.ofl_tx__tiancheng[1] == player and not data.extra_data.ofl_tx__tiancheng[2].dead
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local n = data.extra_data.ofl_tx__tiancheng[3]
    local to = data.extra_data.ofl_tx__tiancheng[2]
    for _ = 1, n do
      if player.dead or to.dead then return end
      room:useVirtualCard("archery_attack", nil, player, to, tiancheng.name)
    end
  end,
})

return tiancheng
