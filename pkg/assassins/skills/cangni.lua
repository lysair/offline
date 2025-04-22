local cangni = fk.CreateSkill {
  name = "cangni",
}

Fk:loadTranslationTable{
  ["cangni"] = "藏匿",
  [":cangni"] = "弃牌阶段开始时，你可以回复1点体力或摸两张牌，然后将你的武将牌翻面；其他角色的回合内，当你获得（每回合限一次）/失去一次牌时，"..
  "若你的武将牌背面朝上，你可以令该角色摸/弃置一张牌。 ",

  ["#cangni-choice"] = "藏匿：你可以回复1点体力或摸两张牌，然后翻面",
  ["#cangni-draw"] = "藏匿：是否令 %dest 摸一张牌？",
  ["#cangni-discard"] = "藏匿：是否令 %dest 弃置一张牌？",
}

cangni:addEffect(fk.EventPhaseStart, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(cangni.name) and player.phase == Player.Discard
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local all_choices = {"recover", "draw2", "Cancel"}
    local choices = table.simpleClone(all_choices)
    if not player:isWounded() then
      table.remove(choices, 1)
    end
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = cangni.name,
      prompt = "#cangni-choice",
      all_choices = all_choices,
    })
    if choice ~= "Cancel" then
      event:setCostData(self, {choice = choice})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if event:getCostData(self).choice == "draw2" then
      player:drawCards(2, cangni.name)
    else
      room:recover({
        who = player,
        num = 1,
        recoverBy = player,
        skillName = cangni.name,
      })
    end
    if not player.dead then
      player:turnOver()
    end
  end,
})

cangni:addEffect(fk.AfterCardsMove, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(cangni.name) and not player.faceup and
      player.room.current ~= player and not player.room.current.dead and
      player:usedEffectTimes(self.name, Player.HistoryTurn) == 0 then
      for _, move in ipairs(data) do
        if move.to == player and move.toArea == Player.Hand then
          return true
        end
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = cangni.name,
      prompt = "#cangni-draw::"..room.current.id,
    }) then
      event:setCostData(self, {tos = {room.current}})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    player.room.current:drawCards(1, cangni.name)
  end,
})

cangni:addEffect(fk.AfterCardsMove, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(cangni.name) and not player.faceup and
      player.room.current ~= player and not player.room.current.dead and
      not player.room.current:isNude() then
      for _, move in ipairs(data) do
        if move.from == player then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Player.Hand or info.fromArea == Player.Equip then
              return true
            end
          end
        end
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = cangni.name,
      prompt = "#cangni-discard::"..room.current.id,
    }) then
      event:setCostData(self, {tos = {room.current}})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:askToDiscard(room.current, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = cangni.name,
      cancelable = false,
    })
  end,
})

return cangni
