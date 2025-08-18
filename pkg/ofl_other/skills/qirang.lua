local qirang = fk.CreateSkill {
  name = "ofl__qirang",
}

Fk:loadTranslationTable{
  ["ofl__qirang"] = "祈禳",
  [":ofl__qirang"] = "当装备牌移至你的装备区后，你可以视为使用一张无距离限制、不可被响应且可以增加或减少一个目标的普通锦囊牌"..
  "（每种牌名每回合限一次）。",

  ["#ofl__qirang-invoke"] = "祈禳：你可以视为使用一张无距离限制、不可被响应、可以增加或减少一个目标的普通锦囊牌",
  ["#ofl__qirang-choose"] = "祈禳：你可以为 %arg 增加或减少一个目标",

  ["$ofl__qirang1"] = "聚天地之灵物，而祈世间之福。",
  ["$ofl__qirang2"] = "乘烟得道而去，窥得仙人之计。",
}

qirang:addEffect(fk.AfterCardsMove, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(qirang.name) then
      for _, move in ipairs(data) do
        if move.to == player and move.toArea == Player.Equip then
          return #player:getViewAsCardNames(qirang.name, Fk:getAllCardNames("t"), nil, player:getTableMark("ofl__qirang-turn"), 
            { bypass_distances = true, bypass_times = true }) > 0
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local use = room:askToUseVirtualCard(player, {
      name = player:getViewAsCardNames(qirang.name, Fk:getAllCardNames("t"), nil, player:getTableMark("ofl__qirang-turn"), 
        { bypass_distances = true, bypass_times = true }),
      skill_name = qirang.name,
      prompt = "#ofl__qirang-invoke",
      cancelable = true,
      extra_data = {
        bypass_distances = true,
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
    use.disresponsiveList = table.simpleClone(room.players)
    room:addTableMark(player, "ofl__qirang-turn", use.card.name)
    room:useCard(use)
  end,
})

qirang:addEffect(fk.AfterCardTargetDeclared, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and not player.dead and
      data.card:isCommonTrick() and
      table.contains(data.card.skillNames, qirang.name)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = data:getExtraTargets({ bypass_times = true })
    table.insertTableIfNeed(targets, data.tos)
    if #targets == 0 then
      return false
    end
    local tos = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#ofl__qirang-choose:::" .. data.card:toLogString(),
      skill_name = qirang.name,
      cancelable = true,
      no_indicate = false,
      target_tip_name = "addandcanceltarget_tip",
      extra_data = table.map(data.tos, Util.IdMapper),
    })
    if #tos > 0 then
      event:setCostData(self, { tos = tos })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    if table.contains(data.tos, to) then
      data:removeTarget(to)
    else
      data:addTarget(to)
      room:sendLog{
        type = "#AddTargetsBySkill",
        from = player.id,
        to = { to.id },
        arg = qirang.name,
        arg2 = data.card:toLogString(),
      }
    end
  end,
})

return qirang
