local guanxing = fk.CreateSkill({
  name = "ofl__guanxing",
})

Fk:loadTranslationTable{
  ["ofl__guanxing"] = "观星",
  [":ofl__guanxing"] = "准备阶段，你可以观看牌堆顶的五张牌，以任意顺序置于牌堆顶或牌堆底。",
}

guanxing:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(guanxing.name) and player.phase == Player.Start
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:askToGuanxing(player, {
    cards = room:getNCards(5),
    skill_name = guanxing.name,
  })
  end,
})

return guanxing
