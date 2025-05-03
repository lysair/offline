local fengpo = fk.CreateSkill {
  name = "sxfy__fengpo",
}

Fk:loadTranslationTable{
  ["sxfy__fengpo"] = "凤魄",
  [":sxfy__fengpo"] = "你使用【杀】对目标造成伤害时，你可以弃置你或其一张牌，若此牌为<font color='red'>♦</font>牌，则此伤害+1。",

  ["#sxfy__fengpo-invoke"] = "凤魄：弃置你或 %dest 一张牌，若为<font color='red'>♦</font>，此伤害+1",
}

fengpo:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(fengpo.name) and
      data.card and data.card.trueName == "slash" and
      player.room.logic:damageByCardEffect() and not (player:isNude() and data.to:isNude())
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = {}
    if not player:isNude() and table.find(player:getCardIds("he"), function (id)
        return not player:prohibitDiscard(id)
      end) then
      table.insert(targets, player)
    end
    if not data.to:isNude() then
      table.insert(targets, data.to)
    end
    if #targets == 0 then
      room:askToCards(player, {
        min_num = 1,
        max_num = 1,
        include_equip = false,
        skill_name = fengpo.name,
        pattern = "false",
        prompt = "#sxfy__fengpo-invoke::"..data.to.id,
        cancelable = true,
      })
      return
    end
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = fengpo.name,
      prompt = "#sxfy__fengpo-invoke::"..data.to.id,
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
    local card
    if to == player then
      card = room:askToDiscard(player, {
        min_num = 1,
        max_num = 1,
        include_equip = true,
        skill_name = fengpo.name,
        cancelable = false,
        skip = true,
      })
    else
      card = room:askToChooseCard(player, {
        target = to,
        flag = "he",
        skill_name = fengpo.name,
      })
      card = {card}
    end
    if Fk:getCardById(card[1]).suit == Card.Diamond then
      data:changeDamage(1)
    end
    room:throwCard(card, fengpo.name, to, player)
  end,
})

return fengpo
