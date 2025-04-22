local ofl_shiji__tianyi = fk.CreateSkill {
  name = "ofl_shiji__tianyi"
}

Fk:loadTranslationTable{
  ['ofl_shiji__tianyi'] = '天翊',
  ['#ofl_shiji__tianyi-choose'] = '天翊：令一名角色获得技能〖佐幸〗',
  [':ofl_shiji__tianyi'] = '觉醒技，准备阶段，若所有存活角色均受到过伤害，你增加体力上限至10点，然后令一名角色获得〖佐幸〗。',
}

ofl_shiji__tianyi:addEffect(fk.EventPhaseStart, {
  anim_type = "special",
  frequency = Skill.Wake,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skill.name) and
      player.phase == Player.Start and
      player:usedSkillTimes(skill.name, Player.HistoryGame) == 0
  end,
  can_wake = function(self, event, target, player, data)
    return table.every(player.room.alive_players, function(p)
      return #player.room.logic:getActualDamageEvents(1, function(e) return e.data[1].to == p end, Player.HistoryGame) > 0
    end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if player.maxHp < 10 then
      room:changeMaxHp(player, 10 - player.maxHp)
    end
    local tos = room:askToChoosePlayers(player, {
      targets = table.map(room.alive_players, Util.IdMapper),
      min_num = 1,
      max_num = 1,
      prompt = "#ofl_shiji__tianyi-choose",
      skill_name = skill.name,
      cancelable = false
    })
    room:handleAddLoseSkills(room:getPlayerById(tos[1]), "zuoxing", nil, true, false)
  end,
})

return ofl_shiji__tianyi
