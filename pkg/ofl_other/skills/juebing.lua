
local juebing = fk.CreateSkill {
  name = "juebing",
}

Fk:loadTranslationTable{
  ["juebing"] = "谲兵",
  [":juebing"] = "你可以将一张非【杀】手牌当【杀】使用，以此法使用的【杀】仅能被目标角色将一张非【闪】手牌当【闪】使用来响应。"..
  "若以此法使用的【杀】造成伤害，此【杀】不计入次数限制。此【杀】结算结束后，你和唯一目标角色依次可以使用弃牌堆中一张双方用于转化的牌。",

  ["#juebing"] = "谲兵：将一张非【杀】手牌当【杀】使用，目标只能用一张非【闪】手牌当【闪】使用来响应",
  ["#juebing-use"] = "谲兵：你可以使用一张用于转化的牌",
}

juebing:addEffect("viewas", {
  anim_type = "offensive",
  pattern = "slash",
  prompt = "#juebing",
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and table.contains(player:getHandlyIds(), to_select) and
      Fk:getCardById(to_select).trueName ~= "slash"
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return end
    local c = Fk:cloneCard("slash")
    c.skillName = juebing.name
    c:addSubcards(cards)
    return c
  end,
  before_use = function (self, player, use)
    for _, p in ipairs(use.tos) do
      player.room:handleAddLoseSkills(p, "juebing&", nil, false, true)
    end
  end,
  after_use = function (self, player, use)
    local room = player.room
    for _, p in ipairs(room.players) do
      room:handleAddLoseSkills(p, "-juebing&", nil, false, true)
    end
    if use.damageDealt and not use.extraUse then
      use.extraUse = true
      player:addCardUseHistory("slash", -1)
    end
    local ids = table.simpleClone(Card:getIdList(use.card))
    if use.cardsResponded then
      for _, c in ipairs(use.cardsResponded) do
        table.insertTableIfNeed(ids, Card:getIdList(c))
      end
    end
    ids = table.filter(ids, function (id)
      return table.contains(room.discard_pile, id)
    end)
    if #ids == 0 then return end
    if not player.dead then
      room:askToUseRealCard(player, {
        pattern = ids,
        skill_name = juebing.name,
        prompt = "#juebing-use",
        extra_data = {
          bypass_times = true,
          extraUse = true,
          expand_pile = ids,
        }
      })
    end
    if #use.tos == 1 and not use.tos[1].dead then
      ids = table.filter(ids, function (id)
        return table.contains(room.discard_pile, id)
      end)
      if #ids == 0 then return end
      room:askToUseRealCard(use.tos[1], {
        pattern = ids,
        skill_name = juebing.name,
        prompt = "#juebing-use",
        extra_data = {
          bypass_times = true,
          extraUse = true,
          expand_pile = ids,
        }
      })
    end
  end,
  enabled_at_response = function (self, player, response)
    return not response
  end,
})

juebing:addEffect(fk.HandleAskForPlayCard, {
  can_refresh = function(self, event, target, player, data)
    return data.eventData and data.eventData.from == player and data.eventData.card.trueName == "slash" and
      table.contains(data.eventData.card.skillNames, juebing.name)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if not data.afterRequest then
      room:setBanner(juebing.name, 1)
    else
      room:setBanner(juebing.name, 0)
    end
  end,
})

--此段用于绕过八卦阵
juebing:addEffect(fk.AskForCardUse, {
  can_refresh = function(self, event, target, player, data)
    return target == player and data.eventData and table.contains(data.eventData.card.skillNames, juebing.name)
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setBanner(juebing.name, 1)
  end,
})
juebing:addEffect(fk.AskForCardUse, {
  late_refresh = true,
  can_refresh = function(self, event, target, player, data)
    return target == player and data.eventData and table.contains(data.eventData.card.skillNames, juebing.name)
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setBanner(juebing.name, 0)
  end,
})

juebing:addEffect("prohibit", {
  prohibit_use = function(self, player, card)
    if card and Fk:currentRoom():getBanner(juebing.name) then
      return not table.contains(card.skillNames, "juebing&")
    end
  end,
})

--如果还是被绕过（eg.护驾），则康掉
juebing:addEffect(fk.PreCardEffect, {
  can_refresh = function(self, event, target, player, data)
    return target == player and data.card.name == "jink" and
      data.toCard and table.contains(data.toCard.skillNames, juebing.name) and
      not table.contains(data.card.skillNames, "juebing&")
    end,
  on_refresh = function (self, event, target, player, data)
    data.nullified = true
  end,
})

return juebing
