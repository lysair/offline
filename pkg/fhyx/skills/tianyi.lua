local tianyi = fk.CreateSkill {
  name = "ofl_shiji__tianyi",
  tags = { Skill.Wake },
}

Fk:loadTranslationTable{
  ["ofl_shiji__tianyi"] = "天翊",
  [":ofl_shiji__tianyi"] = "觉醒技，准备阶段，若所有存活角色均受到过伤害，你增加体力上限至10点，然后令一名角色获得〖佐幸〗。",

  ["#ofl_shiji__tianyi-choose"] = "天翊：令一名角色获得技能〖佐幸〗",

  ["$ofl_shiji__tianyi1"] = "今九州纷乱，当祈天翊佑。",
  ["$ofl_shiji__tianyi2"] = "明主既现，吾定极尽所能。",
  ["$ofl_shiji__tianyi3"] = "人心所向，未来之事皆一睹而尽知。",
  ["$ofl_shiji__tianyi4"] = "笑揽世间众生，坐观天行定数。",
}

tianyi:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(tianyi.name) and player.phase == Player.Start and
      player:usedSkillTimes(tianyi.name, Player.HistoryGame) == 0
  end,
  can_wake = function(self, event, target, player, data)
    return table.every(player.room.alive_players, function(p)
      return #player.room.logic:getActualDamageEvents(1, function(e)
        return e.data.to == p
      end, Player.HistoryGame) > 0
    end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if player.maxHp < 10 then
      room:changeMaxHp(player, 10 - player.maxHp)
      if player.dead then return end
    end
    local to = room:askToChoosePlayers(player, {
      targets = room.alive_players,
      min_num = 1,
      max_num = 1,
      prompt = "#ofl_shiji__tianyi-choose",
      skill_name = tianyi.name,
      cancelable = false,
    })[1]
    room:addTableMark(to, "mobile__tianyi_src", player.id)
    room:handleAddLoseSkills(to, "zuoxing")
  end,
})

return tianyi
