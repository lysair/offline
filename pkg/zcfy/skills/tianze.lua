local tianze = fk.CreateSkill {
  name = "sxfy__tianze",
}

Fk:loadTranslationTable{
  ["sxfy__tianze"] = "天则",
  [":sxfy__tianze"] = "一名角色的结束阶段，若其本回合使用过黑色牌，你可以展示所有手牌，弃置所有的黑色牌（至少一张），然后对其造成1点伤害。",

  ["#sxfy__tianze-invoke"] = "天则：你可以展示手牌并弃置所有黑色牌，对 %dest 造成1点伤害",
}

tianze:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(tianze.name) and target.phase == Player.Finish and
      not target.dead and not player:isKongcheng() and
      #player.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
        return e.data.from == target
      end, Player.HistoryTurn) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = tianze.name,
      prompt = "#sxfy__tianze-invoke::"..target.id,
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:showCards(player:getCardIds("h"))
    if player.dead then return end
    local cards = table.filter(player:getCardIds("he"), function (id)
      return Fk:getCardById(id).color == Card.Black and not player:prohibitDiscard(id)
    end)
    if #cards == 0 then return end
    room:throwCard(cards, tianze.name, player, player)
    if target.dead then return end
    room:damage{
      from = player,
      to = target,
      damage = 1,
      skillName = tianze.name,
    }
  end,
})

return tianze
