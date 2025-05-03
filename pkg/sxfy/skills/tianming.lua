local tianming = fk.CreateSkill {
  name = "sxfy__tianming",
}

Fk:loadTranslationTable {
  ["sxfy__tianming"] = "天命",
  [":sxfy__tianming"] = "当你成为【杀】的目标后，你可以弃置所有牌（无牌则不弃），然后摸两张牌；然后体力唯一最大的其他角色"..
  "也可以如此做。",

  ["#sxfy__tianming-invoke"] = "天命：你可以弃置所有牌（无牌则不弃），然后摸两张牌",
}

tianming:addEffect(fk.TargetConfirmed, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(tianming.name) and data.card.trueName == "slash"
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = tianming.name,
      prompt = "#sxfy__tianming-invoke"
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:throwAllCards("he", tianming.name)
    if not player.dead then
      player:drawCards(2, tianming.name)
    end
    local to = table.filter(room.alive_players, function (p)
      return table.every(room.alive_players, function (q)
        return p.hp >= q.hp
      end)
    end)
    if #to ~= 1 or to[1] == player then return end
    to = to[1]
    if room:askToSkillInvoke(to, {
      skill_name = tianming.name,
      prompt = "#sxfy__tianming-invoke"
    }) then
      to:throwAllCards("he", tianming.name)
      if not to.dead then
        to:drawCards(2, tianming.name)
      end
    end
  end,
})

return tianming
