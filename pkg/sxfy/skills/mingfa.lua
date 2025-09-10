local mingfa = fk.CreateSkill {
  name = "sxfy__mingfa",
}

Fk:loadTranslationTable{
  ["sxfy__mingfa"] = "明伐",
  [":sxfy__mingfa"] = "出牌阶段，你可以对一名体力值大于1的角色造成1点伤害，然后此技能失效直到其死亡或回复体力。",

  ["#sxfy__mingfa"] = "明伐：对一名体力值大于1的角色造成1点伤害",

  ["$sxfy__mingfa1"] = "以诚相待，吴人倾心，攻之必克。",
  ["$sxfy__mingfa2"] = "以强击弱，易如反掌，何须诡诈？",
}

mingfa:addEffect("active", {
  anim_type = "offensive",
  prompt = "#sxfy__mingfa",
  card_num = 0,
  target_num = 1,
  can_use = Util.TrueFunc,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select.hp > 1
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    room:setPlayerMark(player, mingfa.name, target.id)
    room:invalidateSkill(player, mingfa.name)
    room:damage{
      from = player,
      to = target,
      damage = 1,
      skillName = mingfa.name,
    }
  end,
})

local spec = {
  can_refresh = function(self, event, target, player, data)
    return player:getMark("sxfy__mingfa") == target.id
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, mingfa.name, 0)
    room:validateSkill(player, mingfa.name)
  end,
}
mingfa:addEffect(fk.Deathed, spec)
mingfa:addEffect(fk.HpRecover, spec)

mingfa:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, mingfa.name, 0)
  player.room:validateSkill(player, mingfa.name)
end)

return mingfa
