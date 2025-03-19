local xianxing = fk.CreateSkill {
  name = "xianxing"
}

Fk:loadTranslationTable{
  ['xianxing'] = '险行',
  ['#xianxing-invoke'] = '险行：是否摸 %arg 张牌？',
  ['#xianxing_delay'] = '险行',
  ['xianxing_loseHp'] = '失去%arg点体力',
  ['xianxing_invalid'] = '“险行”本回合失效',
  [':xianxing'] = '出牌阶段，当你使用伤害类牌指定其他角色为唯一目标时，你可以摸X张牌，若如此做，此牌结算后，若此牌未造成伤害且X大于1，你选择一项：1.失去X-1点体力；2.此技能本回合失效（X为你本回合发动此技能次数）。',
}

xianxing:addEffect(fk.TargetSpecifying, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xianxing.name) and data.card.is_damage_card and player.phase == Player.Play and
      #AimGroup:getAllTargets(data.tos) == 1 and data.to ~= player.id
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = xianxing.name,
      prompt = "#xianxing-invoke:::"..(player:usedSkillTimes(xianxing.name, Player.HistoryTurn) + 1),
    })
  end,
  on_use = function(self, event, target, player, data)
    data.extra_data = data.extra_data or {}
    data.extra_data.xianxing = player.id
    player:drawCards(player:usedSkillTimes(xianxing.name, Player.HistoryTurn), xianxing.name)
  end,
})

xianxing:addEffect(fk.CardUseFinished, {
  anim_type = "negative",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:usedSkillTimes("xianxing", Player.HistoryTurn) > 1 and
      data.extra_data and data.extra_data.xianxing == player.id and not data.damageDealt
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = player:usedSkillTimes("xianxing", Player.HistoryTurn) - 1
    local choice = room:askToChoice(player, {
      choices = {"xianxing_loseHp:::"..n, "xianxing_invalid"},
      skill_name = "xianxing"
    })
    if choice == "xianxing_invalid" then
      room:invalidateSkill(player, xianxing.name, "-turn")
    else
      room:loseHp(player, n, "xianxing")
    end
  end,
})

return xianxing
