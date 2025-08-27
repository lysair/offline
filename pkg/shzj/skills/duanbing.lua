local duanbing = fk.CreateSkill{
  name = "shzj_juedai__duanbing",
}

Fk:loadTranslationTable{
  ["shzj_juedai__duanbing"] = "短兵",
  [":shzj_juedai__duanbing"] = "你使用【杀】可以额外指定一名距离为1的角色为目标。你对距离为1的角色使用【杀】需额外使用一张【闪】才能抵消。"..
  "当你对距离为1的角色每回合首次造成伤害后，你摸一张牌。",

  ["#shzj_juedai__duanbing-choose"] = "短兵：你可以额外选择一名距离为1的角色为此【杀】目标",

  ["$shzj_juedai__duanbing1"] = "短兵相接勇者胜！",
  ["$shzj_juedai__duanbing2"] = "杀他个落花流水，方为痛快！",
}

duanbing:addEffect(fk.AfterCardTargetDeclared, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(duanbing.name) and data.card.trueName == "slash" and
      table.find(player.room:getOtherPlayers(player, false), function (p)
        return player:distanceTo(p) == 1 and table.contains(data:getExtraTargets(), p)
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player, false), function (p)
      return player:distanceTo(p) == 1 and table.contains(data:getExtraTargets(), p)
    end)
    local tos = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = duanbing.name,
      prompt = "#shzj_juedai__duanbing-choose",
      cancelable = true,
    })
    if #tos > 0 then
      room:sortByAction(tos)
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    data:addTarget(event:getCostData(self).tos[1])
  end,
})

duanbing:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(duanbing.name) and data.card.trueName == "slash" and
      player:distanceTo(data.to) == 1
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    data:setResponseTimes(2)
  end,
})

duanbing:addEffect(fk.Damage, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(duanbing.name) and
      (data.extra_data or {}).duanbingcheck and
      not table.contains(player:getTableMark("shzj_juedai__duanbing-turn"), data.to.id)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:addTableMark(player, "shzj_juedai__duanbing-turn", data.to.id)
    player:drawCards(1, duanbing.name)
  end,
})

duanbing:addEffect(fk.BeforeHpChanged, {
  can_refresh = function(self, event, target, player, data)
    return data.damageEvent and player == data.damageEvent.from and player:compareDistance(target, 1, "==")
  end,
  on_refresh = function(self, event, target, player, data)
    data.damageEvent.extra_data = data.damageEvent.extra_data or {}
    data.damageEvent.extra_data.duanbingcheck = true
  end,
})

return duanbing
