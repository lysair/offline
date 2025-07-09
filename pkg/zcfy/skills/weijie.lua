local weijie = fk.CreateSkill{
  name = "sxfy__weijie",
}

Fk:loadTranslationTable{
  ["sxfy__weijie"] = "诿解",
  [":sxfy__weijie"] = "每轮限一次，当你需使用基本牌时，你可以弃置一名其他角色的一张手牌，若此牌与你需使用的牌牌名相同，你视为使用此牌。",

  ["#sxfy__weijie"] = "诿解：选择视为使用的基本牌，弃置一名角色一张手牌，若与你需要的牌相同则视为使用之",
  ["#sxfy__weijie-choose"] = "诿解：弃置一名角色的一张手牌，若为【%arg】则视为你使用之",
}

weijie:addEffect("viewas", {
  anim_type = "control",
  pattern = ".|.|.|.|.|basic",
  prompt = "#sxfy__weijie",
  interaction = function(self, player)
    local all_names = Fk:getAllCardNames("b")
    local names = player:getViewAsCardNames(weijie.name, all_names)
    if #names > 0 then
      return UI.CardNameBox { choices = names, all_choices = all_names }
    end
  end,
  card_filter = Util.FalseFunc,
  view_as = function(self, player, cards)
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = weijie.name
    return card
  end,
  before_use = function(self, player)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player, false), function (p)
      return not p:isKongcheng()
    end)
    if #targets == 0 then return "" end
    local name = Fk:cloneCard(self.interaction.data).trueName
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = weijie.name,
      prompt = "#sxfy__weijie-choose:::"..name,
      cancelable = false,
    })[1]
    local card = room:askToChooseCard(player, {
      target = to,
      flag = "h",
      skill_name = weijie.name,
    })
    local yes = Fk:getCardById(card).trueName == name
    room:throwCard(card, weijie.name, to, player)
    if not yes then return "" end
  end,
  enabled_at_play = function (self, player)
    return player:usedSkillTimes(weijie.name, Player.HistoryRound) == 0 and
      table.find(Fk:currentRoom().alive_players, function (p)
        return p ~= player and not p:isKongcheng()
      end)
  end,
  enabled_at_response = function(self, player, response)
    return not response and
      player:usedSkillTimes(weijie.name, Player.HistoryRound) == 0 and
      table.find(Fk:currentRoom().alive_players, function (p)
        return p ~= player and not p:isKongcheng()
      end)
  end,
})

return weijie
