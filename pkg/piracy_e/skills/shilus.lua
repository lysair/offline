local shilus = fk.CreateSkill {
  name = "ofl__shilus",
}

Fk:loadTranslationTable{
  ["ofl__shilus"] = "嗜戮",
  [":ofl__shilus"] = "其他角色死亡后，你可以将其武将牌置为“戮”；当你杀死其他角色后，你从武将牌堆获得两张“戮”。"..
  "回合开始时，你可以弃置至多X张牌（X为“戮”数），摸等量的牌。",

  ["@&massacre"] = "戮",
  ["#ofl__shilus-cost"] = "嗜戮：你可以弃置至多%arg张牌，摸等量的牌",
  ["#ofl__shilus-invoke"] = "嗜戮：是否将 %dest 的武将牌置为“戮”？",

  ["$ofl__shilus1"] = "以杀立威，谁敢反我？",
  ["$ofl__shilus2"] = "将这些乱臣贼子，尽皆诛之！",
}

shilus:addEffect(fk.Deathed, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(shilus.name)
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local yes = false
    if room:askToSkillInvoke(player, {
      skill_name = shilus.name,
      prompt = "#ofl__shilus-invoke::"..target.id,
    }) then
      yes = true
      event:setCostData(self, {tos = {target}})
    end
    if data.killer == player and not yes then
      event:setCostData(self, nil)
      yes = true
    end
    return yes
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local generals = {}
    if event:getCostData(self) then
      if target.general and target.general ~= "" and target.general ~= "hiddenone" then
        room:findGeneral(target.general)
        table.insert(generals, target.general)
      end
      if target.deputyGeneral and target.deputyGeneral ~= "" and target.deputyGeneral ~= "hiddenone" then
        room:findGeneral(target.deputyGeneral)
        table.insert(generals, target.deputyGeneral)
      end
    end
    if data.killer == player then
      table.insertTableIfNeed(generals, room:getNGenerals(2))
    end
    if #generals > 0 then
      room:addTableMarkIfNeed(player, "@&massacre", generals)
    end
  end,
})

shilus:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player == target and player:hasSkill(shilus.name) and player.phase == Player.Start and
      not player:isNude() and #player:getTableMark("@&massacre") > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local x = #player:getMark("@&massacre")
    local cards = room:askToDiscard(player, {
      min_num = 1,
      max_num = x,
      include_equip = true,
      skill_name = shilus.name,
      cancelable = true,
      prompt = "#ofl__shilus-cost:::"..tostring(x),
      skip = true,
    })
    if #cards > 0 then
      event:setCostData(self, {cards = cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = event:getCostData(self).cards
    room:throwCard(cards, shilus.name, player, player)
    if not player.dead then
      player:drawCards(#cards, shilus.name)
    end
  end,
})

shilus:addLoseEffect(function (self, player, is_death)
  local room = player.room
  room:returnToGeneralPile(player:getTableMark("@&massacre"))
  room:setPlayerMark(player, "@&massacre", 0)
end)

return shilus
