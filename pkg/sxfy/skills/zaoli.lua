local zaoli = fk.CreateSkill {
  name = "sxfy__zaoli",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["sxfy__zaoli"] = "躁厉",
  [":sxfy__zaoli"] = "锁定技，准备阶段，你须弃置所有手牌或装备区内的牌，然后摸等量的牌（每损失1点体力额外摸一张牌），然后你失去1点体力。",

  ["#sxfy__zaoli-choice"] = "躁厉：弃置所有手牌或装备，摸等量（+已损失体力值）的牌",
}

zaoli:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(zaoli.name) and player.phase == Player.Start
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local choices = {}
    if not player:isKongcheng() and table.find(player:getCardIds("h"), function (id)
      return not player:prohibitDiscard(id)
    end) then
      table.insert(choices, "hand_card")
    end
    if #player:getCardIds("e") > 0 and table.find(player:getCardIds("e"), function (id)
      return not player:prohibitDiscard(id)
    end) then
      table.insert(choices, "$Equip")
    end
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = zaoli.name,
      prompt = "#sxfy__zaoli-choice",
      all_choices = {"hand_card", "$Equip"}
    })
    local n = 0
    if choice == "hand_card" then
      n = #table.filter(player:getCardIds("h"), function (id)
        return not player:prohibitDiscard(id)
      end)
      player:throwAllCards("h", zaoli.name)
    else
      n = #table.filter(player:getCardIds("e"), function (id)
        return not player:prohibitDiscard(id)
      end)
      player:throwAllCards("e", zaoli.name)
    end
    if player.dead then return end
    n = n + player:getLostHp()
    if n > 0 then
      player:drawCards(n + player:getLostHp(), zaoli.name)
      if player.dead then return end
    end
    room:loseHp(player, 1, zaoli.name)
  end,
})

return zaoli
