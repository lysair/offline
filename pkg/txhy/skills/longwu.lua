
local longwu = fk.CreateSkill {
  name = "ofl_tx__longwu",
}

Fk:loadTranslationTable{
  ["ofl_tx__longwu"] = "龙舞",
  [":ofl_tx__longwu"] = "若没有角色处于濒死状态，你可以将一张牌当任意基本牌或普通锦囊牌使用或打出（每种牌名每轮限一次），"..
  "若转化前后的牌类别不同，你可以获得一名本回合未以此法选择过的其他角色的一张牌。",

  ["#ofl_tx__longwu"] = "龙舞：将一张牌当任意基本牌或普通锦囊牌使用",
  ["@$ofl_tx__longwu-round"] = "龙舞",
  ["#ofl_tx__longwu-choose"] = "龙舞：你可以获得一名其他角色一张牌",
}

longwu:addEffect("viewas", {
  pattern = ".",
  prompt = "#ofl_tx__longwu",
  interaction = function(self, player)
    local all_names = Fk:getAllCardNames("bt")
    local names = player:getViewAsCardNames(longwu.name, all_names, nil, player:getTableMark("@$ofl_tx__longwu-round"))
    if #names == 0 then return end
    return UI.CardNameBox { choices = names, all_choices = all_names }
  end,
  handly_pile = true,
  filter_pattern = {
    min_num = 1,
    max_num = 1,
    pattern = ".",
  },
  view_as = function(self, player, cards)
    if #cards ~= 1 or Fk.all_card_types[self.interaction.data] == nil then return end
    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcard(cards[1])
    card.skillName = longwu.name
    return card
  end,
  before_use = function(self, player, use)
    player.room:addTableMark(player, "@$ofl_tx__longwu-round", use.card.trueName)
    if use.card.type ~= Fk:getCardById(Card:getIdList(use.card)[1], true).type then
      use.extra_data = use.extra_data or {}
      use.extra_data.ofl_tx__longwu = true
    end
  end,
  after_use = function(self, player, use)
    if player.dead or not (use.extra_data and use.extra_data.ofl_tx__longwu) then return end
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player, false), function (p)
      return not table.contains(player:getTableMark("ofl_tx__longwu-turn"), p.id) and not p:isNude()
    end)
    if #targets == 0 then return end
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = longwu.name,
      prompt = "#ofl_tx__longwu-choose",
      cancelable = true,
    })
    if #to > 0 then
      to = to[1]
      room:addTableMark(player, "ofl_tx__longwu-turn", to.id)
      local card = room:askToChooseCard(player, {
        target = to,
        flag = "he",
        skill_name = longwu.name,
      })
      room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonPrey, longwu.name, nil, false, player)
    end
  end,
  enabled_at_play = function(self, player)
    return table.every(Fk:currentRoom().alive_players, function(p)
      return not p.dying
    end)
  end,
  enabled_at_response = function(self, player, response)
    return table.every(Fk:currentRoom().alive_players, function(p)
      return not p.dying
    end) and
    #player:getViewAsCardNames(longwu.name, Fk:getAllCardNames("bt"), nil, player:getTableMark("@$ofl_tx__longwu-round")) > 0
  end,
})

longwu:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, "@$ofl_tx__longwu-round", 0)
end)

return longwu
