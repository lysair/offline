local xiangshuz = fk.CreateSkill {
  name = "sxfy__xiangshuz",
}

Fk:loadTranslationTable{
  ["sxfy__xiangshuz"] = "相鼠",
  [":sxfy__xiangshuz"] = "每轮限一次，其他角色出牌阶段开始时，你可以声明其本阶段结束时的手牌数。"..
  "此阶段结束时，若其手牌数与你声明的数相差不大于1，你对其造成1点伤害，否则你失去1点体力并获得其一张牌。",

  ["#sxfy__xiangshuz-invoke"] = "相鼠：猜测 %dest 此阶段结束时手牌数，若相差1以内，获得其一张牌；相等，再对其造成1点伤害",
  ["#sxfy__xiangshuz-choice"] = "相鼠：猜测 %dest 此阶段结束时的手牌数",
  ["@sxfy__xiangshuz-phase"] = "相鼠",
}

xiangshuz:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(xiangshuz.name) and target.phase == Player.Play and
      player:usedSkillTimes(xiangshuz.name, Player.HistoryRound) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = xiangshuz.name,
      prompt = "#sxfy__xiangshuz-invoke::"..target.id,
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choices = {}
    for i = 0, 99 do
      table.insert(choices, tostring(i))
    end
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = xiangshuz.name,
      prompt = "#sxfy__xiangshuz-choice::"..target.id,
    })
    room:setPlayerMark(player, "@sxfy__xiangshuz-phase", choice)
  end,
})

xiangshuz:addEffect(fk.EventPhaseEnd, {
  anim_type = "offensive",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target ~= player and target.phase == Player.Play and
      player:getMark("@sxfy__xiangshuz-phase") ~= 0 and not player.dead
  end,
  on_cost = function (self, event, target, player, data)
    event:setCostData(self, {tos = {target}})
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if math.abs(target:getHandcardNum() - tonumber(player:getMark("@sxfy__xiangshuz-phase"))) < 2 then
      room:damage{
        from = player,
        to = target,
        damage = 1,
        skillName = xiangshuz.name,
      }
    else
      room:loseHp(player, 1, xiangshuz.name)
      if not target.dead and not player.dead and not target:isNude() then
        local id = room:askToChooseCard(player, {
          target = target,
          flag = "he",
          skill_name = xiangshuz.name,
        })
        room:obtainCard(player, id, false, fk.ReasonPrey, player, xiangshuz.name)
      end
    end
  end,
})

return xiangshuz
