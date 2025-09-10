local xianming = fk.CreateSkill {
  name = "ofl_shiji__xianming",
}

Fk:loadTranslationTable{
  ["ofl_shiji__xianming"] = "显名",
  [":ofl_shiji__xianming"] = "每回合限一次，当额外牌堆中失去最后一张基本牌后，你可以摸两张牌并回复1点体力。",
}

xianming:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(xianming.name) and player.room:getBanner("fhyx_extra_pile") and
      player:usedSkillTimes(xianming.name, Player.HistoryTurn) == 0 and
      #table.filter(player.room:getBanner("@$fhyx_extra_pile"), function(id)
        return Fk:getCardById(id).type == Card.TypeBasic
      end) == 0 then
      for _, move in ipairs(data) do
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.Void and
            table.contains(player.room:getBanner("fhyx_extra_pile"), info.cardId) then
            return true
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(2, xianming.name)
    if player:isWounded() and not player.dead then
      player.room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = xianming.name,
      }
    end
  end,
})

return xianming
