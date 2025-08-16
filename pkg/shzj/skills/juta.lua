local juta = fk.CreateSkill {
  name = "juta",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["juta"] = "据沓",
  [":juta"] = "锁定技，其他角色计算与你的距离+1。当其他角色使用牌指定你为目标时，其需弃置你与其距离数张牌，否则此牌对你无效。"..
  "当你使用【杀】结算结束后，你失去〖据沓〗，获得〖不戢〗。",

  ["#juta-discard"] = "据沓：弃置%arg张牌，否则此牌对 %src 无效",
}

juta:addEffect(fk.TargetConfirming, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(juta.name) and
      data.from ~= player
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = player:distanceTo(data.from)
    if data.from.dead or #room:askToDiscard(data.from, {
      min_num = n,
      max_num = n,
      include_equip = true,
      skill_name = juta.name,
      cancelable = true,
      prompt = "#juta-discard:"..player.id.."::"..n,
    }) == 0 then
      data.nullified = true
    end
  end,
})

juta:addEffect("distance", {
  correct_func = function(self, from, to)
    if to:hasSkill(juta.name) then
      return 1
    end
  end,
})

juta:addEffect(fk.CardUseFinished, {
  anim_type = "negative",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(juta.name) and
      data.card.trueName == "slash"
  end,
  on_use = function(self, event, target, player, data)
    player.room:handleAddLoseSkills(player, "-juta|buji")
  end,
})

return juta
