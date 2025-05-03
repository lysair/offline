local zhongzuo = fk.CreateSkill {
  name = "sxfy__zhongzuo",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["sxfy__zhongzuo"] = "忠佐",
  [":sxfy__zhongzuo"] = "锁定技，一名角色回合结束时，若你本回合造成或受到过伤害，你与其各摸一张牌。",
}

zhongzuo:addEffect(fk.TurnEnd, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(zhongzuo.name) and
      #player.room.logic:getActualDamageEvents(1, function (e)
        return e.data.from == player or e.data.to == player
      end, Player.HistoryTurn) > 0
  end,
  on_cost = function (self, event, target, player, data)
    event:setCostData(self, {tos = {target.dead and nil or target}})
    return true
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, zhongzuo.name)
    if not target.dead then
      target:drawCards(1, zhongzuo.name)
    end
  end,
})

return zhongzuo
