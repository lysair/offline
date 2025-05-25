local huxiao = fk.CreateSkill {
  name = "ofl__huxiao",
}

Fk:loadTranslationTable{
  ["ofl__huxiao"] = "虎啸",
  [":ofl__huxiao"] = "回合开始时，你可以进行一次判定，若为基本牌或普通锦囊牌，本回合你可以将相同点数或花色的牌当此判定牌使用。",

  ["@ofl__huxiao-turn"] = "虎啸",
  ["#ofl__huxiao"] = "虎啸：你可以将对应花色或点数的牌当“虎啸”判定牌使用",
}

local U = require "packages/utility/utility"

huxiao:addEffect("viewas", {
  pattern = ".",
  prompt = "#ofl__huxiao",
  interaction = function(self, player)
    local all_names = {}
    for _, info in ipairs(player:getTableMark("ofl__huxiao-turn")) do
      table.insert(all_names, info[1])
    end
    local names = player:getViewAsCardNames(huxiao.name, all_names)
    if #names == 0 then return end
    return U.CardNameBox { choices = names, all_choices = all_names }
  end,
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and
      table.find(player:getTableMark("ofl__huxiao-turn"), function(info)
        return info[2] == Fk:getCardById(to_select).suit or info[3] == Fk:getCardById(to_select).number
      end)
  end,
  view_as = function (self, player, cards)
    if #cards ~= 1 or self.interaction.data == nil then return end
    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcards(cards)
    card.skillName = huxiao.name
    return card
  end,
  enabled_at_play = function (self, player)
    return player:getMark("ofl__huxiao-turn") ~= 0
  end,
  enabled_at_response = function(self, player, response)
    if not response and player:getMark("ofl__huxiao-turn") ~= 0 then
      local all_names = {}
      for _, info in ipairs(player:getTableMark("ofl__huxiao-turn")) do
        table.insert(all_names, info[1])
      end
      return #player:getViewAsCardNames(huxiao.name, all_names) > 0
    end
  end,
})

huxiao:addEffect(fk.TurnStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(huxiao.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local judge = {
      who = player,
      reason = huxiao.name,
      pattern = ".|.|.|.|.|basic,normal_trick",
    }
    room:judge(judge)
    if judge:matchPattern() and not player.dead then
      local info = {judge.card.name, judge.card.suit, judge.card.number}
      room:addTableMark(player, "ofl__huxiao-turn", info)
      room:setPlayerMark(player, "@ofl__huxiao-turn",
        {judge.card:getSuitString(true), judge.card:getNumberStr(), judge.card.name})
    end
  end,
})

return huxiao
