local houying = fk.CreateSkill {
  name = "ofl__houying",
}

Fk:loadTranslationTable{
  ["ofl__houying"] = "后应",
  [":ofl__houying"] = "出牌阶段，你可以弃置两张黑色牌并视为使用一张无次数限制的【杀】，若你造成了伤害，你摸一张张牌。",

  ["#ofl__houying"] = "后应：弃置两张黑色牌视为使用【杀】，若你造成伤害则摸一张牌",
}

houying:addEffect("viewas", {
  anim_type = "offensive",
  prompt = "#ofl__houying",
  card_filter = function(self, player, to_select, selected)
    return #selected < 2 and Fk:getCardById(to_select).color == Card.Black and not player:prohibitDiscard(to_select)
  end,
  view_as = function(self, player, cards)
    if #cards ~= 2 then return end
    local card = Fk:cloneCard("slash")
    card.skillName = houying.name
    self.cost_data = cards
    return card
  end,
  before_use = function(self, player, use)
    use.extraUse = true
    player.room:throwCard(self.cost_data, houying.name, player, player)
  end,
  after_use = function (self, player, use)
    if not player.dead and use.damageDealt and
      table.find(player.room:getOtherPlayers(player, false, true), function (p)
        return use.damageDealt[p] ~= nil
      end) ~= nil then
      player:drawCards(1, houying.name)
    end
  end,
})

houying:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card)
    return skill.trueName == "slash_skill" and scope == Player.HistoryPhase and card and
      table.contains(card.skillNames, houying.name)
  end,
})

return houying
