local meiniang = fk.CreateSkill{
  name = "ofl__meiniang",
}

Fk:loadTranslationTable{
  ["ofl__meiniang"] = "美酿",
  [":ofl__meiniang"] = "其他角色的出牌阶段开始时，你可以令其视为使用一张无次数限制的【酒】。",

  ["#ofl__meiniang-invoke"] = "美酿：你可以令视为 %dest 使用一张【酒】",
}

meiniang:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(meiniang.name) and target.phase == Player.Play and
      not target.dead and target:canUseTo(Fk:cloneCard("analeptic"), target, { bypass_times = true })
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = meiniang.name,
      prompt = "#ofl__meiniang-invoke::"..target.id,
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:useVirtualCard("analeptic", nil, target, target, meiniang.name, true)
  end,
})

return meiniang
