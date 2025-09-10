local aocai = fk.CreateSkill {
  name = "sxfy__aocai",
}

Fk:loadTranslationTable{
  ["sxfy__aocai"] = "傲才",
  [":sxfy__aocai"] = "一名角色回合结束时，若你没有手牌，你可以观看牌堆顶两张牌，然后你可以获得其中一张牌。",

  ["#sxfy__aocai-prey"] = "傲才：你可以获得其中一张牌",
}

aocai:addEffect(fk.TurnEnd, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(aocai.name) and player:isKongcheng()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = room:askToChooseCards(player, {
      target = player,
      min = 0,
      max = 1,
      flag = { card_data = {{ "Top", room:getNCards(2) }} },
      skill_name = aocai.name,
      prompt = "#sxfy__aocai-prey",
    })
    if #card > 0 then
      room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonJustMove, aocai.name, nil, false, player)
    end
  end,
})

return aocai
