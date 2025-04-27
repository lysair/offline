local fhyx_extra_pile = fk.CreateSkill {
  name = "#fhyx_extra_pile&",
}

Fk:loadTranslationTable{
  ["@$fhyx_extra_pile"] = "额外牌堆",
}

fhyx_extra_pile:addEffect(fk.AfterCardsMove, {
  can_refresh = function(self, event, target, player, data)
    if player.seat == 1 then
      for _, move in ipairs(data) do
        for _, info in ipairs(move.moveInfo) do
          if player.room:getBanner("fhyx_extra_pile") and
            table.contains(player.room:getBanner("fhyx_extra_pile"), info.cardId) then
            return true
          end
        end
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local ids = table.filter(room:getBanner("fhyx_extra_pile"), function(id)
      return room:getCardArea(id) == Card.Void
    end)
    room:setBanner("@$fhyx_extra_pile", ids)
  end,
})

return fhyx_extra_pile
