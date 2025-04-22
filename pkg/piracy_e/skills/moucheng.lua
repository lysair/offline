local moucheng = fk.CreateSkill {
  name = "ofl__moucheng",
}

Fk:loadTranslationTable{
  ["ofl__moucheng"] = "谋逞",
  [":ofl__moucheng"] = "每回合限一次，你可以将一张黑色牌当【借刀杀人】使用。",

  ["#ofl__moucheng"] = "谋逞：你可以将一张黑色牌当【借刀杀人】使用",
}

moucheng:addEffect("viewas", {
  anim_type = "control",
  pattern = "collateral",
  prompt = "#ofl__moucheng",
  handly_pile = true,
  card_filter = function (self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).color == Card.Black
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard("collateral")
    card.skillName = moucheng.name
    card:addSubcard(cards[1])
    return card
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(moucheng.name, Player.HistoryTurn) == 0
  end,
  enabled_at_response = function (self, player, response)
    return not response and player:usedSkillTimes(moucheng.name, Player.HistoryTurn) == 0
  end,
})

return moucheng
