local longdan = fk.CreateSkill({
  name = "ofl_mou__longdan",
})

Fk:loadTranslationTable{
  ["ofl_mou__longdan"] = "龙胆",
  [":ofl_mou__longdan"] = "你可以将一张【杀】当【闪】、【闪】当【杀】使用或打出。每阶段限一次，当你以此法使用或打出牌结算结束后，"..
  "你摸两张牌。",

  ["#ofl_mou__longdan0"] = "龙胆：将一张【杀】当【闪】、【闪】当【杀】使用或打出",
  ["#ofl_mou__longdan1"] = "龙胆：将一张基本牌当任意基本牌使用或打出",

  ["$ofl_mou__longdan1"] = "单骑战破万马群，长坂扬威映斜曛。",
  ["$ofl_mou__longdan2"] = "豪情龙枪随义胆，敢教英雄伏忠魂。",
}

longdan:addEffect("viewas", {
  pattern = ".|.|.|.|.|basic",
  prompt = function (self, player)
    return "#ofl_mou__longdan" .. player:getMark("@@mou__jizhu")
  end,
  interaction = function(self, player)
    local all_names = player:getMark("@@mou__jizhu") == 0 and { "slash", "jink" } or Fk:getAllCardNames("b")
    local names = player:getViewAsCardNames(longdan.name, all_names)
    if #names == 0 then return end
    return UI.CardNameBox { choices = names, all_choices = all_names }
  end,
  filter_pattern = function (self, player, card_name)
    if player:getMark("@@mou__jizhu") == 0 then
      local pat = {
        max_num = 1,
        min_num = 1,
        pattern = "slash,jink",
      }
      if card_name == "slash" then
        pat.pattern = "jink"
      elseif card_name == "jink" then
        pat.pattern = "slash"
      end
      return pat
    else
      return {
        max_num = 1,
        min_num = 1,
        pattern = ".|.|.|.|.|basic",
      }
    end
  end,
  card_filter = function(self, player, to_select, selected)
    if #selected ~= 0 or not self.interaction.data then return false end
    local card = Fk:getCardById(to_select)
    if player:getMark("@@mou__jizhu") == 0 then
      return card.trueName == (self.interaction.data == "jink" and "slash" or "jink")
    else
      return card.type == Card.TypeBasic
    end
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 or not self.interaction.data then return end
    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcard(cards[1])
    card.skillName = longdan.name
    return card
  end,
  enabled_at_response = function (self, player, response)
    if Fk.currentResponsePattern then
      local names = player:getMark("@@mou__jizhu") == 0 and { "slash", "jink" } or Fk:getAllCardNames("b")
      return table.find(names, function (name)
        local card = Fk:cloneCard(name)
        card.skillName = longdan.name
        return Exppattern:Parse(Fk.currentResponsePattern):match(card)
      end)
    end
  end,
})

local spec = {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and not player.dead and
      table.contains(data.card.skillNames, longdan.name) and
      player:usedEffectTimes("#ofl_mou__longdan_2_trig", Player.HistoryPhase) == 0 and
      player:usedEffectTimes("#ofl_mou__longdan_3_trig", Player.HistoryPhase) == 0
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(2, longdan.name)
  end,
}
longdan:addEffect(fk.CardUseFinished, spec)
longdan:addEffect(fk.CardRespondFinished, spec)

return longdan
