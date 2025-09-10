local jiaozi = fk.CreateSkill{
  name = "ofl_tx__jiaozi",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_tx__jiaozi"] = "骄恣",
  [":ofl_tx__jiaozi"] = "锁定技，若你的手牌数为全场最多，你造成的伤害+1。",

  ["$ofl_tx__jiaozi1"] = "数战之功，吾应得此赏！",
  ["$ofl_tx__jiaozi2"] = "无我出力，怎会连胜？",
}

jiaozi:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jiaozi.name) and
    table.every(player.room.alive_players, function(p)
      return player:getHandcardNum() >= p:getHandcardNum()
    end)
  end,
  on_cost = function (self, event, target, player, data)
    event:setCostData(self, { tos = { data.to } })
    return true
  end,
  on_use = function(self, event, target, player, data)
    data:changeDamage(1)
  end,
})

return jiaozi
