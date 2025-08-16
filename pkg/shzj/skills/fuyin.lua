local fuyin = fk.CreateSkill {
  name = "shzj_xiangfan__fuyin",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["shzj_xiangfan__fuyin"] = "负荫",
  [":shzj_xiangfan__fuyin"] = "锁定技，你的手牌上限+X（X为蜀势力角色数）。当你成为【杀】的目标时，若为本回合首次，取消之；"..
  "否则你本回合不能回复体力。",

  ["@@shzj_xiangfan__fuyin-turn"] = "禁止回复体力",
}

fuyin:addEffect(fk.TargetConfirming, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(fuyin.name) and
      data.card.trueName == "slash"
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if player:usedSkillTimes(fuyin.name, Player.HistoryTurn) == 1 then
      data:cancelCurrentTarget()
    else
      room:setPlayerMark(player, "@@shzj_xiangfan__fuyin-turn", 1)
    end
  end,
})

fuyin:addEffect("maxcards", {
  correct_func = function(self, player)
    if player:hasSkill(fuyin.name) then
      return #table.filter(Fk:currentRoom().alive_players, function (p)
        return p.kingdom == "shu"
      end)
    end
  end,
})

fuyin:addEffect(fk.PreHpRecover, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@@shzj_xiangfan__fuyin-turn") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    data:preventRecover()
  end,
})

return fuyin
