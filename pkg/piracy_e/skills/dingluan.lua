local dingluan = fk.CreateSkill {
  name = "dingluan",
}

Fk:loadTranslationTable{
  ["dingluan"] = "定乱",
  [":dingluan"] = "出牌阶段限一次，你可以失去1点体力，令一名其他角色选择一项：1.视为你对其使用一张【大军压境】；2.其武将牌上的技能失效"..
  "直到其回合结束。",

  ["#dingluan"] = "定乱：失去1点体力，令一名角色选择你视为对其使用【大军压境】或其技能失效直到其回合结束",
  ["dingluan_use"] = "%src视为对你使用【大军压境】",
  ["dingluan_invalidity"] = "武将牌上的技能失效直到你的回合结束",
  ["@@dingluan_invalidity"] = "技能失效",
}

dingluan:addEffect("active", {
  anim_type = "control",
  prompt = "#dingluan",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(dingluan.name, Player.HistoryPhase) == 0 and #Fk:currentRoom().alive_players > 1
  end,
  card_filter = Util.FalseFunc,
  target_filter = function (self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    room:loseHp(player, 1, dingluan.name)
    if target.dead then return end
    local choices = { "dingluan_invalidity" }
    if not player.dead and player:canUseTo(Fk:cloneCard("bearing_down_border"), target) then
      table.insert(choices, 1, "dingluan_use:"..player.id)
    end
    local choice = room:askToChoice(target, {
      choices = choices,
      skill_name = dingluan.name,
    })
    if choice == "dingluan_invalidity" then
      room:setPlayerMark(target, "@@dingluan_invalidity", 1)
    else
      room:useVirtualCard("bearing_down_border", nil, player, target, dingluan.name)
    end
  end,
})

dingluan:addEffect("invalidity", {
  invalidity_func = function (self, from, skill)
    if from:getMark("@@dingluan_invalidity") > 0 then
      if table.contains(Fk.generals[from.general]:getSkillNameList(true), skill.name) then
        return true
      end
      if from.deputyGeneral ~= "" and table.contains(Fk.generals[from.deputyGeneral]:getSkillNameList(true), skill.name) then
        return true
      end
    end
  end,
})

dingluan:addEffect(fk.TurnEnd, {
  late_refresh = true,
  can_refresh = function (self, event, target, player, data)
    return target == player
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:setPlayerMark(player, "@@dingluan_invalidity", 0)
  end,
})

return dingluan
