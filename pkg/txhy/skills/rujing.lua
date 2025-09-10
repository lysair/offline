local rujing = fk.CreateSkill {
  name = "ofl_tx__rujing",
}

Fk:loadTranslationTable{
  ["ofl_tx__rujing"] = "入荆",
  [":ofl_tx__rujing"] = "每轮开始时，你可以令一名其他角色的一个技能失效，直到其杀死一名角色后或其回合结束。"..
  "<a href='os__override'>凌越·手牌</a>：改为选择至多两个技能失效。",

  ["#ofl_tx__rujing-choose"] = "入荆：令一名角色一个技能失效直到其回合结束，若凌越则选择两个技能",
  ["#ofl_tx__rujing-choice"] = "入荆：令 %dest 的%arg个技能失效",
}

Fk:addTargetTip{
  name = rujing.name,
  target_tip = function(self, player, to_select, selected, selected_cards, card, selectable)
    if not selectable then return end
    if player:getHandcardNum() > to_select:getHandcardNum() then
      return "override"
    end
  end,
}

rujing:addEffect(fk.RoundStart, {
  anim_type = "control",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(rujing.name) and
      #player.room:getOtherPlayers(player, false) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room:getOtherPlayers(player, false),
      skill_name = rujing.name,
      prompt = "#ofl_tx__rujing-choose",
      cancelable = true,
      target_tip_name = rujing.name,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local skills = {}
    for _, s in ipairs(to:getSkillNameList()) do
      if to:hasSkill(s) then
        table.insertIfNeed(skills, s)
      end
    end
    if #skills == 0 then return end
    local n = player:getHandcardNum() > to:getHandcardNum() and 2 or 1
    local choices = skills
    if #choices > n then
      choices = room:askToCustomDialog(player, {
        skill_name = rujing.name,
        qml_path = "packages/utility/qml/ChooseSkillBox.qml",
        extra_data = { skills, 1, n, "#ofl_tx__rujing-choice::"..to.id..":"..n },
      })
      if #choices == 0 then
        choices = table.random(skills, n)
      end
    end
    room:sendLog{
      type = "#ofl__podai",
      from = player.id,
      to = { to.id },
      arg = table.concat(table.map(choices, function (s)
        return Fk:translate(s)
      end), ","),
      toast = true,
    }
    for _, s in ipairs(choices) do
      room:addTableMarkIfNeed(to, rujing.name, s)
    end
  end,
})

rujing:addEffect(fk.Deathed, {
  late_refresh = true,
  can_refresh = function (self, event, target, player, data)
    return data.killer == player
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:setPlayerMark(player, rujing.name, 0)
  end,
})

rujing:addEffect(fk.TurnEnd, {
  late_refresh = true,
  can_refresh = function (self, event, target, player, data)
    return target == player
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:setPlayerMark(player, rujing.name, 0)
  end,
})

rujing:addEffect("invalidity", {
  invalidity_func = function (self, from, skill)
    return table.contains(from:getTableMark(rujing.name), skill:getSkeleton().name)
  end,
})

return rujing
