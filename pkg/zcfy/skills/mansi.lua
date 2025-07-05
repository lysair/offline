local mansi = fk.CreateSkill {
  name = "sxfy__mansi",
}

Fk:loadTranslationTable{
  ["sxfy__mansi"] = "蛮嗣",
  [":sxfy__mansi"] = "出牌阶段限一次，你可以将所有手牌当【南蛮入侵】使用（至少一张）。",

  ["#sxfy__mansi"] = "蛮嗣：你可以将所有手牌当【南蛮入侵】使用",
}

mansi:addEffect("viewas", {
  anim_type = "offensive",
  prompt = "#sxfy__mansi",
  card_filter = Util.FalseFunc,
  view_as = function(self, player, cards)
    local card = Fk:cloneCard("savage_assault")
    card:addSubcards(player:getCardIds("h"))
    card.skillName = mansi.name
    return card
  end,
  enabled_at_play = function(self, player)
    return player:usedEffectTimes(self.name, Player.HistoryPhase) == 0 and not player:isKongcheng() and
      #player:getViewAsCardNames(mansi.name, {"savage_assault"}, player:getCardIds("h")) > 0
  end,
})

return mansi
