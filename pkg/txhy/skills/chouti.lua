local chouti = fk.CreateSkill {
  name = "ofl_tx__chouti",
}

Fk:loadTranslationTable{
  ["ofl_tx__chouti"] = "抽梯",
  [":ofl_tx__chouti"] = "每回合限一次，当你于一回合受到过不小于3点伤害后，你可以令一名其他角色选择获得〖断援〗或〖陷渊〗直到本回合结束。"..
  "<a href='os__override'>凌越·势力</a>：其永久获得另一个未选择的技能。",

  ["#ofl_tx__chouti-choose"] = "抽梯：令一名角色本回合获得一个负面技能，若凌越则其再永久获得另一个负面技能",
  ["#ofl_tx__chouti-choice"] = "抽梯：获得一个负面技能直到本回合结束",
  ["#ofl_tx__chouti_override-choice"] = "抽梯：获得一个负面技能直到本回合结束，永久获得另一个",
}

Fk:addTargetTip{
  name = chouti.name,
  target_tip = function(self, player, to_select, selected, selected_cards, card, selectable)
    if not selectable then return end
    local n1 = #table.filter(Fk:currentRoom().alive_players, function (p)
      return p.kingdom == player.kingdom
    end)
    if #table.filter(Fk:currentRoom().alive_players, function (p)
      return p.kingdom == to_select.kingdom
    end) < n1 then
      return "override"
    end
  end,
}

chouti:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function (self, event, target, player, data)
    if target == player and player:hasSkill(chouti.name) and
      player:usedSkillTimes(chouti.name, Player.HistoryTurn) == 0 and
      #player.room:getOtherPlayers(player, false) > 0 then
      local n = 0
      player.room.logic:getActualDamageEvents(1, function (e)
        local damage = e.data
        if damage.to == player then
          n = n + damage.damage
          return n > 2
        end
      end, Player.HistoryTurn)
      return n > 2
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room:getOtherPlayers(player, false),
      skill_name = chouti.name,
      prompt = "#ofl_tx__chouti-choose",
      cancelable = true,
      target_tip_name = chouti.name,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local choices = table.filter({ "ofl_tx__duanyuan", "ofl_tx__xianyuan" }, function (s)
      return not to:hasSkill(s, true)
    end)
    if #choices == 0 then
      return
    elseif #choices == 1 then
      room:handleAddLoseSkills(to, choices[1], nil, true, false)
      room.logic:getCurrentEvent():findParent(GameEvent.Turn):addCleaner(function()
        room:handleAddLoseSkills(to, "-"..choices[1])
      end)
    else
      local yes = #table.filter(room.alive_players, function (p)
        return p.kingdom == player.kingdom
      end) > #table.filter(room.alive_players, function (p)
        return p.kingdom == to.kingdom
      end)
      local prompt = yes and "#ofl_tx__chouti_override-choice" or "#ofl_tx__chouti-choice"
      local choice = room:askToCustomDialog(to, {
        skill_name = chouti.name,
        qml_path = "packages/utility/qml/ChooseSkillBox.qml",
        extra_data = {
          { "ofl_tx__duanyuan", "ofl_tx__xianyuan" }, 1, 1, prompt,
        },
      })
      room:handleAddLoseSkills(to, choice[1], nil, true, false)
      room.logic:getCurrentEvent():findParent(GameEvent.Turn):addCleaner(function()
        room:handleAddLoseSkills(to, "-"..choice[1])
      end)
      if yes then
        local skill2 = choice[1] == "ofl_tx__duanyuan" and "ofl_tx__xianyuan" or "ofl_tx__duanyuan"
        room:handleAddLoseSkills(to, skill2, nil, true, false)
      end
    end
  end,
})

return chouti
