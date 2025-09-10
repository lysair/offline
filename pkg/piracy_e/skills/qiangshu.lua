local qiangshu = fk.CreateSkill {
  name = "qiangshu",
}

Fk:loadTranslationTable{
  ["qiangshu"] = "枪术",
  [":qiangshu"] = "当你使用【杀】或【决斗】造成伤害时，你可以弃置X张牌，令此伤害+X（X为你的攻击范围-1）。",

  ["#qiangshu-invoke"] = "枪术：你可以弃置%arg张牌，令你对 %dest 造成的伤害+%arg",
}

qiangshu:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(qiangshu.name) and data.card and
      table.contains({"slash", "duel"}, data.card.trueName) and
      #player:getCardIds("he") >= player:getAttackRange() - 1 and
      player:getAttackRange() > 1
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local n = player:getAttackRange() - 1
    local cards = room:askToDiscard(player, {
      min_num = n,
      max_num = n,
      include_equip = true,
      skill_name = qiangshu.name,
      cancelable = true,
      prompt = "#qiangshu-invoke::" .. data.to.id..":"..n,
      skip = true,
    })
    if #cards > 0 then
      event:setCostData(self, {tos = {data.to}, cards = cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local n = player:getAttackRange() - 1
    player.room:throwCard(event:getCostData(self).cards, qiangshu.name, player, player)
    data:changeDamage(n)
  end,
})

return qiangshu
