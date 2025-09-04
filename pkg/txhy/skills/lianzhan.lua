local lianzhan = fk.CreateSkill {
  name = "ofl_tx__lianzhan",
}

Fk:loadTranslationTable{
  ["ofl_tx__lianzhan"] = "连战",
  [":ofl_tx__lianzhan"] = "当你造成伤害后，你摸一张牌。<a href='os__wrestle'>搏击</a>：再摸X张牌（X为此伤害值）。",
}

lianzhan:addEffect(fk.Damage, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(lianzhan.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local yes = player:inMyAttackRange(data.to) and data.to:inMyAttackRange(player)
    player:drawCards(1, lianzhan.name)
    if player.dead then return end
    if yes then
      player:drawCards(data.damage, lianzhan.name)
    end
  end,
})

return lianzhan
