local tuqi = fk.CreateSkill {
  name = "tuqi",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["tuqi"] = "突骑",
  [":tuqi"] = "锁定技，准备阶段，你将所有“扈”置入弃牌堆，本回合你与其他角色的距离-X，若X不大于2，你摸一张牌。（X为以此法置入弃牌堆的“扈”的数量）",
}

tuqi:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(tuqi.name) and player.phase == Player.Start and
      #player:getPile("bgm_follower") > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = player:getPile("bgm_follower")
    room:moveCards({
      ids = cards,
      from = player,
      toArea = Card.DiscardPile,
      moveReason = fk.ReasonPutIntoDiscardPile,
      skillName = tuqi.name,
      proposer = player,
    })
    if player.dead then return end
    room:addPlayerMark(player, "tuqi-turn", #cards)
    if #cards <= 2 then
      player:drawCards(1, tuqi.name)
    end
  end,
})

tuqi:addEffect("distance", {
  correct_func = function(self, from, to)
    return -from:getMark("tuqi-turn")
  end,
})

return tuqi
