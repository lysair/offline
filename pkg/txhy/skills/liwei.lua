local liwei = fk.CreateSkill{
  name = "ofl_tx__liwei",
}

Fk:loadTranslationTable{
  ["ofl_tx__liwei"] = "立威",
  [":ofl_tx__liwei"] = "<a href='os__presumption'>妄行</a>：出牌阶段限一次，你可以视为对一名其他角色依次使用X张【杀】。",

  ["#ofl_tx__liwei"] = "立威：视为对一名角色使用1~4张【杀】，结束阶段执行妄行效果",
  ["@ofl_tx__liwei_presume-turn"] = "立威 妄行",
  ["#ofl_tx__liwei_presume-discard"] = "立威：弃置%arg张牌，否则减1点体力上限",
}

liwei:addEffect("active", {
  anim_type = "control",
  prompt = "#ofl_tx__liwei",
  card_num = 0,
  target_num = 1,
  interaction = UI.Spin {
    from = 1,
    to = 4,
  },
  can_use = function(self, player)
    return player:usedSkillTimes(liwei.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= player and
      player:canUseTo(Fk:cloneCard("slash"), to_select, { bypass_distances = true, bypass_times = true })
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local n = 0
    for _ = 1, self.interaction.data do
      if target.dead then
        break
      end
      if room:useVirtualCard("slash", nil, player, target, liwei.name, true) then
        n = n + 1
      else
        break
      end
      if player.dead then return end
    end
    if not player.dead then
      room:setPlayerMark(player, "@ofl_tx__liwei_presume-turn", n)
    end
  end,
})

liwei:addEffect(fk.EventPhaseStart, {
  anim_type = "negative",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return player == target and player.phase == Player.Finish and
      player:getMark("@ofl_tx__liwei_presume-turn") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local num = player:getMark("@ofl_tx__liwei_presume-turn")
    if #room:askToDiscard(player, {
      min_num = num,
      max_num = num,
      include_equip = true,
      skill_name = liwei.name,
      prompt = "#ofl_tx__liwei_presume-discard:::" .. num,
    }) == 0 then
      room:changeMaxHp(player, -1)
    end
  end,
})

return liwei
