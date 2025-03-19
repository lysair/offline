local ofl__shilus = fk.CreateSkill {
  name = "ofl__shilus"
}

Fk:loadTranslationTable{
  ['ofl__shilus'] = '嗜戮',
  ['@&massacre'] = '戮',
  ['#ofl__shilus-cost'] = '嗜戮：你可以弃置至多%arg张牌，摸等量的牌',
  ['#ofl__shilus-invoke'] = '嗜戮：是否将 %dest 的武将牌置为“戮”？',
  [':ofl__shilus'] = '游戏开始时，你从剩余武将牌堆获得两张“戮”；其他角色死亡时，你可将其武将牌置为“戮”；当你杀死其他角色时，你从剩余武将牌堆额外获得两张“戮”。回合开始时，你可以弃置至多X张牌（X为“戮”数），摸等量的牌。',
  ['$ofl__shilus1'] = '以杀立威，谁敢反我？',
  ['$ofl__shilus2'] = '将这些乱臣贼子，尽皆诛之！',
}

ofl__shilus:addEffect({fk.GameStart, fk.Deathed, fk.EventPhaseStart}, {
  can_trigger = function(self, event, target, player)
    if player:hasSkill(ofl__shilus.name) then
      if event == fk.EventPhaseStart then
        return player == target and player.phase == Player.Start and not player:isNude() and #player:getTableMark("@&massacre") > 0
      else
        return true
      end
    end
  end,
  on_cost = function(self, event, target, player)
    local room = player.room
    if event == fk.EventPhaseStart then
      local x = #player:getMark("@&massacre")
      local cards = room:askToDiscard(player, {
        min_num = 1,
        max_num = x,
        include_equip = true,
        skill_name = ofl__shilus.name,
        cancelable = true,
        prompt = "#ofl__shilus-cost:::"..tostring(x),
        skip = true
      })
      if #cards > 0 then
        event:setCostData(skill, cards)
        return true
      end
    elseif event == fk.GameStart then
      return true
    else
      return room:askToSkillInvoke(player, {
        skill_name = ofl__shilus.name,
        prompt = "#ofl__shilus-invoke::"..target.id
      })
    end
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    player:broadcastSkillInvoke("shilus")
    if event == fk.EventPhaseStart then
      room:notifySkillInvoked(player, ofl__shilus.name, "drawcard")
      room:throwCard(event:getCostData(skill), ofl__shilus.name, player, player)
      if not player.dead then
        room:drawCards(player, #event:getCostData(skill), ofl__shilus.name)
      end
    else
      room:notifySkillInvoked(player, ofl__shilus.name, "special")
      local cards = {}
      if event == fk.GameStart then
        table.insertTableIfNeed(cards, room:getNGenerals(2))
      elseif event == fk.Deathed then
        room:doIndicate(player.id, {target.id})
        if target.general and target.general ~= "" and target.general ~= "hiddenone" then
          room:findGeneral(target.general)
          table.insert(cards, target.general)
        end
        if target.deputyGeneral and target.deputyGeneral ~= "" and target.deputyGeneral ~= "hiddenone" then
          room:findGeneral(target.deputyGeneral)
          table.insert(cards, target.deputyGeneral)
        end
        if data.damage and data.damage.from == player then
          table.insertTableIfNeed(cards, room:getNGenerals(2))
        end
      end
      if #cards > 0 then
        local generals = player:getTableMark("@&massacre")
        table.insertTableIfNeed(generals, cards)
        room:setPlayerMark(player, "@&massacre", generals)
      end
    end
  end,
})

ofl__shilus:addEffect({fk.EventLoseSkill, fk.BuryVictim}, {
  can_refresh = function(self, event, target, player)
    if target == player and player:getMark("@&massacre") ~= 0 then
      if event == fk.EventLoseSkill then
        return data == ofl__shilus.name
      elseif event == fk.BuryVictim then
        return true
      end
    end
  end,
  on_refresh = function(self, event, target, player)
    local room = player.room
    room:returnToGeneralPile(player:getTableMark("@&massacre"))
    room:setPlayerMark(player, "@&massacre", 0)
  end,
})

return ofl__shilus
