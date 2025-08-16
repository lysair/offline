local qingming = fk.CreateSkill{
  name = "qingming",
}

Fk:loadTranslationTable{
  ["qingming"] = "请命",
  [":qingming"] = "出牌阶段开始时，你可以与“忠绝”角色议事，你不展示意见牌，改为将上一张被使用或打出的牌的颜色作为意见。"..
  "若意见与其相同，你摸两张牌并获得〖烈伐〗，然后跳过本回合的弃牌阶段。",

  ["#qingming-invoke"] = "忠绝：你可以与 %dest 议事（你不展示意见，直接视为%arg）",
}

local U = require "packages/utility/utility"

qingming:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(qingming.name) and player.phase == Player.Play and
      player:getMark("zhongjue") ~= 0 then
      local room = player.room
      local to = room:getPlayerById(player:getMark("zhongjue"))
      if to.dead then
        room:setPlayerMark(player, "zhongjue", 0)
        return
      elseif to:isKongcheng() then
        return
      end
      local color = ""
      if #room.logic:getEventsByRule(GameEvent.UseCard, 1, function (e)
        color = e.data.card:getColorString()
        return true
      end, nil, Player.HistoryGame) == 0 then
        room.logic:getEventsByRule(GameEvent.RespondCard, 1, function (e)
          color = e.data.card:getColorString()
          return true
        end, nil, Player.HistoryGame)
      end
      if color ~= "" then
        event:setCostData(self, {choice = color})
        return true
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local choice = event:getCostData(self).choice
    if room:askToSkillInvoke(player, {
      skill_name = qingming.name,
      prompt = "#qingming-invoke::"..player:getMark("zhongjue")..":"..choice,
    }) then
      event:setCostData(self, {tos = {room:getPlayerById(player:getMark("zhongjue"))}, choice = choice})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(player:getMark("zhongjue"))
    local choice = event:getCostData(self).choice
    local discussion = U.Discussion(player, {player, to}, qingming.name)
    if discussion.color == choice and not player.dead then
      player:drawCards(2, qingming.name)
      if not player.dead then
        player:skip(Player.Discard)
        room:handleAddLoseSkills(player, "liefa")
      end
    end
  end,
})

qingming:addEffect(U.StartDiscussion, {
  can_refresh = function (self, event, target, player, data)
    return target == player and data.reason == qingming.name
  end,
  on_refresh = function (self, event, target, player, data)
    data.results[player] = data.results[player] or {}
    local color = ""
    if #player.room.logic:getEventsByRule(GameEvent.UseCard, 1, function (e)
      color = e.data.card:getColorString()
      return true
    end, nil, Player.HistoryGame) == 0 then
      player.room.logic:getEventsByRule(GameEvent.RespondCard, 1, function (e)
        color = e.data.card:getColorString()
        return true
      end, nil, Player.HistoryGame)
    end
    data.results[player].opinion = color
    player.room:sendLog{
      type = "#SendDiscussionOpinion",
      from = player.id,
      arg = color,
      toast = true,
    }
  end,
})

return qingming
