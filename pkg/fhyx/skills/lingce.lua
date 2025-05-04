local lingce = fk.CreateSkill {
  name = "ofl_shiji__lingce",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_shiji__lingce"] = "灵策",
  [":ofl_shiji__lingce"] = "锁定技，其他角色使用的智囊牌对你无效；一名角色使用智囊牌时，你摸一张牌。",

  ["$ofl_shiji__lingce1"] = "良策者，胜败之机也。",
  ["$ofl_shiji__lingce2"] = "以帷幄之规，下攻拔之捷。",
}

lingce:addEffect(fk.CardUsing, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(lingce.name) and data.card:isCommonTrick() and
      player.room:getBanner("Zhinang") and table.contains(player.room:getBanner("Zhinang"), data.card.name)
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, lingce.name)
  end,
})

lingce:addEffect(fk.PreCardEffect, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(lingce.name) and data.card:isCommonTrick() and
      player.room:getBanner("Zhinang") and table.contains(player.room:getBanner("Zhinang"), data.card.name) and
      data.from ~= player and data.to == player
  end,
  on_use = function(self, event, target, player, data)
    data.nullified = true
  end,
})

lingce:addAcquireEffect(function (self, player, is_start)
  local room = player.room
  if not room:getBanner("Zhinang") then
    room:setBanner("Zhinang", {"dismantlement", "nullification", "ex_nihilo"})
  end
end)

return lingce
