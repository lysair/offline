local cangni = fk.CreateSkill {
  name = "cangni"
}

Fk:loadTranslationTable{
  ['cangni'] = '藏匿',
  [':cangni'] = '弃牌阶段开始时，你可以回复1点体力或摸两张牌，然后将你的武将牌翻面；其他角色的回合内，当你获得（每回合限一次）/失去一次牌时，若你的武将牌背面朝上，你可以令该角色摸/弃置一张牌。 ',
}

cangni:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player)
    if not player:hasSkill(cangni.name) then return end
    if player.phase == Player.Discard then
      return true
    end
  end,
  on_cost = function (skill, event, target, player)
    local room = player.room
    return room:askToSkillInvoke(player, { skill_name = cangni.name })
  end,
  on_use = function (skill, event, target, player)
    local room = player.room
    if (player.hp == player.maxHp) or room:askToChoice(player, { choices = {"recover","draw2"}, skill_name = cangni.name }) == "draw2" then
      player:drawCards(2, cangni.name)
    else
      room:recover({
        who = player,
        num = 1,
        recoverBy = player,
        skillName = cangni.name
      })
    end
    if not player.dead then
      player:turnOver()
    end
  end,
})

cangni:addEffect(fk.AfterCardsMove, {
  can_trigger = function(self, event, target, player, data)
    local current = player.room.current
    if current ~= player and not current.dead and not player.faceup then
      local choices = {}
      for _, move in ipairs(data) do
        if move.to == player.id and move.toArea == Player.Hand and player:getMark("cangni_draw-turn") == 0 then
          table.insertIfNeed(choices, "draw")
        end
        if move.from == player.id then
          for _, info in ipairs(move.moveInfo) do
            if (info.fromArea == Player.Equip and move.toArea ~= Player.Hand)
              or (info.fromArea == Player.Hand and move.toArea ~= Player.Equip) then
              table.insertIfNeed(choices, "discard")
            end
          end
        end
      end
      if #choices > 0 then
        if #choices == 1 and choices[1] == "discard" and current:isNude() then return end
        event:setCostData(skill, choices)
        return true
      end
    end
  end,
  on_cost = function (skill, event, target, player)
    local room = player.room
    local choices = {}
    for _, choice in ipairs(event:getCostData(skill)) do
      if room:askToSkillInvoke(player, { skill_name = cangni.name, prompt = "#cangni-"..choice..":"..room.current.id }) then
        table.insert(choices, choice)
      end
    end
    if #choices > 0 then
      event:setCostData(skill, choices)
      return true
    end
  end,
  on_use = function (skill, event, target, player)
    local room = player.room
    if table.contains(event:getCostData(skill), "draw") then
      room:setPlayerMark(player, "cangni_draw-turn", 1)
    end
    local current = room.current
    for _, choice in ipairs(event:getCostData(skill)) do
      if current.dead then break end
      if choice == "draw" then
        current:drawCards(1, cangni.name)
      else
        room:askToDiscard(current, { min_num = 1, max_num = 1, include_equip = true, skill_name = cangni.name })
      end
    end
  end,
})

return cangni
