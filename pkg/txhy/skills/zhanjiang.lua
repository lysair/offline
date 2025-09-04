local zhanjiang = fk.CreateSkill {
  name = "ofl_tx__zhanjiang",
}

Fk:loadTranslationTable{
  ["ofl_tx__zhanjiang"] = "斩将",
  [":ofl_tx__zhanjiang"] = "<a href='os__assault'>摧坚</a>：此牌对其造成伤害+X。",

  ["#ofl_tx__zhanjiang-choose"] = "斩将：你可以令此%arg对一名目标角色伤害增加",
  ["ofl_tx__zhanjiang_tip"] = "+%arg",
}

Fk:addTargetTip{
  name = "ofl_tx__zhanjiang",
  target_tip = function(self, player, to_select, selected, selected_cards, card, selectable)
    if not selectable then return end
    return "ofl_tx__zhanjiang_tip:::"..math.min(4, #to_select:getSkillNameList())
  end,
}

zhanjiang:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(zhanjiang.name) and data.firstTarget and
      data.card.is_damage_card and player:usedSkillTimes(zhanjiang.name, Player.HistoryTurn) == 0 and
      table.find(data.use.tos, function (p)
        return #p:getSkillNameList() > 0
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(data.use.tos, function (p)
      return #p:getSkillNameList() > 0
    end)
      local to = room:askToChoosePlayers(player, {
        skill_name = zhanjiang.name,
        min_num = 1,
        max_num = 1,
        targets = targets,
        prompt = "#ofl_tx__zhanjiang-choose:::"..data.card:toLogString(),
        cancelable = true,
        target_tip_name = zhanjiang.name,
      })
      if #to > 0 then
        event:setCostData(self, {tos = to})
        return true
      end
  end,
  on_use = function (self, event, target, player, data)
    local to = event:getCostData(self).tos[1]
    local n = math.min(4, #to:getSkillNameList())
    data.extra_data = data.extra_data or {}
    data.extra_data.ofl_tx__zhanjiang = data.extra_data.ofl_tx__zhanjiang or {}
    data.extra_data.ofl_tx__zhanjiang[to] = (data.extra_data.ofl_tx__zhanjiang[to] or 0) + n
  end,
})

zhanjiang:addEffect(fk.DamageInflicted, {
  can_refresh = function (self, event, target, player, data)
    if target == player and data.card then
      local use_event = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
      if use_event then
        local use = use_event.data
        return use.extra_data and use.extra_data.ofl_tx__zhanjiang and use.extra_data.ofl_tx__zhanjiang[player]
      end
    end
  end,
  on_refresh = function (self, event, target, player, data)
    local use_event = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
    if use_event then
      data:changeDamage(use_event.data.extra_data.ofl_tx__zhanjiang[player])
    end
  end,
})

return zhanjiang
