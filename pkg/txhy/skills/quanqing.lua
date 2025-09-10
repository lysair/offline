local quanqing = fk.CreateSkill {
  name = "ofl_tx__quanqing",
}

Fk:loadTranslationTable{
  ["ofl_tx__quanqing"] = "权倾",
  [":ofl_tx__quanqing"] = "出牌阶段开始时，你可以<a href='os__qiangling_href'>强令</a>一名其他角色直到其下回合结束不发动技能。<br>"..
  "成功：其翻面；失败：你加2点体力上限并回复2点体力。",

  ["#ofl_tx__quanqing-choose"] = "权倾：你可以强令一名角色直到其下回合结束不发动技能",
  ["@ofl_tx__quanqing"] = "权倾",
}

quanqing:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(quanqing.name) and player.phase == Player.Play and
      #player.room:getOtherPlayers(player, false) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      targets = room:getOtherPlayers(player, false),
      min_num = 1,
      max_num = 1,
      prompt = "#ofl_tx__quanqing-choose",
      skill_name = quanqing.name,
    })
    if #to > 0 then
      event:setCostData(self, { tos = to })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    if to:getMark("@ofl_tx__quanqing") == 0 then
      room:setPlayerMark(to, "@ofl_tx__quanqing", " ")
    end
    room:addTableMark(to, quanqing.name, { player.id, 0 })
  end
})

quanqing:addEffect(fk.SkillEffect, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@ofl_tx__quanqing") ~= 0 and
      data.skill:isPlayerSkill(target) and player:hasSkill(data.skill:getSkeleton().name, true, true)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local mark = player:getTableMark(quanqing.name)
    for _, info in ipairs(mark) do
      info[2] = 1
    end
    room:setPlayerMark(player, quanqing.name, mark)
    room:setPlayerMark(player, "@ofl_tx__quanqing", "quest_failed")
  end
})

quanqing:addEffect(fk.TurnEnd, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@ofl_tx__quanqing") ~= 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@ofl_tx__quanqing", 0)
    local mark = player:getTableMark(quanqing.name)
    room:setPlayerMark(player, quanqing.name, 0)
    for _, info in ipairs(mark) do
      if info[2] == 0 and not player.dead then
        player:turnOver()
      elseif info[2] == 1 then
        local src = room:getPlayerById(info[1])
        if not src.dead then
          room:changeMaxHp(src, 2)
          if not src.dead then
            room:recover{
              who = src,
              num = 2,
              recoverBy = src,
              skillName = quanqing.name,
            }
          end
        end
      end
    end
  end
})

return quanqing
