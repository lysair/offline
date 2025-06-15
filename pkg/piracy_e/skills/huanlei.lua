local huanlei = fk.CreateSkill({
  name = "huanlei",
})

Fk:loadTranslationTable{
  ["huanlei"] = "唤雷",
  [":huanlei"] = "当你使用或打出【闪】、【闪电】或不因此技能进行判定结算结束后，你可以令一名其他角色进行判定，若结果为♠，你对其造成2点雷电伤害；"..
  "不为♠，你获得其一张手牌。",

  ["#huanlei-choose"] = "唤雷：令一名角色进行判定，若为♠，对其造成2点雷电伤害，否则获得其一张手牌",
}

local spec = {
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(huanlei.name) and target == player and #player.room:getOtherPlayers(player, false) > 0 then
      if event == fk.CardUseFinished or event == fk.CardRespondFinished then
        return data.card.trueName == "jink" or data.card.trueName == "lightning"
      elseif event == fk.FinishJudge then
        return data.reason ~= huanlei.name
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room:getOtherPlayers(player, false),
      skill_name = huanlei.name,
      prompt = "#huanlei-choose",
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local judge = {
      who = to,
      reason = huanlei.name,
      pattern = ".",
    }
    room:judge(judge)
    if to.dead then return end
    if judge.card.suit == Card.Spade then
      room:damage{
        from = player,
        to = to,
        damage = 2,
        damageType = fk.ThunderDamage,
        skillName = huanlei.name,
      }
    elseif not player.dead and not to:isKongcheng() then
      local card = room:askToChooseCard(player, {
        target = to,
        flag = "h",
        skill_name = huanlei.name,
      })
      room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonPrey, huanlei.name, nil, false, player)
    end
  end,
}

huanlei:addEffect(fk.CardUseFinished, spec)
huanlei:addEffect(fk.CardRespondFinished, spec)
huanlei:addEffect(fk.FinishJudge, spec)

return huanlei
