local wanwang = fk.CreateSkill({
  name = "ofl__wanwang",
})

Fk:loadTranslationTable{
  ["ofl__wanwang"] = "万王",
  [":ofl__wanwang"] = "每轮限一次，其他西势力角色的出牌阶段开始时，你可以改为代替其执行此阶段。",

  ["#ofl__wanwang-invoke"] = "万王：你可以代替 %dest 执行其出牌阶段！",
}

wanwang:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function (self, event, target, player, data)
    return
      target ~= player and
      target.kingdom == "west" and
      player:hasSkill(wanwang.name) and
      target.phase == Player.Play and
      not target.dead and
      not data.phase_end and
      player:usedSkillTimes(wanwang.name, Player.HistoryRound) == 0
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = wanwang.name,
      prompt = "#ofl__wanwang-invoke::"..target.id,
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    player:gainAnExtraPhase(Player.Play, wanwang.name, true)
    target:endPlayPhase()
  end,
})

return wanwang
