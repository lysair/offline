local skill = fk.CreateSkill {
  name = "destroy_indiscrimintely_skill",
}

skill:addEffect("cardskill", {
  prompt = "#destroy_indiscrimintely_skill",
  target_num = 1,
  mod_target_filter = Util.TrueFunc,
  target_filter = Util.CardTargetFilter,
  on_effect = function(self, room, effect)
    local player = effect.from
    local target = effect.to
    room:damage({
      from = player,
      to = target,
      card = effect.card,
      damage = 1,
      skillName = skill.name,
    })
    if not player.dead then
      room:loseHp(player, 1, skill.name)
    end
  end,
})

return skill
