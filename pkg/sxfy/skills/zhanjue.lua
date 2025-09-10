
local zhanjue = fk.CreateSkill {
  name = "sxfy__zhanjue",
}

Fk:loadTranslationTable{
  ["sxfy__zhanjue"] = "战绝",
  [":sxfy__zhanjue"] = "出牌阶段限一次，你可以将所有手牌当【决斗】使用，然后你摸一张牌。",

  ["#sxfy__zhanjue"] = "战绝：你可以将所有手牌当【决斗】使用，然后摸一张牌",
}

zhanjue:addEffect("viewas", {
  anim_type = "offensive",
  prompt = "#sxfy__zhanjue",
  card_filter = Util.FalseFunc,
  view_as = function(self, player, cards)
    local card = Fk:cloneCard("duel")
    card:addSubcards(player:getCardIds("h"))
    return card
  end,
  after_use = function(self, player, use)
    if not player.dead then
      player:drawCards(1, zhanjue.name)
    end
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(zhanjue.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
})

return zhanjue
