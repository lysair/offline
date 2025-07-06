local tianyi = fk.CreateSkill {
  name = "sxfy__tianyi",
  tags = { Skill.Wake },
}

Fk:loadTranslationTable{
  ["sxfy__tianyi"] = "天翊",
  [":sxfy__tianyi"] = "觉醒技，准备阶段，若所有角色均已受伤，你获得〖佐幸〗，然后你将体力上限调整至本局游戏人数。",
}

tianyi:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(tianyi.name) and player.phase == Player.Start and
      player:usedSkillTimes(tianyi.name, Player.HistoryGame) == 0
  end,
  can_wake = function(self, event, target, player, data)
    return table.every(player.room.alive_players, function(p)
      return p:isWounded()
    end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:handleAddLoseSkills(player, "sxfy__zuoxing")
    if player.maxHp ~= #room.players then
      room:changeMaxHp(player, #room.players - player.maxHp)
    end
  end,
})

return tianyi
