local jishe = fk.CreateSkill {
  name = "sxfy__jishe",
}

Fk:loadTranslationTable{
  ["sxfy__jishe"] = "极奢",
  [":sxfy__jishe"] = "出牌阶段，你可以令本回合手牌上限-1（至少为0），然后摸一张牌。",

  ["#sxfy__jishe"] = "极奢：本回合手牌上限-1，摸一张牌",
}

jishe:addEffect("active", {
  anim_type = "drawcard",
  card_num = 0,
  target_num = 0,
  prompt = "#sxfy__jishe",
  can_use = function(self, player)
    return player:getMaxCards() > 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    room:addPlayerMark(player, MarkEnum.MinusMaxCardsInTurn, 1)
    player:drawCards(1, jishe.name)
  end,
})

return jishe
