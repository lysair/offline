local xianqi_active = fk.CreateSkill {
  name = "xianqi&",
}

Fk:loadTranslationTable{
  ["xianqi&"] = "献气",
  [":xianqi&"] = "出牌阶段限一次，你可以对自己造成1点伤害或弃置两张手牌，令暗影受到1点无来源伤害。",

  ["#xianqi&"] = "献气：弃置两张手牌，或不选牌对自己造成1点伤害，令暗影受到1点无来源伤害",
}

xianqi_active:addEffect("active", {
  mute = true,
  prompt = "#xianqi&",
  min_card_num = 0,
  max_card_num = 2,
  target_num = 1,
  can_use = function (self, player)
    return table.find(Fk:currentRoom().alive_players, function (p)
      return p:hasSkill("xianqi") and p ~= player and p:usedSkillTimes("xianqi", Player.HistoryPhase) == 0
    end)
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected < 2 and table.contains(player:getHandlyIds(), to_select) and not player:prohibitDiscard(to_select)
  end,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select:hasSkill("xianqi") and to_select:usedSkillTimes("xianqi", Player.HistoryPhase) == 0
  end,
  feasible = function (self, player, selected, selected_cards)
    return #selected == 1 and (#selected_cards == 0 or #selected_cards == 2)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    target:addSkillUseHistory("xianqi", 1)
    target:broadcastSkillInvoke("xianqi")
    room:notifySkillInvoked(target, "xianqi", "negative")
    if #effect.cards > 0 then
      room:throwCard(effect.cards, "xianqi", player, player)
    else
      room:damage{
        from = player,
        to = player,
        damage = 1,
        skillName = "xianqi",
      }
    end
    if not target.dead then
      room:damage{
        to = target,
        damage = 1,
        skillName = "xianqi",
      }
    end
  end,
})

return xianqi_active
