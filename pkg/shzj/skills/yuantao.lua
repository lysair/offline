local yuantao = fk.CreateSkill {
  name = "yuantao",
}

Fk:loadTranslationTable{
  ["yuantao"] = "援讨",
  [":yuantao"] = "每回合限一次，一名角色使用基本牌时，你可以令此牌结算后额外使用一次，当前回合结束时，你失去1点体力。",

  ["#yuantao-invoke"] = "援讨：%dest 使用了%arg，是否令此牌额外使用一次？回合结束你失去1点体力",
}

yuantao:addEffect(fk.CardUsing, {
  anim_type = "support",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(yuantao.name) and
      data.card.type == Card.TypeBasic and
      player:usedEffectTimes(self.name, Player.HistoryTurn) == 0 and
      target:canUse(data.card, {bypass_times = true})
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = yuantao.name,
      prompt = "#yuantao-invoke::"..target.id..":"..data.card:toLogString(),
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    data.extra_data = data.extra_data or {}
    data.extra_data.yuantao = data.extra_data.yuantao or {}
    data.extra_data.yuantao = {
      from = target,
      tos = data.tos,
      times = (data.extra_data.yuantao.times or 0) + 1,
    }
  end,
})

yuantao:addEffect(fk.CardUseFinished, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if data.extra_data and data.extra_data.yuantao then
      local from = data.extra_data.yuantao.from
      if from.dead or from:prohibitUse(data.card) then return end
      if table.find(data.extra_data.yuantao.tos, function (p)
        return not p.dead and from:canUseTo(data.card, p, {bypass_times = true})
      end) then
        event:setCostData(self, {extra_data = table.simpleClone(data.extra_data.yuantao)})
        data.extra_data.yuantao = nil
        return true
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local dat = event:getCostData(self).extra_data
    local n = dat.times
    for _ = 1, n do
      local from = dat.from
      if from.dead or from:prohibitUse(data.card) then return end
      local tos = table.filter(dat.tos, function (p)
        return not p.dead and from:canUseTo(data.card, p, {bypass_times = true})
      end)
      if #tos == 0 then return end
      room:sortByAction(tos)
      local use = {
        from = from,
        tos = tos,
        card = data.card,
        extraUse = true,
      }
      room:useCard(use)
    end
  end,
})

yuantao:addEffect(fk.TurnEnd, {
  anim_type = "negative",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return player:usedSkillTimes(yuantao.name, Player.HistoryTurn) > 0 and not player.dead
  end,
  on_use = function(self, event, target, player, data)
    player.room:loseHp(player, player:usedSkillTimes(yuantao.name, Player.HistoryTurn), yuantao.name)
  end,
})

return yuantao
