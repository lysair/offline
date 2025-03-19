local ofl_shiji__jvyi = fk.CreateSkill {
  name = "ofl_shiji__jvyi$"
}

Fk:loadTranslationTable{
  ['#ofl_shiji__jvyi-put'] = '据益：你可以将一张手牌置入仁区，若因此溢出（仁区超过6张牌会溢出），%src 获得溢出的牌',
}

ofl_shiji__jvyi:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player)
    return player:hasSkill(skill.name) and target.phase == Player.Discard and
      target ~= player and target.kingdom == "qun" and not target.dead and not target:isKongcheng()
  end,
  on_cost = function (skill, event, target, player)
    local card = player.room:askToCards(target, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = skill.name,
      cancelable = true,
      prompt = "#ofl_shiji__jvyi-put:"..player.id
    })
    if #card > 0 then
      event:setCostData(skill, {tos = {player.id}, cards = card})
      return true
    end
  end,
  on_use = function (skill, event, target, player)
    U.AddToRenPile(player.room, event:getCostData(skill).cards, skill.name, target.id)
  end,
})

ofl_shiji__jvyi:addEffect(fk.AfterCardsMove, {
  can_refresh = function (skill, event, target, player)
    if player:usedSkillTimes(skill.name, Player.HistoryPhase) > 0 and not player.dead then
      local e = player.room.logic:getCurrentEvent():findParent(GameEvent.SkillEffect)
      if e and e.data[3] == skill then
        return true
      end
    end
  end,
  on_refresh = function (skill, event, target, player, data)
    for _, move in ipairs(data) do
      if move.toArea == Card.DiscardPile and move.skillName == "ren_overflow" then
        for _, info in ipairs(move.moveInfo) do
          if table.contains(player.room.discard_pile, info.cardId) then
            player.room:moveCardTo(info.cardId, Card.PlayerHand, player, fk.ReasonJustMove, skill.name, nil, true, player.id)
          end
        end
      end
    end
  end,
})

return ofl_shiji__jvyi
