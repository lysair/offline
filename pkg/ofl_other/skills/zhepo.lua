local zhepo = fk.CreateSkill {
  name = "zhepo"
}

Fk:loadTranslationTable{
  ['zhepo'] = '辄破',
  [':zhepo'] = '锁定技，每回合限一次，当你对体力值不大于你的角色造成伤害后，你摸X张牌（X为场上起义军数量）。',
}

zhepo:addEffect(fk.Damage, {
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zhepo.name) and (data.extra_data or {}).zhepo and
      player:usedSkillTimes(zhepo.name, Player.HistoryTurn) == 0 and
      table.find(player.room.alive_players, function(p)
        return IsInsurrectionary(p)
      end)
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(#table.filter(player.room.alive_players, function(p)
      return IsInsurrectionary(p)
    end), zhepo.name)
  end,

  can_refresh = function(self, event, target, player, data)
    return data.damageEvent and player == data.damageEvent.from and player.hp >= target.hp
  end,
  on_refresh = function(self, event, target, player, data)
    data.damageEvent.extra_data = data.damageEvent.extra_data or {}
    data.damageEvent.extra_data.zhepo = true
  end,
})

return zhepo
