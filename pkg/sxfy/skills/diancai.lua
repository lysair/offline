local diancai = fk.CreateSkill {
  name = "sxfy__diancai",
}

Fk:loadTranslationTable{
  ["sxfy__diancai"] = "典财",
  [":sxfy__diancai"] = "当一名角色失去装备区内的最后一张牌后，你摸一张牌。",
}

diancai:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  trigger_times = function(self, event, target, player, data)
    local i = 0
    for _, move in ipairs(data) do
      if move.from and #move.from:getCardIds("e") == 0 and
        table.find(move.moveInfo, function (info)
          return info.fromArea == Card.PlayerEquip
        end) then
        i = i + 1
      end
    end
    return i
  end,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(diancai.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, diancai.name)
  end,
})

return diancai
