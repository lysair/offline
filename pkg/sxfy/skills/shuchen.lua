local shuchen = fk.CreateSkill {
  name = "sxfy__shuchen",
}

Fk:loadTranslationTable{
  ["sxfy__shuchen"] = "疏陈",
  [":sxfy__shuchen"] = "你的回合外，你可以将超出手牌上限部分的手牌当一张【桃】使用。",

  ["#sxfy__shuchen"] = "疏陈：你可以%arg张手牌当一张【桃】使用",
}

shuchen:addEffect("viewas", {
  anim_type = "support",
  pattern = "peach",
  prompt = function (self, player)
    return "#sxfy__shuchen:::"..(player:getHandcardNum() - player:getMaxCards())
  end,
  card_filter = function(self, player, to_select, selected)
    return table.contains(player:getCardIds("h"), to_select) and #selected < (player:getHandcardNum() - player:getMaxCards())
  end,
  view_as = function(self, player, cards)
    if #cards ~= (player:getHandcardNum() - player:getMaxCards()) then return end
    local c = Fk:cloneCard("peach")
    c.skillName = shuchen.name
    c:addSubcards(cards)
    return c
  end,
  enabled_at_play = Util.FalseFunc,
  enabled_at_response = function(self, player, response)
    return not response and Fk:currentRoom().current ~= player and player:getHandcardNum() > player:getMaxCards()
  end,
})

return shuchen
