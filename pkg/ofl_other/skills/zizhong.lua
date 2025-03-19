local zizhong = fk.CreateSkill {
  name = "zizhong"
}

Fk:loadTranslationTable{
  ['zizhong'] = '自重',
  [':zizhong'] = '锁定技，当你使用或打出一张你本轮未使用过的非装备牌时，你摸X-2张牌；你的手牌上限+X。（X为你的技能数）',
  ['$zizhong1'] = '不自重者取辱，不自贵者无威。',
  ['$zizhong2'] = '尊王攘夷，扩土生杀，圣人为也！',
}

zizhong:addEffect(fk.CardUsing, {
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(zizhong.name) and data.card.type ~= Card.TypeEquip and
      #table.filter(player.player_skills, function(skill)
        return skill:isPlayerSkill(player) and skill.visible
      end) > 2 then
      local room = player.room
      local logic = room.logic
      local current_event = logic:getCurrentEvent()
      local mark_name = "zizhong_" .. data.card.trueName .. "-round"
      local mark = player:getMark(mark_name)
      if mark == 0 then
        logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
          local use = e.data[1]
          if use.from == player.id and use.card.trueName == data.card.trueName then
            mark = e.id
            room:setPlayerMark(player, mark_name, mark)
            return true
          end
          return false
        end, Player.HistoryRound)
        logic:getEventsOfScope(GameEvent.RespondCard, 1, function (e)
          local use = e.data[1]
          if use.from == player.id and use.card.trueName == data.card.trueName then
            mark = math.max(e.id, mark)
            room:setPlayerMark(player, mark_name, mark)
            return true
          end
          return false
        end, Player.HistoryRound)
      end
      return mark == current_event.id
    end
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(#table.filter(player.player_skills, function(skill) return skill:isPlayerSkill(player) end) - 2, zizhong.name)
  end,
})

zizhong:addEffect(fk.CardResponding, {
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(zizhong.name) and data.card.type ~= Card.TypeEquip and
      #table.filter(player.player_skills, function(skill)
        return skill:isPlayerSkill(player) and skill.visible
      end) > 2 then
      local room = player.room
      local logic = room.logic
      local current_event = logic:getCurrentEvent()
      local mark_name = "zizhong_" .. data.card.trueName .. "-round"
      local mark = player:getMark(mark_name)
      if mark == 0 then
        logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
          local use = e.data[1]
          if use.from == player.id and use.card.trueName == data.card.trueName then
            mark = e.id
            room:setPlayerMark(player, mark_name, mark)
            return true
          end
          return false
        end, Player.HistoryRound)
        logic:getEventsOfScope(GameEvent.RespondCard, 1, function (e)
          local use = e.data[1]
          if use.from == player.id and use.card.trueName == data.card.trueName then
            mark = math.max(e.id, mark)
            room:setPlayerMark(player, mark_name, mark)
            return true
          end
          return false
        end, Player.HistoryRound)
      end
      return mark == current_event.id
    end
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(#table.filter(player.player_skills, function(skill) return skill:isPlayerSkill(player) end) - 2, zizhong.name)
  end,
})

local zizhong_maxcards_spec = {
  main_skill = zizhong,
  correct_func = function(self, player)
    if player:hasSkill(zizhong.name) then
      return #table.filter(player.player_skills, function(skill)
        return skill:isPlayerSkill(player) and skill.visible
      end)
    else
      return 0
    end
  end,
}

zizhong:addEffect('maxcards', zizhong_maxcards_spec)

return zizhong
