local koulue = fk.CreateSkill {
  name = "sxfy__koulue",
}

Fk:loadTranslationTable{
  ["sxfy__koulue"] = "寇略",
  [":sxfy__koulue"] = "每阶段限一次，当你于出牌阶段内对其他角色造成伤害后，你可以展示其X张手牌（X为其已损失体力值），若其中有："..
  "伤害牌，你获得之；红色牌，你减1点体力上限，然后摸一张牌。",

  ["#sxfy__koulue-invoke"] = "寇略：你可以展示 %dest 的手牌，获得其中的伤害牌",
}

koulue:addEffect(fk.Damage, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(koulue.name) and
      player.phase == Player.Play and data.to ~= player and
      not data.to.dead and not data.to:isKongcheng() and data.to:isWounded() and
      player:usedSkillTimes(koulue.name, Player.HistoryPhase) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = koulue.name,
      prompt = "#sxfy__koulue-invoke::" .. data.to.id,
    }) then
      event:setCostData(self, {tos = {data.to}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = room:askToChooseCards(player, {
      target = data.to,
      min = data.to:getLostHp(),
      max = data.to:getLostHp(),
      flag = "h",
      skill_name = koulue.name,
    })
    data.to:showCards(cards)
    if player.dead then return end
    local get = table.filter(cards, function(id)
      return Fk:getCardById(id).is_damage_card and table.contains(data.to:getCardIds("h"), id)
    end)
    if #get > 0 then
      room:moveCardTo(get, Card.PlayerHand, player, fk.ReasonPrey, koulue.name, nil, true, player)
    end
    if not player.dead and table.find(cards, function(id)
      return Fk:getCardById(id).color == Card.Red
    end) then
      room:changeMaxHp(player, -1)
      if not player.dead then
        player:drawCards(1, koulue.name)
      end
    end
  end,
})

return koulue
