local qianfu = fk.CreateSkill{
  name = "qianfu",
}

Fk:loadTranslationTable{
  ["qianfu"] = "搴芙",
  [":qianfu"] = "每回合限一次，你可以视为使用一张基本牌，然后摸三张牌。若指定了女性角色为目标，其加1点体力上限。",

  ["#qianfu"] = "搴芙：视为使用一张基本牌，然后摸三张牌",
}

qianfu:addEffect("viewas", {
  pattern = ".|.|.|.|.|basic|",
  prompt = "#qianfu",
  interaction = function(self, player)
    local all_names = Fk:getAllCardNames("b")
    local names = player:getViewAsCardNames(qianfu.name, all_names)
    if #names == 0 then return end
    return UI.CardNameBox { choices = names, all_choices = all_names }
  end,
  card_filter = Util.FalseFunc,
  view_as = function(self, player, cards)
    if self.interaction.data == nil then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = qianfu.name
    return card
  end,
  after_use = function(self, player, use)
    local room = player.room
    if not player.dead then
      player:drawCards(3, qianfu.name)
    end
    for _, p in ipairs(room:getAlivePlayers()) do
      if table.contains(use.tos, p) and p:isFemale() and not p.dead then
        room:changeMaxHp(p, 1)
      end
    end
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(qianfu.name, Player.HistoryTurn) == 0
  end,
  enabled_at_response = function(self, player, response)
    return not response and player:usedSkillTimes(qianfu.name, Player.HistoryTurn) == 0 and
      #player:getViewAsCardNames(qianfu.name, Fk:getAllCardNames("b")) > 0
  end,
})

return qianfu
