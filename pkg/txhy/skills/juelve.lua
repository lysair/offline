local juelve = fk.CreateSkill {
  name = "ofl_tx__juelve",
}

Fk:loadTranslationTable{
  ["ofl_tx__juelve"] = "绝掠",
  [":ofl_tx__juelve"] = "出牌阶段限一次，你可以失去1点体力，消耗任意点<a href='os__baonue_href'>暴虐值</a>，"..
  "获得一名其他角色等量张牌（若选择装备区的牌则需额外消耗1点暴虐值）。",

  ["#ofl_tx__juelve"] = "绝掠：失去1点体力并消耗暴虐值，获得一名角色等量张牌",
}

juelve.os__baonue = true

Fk:addPoxiMethod{
  name = juelve.name,
  card_filter = function(to_select, selected, data)
    local n = Fk:currentRoom():getCardArea(to_select) == Card.PlayerHand and 1 or 2
    for _, id in ipairs(selected) do
      if Fk:currentRoom():getCardArea(id) == Card.PlayerHand then
        n = n + 1
      else
        n = n + 2
      end
    end
    return n <= Self:getMark("@os__baonue")
  end,
  feasible = function(selected)
    return #selected > 0
  end,
  default_choice = function (data, extra_data)
    return {data[1][1]}
  end,
}

juelve:addEffect("active", {
  anim_type = "offensive",
  prompt = "#ofl_tx__juelve",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(juelve.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    if #selected == 0 and to_select ~= player and not to_select:isNude() then
      if to_select:isKongcheng() and player:getMark("@os__baonue") < 2 then
        return false
      end
      return true
    end
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    room:loseHp(player, 1, juelve.name)
    if player.dead or target:isNude() or player:getMark("@os__baonue") < 1 then return end
    if target:isKongcheng() and player:getMark("@os__baonue") < 2 then return end
    local card_data, extra_data, visible_data = {}, {}, {}
    if not target:isKongcheng() then
      table.insert(card_data, { "$Hand", target:getCardIds("h") })
      for _, id in ipairs(target:getCardIds("h")) do
        if not player:cardVisible(id) then
          visible_data[tostring(id)] = false
        end
      end
      if next(visible_data) == nil then visible_data = nil end
      extra_data.visible_data = visible_data
    end
    if #target:getCardIds("e") > 0 then
      table.insert(card_data, { "$Equip", target:getCardIds("e") })
    end
    local result = room:askToPoxi(player, {
      poxi_type = juelve.name,
      data = card_data,
      cancelable = false,
      extra_data = extra_data,
    })
    local n = 0
    for _, id in ipairs(result) do
      if table.contains(target:getCardIds("h"), id) then
        n = n + 1
      else
        n = n + 2
      end
    end
    room:removePlayerMark(player, "@os__baonue", n)
    room:moveCardTo(result, Card.PlayerHand, player, fk.ReasonPrey, juelve.name, nil, false, player)
  end,
})

juelve:addAcquireEffect(function(self, player)
  player.room:addSkill("#os__baonue_mark")
end)

return juelve
