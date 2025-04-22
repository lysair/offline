local lijunc = fk.CreateSkill {
  name = "ofl__lijunc",
}

Fk:loadTranslationTable{
  ["ofl__lijunc"] = "励军",
  [":ofl__lijunc"] = "当魏势力角色受到伤害后，你可以令其摸一张牌。",

  ["#ofl__lijunc-invoke"] = "励军：可以令 %dest 摸一张牌",
}

lijunc:addEffect(fk.Damaged, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(lijunc.name) and target.kingdom == "wei" and not target.dead
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = lijunc.name,
      prompt = "#ofl__lijunc-invoke::"..target.id,
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    target:drawCards(1, lijunc.name)
  end,
})

return lijunc