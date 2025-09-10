local jiyang = fk.CreateSkill {
  name = "ofl_tx__jiyang",
  tags = { Skill.Spirited },
}

Fk:loadTranslationTable{
  ["ofl_tx__jiyang"] = "激扬",
  [":ofl_tx__jiyang"] = "<a href='#SpiritedSkillDesc'>昂扬技</a>，摸牌阶段，你多摸两张牌。"..
  "<a href='#SpiritedSkillDesc'>激昂</a>：使用四张牌。",

  ["@ofl_tx__jiyang"] = "激扬",
}

jiyang:addEffect(fk.DrawNCards, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jiyang.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@ofl_tx__jiyang", "0/4")
    data.n = data.n + 2
  end
})

jiyang:addEffect(fk.CardUsing, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@ofl_tx__jiyang") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local n = tonumber(player:getMark("@ofl_tx__jiyang")[1])
    n = n + 1
    if n > 3 then
      room:setPlayerMark(player, "@ofl_tx__jiyang", 0)
    else
      room:setPlayerMark(player, "@ofl_tx__jiyang", n.."/4")
    end
  end,
})

jiyang:addEffect("invalidity", {
  invalidity_func = function (self, from, skill)
    return from:getMark("@ofl_tx__jiyang") ~= 0 and skill.name == jiyang.name
  end,
})

jiyang:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, "@ofl_tx__jiyang", 0)
end)

return jiyang
