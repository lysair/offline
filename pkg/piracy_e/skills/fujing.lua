local fujing = fk.CreateSkill {
  name = "fujing",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["fujing"] = "富荆",
  [":fujing"] = "锁定技，你跳过摸牌阶段，改为使用一张<a href=':jingxiang_golden_age'>【荆襄盛世】</a>。以此法获得牌的其他角色"..
  "本轮首次使用牌指定你为目标后，其需弃置一张牌。",

  ["#fujing-use"] = "富荆：请使用一张【荆襄盛世】",
}

fujing:addEffect(fk.EventPhaseChanging, {
  anim_type = "negative",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(fujing.name) and data.phase == Player.Draw and not data.skipped
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    data.skipped = true
    local use = room:askToUseCard(player, {
      skill_name = fujing.name,
      pattern = "jingxiang_golden_age",
      prompt = "#fujing-use",
      cancelable = true,
    })
    if use then
      use.extra_data = use.extra_data or {}
      use.extra_data.fujing = true
      room:useCard(use)
    end
  end,
})

fujing:addEffect(fk.CardUseFinished, {
  can_refresh = function (self, event, target, player, data)
    return target == player and not player.dead and data.extra_data and
      data.extra_data.fujing and data.extra_data.jingxiangGoldenAgeResult
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    local mark = {}
    for _, dat in ipairs(data.extra_data.jingxiangGoldenAgeResult) do
      table.insertIfNeed(mark, dat[1])
    end
    room:setPlayerMark(player, "fujing-round", mark)
  end,
})

fujing:addEffect(fk.TargetSpecified, {
  anim_type = "defensive",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return data.to == player and table.contains(player:getTableMark("fujing-round"), target.id) and not target.dead
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:removeTableMark(player, "fujing-round", target.id)
    room:askToDiscard(target, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = fujing.name,
      cancelable = false,
    })
  end,
})

return fujing
