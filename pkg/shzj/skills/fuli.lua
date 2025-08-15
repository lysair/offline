
local fuli = fk.CreateSkill {
  name = "shzj_juedai__fuli",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable{
  ["shzj_juedai__fuli"] = "伏枥",
  [":shzj_juedai__fuli"] = "限定技，当你处于濒死状态时，你可以回复体力至2点并摸两张牌，然后当前回合结束后，你执行一个额外的出牌阶段。",

  ["$shzj_juedai__fuli1"] = "将士们，随老夫再战一场！",
  ["$shzj_juedai__fuli2"] = "老夫可没这么容易被打败。",
}

fuli:addEffect(fk.AskForPeaches, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(fuli.name) and
      player.dying and player:usedSkillTimes(fuli.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:recover{
      who = player,
      num = 2 - player.hp,
      recoverBy = player,
      skillName = fuli.name,
    }
    if not player.dead then
      player:drawCards(2, fuli.name)
    end
    if not player.dead then
      room.logic:getCurrentEvent():findParent(GameEvent.Turn):addCleaner(function()
        player:gainAnExtraPhase(Player.Play, fuli.name, false)
      end)
    end
  end,
})

return fuli
