local baijun = fk.CreateSkill {
  name = "ofl_tx__baijun",
}

Fk:loadTranslationTable{
  ["ofl_tx__baijun"] = "败军",
  [":ofl_tx__baijun"] = "<a href='os__assault'>摧坚</a>：弃置其X张牌。",

  ["#ofl_tx__baijun-choose"] = "败军：你可以弃置一名目标角色其技能数张牌（至多4张）",
  ["ofl_tx__baijun_tip"] = "%arg张",
}

Fk:addTargetTip{
  name = "ofl_tx__baijun",
  target_tip = function(self, player, to_select, selected, selected_cards, card, selectable)
    if not selectable then return end
    return "ofl_tx__baijun_tip:::"..math.min(4, #to_select:getSkillNameList())
  end,
}

baijun:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(baijun.name) and data.firstTarget and
      data.card.is_damage_card and player:usedSkillTimes(baijun.name, Player.HistoryTurn) == 0 and
      table.find(data.use.tos, function (p)
        return not p:isNude() and #p:getSkillNameList() > 0
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(data.use.tos, function (p)
      return not p:isNude() and #p:getSkillNameList() > 0
    end)
    if not table.find(player:getCardIds("he"), function (id)
        return not player:prohibitDiscard(id)
      end) then
      table.removeOne(targets, player)
    end
    if #targets == 0 then
      room:askToCards(player, {
        min_num = 1,
        max_num = 1,
        include_equip = false,
        skill_name = baijun.name,
        pattern = "false",
        prompt = "#ofl_tx__baijun-choose",
        cancelable = true,
      })
    else
      local to = room:askToChoosePlayers(player, {
        skill_name = baijun.name,
        min_num = 1,
        max_num = 1,
        targets = targets,
        prompt = "#ofl_tx__baijun-choose",
        cancelable = true,
        target_tip_name = baijun.name,
      })
      if #to > 0 then
        event:setCostData(self, {tos = to})
        return true
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local n = math.min(4, #to:getSkillNameList())
    if to == player then
      room:askToDiscard(player, {
        min_num = n,
        max_num = n,
        include_equip = true,
        skill_name = baijun.name,
        cancelable = false,
      })
    else
      local cards = room:askToChooseCards(player, {
        target = to,
        min = n,
        max = n,
        flag = "he",
        skill_name = baijun.name,
      })
      room:throwCard(cards, baijun.name, to, player)
    end
  end,
})

return baijun
