local yuxian = fk.CreateSkill {
  name = "yuxiangs",
  tags = { Skill.Quest },
}

Fk:loadTranslationTable{
  ["yuxiangs"] = "羽现",
  [":yuxiangs"] = "使命技，每轮限一次，一名角色的回合结束后，若你或其本回合回复过体力，你可以获得一个额外回合。<br>\
  ⬤　成功：准备阶段，若你本局游戏已进行过至少四个回合，你失去〖羽现〗，获得〖应龙〗和〖撷芳〗。<br>\
  ⬤　失败：当一名女性角色造成伤害使你进入濒死状态时，你失去〖羽现〗。",
}

yuxian:addEffect(fk.TurnEnd, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(yuxian.name) and
      player:usedSkillTimes(yuxian.name, Player.HistoryRound) == 0 and
      #player.room.logic:getEventsOfScope(GameEvent.Recover, 1, function (e)
        return e.data.who == player or e.data.who == target
      end, Player.HistoryTurn) > 0
  end,
  on_use = function(self, event, target, player, data)
    player:gainAnExtraTurn(true, yuxian.name)
  end,
})

yuxian:addEffect(fk.EventPhaseStart, {
  anim_type = "special",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(yuxian.name) and player.phase == Player.Start and
      #player.room.logic:getEventsOfScope(GameEvent.Turn, 4, function (e)
        return e.data.who == player
      end, Player.HistoryGame) > 3
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:updateQuestSkillState(player, yuxian.name, false)
    room:invalidateSkill(player, yuxian.name)
    room:handleAddLoseSkills(player, "-yuxiangs|yinglong|shzj_guansuo__xiefang")
  end,
})

yuxian:addEffect(fk.EnterDying, {
  anim_type = "negative",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(yuxian.name) and
      data.damage and data.damage.from and data.damage.from:isFemale()
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:updateQuestSkillState(player, yuxian.name, true)
    room:invalidateSkill(player, yuxian.name)
    room:handleAddLoseSkills(player, "-yuxiangs")
  end,
})

return yuxian
