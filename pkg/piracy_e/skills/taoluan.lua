local taoluan = fk.CreateSkill {
  name = "ofl__taoluan"
}

Fk:loadTranslationTable{
  ["ofl__taoluan"] = "滔乱",
  [":ofl__taoluan"] = "出牌阶段限X次，你可以将一张牌当任意基本牌或普通锦囊牌使用（X为场上有“常侍”标记的角色数，每种牌名每回合限一次）。",

  ["#ofl__taoluan"] = "滔乱：你可以将一张牌当任意基本牌或普通锦囊牌使用",

  ["$ofl__taoluan1"] = "罗绮朱紫，皆若吾等手中傀儡。",
  ["$ofl__taoluan2"] = "吾乃当今帝父，汝岂配与我同列？",
}

taoluan:addEffect("viewas", {
  prompt = "#ofl__taoluan",
  times = function(self, player)
    return player.phase == Player.Play and
      #table.filter(Fk:currentRoom().alive_players, function (p)
        return p:getMark("@@changshi") > 0
      end) - player:usedSkillTimes(taoluan.name, Player.HistoryPhase) or -1
  end,
  interaction = function(self, player)
    local all_names = Fk:getAllCardNames("bt")
    local names = player:getViewAsCardNames(taoluan.name, all_names, nil, player:getTableMark("ofl__taoluan-turn"))
    if #names == 0 then return end
    return UI.CardNameBox { choices = names, all_choices = all_names}
  end,
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk.all_card_types[self.interaction.data] ~= nil
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 or Fk.all_card_types[self.interaction.data] == nil then return end
    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcard(cards[1])
    card.skillName = taoluan.name
    return card
  end,
  before_use = function(self, player, use)
    player.room:addTableMark(player, "ofl__taoluan-turn", use.card.trueName)
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(taoluan.name, Player.HistoryPhase) <
      #table.filter(Fk:currentRoom().alive_players, function (p)
        return p:getMark("@@changshi") > 0
      end)
  end,
})

return taoluan
