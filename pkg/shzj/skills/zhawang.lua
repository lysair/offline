local zhawang = fk.CreateSkill {
  name = "zhawang",
}

Fk:loadTranslationTable{
  ["zhawang"] = "诈亡",
  [":zhawang"] = "回合开始时，你可以选择一项：1.本回合获得〖诈降〗；2.失去1点体力，本回合准备阶段和结束阶段改为出牌阶段；背水：减1点体力上限。",

  ["zhawang_zhaxiang"] = "本回合获得“诈降”",
  ["zhawang_losehp"] = "失去1点体力，本回合准备阶段和结束阶段改为出牌阶段",
  ["zhawang_beishui"] = "背水：减1点体力上限",
  ["@@zhawang-turn"] = "诈亡",
}

zhawang:addEffect(fk.TurnStart, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zhawang.name)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local all_choices = { "zhawang_zhaxiang", "zhawang_losehp", "zhawang_beishui", "Cancel" }
    local choices = table.simpleClone(all_choices)
    if player:hasSkill("ol_ex__zhaxiang", true) then
      table.remove(choices, 1)
    end
    if player.hp < 1 then
      table.removeOne(choices, "zhawang_losehp")
    end
    if #choices < 4 then
      table.removeOne(choices, "zhawang_beishui")
    end
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = zhawang.name,
      all_choices = all_choices,
    })
    if choice ~= "Cancel" then
      event:setCostData(self, {choice = choice})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choice = event:getCostData(self).choice
    if choice ~= "zhawang_losehp" then
      room:handleAddLoseSkills(player, "ol_ex__zhaxiang")
      room.logic:getCurrentEvent():findParent(GameEvent.Turn):addCleaner(function()
        room:handleAddLoseSkills(player, "-ol_ex__zhaxiang")
      end)
    end
    if choice ~= "zhawang_zhaxiang" then
      room:loseHp(player, 1, zhawang.name)
      if player.dead then return end
      room:setPlayerMark(player, "@@zhawang-turn", 1)
    end
    if choice == "zhawang_beishui" then
      room:changeMaxHp(player, -1)
    end
  end,
})

zhawang:addEffect(fk.EventPhaseChanging, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@@zhawang-turn") > 0 and
      (data.phase == Player.Start or data.phase == Player.Finish)
  end,
  on_refresh = function(self, event, target, player, data)
    data.phase = Player.Play
  end,
})

return zhawang
