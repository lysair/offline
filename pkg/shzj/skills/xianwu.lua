
local xianwu = fk.CreateSkill {
  name = "xianwu",
}

Fk:loadTranslationTable{
  ["xianwu"] = "显武",
  [":xianwu"] = "当你受到其他角色造成的伤害后，你可以弃置一张牌，直到本轮结束，你可以将一张红色牌当【杀】对其使用，且你对其使用牌无距离限制。",

  ["#xianwu-discard"] = "显武：弃一张牌，本轮你可以将红色牌当【杀】对 %dest 使用且无距离限制",
  ["@@xianwu-round"] = "显武",
  ["#xianwu"] = "显武：你可以将一张红色牌当【杀】对“显武”目标使用",
}

xianwu:addEffect("viewas", {
  anim_type = "offensive",
  pattern = "slash",
  prompt = "#xianwu",
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).color == Card.Red
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return end
    local c = Fk:cloneCard("slash")
    c.skillName = xianwu.name
    c:addSubcards(cards)
    return c
  end,
  enabled_at_play = function(self, player)
    return table.find(Fk:currentRoom().alive_players, function (p)
      return table.contains(p:getTableMark("@@xianwu-round"), player.id)
    end)
  end,
  enabled_at_response = function(self, player, response)
    return not response and table.find(Fk:currentRoom().alive_players, function (p)
      return table.contains(p:getTableMark("@@xianwu-round"), player.id)
    end)
  end,
})

xianwu:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xianwu.name) and
      data.from and data.from ~= player and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local card = room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = xianwu.name,
      prompt = "#xianwu-discard::"..data.from.id,
      cancelable = true,
      skip = true,
    })
    if #card > 0 then
      event:setCostData(self, {tos = {target}, cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(event:getCostData(self).cards, xianwu.name, player, player)
    if not data.from.dead and not player.dead then
      room:addTableMarkIfNeed(data.from, "@@xianwu-round", player.id)
    end
  end,
})

xianwu:addEffect("prohibit", {
  is_prohibited = function(self, from, to, card)
    return card and table.contains(card.skillNames, xianwu.name) and
      not table.contains(to:getTableMark("@@xianwu-round"), from.id)
  end,
})

xianwu:addEffect("targetmod", {
  bypass_distances = function(self, player, skill, card, to)
    return card and to and table.contains(to:getTableMark("@@xianwu-round"), player.id)
  end,
})

xianwu:addLoseEffect(function (self, player, is_death)
  local room = player.room
  for _, p in ipairs(room.alive_players) do
    room:removeTableMark(p, "@@xianwu-round", player.id)
  end
end)

return xianwu
