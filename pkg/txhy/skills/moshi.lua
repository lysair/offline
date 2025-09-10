local moshi = fk.CreateSkill {
  name = "ofl_tx__moshi",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_tx__moshi"] = "魔士",
  [":ofl_tx__moshi"] = "锁定技，当你使用黑色锦囊牌指定敌方角色为目标后，其失去1点体力；"..
  "当你使用红色锦囊牌指定敌方角色为目标后，对其造成1点火焰伤害。"..
  "若你在一回合内对同一名角色发动了前两项效果，则其非锁定技失效直到其下回合开始。",

  ["@@ofl_tx__moshi"] = "非锁定技失效",
}

moshi:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(moshi.name) and
      data.card.type == Card.TypeTrick and data.card.color ~= Card.NoColor and
      player:isEnemy(data.to) and not data.to.dead
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local mark = player:getTableMark("ofl_tx__moshi-turn")
    mark[data.to] = mark[data.to] or {}
    table.insertIfNeed(mark[data.to], data.card.color)
    room:setPlayerMark(player, "ofl_tx__moshi-turn", mark)
    local yes = #mark[data.to] == 2 and data.to:getMark("@@ofl_tx__moshi") == 0
    if data.card.color == Card.Black then
      room:loseHp(data.to, 1, moshi.name)
    else
      room:damage{
        from = player,
        to = data.to,
        damage = 1,
        damageType = fk.FireDamage,
        skillName = moshi.name,
      }
    end
    if yes and not data.to.dead then
      room:addPlayerMark(data.to, "@@ofl_tx__moshi", 1)
      room:addPlayerMark(data.to, MarkEnum.UncompulsoryInvalidity, 1)
    end
  end,
})

moshi:addEffect(fk.TurnStart, {
  can_refresh = function (self, event, target, player, data)
    return target == player and player:getMark("@@ofl_tx__moshi") > 0
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    room:removePlayerMark(player, MarkEnum.UncompulsoryInvalidity, player:getMark("@@ofl_tx__moshi"))
    room:setPlayerMark(player, "@@ofl_tx__moshi", 0)
  end,
})

return moshi
