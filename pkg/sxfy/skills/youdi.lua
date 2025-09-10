local youdi = fk.CreateSkill{
  name = "sxfy__youdi",
}

Fk:loadTranslationTable{
  ["sxfy__youdi"] = "诱敌",
  [":sxfy__youdi"] = "结束阶段，你可以将一张红色牌当【顺手牵羊】使用。",

  ["#sxfy__youdi-invoke"] = "诱敌：你可以将一张红色牌当【顺手牵羊】使用",
}

youdi:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(youdi.name) and player.phase == Player.Finish and
      (#player:getHandlyIds() > 0 or #player:getCardIds("e") > 0)
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local use = room:askToUseVirtualCard(player, {
      name = "snatch",
      skill_name = youdi.name,
      prompt = "#sxfy__youdi-invoke",
      cancelable = true,
      card_filter = {
        n = 1,
        pattern = ".|.|heart,diamond",
      },
      skip = true,
    })
    if use then
      event:setCostData(self, {extra_data = use})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:useCard(event:getCostData(self).extra_data)
  end,
})

return youdi
