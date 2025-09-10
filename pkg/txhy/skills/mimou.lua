local mimou = fk.CreateSkill {
  name = "ofl_tx__mimou",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_tx__mimou"] = "密谋",
  [":ofl_tx__mimou"] = "锁定技，你受到的伤害-X（X为场上其他友方角色数）。友方角色的准备阶段，其从弃牌堆随机获得一张【杀】和两张锦囊牌。",
}

mimou:addEffect(fk.DamageInflicted, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(mimou.name) and
      #player:getFriends(false) > 0
  end,
  on_use = function (self, event, target, player, data)
    data:changeDamage(-#player:getFriends(false))
  end,
})

mimou:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(mimou.name) and target:isFriend(player) and target.phase == Player.Start and
      not target.dead
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local cards = room:getCardsFromPileByRule("slash", 1, "discardPile")
    table.insertTable(cards, room:getCardsFromPileByRule(".|.|.|.|.|trick", 2, "discardPile"))
    if #cards > 0 then
      room:moveCardTo(cards, Card.PlayerHand, target, fk.ReasonJustMove, mimou.name, nil, true, target)
    end
  end,
})

return mimou
