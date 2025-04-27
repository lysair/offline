local ofl_shiji__moushi = fk.CreateSkill {
  name = "ofl_shiji__moushi"
}

Fk:loadTranslationTable{
  ['ofl_shiji__moushi'] = '谋识',
  [':ofl_shiji__moushi'] = '锁定技，当你受到牌造成的伤害时，若你本回合受到过此花色的牌造成的伤害，防止此伤害。',
}

ofl_shiji__moushi:addEffect(fk.DamageInflicted, {
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(ofl_shiji__moushi.name) and data.card and data.card.suit ~= Card.NoSuit and
      #player.room.logic:getActualDamageEvents(1, function(e)
        local damage = e.data[1]
        if damage.to == player and damage.card and damage.card.suit == data.card.suit then
          return true
        end
      end, Player.HistoryTurn) > 0
  end,
  on_use = Util.TrueFunc,
})

return ofl_shiji__moushi
