local sheji = fk.CreateSkill {
  name = "ofl__sheji",
}

Fk:loadTranslationTable{
  ["ofl__sheji"] = "射戟",
  [":ofl__sheji"] = "出牌阶段限一次，你可以将所有手牌当一张无距离限制的【杀】使用，若对目标角色造成伤害，你获得其装备区的武器和坐骑牌。",

  ["#ofl__sheji"] = "射戟：将所有手牌当一张无距离限制的【杀】使用，若造成伤害则获得目标角色的武器和坐骑",
}

sheji:addEffect("viewas", {
  anim_type = "offensive",
  prompt = "#ofl__sheji",
  card_filter = Util.FalseFunc,
  view_as = function(self, player, cards)
    local card = Fk:cloneCard("slash")
    card:addSubcards(player:getCardIds("h"))
    card.skillName = sheji.name
    return card
  end,
  before_use = function (self, player, use)
    use.extra_data = use.extra_data or {}
    use.extra_data.shejiUser = player.id
  end,
  after_use = function (self, player, use)
    local room = player.room
    if use.damageDealt and not player.dead then
      for _, p in ipairs(room:getAlivePlayers()) do
        if not p.dead and table.contains(use.tos, p) and use.damageDealt[p] then
          local cards = p:getEquipments(Card.SubtypeWeapon)
          table.insertTable(cards, p:getEquipments(Card.SubtypeDefensiveRide))
          table.insertTable(cards, p:getEquipments(Card.SubtypeOffensiveRide))
          if #cards > 0 then
            room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonPrey, sheji.name, nil, true, player)
            if player.dead then return end
          end
        end
      end
    end
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(sheji.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
})

sheji:addEffect("targetmod", {
  bypass_distances = function (self, player, skill, card, to)
    return card and table.contains(card.skillNames, sheji.name)
  end,
})

sheji:addAI(nil, "vs_skill")

return sheji
