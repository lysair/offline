local moushi = fk.CreateSkill {
  name = "ofl_shiji__moushi",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_shiji__moushi"] = "谋识",
  [":ofl_shiji__moushi"] = "锁定技，当你受到牌造成的伤害时，若你本回合受到过此花色的牌造成的伤害，防止此伤害。",
}

moushi:addEffect(fk.DamageInflicted, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(moushi.name) and data.card and
      #player.room.logic:getActualDamageEvents(1, function(e)
        local damage = e.data
        return damage.to == player and damage.card ~= nil and damage.card:compareSuitWith(data.card)
      end, Player.HistoryTurn) > 0
  end,
  on_use = function (self, event, target, player, data)
    data:preventDamage()
  end,
})

return moushi
