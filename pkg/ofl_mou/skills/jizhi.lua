local jizhi = fk.CreateSkill{
  name = "ofl_mou__jizhi",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_mou__jizhi"] = "集智",
  [":ofl_mou__jizhi"] = "锁定技，当你使用非转化的普通锦囊牌时，你摸一张牌，本回合手牌上限+1。",

  ["$ofl_mou__jizhi1"] = "奇思机上巧，妙想晦下明。",
  ["$ofl_mou__jizhi2"] = "愚，固曾有，智，从未绝。",
}

jizhi:addEffect(fk.CardUsing, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jizhi.name) and
      data.card:isCommonTrick() and not data.card:isVirtual()
  end,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(player, MarkEnum.AddMaxCardsInTurn, 1)
    player:drawCards(1, jizhi.name)
  end,
})

return jizhi
