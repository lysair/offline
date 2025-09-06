local rulong = fk.CreateSkill {
  name = "ofl_tx__rulong",
}

Fk:loadTranslationTable{
  ["ofl_tx__rulong"] = "如龙",
  [":ofl_tx__rulong"] = "与你距离为1的角色被【杀】指定为目标时，你可以取消所有目标，改为你成为此【杀】目标。"..
  "以你为目标的【杀】结算结束后，若此【杀】未造成伤害，你视为对此【杀】使用者使用一张【决斗】。",

  ["#ofl_tx__rulong-invoke"] = "如龙：你可以取消此【杀】所有目标，将目标改为你",
}

rulong:addEffect(fk.TargetSpecifying, {
  anim_type = "support",
  can_trigger = function (self, event, target, player, data)
    return target ~= player and player:hasSkill(rulong.name) and
      data.card.trueName == "slash" and data.firstTarget and
      table.find(data.use.tos, function (p)
        return p:distanceTo(player) == 1
      end)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = rulong.name,
      prompt = "#ofl_tx__rulong-invoke",
    })
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    data:cancelAllTarget()
    data:addTarget(player, nil, true)
    room:doIndicate(target, {player})
  end,
})

rulong:addEffect(fk.CardUseFinished, {
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    return target ~= player and player:hasSkill(rulong.name) and
      data.card.trueName == "slash" and table.contains(data.tos, player) and not data.damageDealt and
      not target.dead and not player:isProhibited(target, Fk:cloneCard("duel"))
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    player.room:useVirtualCard("duel", nil, player, target, rulong.name)
  end,
})

return rulong
