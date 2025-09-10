local dizhou = fk.CreateSkill {
  name = "ofl_tx__dizhou",
  derived_piles = "$ofl_tx__dizhou",
}

Fk:loadTranslationTable{
  ["ofl_tx__dizhou"] = "地咒",
  [":ofl_tx__dizhou"] = "准备阶段或结束阶段，你可以将一张牌置于你的武将牌上，称为“地咒”。当敌方角色使用与“地咒”花色相同的牌时，"..
  "其进行判定，若结果为：黑色，其随机弃置一张牌；♠，此牌无效；♠2~9，其失去1点体力。当你受到伤害后，移去一张“地咒”。",

  ["$ofl_tx__dizhou"] = "地咒",
  ["#ofl_tx__dizhou-ask"] = "地咒：你可以将一张牌置于你的武将牌上",
  ["#ofl_tx__dizhou-remove"] = "地咒：你需移去一张“地咒”牌",

  ["$ofl_tx__dizhou1"] = "朱雀玄武，誓为我征！",
  ["$ofl_tx__dizhou2"] = "所呼立至，所召立前！"
}

dizhou:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(dizhou.name) and
      (player.phase == Player.Start or player.phase == Player.Finish) and
      not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cards = room:askToCards(player, {
      skill_name = dizhou.name,
      min_num = 1,
      max_num = 1,
      include_equip = true,
      prompt = "#ofl_tx__dizhou-ask",
      cancelable = true,
    })
    if #cards > 0 then
      event:setCostData(self, {cards = cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player:addToPile("$ofl_tx__dizhou", event:getCostData(self).cards, false, dizhou.name)
  end,
})

dizhou:addEffect(fk.CardUsing, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target:isEnemy(player) and player:hasSkill(dizhou.name) and
      not target.dead and
      table.find(player:getPile("$ofl_tx__dizhou"), function (id)
        return Fk:getCardById(id):compareSuitWith(data.card)
      end)
  end,
  on_cost = function (self, event, target, player, data)
    event:setCostData(self, {tos = {target}})
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local judge = {
      who = target,
      reason = dizhou.name,
      pattern = ".|.|spade,club",
    }
    room:judge(judge)
    if judge:matchPattern() then
      if not target.dead then
        local cards = table.filter(target:getCardIds("he"), function (id)
          return not target:prohibitDiscard(id)
        end)
        if #cards > 0 then
          room:throwCard(table.random(cards), dizhou.name, target, target)
        end
      end
      if judge.card and judge.card.suit == Card.Spade then
        data.toCard = nil
        data:removeAllTargets()
        if judge.card.number > 1 and judge.card.number < 10 and not target.dead then
          room:loseHp(target, 1, dizhou.name)
        end
      end
    end
  end,
})

dizhou:addEffect(fk.Damaged, {
  anim_type = "negative",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(dizhou.name) and #player:getPile("$ofl_tx__dizhou") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = player:getPile("$ofl_tx__dizhou")
    if #cards > 1 then
      cards = room:askToCards(player, {
        skill_name = dizhou.name,
        min_num = 1,
        max_num = 1,
        include_equip = false,
        pattern = ".|.|.|$ofl_tx__dizhou",
        prompt = "#ofl_tx__dizhou-remove",
        expand_pile = "$ofl_tx__dizhou",
        cancelable = false,
      })
    end
    room:moveCardTo(cards, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, dizhou.name, nil, true, player)
  end,
})

return dizhou
