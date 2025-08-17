local shuwei = fk.CreateSkill {
  name = "shzj_juedai__shuwei",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["shzj_juedai__shuwei"] = "戍卫",
  [":shzj_juedai__shuwei"] = "锁定技，出牌阶段，你至多使用X张牌。你使用【杀】伤害基数值改为X（X为你的体力值）。",
}

shuwei:addEffect(fk.PreCardUse, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(shuwei.name) and
      data.card.trueName == "slash"
  end,
  on_use = function(self, event, target, player, data)
    data.additionalDamage = (data.additionalDamage or 0) + player.hp - 1
  end,
})

shuwei:addEffect(fk.CardUsing, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player.phase == Player.Play
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "shuwei-turn", 1)
  end,
})

shuwei:addEffect("prohibit", {
  prohibit_use = function(self, player, card)
    return
      card and
      player.phase == Player.Play and
      player:getMark("shuwei-turn") >= player.hp and
      player:hasSkill(shuwei.name)
  end,
})

return shuwei
