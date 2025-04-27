
local fenwei = fk.CreateSkill{
  name = "ofl_mou__fenwei",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable{
  ["ofl_mou__fenwei"] = "奋威",
  [":ofl_mou__fenwei"] = "限定技，当一张锦囊牌指定多个目标后，你可以令此牌对其中任意个目标无效，若包含你，本回合结束时你可以发动一次〖奇袭〗。",

  ["#ofl_mou__fenwei-choose"] = "奋威：你可以令此%arg对任意个目标无效，若包含你则本回合结束时可以发动“奇袭”",

  ["$ofl_mou__fenwei1"] = "浪淘英雄泪，血染将军魂！",
  ["$ofl_mou__fenwei2"] = "立功护英主，奋威破敌酋！",
}

fenwei:addEffect(fk.TargetSpecified, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(fenwei.name) and
      data.card.type == Card.TypeTrick and data.firstTarget and #data.use.tos > 1 and
      player:usedSkillTimes(fenwei.name, Player.HistoryGame) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local tos = room:askToChoosePlayers(player, {
      targets = data.use.tos,
      min_num = 1,
      max_num = #data.tos,
      prompt = "#ofl_mou__fenwei-choose:::"..data.card:toLogString(),
      skill_name = fenwei.name,
      cancelable = true,
    })
    if #tos > 0 then
      room:sortByAction(tos)
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    data.use.nullifiedTargets = data.use.nullifiedTargets or {}
    table.insertTableIfNeed(data.use.nullifiedTargets, event:getCostData(self).tos)
    if table.contains(event:getCostData(self).tos, player) then
      player.room:setPlayerMark(player, "ofl_mou__fenwei-turn", 1)
    end
  end,
})

fenwei:addEffect(fk.TurnEnd, {
  anim_type = "control",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return player:getMark("ofl_mou__fenwei-turn") > 0 and not player:isKongcheng() and
      table.find(player.room:getOtherPlayers(player, false), function (p)
        return not p:isAllNude()
      end)
  end,
  on_use = function(self, event, target, player, data)
    player.room:askToUseActiveSkill(player, {
      skill_name = "ofl_mou__qixi",
      prompt = "#ofl_mou__qixi",
    })
  end,
})

return fenwei
