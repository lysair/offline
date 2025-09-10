local xiongshi = fk.CreateSkill {
  name = "ofl__xiongshi",
  derived_piles = "ofl__xiongshi",
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
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(xiongshi.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and table.contains(player:getCardIds("h"), to_select)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    player:addToPile(xiongshi.name, effect.cards, false, xiongshi.name, player)
  end,
})

return xiongshi
