local duyi = fk.CreateSkill {
  name = "shzj_guansuo__duyi",
}

Fk:loadTranslationTable{
  ["shzj_guansuo__duyi"] = "毒医",
  [":shzj_guansuo__duyi"] = "每回合每种牌名限一次，你可以将一张【毒】当【杀】、<a href=':scrape_poison'>【刮骨疗毒】</a>或"..
  "<a href=':cure_poison_with_poison'>【以毒攻毒】</a>使用。",

  ["#shzj_guansuo__duyi"] = "毒医：你可以将一张【毒】当【杀】【刮骨疗毒】或【以毒攻毒】使用",
}

local U = require "packages/utility/utility"

local all_names = {"slash", "scrape_poison", "cure_poison_with_poison"}

duyi:addEffect("viewas", {
  pattern = "slash,scrape_poison,cure_poison_with_poison",
  prompt = "#shzj_guansuo__duyi",
  interaction = function(self, player)
    local names = player:getViewAsCardNames(duyi.name, all_names, nil, player:getTableMark("shzj_guansuo__duyi-turn"))
    if #names == 0 then return end
    return U.CardNameBox {choices = names, all_choices = all_names}
  end,
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).trueName == "poison"
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 or not self.interaction.data then return end
    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcard(cards[1])
    card.skillName = duyi.name
    return card
  end,
  before_use = function (self, player, use)
    player.room:addTableMark(player, "shzj_guansuo__duyi-turn", use.card.name)
  end,
  enabled_at_play = function(self, player)
    return #player:getViewAsCardNames(duyi.name, all_names, nil, player:getTableMark("shzj_guansuo__duyi-turn")) > 0
  end,
  enabled_at_response = function (self, player, response)
    return not response and #player:getViewAsCardNames(duyi.name, all_names, nil, player:getTableMark("shzj_guansuo__duyi-turn")) > 0
  end,
})

duyi:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, "shzj_guansuo__duyi-turn", 0)
end)

return duyi
