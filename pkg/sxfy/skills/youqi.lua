local youqi = fk.CreateSkill {
  name = "sxfy__youqi",
  tags = { Skill.Lord },
}

Fk:loadTranslationTable{
  ["sxfy__youqi"] = "游骑",
  [":sxfy__youqi"] = "主公技，准备阶段，你可以移动一名群势力角色装备区内的一张坐骑牌。",

  ["#sxfy__youqi-invoke"] = "游骑：你可以移动一名群势力角色装备区内的一张坐骑牌",
}

youqi:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(youqi.name) then
      for _, p in ipairs(player.room.alive_players) do
        if p.kingdom == "qun" then
          for _, id in ipairs(table.connect(p:getEquipments(Card.SubtypeOffensiveRide), p:getEquipments(Card.SubtypeDefensiveRide))) do
            for _, q in ipairs(player.room:getOtherPlayers(p, false)) do
              if p:canMoveCardInBoardTo(q, id) then
                return true
              end
            end
          end
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local ids = {}
    for _, p in ipairs(room.alive_players) do
      if p.kingdom ~= "qun" then
        table.insertTable(ids, p:getCardIds("e"))
      else
        table.insertTable(ids, p:getEquipments(Card.SubtypeWeapon))
        table.insertTable(ids, p:getEquipments(Card.SubtypeArmor))
        table.insertTable(ids, p:getEquipments(Card.SubtypeTreasure))
      end
    end
    local tos = room:askToChooseToMoveCardInBoard(player, {
      skill_name = youqi.name,
      flag = "e",
      exclude_ids = ids,
      prompt = "#sxfy__youqi-invoke",
      cancelable = true,
    })
    if #tos == 2 then
      event:setCostData(self, {tos = tos, exclude_ids = ids})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = event:getCostData(self).tos
    local exclude_ids = event:getCostData(self).exclude_ids
    room:askToMoveCardInBoard(player, {
      skill_name = youqi.name,
      target_one = targets[1],
      target_two = targets[2],
      flag = "e",
      exclude_ids = exclude_ids,
    })
  end,
})

return youqi
