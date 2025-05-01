local fuhans = fk.CreateSkill {
  name = "fuhans",
}

Fk:loadTranslationTable{
  ["fuhans"] = "辅汉",
  [":fuhans"] = "当你获得其他角色的手牌后，其可以废除你一个装备栏；当其他角色获得你的手牌后，其可以恢复你一个装备栏。"..
  "每个回合结束时，若你本回合发动过此技能，你令当前回合角色将手牌摸至体力上限。",

  ["#fuhans1-invoke"] = "辅汉：是否废除 %src 一个装备栏？回合结束时 %dest 将手牌摸至体力上限",
  ["#fuhans2-invoke"] = "辅汉：是否恢复 %src 一个装备栏？回合结束时 %dest 将手牌摸至体力上限",
}

fuhans:addEffect(fk.AfterCardsMove, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(fuhans.name) then
      for _, move in ipairs(data) do
        if move.toArea == Card.PlayerHand then
          if move.to == player and move.from and move.from ~= player and
            #player:getAvailableEquipSlots() > 0 and not move.from.dead then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.PlayerHand then
                return true
              end
            end
          end
          if move.from == player and move.to and move.to ~= player and
            #player.sealedSlots > 0 and table.find(player.sealedSlots, function (slot)
              return slot ~= Player.JudgeSlot
            end) and not move.to.dead then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.PlayerHand then
                return true
              end
            end
          end
        end
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    local room = player.room
    local dat = {}
    for _, move in ipairs(data) do
      if move.toArea == Card.PlayerHand then
        if move.to == player and move.from and move.from ~= player then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand then
              table.insert(dat, {move.from, 1})
              break
            end
          end
        end
        if move.from == player and move.to and move.to ~= player then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand then
              table.insert(dat, {move.to, 2})
              break
            end
          end
        end
      end
    end
    for _, info in ipairs(dat) do
      if not player:hasSkill(fuhans.name) then break end
      local to = info[1]
      if to and not to.dead then
        if info[2] == 1 and #player:getAvailableEquipSlots() > 0 then
          event:setCostData(self, {target = to, choice = 1})
          self:doCost(event, target, player, data)
        end
        if info[2] == 2 and #player.sealedSlots > 0 and
          table.find(player.sealedSlots, function (slot)
            return slot ~= Player.JudgeSlot
          end) then
          event:setCostData(self, {target = to, choice = 2})
          self:doCost(event, target, player, data)
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).target
    local slot = "Cancel"
    if event:getCostData(self).choice == 1 then
      local slots = table.simpleClone(player:getAvailableEquipSlots())
      table.insert(slots, "Cancel")
      slot = room:askToChoice(to, {
        choices = slots,
        skill_name = fuhans.name,
        prompt = "#fuhans1-invoke:"..player.id,
      })
    else
      local slots = table.simpleClone(player.sealedSlots)
      table.removeOne(slots, Player.JudgeSlot)
      table.insert(slots, "Cancel")
      slot = room:askToChoice(to, {
        choices = slots,
        skill_name = fuhans.name,
        prompt = "#fuhans2-invoke:"..player.id,
      })
    end
    if slot ~= "Cancel" then
      room:doIndicate(to, {player})
      event:setCostData(self, {slot = slot, choice = event:getCostData(self).choice})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(fuhans.name)
    if event:getCostData(self).choice == 1 then
      room:notifySkillInvoked(player, fuhans.name, "negative")
      room:abortPlayerArea(player, event:getCostData(self).slot)
    else
      room:notifySkillInvoked(player, fuhans.name, "support")
      room:resumePlayerArea(player, {event:getCostData(self).slot})
    end
  end,
})

fuhans:addEffect(fk.TurnEnd, {
  anim_type = "support",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(fuhans.name) and player:usedSkillTimes(fuhans.name, Player.HistoryTurn) > 0 and
      not target.dead and target:getHandcardNum() < target.maxHp
  end,
  on_cost = function (self, event, target, player, data)
    event:setCostData(self, {tos = {target}})
    return true
  end,
  on_use = function (self, event, target, player, data)
    target:drawCards(target.maxHp - target:getHandcardNum(), fuhans.name)
  end,
})

return fuhans
