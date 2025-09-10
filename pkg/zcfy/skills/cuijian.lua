local cuijian = fk.CreateSkill {
  name = "sxfy__cuijian",
}

Fk:loadTranslationTable{
  ["sxfy__cuijian"] = "摧坚",
  [":sxfy__cuijian"] = "摸牌阶段开始前，你可以跳过摸牌阶段，然后选择一名其他角色，令其展示所有手牌，你获得其中至多两张基本牌。",

  ["#sxfy__cuijian-choose"] = "摧坚：令一名角色展示手牌，获得其中至多两张基本牌",
}

cuijian:addEffect(fk.EventPhaseChanging, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(cuijian.name) and
      data.phase == Player.Draw and not data.skipped
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    data.skipped = true
    local targets = table.filter(room:getOtherPlayers(player, false), function (p)
      return not p:isKongcheng()
    end)
    if #targets > 0 then
      local to = room:askToChoosePlayers(player, {
        min_num = 1,
        max_num = 1,
        targets = targets,
        skill_name = cuijian.name,
        prompt = "#sxfy__cuijian-choose",
        cancelable = false,
      })[1]
      local cards = table.simpleClone(to:getCardIds("h"))
      to:showCards(cards)
      if player.dead or to.dead then return end
      cards = table.filter(cards, function (id)
        return Fk:getCardById(id).type == Card.TypeBasic
      end)
      if #cards > 0 then
        cards = room:askToChooseCards(player, {
          target = to,
          min = 0,
          max = 2,
          flag = { card_data = {{ to.general, cards }} },
          skill_name = cuijian.name,
        })
        if #cards > 0 then
          room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonPrey, cuijian.name, nil, true, player)
        end
      end
    end
  end,
})

return cuijian
