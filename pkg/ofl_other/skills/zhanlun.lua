local zhanlun = fk.CreateSkill {
  name = "zhanlun",
}

Fk:loadTranslationTable{
  ["zhanlun"] = "战论",
  [":zhanlun"] = "你的【杀】拥有助战：不计次数。此【杀】结算后，根据助战牌的颜色：黑色，你本回合使用的下一张【杀】伤害基数值+1；"..
  "红色，你和本回合参与过助战的角色各摸两张牌，此技能本回合失效。",

  ["#zhanlun-zhuzhan"] = "助战：你可以弃置一张%arg，助战%src使用的%arg2不计次数",
  ["@zhanlun-turn"] = "战论 杀增伤",
}

zhanlun:addEffect(fk.AfterCardUseDeclared, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(zhanlun.name) and
      data.card.trueName == "slash" and player.phase == Player.Play and not data.extraUse then
      if data.extra_data and table.contains(data.extra_data.variation_type or {}, "@zhuzhan") then
        --铜雀，偷懒写法
        data.extraUse = true
        player:addCardUseHistory("slash", -1)
      else
        return true
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player, false), function (p)
      return not p:isKongcheng() and not table.contains(data.tos, p)
    end)
    if #targets > 0 then
      local extra_data = {
        num = 1,
        min_num = 1,
        include_equip = false,
        skillName = "#variation&",
        pattern = ".|.|.|.|.|"..data.card:getTypeString(),
      }
      local dat = {
        "discard_skill",
        "#zhanlun-zhuzhan:"..player.id.."::"..data.card:getTypeString()..":"..data.card:toLogString(),
        true,
        extra_data,
      }
      local req = Request:new(targets, "AskForUseActiveSkill")
      req.focus_text = "@zhuzhan"
      req.n = 1
      for _, p in ipairs(targets) do req:setData(p, dat) end
      req:ask()
      local winner = req.winners[1]
      if winner then
        local result = req:getResult(winner)
        local ids = result
        if result ~= "" then
          if result.card then
            ids = result.card.subcards
          else
            ids = result
          end
        end
        data.extraUse = true
        player:addCardUseHistory("slash", -1)
        local color = Fk:getCardById(ids[1]).color
        if color ~= Card.NoColor then
          data.extra_data = data.extra_data or {}
          data.extra_data.zhanlun = color
        end
        room:throwCard(ids, "#variation&", winner, winner)
      end
    end
  end,
})

zhanlun:addEffect(fk.CardUseFinished, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and not player.dead and data.extra_data and data.extra_data.zhanlun
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local color = data.extra_data.zhanlun
    if color == Card.Black then
      room:addPlayerMark(player, "@zhanlun-turn", 1)
    elseif color == Card.Red then
      room:invalidateSkill(player, zhanlun.name, "-turn")
      player:drawCards(2, zhanlun.name)
      local targets = {}
      room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
        for _, move in ipairs(e.data) do
          if move.from and move.skillName == "#variation&" and move.moveReason == fk.ReasonDiscard then
            table.insertIfNeed(targets, move.from)
          end
        end
      end, Player.HistoryTurn)
      room:sortByAction(targets)
      for _, p in ipairs(targets) do
        if not p.dead then
          p:drawCards(2, zhanlun.name)
        end
      end
    end
  end,
})

zhanlun:addEffect(fk.PreCardUse, {
  can_refresh = function (self, event, target, player, data)
    return target == player and data.card.trueName == "slash" and player:getMark("@zhanlun-turn") > 0
  end,
  on_refresh = function (self, event, target, player, data)
    data.additionalDamage = (data.additionalDamage or 0) + player:getMark("@zhanlun-turn")
    player.room:setPlayerMark(player, "@zhanlun-turn", 0)
  end,
})

return zhanlun
