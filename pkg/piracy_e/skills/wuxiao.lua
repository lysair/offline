local wuxiao = fk.CreateSkill {
  name = "ofl__wuxiao",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl__wuxiao"] = "武嚣",
  [":ofl__wuxiao"] = "锁定技，当每回合首次有红色牌进入弃牌堆后，你本回合下次造成或受到的伤害+1。",

  ["@@ofl__wuxiao-turn"] = "造成/受到伤害+1",
}

wuxiao:addEffect(fk.AfterCardsMove, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(wuxiao.name) and player:usedSkillTimes(wuxiao.name, Player.HistoryTurn) == 0 then
      local turn_event = player.room.logic:getCurrentEvent():findParent(GameEvent.Turn)
      if not turn_event then return end
      for _, move in ipairs(data) do
        if move.toArea == Card.DiscardPile then
          for _, info in ipairs(move.moveInfo) do
            if Fk:getCardById(info.cardId).color == Card.Red then
              return true
            end
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "@@ofl__wuxiao-turn", 1)
  end,
})

wuxiao:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and player:getMark("@@ofl__wuxiao-turn") > 0
  end,
  on_use = function (self, event, target, player, data)
    data:changeDamage(player:getMark("@@ofl__wuxiao-turn"))
    player.room:setPlayerMark(player, "@@ofl__wuxiao-turn", 0)
  end,
})

wuxiao:addEffect(fk.DamageInflicted, {
  anim_type = "negative",
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and player:getMark("@@ofl__wuxiao-turn") > 0
  end,
  on_use = function (self, event, target, player, data)
    data:changeDamage(player:getMark("@@ofl__wuxiao-turn"))
    player.room:setPlayerMark(player, "@@ofl__wuxiao-turn", 0)
  end,
})

return wuxiao
