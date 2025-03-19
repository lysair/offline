local fujing = fk.CreateSkill {
  name = "fujing"
}

Fk:loadTranslationTable{
  ['fujing'] = '富荆',
  ['#fujing-use'] = '富荆：请使用一张【荆襄盛世】',
  ['#fujing_delay'] = '富荆',
  [':fujing'] = '锁定技，你跳过摸牌阶段，改为使用一张【荆襄盛世】。以此法获得牌的其他角色本轮首次使用牌指定你为目标后，其需弃置一张牌。',
}

fujing:addEffect(fk.EventPhaseChanging, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skill.name) and data.to == Player.Draw
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local use = room:askToUseCard(player, {
      skill_name = skill.name,
      pattern = "jingxiang_golden_age",
      prompt = "#fujing-use",
      cancelable = true,
    })
    if use then
      use.extra_data = use.extra_data or {}
      use.extra_data.fujing = true
      room:useCard(use)
    end
    return true
  end,
})

fujing:addEffect(fk.CardUseFinished, {
  can_refresh = function (skill, event, target, player, data)
    return target == player and not player.dead and data.extra_data and
      data.extra_data.fujing and data.extra_data.jingxiangGoldenAgeResult
  end,
  on_refresh = function (skill, event, target, player, data)
    local room = player.room
    local mark = {}
    for _, dat in ipairs(data.extra_data.jingxiangGoldenAgeResult) do
      table.insertIfNeed(mark, dat[1])
    end
    room:setPlayerMark(player, "fujing-round", mark)
  end,
})

fujing:addEffect(fk.TargetSpecified, {
  global = true,
  can_trigger = function(self, event, target, player, data)
    return data.to == player.id and table.contains(player:getTableMark("fujing-round"), target.id) and not target.dead
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:removeTableMark(player, "fujing-round", target.id)
    room:askToDiscard(target, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = "fujing",
      cancelable = false,
    })
  end,
})

return fujing
