local huxiao = fk.CreateSkill{
  name = "shzj_guansuo__huxiao",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["shzj_guansuo__huxiao"] = "虎啸",
  [":shzj_guansuo__huxiao"] = "锁定技，当你每回合首次造成火焰伤害后，你摸一张牌，本回合对已受伤角色使用牌无次数限制。",

  ["$shzj_guansuo__huxiao1"] = "白雪卷地起，大地换新装！",
  ["$shzj_guansuo__huxiao2"] = "虎啸融山雪，迎春换新芽！",
}

huxiao:addEffect(fk.Damage, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(huxiao.name) and data.damageType == fk.FireDamage then
      local damage_events = player.room.logic:getEventsOfScope(GameEvent.Damage, 1, function (e)
        return e.data.from == player and e.data.damageType == fk.FireDamage
      end, player.HistoryTurn)
      return #damage_events == 1 and damage_events[1].data == data
    end
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, huxiao.name)
  end,
})

huxiao:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card, to)
    return card and player:usedSkillTimes(huxiao.name, Player.HistoryTurn) > 0 and to and to:isWounded()
  end,
})

return huxiao
