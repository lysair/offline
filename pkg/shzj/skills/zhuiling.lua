local zhuiling = fk.CreateSkill {
  name = "zhuiling",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["zhuiling"] = "追灵",
  [":zhuiling"] = "锁定技，一名角色失去体力后，你获得等量的“魂”（“魂”至多为3）。你对没有手牌的角色使用牌无距离次数限制。",

  ["@anying_soul"] = "魂",
}

zhuiling:addEffect(fk.HpLost, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(zhuiling.name) and data.num > 0 and player:getMark("@anying_soul") < 3
  end,
  on_use = function(self, event, target, player, data)
    local n = math.min(3 - player:getMark("@anying_soul"), data.num)
    player.room:addPlayerMark(player, "@anying_soul", n)
  end,
})

zhuiling:addEffect(fk.PreCardUse, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(zhuiling.name) and
      table.find(data.tos, function (p)
        return p:isKongcheng()
      end)
  end,
  on_refresh = function(self, event, target, player, data)
    data.extraUse = true
  end,
})

zhuiling:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card, to)
    return card and player:hasSkill(zhuiling.name) and to and to:isKongcheng()
  end,
  bypass_distances =  function(self, player, skill, card, to)
    return card and player:hasSkill(zhuiling.name) and to and to:isKongcheng()
  end,
})

zhuiling:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, "@anying_soul", 0)
end)

return zhuiling
