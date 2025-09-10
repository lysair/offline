local duanjin = fk.CreateSkill {
  name = "ofl_tx__duanjin",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_tx__duanjin"] = "断金",
  [":ofl_tx__duanjin"] = "锁定技，当你造成伤害时，你摸X张牌并回复1点体力（X为你本回合造成伤害的次数，至多为5）。",
}

duanjin:addEffect(fk.DamageCaused, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(duanjin.name)
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local n = #room.logic:getActualDamageEvents(4, function (e)
      return e.data.from == player
    end, Player.HistoryTurn)
    player:drawCards(1 + n, duanjin.name)
    if not player.dead then
      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = duanjin.name,
      }
    end
  end,
})

return duanjin
