local yanli = fk.CreateSkill {
  name = "ofl__yanli",
}

Fk:loadTranslationTable{
  ["ofl__yanli"] = "妍丽",
  [":ofl__yanli"] = "每轮限一次，当一名角色于你的回合外进入濒死状态时，你可以令其回复至1点体力，然后其摸一张牌。",

  ["#ofl__yanli-invoke"] = "妍丽：你可以令 %dest 回复至1点体力并摸一张牌",
}

yanli:addEffect(fk.EnterDying, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(yanli.name) and
      player.room:getCurrent() ~= player and
      player:usedSkillTimes(yanli.name, Player.HistoryRound) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = yanli.name,
      prompt = "#ofl__yanli-invoke::"..target.id,
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:recover{
      who = target,
      num = 1 - target.hp,
      recoverBy = player,
      skillName = yanli.name,
    }
    if not target.dead then
      target:drawCards(1, yanli.name)
    end
  end,
})

return yanli