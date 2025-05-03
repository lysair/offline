local duanbing = fk.CreateSkill {
  name = "sxfy__duanbing",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["sxfy__duanbing"] = "短兵",
  [":sxfy__duanbing"] = "锁定技，你的攻击范围始终为1，你使用【杀】每回合首次造成的伤害+1。",
}

duanbing:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(duanbing.name) and
      data.card and data.card.trueName == "slash" and
      player:usedSkillTimes(duanbing.name, Player.HistoryTurn) == 0 and
        #player.room.logic:getActualDamageEvents(1, function(e)
          local damage = e.data
          return damage.from == player and damage.card ~= nil and damage.card.trueName == "slash"
        end, Player.HistoryTurn) == 0
  end,
  on_use = function(self, event, target, player, data)
    data:changeDamage(1)
  end,
})

duanbing:addEffect("atkrange", {
  final_func = function (self, player)
    if player:hasSkill(duanbing.name) then
      return 1
    end
  end,
})

return duanbing
