local skill = fk.CreateSkill {
  name = "chunqiu_brush_skill&",
  attached_equip = "chunqiu_brush",
}

Fk:loadTranslationTable{
  ["chunqiu_brush_skill&"] = "春秋笔",
  [":chunqiu_brush_skill&"] = "出牌阶段限一次，你可以随机选择一项，然后你选择一名角色，其从此项开始正序或逆序执行以下效果：<br>"..
  "起：失去1点体力；<br>承：摸已损失体力值张牌；<br>转：回复1点体力；<br>合：弃置已损失体力值张手牌。",
  ["#chunqiu_brush_skill&"] = "春秋笔：令一名角色从“%arg”开始，顺序或逆序执行效果",
  ["chunqiu_brush1"] = "起",
  ["chunqiu_brush2"] = "承",
  ["chunqiu_brush3"] = "转",
  ["chunqiu_brush4"] = "合",
  ["chunqiu_order"] = "顺序",
  ["chunqiu_reverse"] = "逆序",
}

skill:addEffect("active", {
  prompt = function (self, player, selected_cards, selected_targets)
    return "#chunqiu_brush_skill&:::chunqiu_brush"..player:getMark("chunqiu_brush-phase")
  end,
  interaction = UI.ComboBox { choices = {"chunqiu_order", "chunqiu_reverse"}},
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(skill.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function (self, player, to_select, selected, selected_cards)
    return #selected == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local index, total = player:getMark("chunqiu_brush-phase"), 0
    local order = self.interaction.data == "chunqiu_order" and {1, 2, 3, 4, 1, 2, 3, 4} or {4, 3, 2, 1, 4, 3, 2, 1}
    for i = 1, 8 do
      if target.dead or total == 4 then return end
      if index == order[i] then
        if index == 1 then
          room:loseHp(target, 1, skill.name)
        elseif index == 2 then
          if target:isWounded() then
            target:drawCards(target:getLostHp(), skill.name)
          end
        elseif index == 3 then
          if target:isWounded() then
            room:recover{
              who = target,
              num = 1,
              recoverBy = player,
              skillName = skill.name,
            }
          end
        elseif index == 4 then
          if target:isWounded() then
            room:askToDiscard(target, {
              min_num = target:getLostHp(),
              max_num = target:getLostHp(),
              include_equip = false,
              skill_name = skill.name,
              cancelable = false,
            })
          end
        end
        total = total + 1
        index = order[i + 1]
      end
    end
  end,
})

skill:addEffect(fk.EventPhaseStart, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(skill.name, true) and player.phase == Player.Play
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "chunqiu_brush-phase", math.random(4))
  end
})

skill:addAcquireEffect(function (self, player, is_start)
  player.room:setPlayerMark(player, "chunqiu_brush-phase", math.random(4))
end)

return skill
