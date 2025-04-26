local xiongshi = fk.CreateSkill {
  name = "ofl__xiongshi",
  attached_skill_name = "ofl__xiongshi&",
}

Fk:loadTranslationTable{
  ["ofl__xiongshi"] = "凶势",
  [":ofl__xiongshi"] = "每名角色出牌阶段限一次，其可以将一张手牌置于你武将牌上。",

  ["#ofl__xiongshi"] = "凶势：你可以将一张手牌置于你武将牌上",
}

xiongshi:addEffect("active", {
  anim_type = "support",
  prompt = "#ofl__xiongshi",
  card_num = 1,
  target_num = 1,
  derived_piles = "ofl__xiongshi",
  can_use = function(self, player)
    return table.find(Fk:currentRoom().alive_players, function (p)
      return p:hasSkill("ofl__xiongshi") and p:usedSkillTimes("ofl__xiongshi", Player.HistoryPhase) == 0
    end)
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and table.contains(player:getCardIds("h"), to_select)
  end,
  target_filter = function(self, player, to_select, selected, cards)
    if #selected == 0 then
      local targets = table.filter(Fk:currentRoom().alive_players, function (p)
        return p:hasSkill("ofl__xiongshi") and p:usedSkillTimes("ofl__xiongshi", Player.HistoryPhase) == 0
      end)
      if #targets == 1 and targets[1] == player then
        return false
      else
        return true
      end
    end
  end,
  on_use = function(self, room, effect)
    local target = effect.from
    if #effect.tos == 1 then
      target = effect.tos[1]
      target:addSkillUseHistory(xiongshi.name, 1)
      effect.from:addSkillUseHistory(xiongshi.name, -1)
    end
    target:addToPile(xiongshi.name, effect.cards, false, xiongshi.name, effect.from)
  end,
})

return xiongshi
