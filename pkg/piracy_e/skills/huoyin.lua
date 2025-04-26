local huoyin = fk.CreateSkill {
  name = "ofl__huoyin",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl__huoyin"] = "祸引",
  [":ofl__huoyin"] = "锁定技，你对攻击范围内含有你且你攻击范围内有其的其他角色：使用【杀】无次数限制；当你对这些角色造成伤害后，你摸一张牌，"..
  "然后其选择是否使用一张牌。",

  ["#ofl__huoyin-use"] = "祸引：你可以使用一张牌",
}

huoyin:addEffect(fk.Damage, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(huoyin.name) and (data.extra_data or {}).ofl__huoyin
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(1, huoyin.name)
    if not data.to.dead then
      room:askToPlayCard(data.to, {
        skill_name = huoyin.name,
        prompt = "#ofl__huoyin-use",
        cancelable = true,
        extra_data = {
          bypass_times = true,
          extraUse = true,
        },
      })
    end
  end,
})

huoyin:addEffect(fk.BeforeHpChanged, {
  can_refresh = function(self, event, target, player, data)
    return data.damageEvent and data.damageEvent.from == player and
      player:inMyAttackRange(target) and target:inMyAttackRange(player)
  end,
  on_refresh = function(self, event, target, player, data)
    data.damageEvent.extra_data = data.damageEvent.extra_data or {}
    data.damageEvent.extra_data.ofl__huoyin = true
  end,
})

huoyin:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card, to)
    return player:hasSkill(huoyin.name) and card and card.trueName == "slash" and
      to and player:inMyAttackRange(to) and to:inMyAttackRange(player)
  end,
})

return huoyin
