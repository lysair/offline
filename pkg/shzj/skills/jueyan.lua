local jueyan = fk.CreateSkill {
  name = "shzj_juedai__jueyan",
}

Fk:loadTranslationTable{
  ["shzj_juedai__jueyan"] = "决堰",
  [":shzj_juedai__jueyan"] = "出牌阶段限一次，你可以废除你装备区里的一种装备栏，然后执行对应的一项：<br>"..
  "武器栏，你本回合使用牌无次数限制；"..
  "防具栏，你摸三张牌并跳过本回合的弃牌阶段；<br>"..
  "坐骑栏，你本回合使用牌无距离限制且不能被响应；<br>"..
  "宝物栏，本回合获得〖集智〗。",

  ["#shzj_juedai__jueyan"] = "决堰：废除一种装备栏执行效果：<br>"..
  "武器栏-本回合使用牌无次数限制；  防具栏，摸三张牌并跳过弃牌阶段<br>"..
  "坐骑栏-本回合使用牌无距离限制且不能被响应；  宝物栏，本回合获得“集智”",

  ["$shzj_juedai__jueyan1"] = "水路粮道既断，敌又可复进乎？",
  ["$shzj_juedai__jueyan2"] = "决堤纵水之法，如扼敌要腕！",
}

jueyan:addEffect("active", {
  anim_type = "offensive",
  prompt = "#shzj_juedai__jueyan",
  card_num = 0,
  target_num = 0,
  interaction = function(self, player)
    local choices = {}
    for _, slot in ipairs(player:getAvailableEquipSlots()) do
      if slot == Player.OffensiveRideSlot or slot == Player.DefensiveRideSlot then
        table.insertIfNeed(choices, "RideSlot")
      else
        table.insert(choices, slot)
      end
    end
    if #choices == 0 then return end
    return UI.ComboBox {choices = choices}
  end,
  can_use = function (self, player)
    return #player:getAvailableEquipSlots() > 0 and player:usedSkillTimes(jueyan.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    local choice = self.interaction.data
    if choice == "RideSlot" then
      choice = {Player.OffensiveRideSlot, Player.DefensiveRideSlot}
    end
    room:abortPlayerArea(player, choice)
    if player.dead then return end
    if choice == "WeaponSlot" then
      room:setPlayerMark(player, "shzj_juedai__jueyan_weapon-turn", 1)
    elseif choice == "ArmorSlot" then
      player:skip(Player.Discard)
      player:drawCards(3, jueyan.name)
    elseif choice == "TreasureSlot" then
      if not player:hasSkill("ex__jizhi", true) then
        room:handleAddLoseSkills(player, "ex__jizhi", nil, true, false)
        room.logic:getCurrentEvent():findParent(GameEvent.Turn):addCleaner(function()
          room:handleAddLoseSkills(player, "-ex__jizhi", nil, true, false)
        end)
      end
    else
      room:addPlayerMark(player, "shzj_juedai__jueyan_horse-turn")
    end
  end,
})

jueyan:addEffect(fk.CardUsing, {
  anim_type = "offensive",
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and player:getMark("shzj_juedai__jueyan_horse-turn") > 0 and
      (data.card.trueName == "slash" or data.card:isCommonTrick())
  end,
  on_use = function (self, event, target, player, data)
    data.disresponsiveList = table.simpleClone(player.room.players)
  end,
})

jueyan:addEffect("targetmod", {
  bypass_distances = function(self, player, skill, card)
    return card and player:getMark("shzj_juedai__jueyan_horse-turn") > 0
  end,
  bypass_times = function (self, player, skill, scope, card, to)
    return card and player:getMark("shzj_juedai__jueyan_weapon-turn") > 0
  end,
})

return jueyan
