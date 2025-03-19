local fhyx__shouxi = fk.CreateSkill {
  name = "fhyx__shouxi"
}

Fk:loadTranslationTable{
  ['fhyx__shouxi'] = '守玺',
  ['#fhyx__shouxi-invoke'] = '守玺：你可以声明类别，%dest 需弃置一张此类别牌并获得你一张手牌，否则%arg对你无效',
  ['#fhyx__shouxi-discard'] = '守玺：弃置一张 %arg 并获得 %src 一张手牌，否则%arg对其无效',
  [':fhyx__shouxi'] = '当你成为其他角色使用【杀】或普通锦囊牌的目标后，你可声明一种牌的类别，令使用者选择一项：1.弃置一张此类别的牌，然后其可以获得你的一张手牌；2.此牌对你无效。',
}

fhyx__shouxi:addEffect(fk.TargetConfirmed, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skill.name) and (data.card.trueName == "slash" or data.card:isCommonTrick()) and
      data.from ~= player.id
  end,
  on_cost = function(self, event, target, player, data)
    local choice = player.room:askToChoice(player, {
      choices = {"basic", "trick", "equip", "Cancel"},
      skill_name = skill.name,
      prompt = "#fhyx__shouxi-invoke::"..data.from..":"..data.card:toLogString()
    })
    if choice ~= "Cancel" then
      event:setCostData(skill, {choice = choice})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local from = room:getPlayerById(data.from)
    local cardType = event:getCostData(skill).choice
    if from.dead or #room:askToDiscard(from, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = skill.name,
      cancelable = true,
      pattern = ".|.|.|.|.|"..cardType,
      prompt = "#fhyx__shouxi-discard:"..player.id.."::"..cardType
    }) == 0 then
      table.insertIfNeed(data.nullifiedTargets, player.id)
    elseif not player:isKongcheng() and not player.dead and not from.dead then
      local cards = room:askToChooseCards(from, {
        min = 0,
        max = 1,
        target = player,
        flag = "h",
        skill_name = skill.name
      })
      if #cards > 0 then
        room:moveCardTo(cards, Card.PlayerHand, from, fk.ReasonPrey, skill.name, nil, false, from.id)
      end
    end
  end,
})

return fhyx__shouxi
