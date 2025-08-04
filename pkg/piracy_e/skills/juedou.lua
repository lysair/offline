local juedou = fk.CreateSkill({
  name = "ofl__juedou",
})

Fk:loadTranslationTable{
  ["ofl__juedou"] = "角斗",
  [":ofl__juedou"] = "当其他角色对你使用【杀】结算结束后，若此【杀】未对你造成伤害，你可以视为对其使用一张无距离限制的【杀】。",

  ["#ofl__juedou-invoke"] = "角斗：你可以视为对 %dest 使用【杀】",
}

juedou:addEffect(fk.CardUseFinished, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(juedou.name) and
      data.card.trueName == "slash" and table.contains(data.tos, player) and
      not (data.damageDealt and data.damageDealt[player]) and
      not target.dead and player:canUseTo(Fk:cloneCard("slash"), target, { bypass_distances = true, bypass_times = true })
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = juedou.name,
      prompt = "#ofl__juedou-invoke::"..target.id,
    })
  end,
  on_use = function(self, event, target, player, data)
    player.room:useVirtualCard("slash", nil, player, target, juedou.name, true)
  end,
})

return juedou
