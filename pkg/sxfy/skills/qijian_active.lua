local qijian_active = fk.CreateSkill {
  name = "sxfy__qijian_active",
}

Fk:loadTranslationTable{
  ["sxfy__qijian_active"] = "七笺",
}

qijian_active:addEffect("active", {
  card_num = 0,
  target_num = 2,
  target_filter = function (self, player, to_select, selected)
    if #selected < 2 and to_select:getHandcardNum() < 8 then
      if #selected == 0 then
        return table.find(Fk:currentRoom().alive_players, function (p)
          return p:getHandcardNum() + to_select:getHandcardNum() == 7
        end)
      else
        return to_select:getHandcardNum() + selected[1]:getHandcardNum() == 7
      end
    end
  end,
})

return qijian_active
