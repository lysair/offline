local lifengs = fk.CreateSkill {
  name = "lifengs"
}

Fk:loadTranslationTable{
  ["lifengs"] = "厉锋",
  [":lifengs"] = "出牌阶段限一次，你可以获得弃牌堆中的一张装备牌。你可以赠予手牌或装备区内的装备牌。",

  ["#lifengs"] = "厉锋：你可以获得弃牌堆中的一张装备牌",
}

lifengs:addEffect("active", {
  anim_type = "drawcard",
  prompt = "#lifengs",
  card_num = 1,
  target_num = 0,
  expand_pile = function (self)
    return table.filter(Fk:currentRoom().discard_pile, function (id)
      return Fk:getCardById(id).type == Card.TypeEquip
    end)
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(lifengs.name, Player.HistoryPhase) == 0 and
      table.find(Fk:currentRoom().discard_pile, function (id)
        return Fk:getCardById(id).type == Card.TypeEquip
      end)
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and table.contains(Fk:currentRoom().discard_pile, to_select)
  end,
  on_use = function(self, room, effect)
    room:moveCardTo(effect.cards, Card.PlayerHand, effect.from, fk.ReasonJustMove, lifengs.name, nil, true, effect.from)
  end
})

lifengs:addAcquireEffect(function (self, player, is_start)
  local room = player.room
  if player:hasSkill("present_skill&", true) then
    room:handleAddLoseSkills(player, "-present_skill&|lifengs_present_skill&", nil, false, true)
  else
    room:handleAddLoseSkills(player, "lifengs_present_skill&", nil, false, true)
  end
end)

lifengs:addLoseEffect(function (self, player, is_death)
  local room = player.room
  if table.find(room:getOtherPlayers(player, false), function (p)
    return p:hasSkill("present_skill&", true)
  end) then
    room:handleAddLoseSkills(player, "-lifengs_present_skill&|present_skill&", nil, false, true)
  else
    room:handleAddLoseSkills(player, "-lifengs_present_skill&", nil, false, true)
  end
end)

return lifengs
