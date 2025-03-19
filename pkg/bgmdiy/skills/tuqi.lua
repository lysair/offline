local tuqi = fk.CreateSkill {
  name = "tuqi"
}

Fk:loadTranslationTable{
  ['tuqi'] = '突骑',
  ['bgm_follower'] = '扈',
  [':tuqi'] = '锁定技，准备阶段开始时，若你的武将牌上有“扈”，你将所有“扈”置入弃牌堆，本回合你与其他角色的距离-X，若X小于或等于2，你摸一张牌。（X为以此法置入弃牌堆的“扈”的数量）',
}

tuqi:addEffect(fk.EventPhaseStart, {
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(tuqi.name) and target == player and player.phase == Player.Start and #player:getPile("bgm_follower") > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = player:getPile("bgm_follower")
    room:moveCards({
      ids = cards,
      from = player.id,
      toArea = Card.DiscardPile,
      moveReason = fk.ReasonPutIntoDiscardPile,
      skillName = tuqi.name,
      proposer = player.id,
    })
    room:addPlayerMark(player, "tuqi-turn", #cards)
    if not player.dead and #cards <= 2 then
      player:drawCards(1, tuqi.name)
    end
  end,
})

tuqi:addEffect('distance', {
  name = "#bgm__tuqi_distance",
  correct_func = function(self, from, to)
    return - from:getMark("tuqi-turn")
  end,
})

return tuqi
