local huiyao = fk.CreateSkill {
  name = "sxfy__huiyao",
}

Fk:loadTranslationTable{
  ["sxfy__huiyao"] = "慧夭",
  [":sxfy__huiyao"] = "出牌阶段限一次，你可以受到1点无来源伤害，然后你复原武将牌并摸一张牌。",

  ["#sxfy__huiyao"] = "慧夭：你可以受到1点无来源伤害，复原武将牌并摸一张牌",
}

huiyao:addEffect("active", {
  anim_type = "masochism",
  card_num = 0,
  target_num = 0,
  prompt = "#sxfy__huiyao",
  can_use = function(self, player)
    return player:usedSkillTimes(huiyao.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    room:damage{
      from = nil,
      to = player,
      damage = 1,
      skillName = huiyao.name,
    }
    if player.dead then return end
    player:reset()
    if player.dead then return end
    player:drawCards(1, huiyao.name)
  end,
})

return huiyao
