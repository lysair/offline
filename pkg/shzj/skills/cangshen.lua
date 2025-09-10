local cangshen = fk.CreateSkill {
  name = "cangshen",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["cangshen"] = "藏身",
  [":cangshen"] = "锁定技，其他角色计算与你距离+1；当你使用【杀】后，〖藏身〗本轮失效。",
}

cangshen:addEffect(fk.CardUseFinished, {
  anim_type = "negative",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(cangshen.name) and
      data.card.trueName == "slash"
  end,
  on_use = function(self, event, target, player, data)
    player.room:invalidateSkill(player, "cangshen", "-round")
  end,
})

cangshen:addEffect("distance", {
  correct_func = function(self, from, to)
    if to:hasSkill(cangshen.name) then
      return 1
    end
  end,
})

return cangshen
