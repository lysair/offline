local zhenjue = fk.CreateSkill {
  name = "zhenjue",
}

Fk:loadTranslationTable{
  ["zhenjue"] = "阵绝",
  [":zhenjue"] = "一名角色结束阶段，若你没有手牌，你可以令其选择一项：1.弃置一张牌；2.你摸一张牌。",

  ["#zhenjue-invoke"] = "阵绝：是否令 %dest 选择弃一张牌或令你摸一张牌？",
  ["#zhenjue-discard"] = "阵绝：请弃置一张牌，否则 %src 摸一张牌",
}

zhenjue:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(zhenjue.name) and target.phase == Player.Finish and
      player:isKongcheng() and not target.dead
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askToSkillInvoke(player, {
      skill_name = zhenjue.name,
      prompt = "#zhenjue-invoke::"..target.id,
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if target:isNude() or
      #room:askToDiscard(target, {
        min_num = 1,
        max_num = 1,
        include_equip = true,
        skill_name = zhenjue.name,
        cancelable = true,
        prompt = "#zhenjue-discard:"..player.id,
      }) == 0 then
      player:drawCards(1, zhenjue.name)
    end
  end,
})

return zhenjue
