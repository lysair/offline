local chenghao = fk.CreateSkill {
  name = "sxfy__chenghao",
}

Fk:loadTranslationTable{
  ["sxfy__chenghao"] = "称好",
  [":sxfy__chenghao"] = "每回合限一次，当有角色受到属性伤害时，你可以观看牌堆顶一张牌，将之交给任意一名角色。",

  ["#sxfy__chenghao-give"] = "称好：将这张牌交给一名角色",
}

chenghao:addEffect(fk.DamageInflicted, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(chenghao.name) and
      data.damageType ~= fk.NormalDamage and player:usedSkillTimes(chenghao.name, Player.HistoryTurn) == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = room:getNCards(1)
    room:askToYiji(player, {
      targets = room.alive_players,
      skill_name = chenghao.name,
      min_num = 1,
      max_num = 1,
      prompt = "#sxfy__chenghao-give",
      cards = cards,
      expand_pile = cards,
      single_max = 1,
    })
  end,
})

return chenghao
