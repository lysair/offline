local xianming = fk.CreateSkill {
  name = "ofl_shiji__xianming"
}

Fk:loadTranslationTable{
  ['ofl_shiji__xianming'] = '显名',
  ['@$fhyx_extra_pile'] = '额外牌堆',
  [':ofl_shiji__xianming'] = '每回合限一次，当额外牌堆中失去最后一张基本牌时，你可以摸两张牌并回复1点体力。',
}

xianming:addEffect(fk.BeforeCardsMove, {
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(xianming) and player:usedSkillTimes(xianming.name, Player.HistoryTurn) == 0 and
      player.room:getBanner("fhyx_extra_pile") then
      local ids = {}
      for _, move in ipairs(data) do
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.Void and player.room:getBanner("@$fhyx_extra_pile") and
            table.contains(player.room:getBanner("@$fhyx_extra_pile"), info.cardId) then
            table.insertIfNeed(ids, info.cardId)
          end
        end
      end
      return #table.filter(player.room:getBanner("@$fhyx_extra_pile"), function(id)
        return Fk:getCardById(id).type == Card.TypeBasic
      end) == #ids
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
