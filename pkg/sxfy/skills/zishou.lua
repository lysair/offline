local zishou = fk.CreateSkill {
  name = "sxfy__zishou",
}

Fk:loadTranslationTable{
  ["sxfy__zishou"] = "自守",
  [":sxfy__zishou"] = "出牌阶段开始前，你可以摸当前势力张牌，然后你跳过此阶段。",
}

zishou:addEffect(fk.EventPhaseChanging, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zishou.name) and data.phase == Player.Play and
      not data.skipped
  end,
  on_use = function(self, event, target, player, data)
    data.skipped = true
    local kingdoms = {}
    for _, p in ipairs(player.room.alive_players) do
      table.insertIfNeed(kingdoms, p.kingdom)
    end
    player:drawCards(#kingdoms, zishou.name)
  end,
})

return zishou
