local shouxi = fk.CreateSkill {
  name = "fhyx__shouxi",
}

Fk:loadTranslationTable{
  ["fhyx__shouxi"] = "守玺",
  [":fhyx__shouxi"] = "当你成为其他角色使用【杀】或普通锦囊牌的目标后，你可以声明一种牌的类别，令使用者选择一项：1.弃置一张此类别的牌，"..
  "然后其可以获得你的一张手牌；2.此牌对你无效。",

  ["#fhyx__shouxi-invoke"] = "守玺：你可以声明类别，%dest 需弃置一张此类别牌并获得你一张手牌，否则%arg对你无效",
  ["#fhyx__shouxi-discard"] = "守玺：弃置一张%arg并获得 %src 一张手牌，否则%arg2对其无效",
  ["#fhyx__shouxi-prey"] = "守玺：你可以获得 %src 一张手牌",
}

shouxi:addEffect(fk.TargetConfirmed, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(shouxi.name) and data.from ~= player and
      (data.card.trueName == "slash" or data.card:isCommonTrick())
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local choice = room:askToChoice(player, {
      choices = {"basic", "trick", "equip", "Cancel"},
      skill_name = shouxi.name,
      prompt = "#fhyx__shouxi-invoke::"..data.from.id..":"..data.card:toLogString()
    })
    if choice ~= "Cancel" then
      event:setCostData(self, {tos = {data.from}, choice = choice})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cardType = event:getCostData(self).choice
    room:sendLog{
      type = "#Choice",
      from = player.id,
      arg = cardType,
      toast = true,
    }
    if data.from.dead or data.from:isNude() or
      #room:askToDiscard(data.from, {
        min_num = 1,
        max_num = 1,
        include_equip = false,
        skill_name = shouxi.name,
        cancelable = true,
        pattern = ".|.|.|.|.|"..cardType,
        prompt = "#fhyx__shouxi-discard:"..player.id.."::"..cardType..":"..data.card:toLogString(),
      }) == 0 then
      data.use.nullifiedTargets = data.use.nullifiedTargets or {}
      table.insertIfNeed(data.use.nullifiedTargets, player)
      return
    end
    if not player:isKongcheng() and not player.dead and not data.from.dead then
      local card = room:askToChooseCards(data.from, {
        min = 0,
        max = 1,
        target = player,
        flag = "h",
        skill_name = shouxi.name,
        prompt = "#fhyx__shouxi-prey:"..player.id,
      })
      if #card > 0 then
        room:moveCardTo(card, Card.PlayerHand, data.from, fk.ReasonPrey, shouxi.name, nil, false, data.from)
      end
    end
  end,
})

return shouxi
