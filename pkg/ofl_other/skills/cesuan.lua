local cesuan = fk.CreateSkill {
  name = "cesuan"
}

Fk:loadTranslationTable{
  ['cesuan'] = '策算',
  [':cesuan'] = '锁定技，当你受到伤害时，你防止此伤害，若你的体力：小于体力上限，你减1点体力上限；不小于体力上限，你减1点体力上限，摸一张牌。',
}

cesuan:addEffect(fk.DamageInflicted, {
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("yisuan")
    if player.hp < player.maxHp then
      room:changeMaxHp(player, -1)
    else
      room:changeMaxHp(player, -1)
      player:drawCards(1, cesuan.name)
    end
    return true
  end,
})

return cesuan
