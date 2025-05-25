local longyin = fk.CreateSkill {
  name = "ofl__longyin",
}

Fk:loadTranslationTable{
  ["ofl__longyin"] = "龙吟",
  [":ofl__longyin"] = "每回合限一次，你可以将任意张点数之和为13的牌当任意基本牌或普通锦囊牌使用或打出。",

  ["#ofl__longyin"] = "龙吟：将点数之和为13的牌当任意基本牌或普通锦囊牌使用或打出",
}

local U = require "packages/utility/utility"

longyin:addEffect("viewas", {
  pattern = ".",
  prompt = "#ofl__longyin",
  interaction = function(self, player)
    local all_names = Fk:getAllCardNames("bt")
    local names = player:getViewAsCardNames(longyin.name, all_names)
    if #names == 0 then return end
    return U.CardNameBox { choices = names, all_choices = all_names }
  end,
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    local num = 0
    for _, id in ipairs(selected) do
      num = num + Fk:getCardById(id).number
    end
    return num + Fk:getCardById(to_select).number <= 13
  end,
  view_as = function (self, player, cards)
    if self.interaction.data == nil then return end
    local num = 0
    for _, id in ipairs(cards) do
      num = num + Fk:getCardById(id).number
    end
    if num ~= 13 then return end
    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcards(cards)
    card.skillName = longyin.name
    return card
  end,
  enabled_at_play = function (self, player)
    return player:usedSkillTimes(longyin.name, Player.HistoryTurn) == 0
  end,
  enabled_at_response = function(self, player, response)
    return player:usedSkillTimes(longyin.name, Player.HistoryTurn) == 0 and
      #player:getViewAsCardNames(longyin.name, Fk:getAllCardNames("bt")) > 0
  end,
})

return longyin
