local zizhong = fk.CreateSkill {
  name = "zizhong",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["zizhong"] = "自重",
  [":zizhong"] = "锁定技，当你使用或打出一张你本轮未使用过的非装备牌时，你摸X-2张牌；你的手牌上限+X。（X为你的技能数）",

  ["$zizhong1"] = "不自重者取辱，不自贵者无威。",
  ["$zizhong2"] = "尊王攘夷，扩土生杀，圣人为也！",
}

local spec = {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(zizhong.name) and data.card.type ~= Card.TypeEquip and
      #player:getSkillNameList() > 2 then
      local room = player.room
      if not table.contains(player:getTableMark("zizhong-round"), data.card.trueName) then
        local use_events = room.logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
          local use = e.data
          if use.from == player and use.card.trueName == data.card.trueName then
            room:addTableMark(player, "zizhong-round", data.card.trueName)
            return true
          end
        end, Player.HistoryRound)
        if #use_events == 0 then
          use_events = room.logic:getEventsOfScope(GameEvent.RespondCard, 1, function (e)
            local use = e.data
            if use.from == player and use.card.trueName == data.card.trueName then
              room:addTableMark(player, "zizhong-round", data.card.trueName)
              return true
            end
          end, Player.HistoryRound)
        end
        return #use_events == 1 and use_events[1].data == data
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(#player:getSkillNameList() - 2, zizhong.name)
  end,
}

zizhong:addEffect(fk.CardUsing, spec)
zizhong:addEffect(fk.CardResponding, spec)

zizhong:addEffect("maxcards", {
  correct_func = function(self, player)
    if player:hasSkill(zizhong.name) then
      return #player:getSkillNameList()
    end
  end,
})

return zizhong
