local liefa = fk.CreateSkill {
  name = "liefa",
}

Fk:loadTranslationTable{
  ["liefa"] = "烈伐",
  [":liefa"] = "你可以视为使用一张目标不包含你的基本牌，然后选择一项：1.失去1点体力或失去本技能；2.弃置两张牌。",

  ["#liefa"] = "烈伐：视为使用一张基本牌使用（目标不能为你），然后失去体力、失去此技能或弃两张牌",
  ["liefa_lose"] = "失去“烈伐”",
}

liefa:addEffect("viewas", {
  anim_type = "special",
  pattern = ".|.|.|.|.|basic",
  prompt = "#liefa",
  filter_pattern = {
    min_num = 0,
    max_num = 0,
    pattern = "",
    subcards = {}
  },
  interaction = function(self, player)
    local all_names = Fk:getAllCardNames("b")
    local names = player:getViewAsCardNames(liefa.name, all_names)
    if #names == 0 then return end
    return UI.CardNameBox { choices = names, all_choices = all_names }
  end,
  card_filter = Util.FalseFunc,
  view_as = function(self, player, cards)
    if self.interaction.data == nil or #cards ~= 0 then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = liefa.name
    return card
  end,
  after_use = function (self, player, use)
    local room = player.room
    if player.dead then return end
    local choices = {"loseHp"}
    if player:hasSkill(liefa.name, true) then
      table.insert(choices, "liefa_lose")
    end
    if #table.filter(player:getCardIds("he"), function (id)
      return not player:prohibitDiscard(id)
    end) > 1 then
      table.insert(choices, "discard2")
    end
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = liefa.name,
    })
    if choice == "loseHp" then
      room:loseHp(player, 1, liefa.name)
    elseif choice == "liefa_lose" then
      room:handleAddLoseSkills(player, "-liefa")
    elseif choice == "discard2" then
      room:askToDiscard(player, {
        min_num = 2,
        max_num = 2,
        include_equip = true,
        skill_name = liefa.name,
        cancelable = false,
      })
    end
  end,
  enabled_at_response = function (self, player, response)
    return not response
  end,
})

liefa:addEffect("prohibit", {
  is_prohibited = function (self, from, to, card)
    return card and table.contains(card.skillNames, liefa.name) and from == to
  end,
})

return liefa
