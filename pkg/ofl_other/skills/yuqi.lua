local yuqi = fk.CreateSkill {
  name = "ofl__yuqi"
}

Fk:loadTranslationTable{
  ['ofl__yuqi'] = '隅泣',
  ['ofl__yuqi1'] = '距离',
  ['ofl__yuqi2'] = '观看牌数',
  ['ofl__yuqi3'] = '交给受伤角色牌数',
  ['ofl__yuqi4'] = '自己获得牌数',
  ['#ofl__yuqi'] = '隅泣：请分配卡牌，余下的牌置于牌堆顶',
  [':ofl__yuqi'] = '每回合限两次，当一名角色受到伤害后，若你与其距离0或者更少，你可以观看牌堆顶的3张牌，将其中至多1张交给受伤角色，至多1张自己获得，剩余的牌放回牌堆顶。',
  ['$ofl__yuqi1'] = '玉儿摔倒了，要阿娘抱抱。',
  ['$ofl__yuqi2'] = '这么漂亮的雪花，为什么只能在寒冬呢？',
}

yuqi:addEffect(fk.Damaged, {
  can_trigger = function(self, event, target, player)
    return player:hasSkill(yuqi.name) and not target.dead and player:usedSkillTimes(yuqi.name) < 2 and
      (target == player or player:distanceTo(target) <= player:getMark("ofl__yuqi1"))
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    local n1, n2, n3 = player:getMark("ofl__yuqi2"), player:getMark("ofl__yuqi3"), player:getMark("ofl__yuqi4")
    if n1 < 2 and n2 < 1 and n3 < 1 then
      return false
    end
    local cards = room:getNCards(n1)
    local result = room:askToArrangeCards(player, {
      card_map = {cards, "Top", target.general, player.general},
      prompt = "#ofl__yuqi",
      box_size = 0,
      max_limit = {n1, n2, n3},
      min_limit = {0, 1, 1}
    })
    local top, bottom = result[2], result[3]
    local moveInfos = {}
    if #top > 0 then
      table.insert(moveInfos, {
        ids = top,
        to = target.id,
        toArea = Card.PlayerHand,
        moveReason = fk.ReasonGive,
        proposer = player.id,
        skillName = yuqi.name,
        visiblePlayers = {player.id},
      })
      for _, id in ipairs(top) do
        table.removeOne(cards, id)
      end
    end
    if #bottom > 0 then
      table.insert(moveInfos, {
        ids = bottom,
        to = player.id,
        toArea = Card.PlayerHand,
        moveReason = fk.ReasonJustMove,
        proposer = player.id,
        skillName = yuqi.name,
      })
      for _, id in ipairs(bottom) do
        table.removeOne(cards, id)
      end
    end
    room:moveCards(table.unpack(moveInfos))
  end,
})

yuqi:addEffect('on_acquire', {
  on_acquire = function(self, player, is_start)
    local room = player.room
    room:setPlayerMark(player, "ofl__yuqi1", 0)
    room:setPlayerMark(player, "ofl__yuqi2", 3)
    room:setPlayerMark(player, "ofl__yuqi3", 1)
    room:setPlayerMark(player, "ofl__yuqi4", 1)
    room:setPlayerMark(player, "@" .. yuqi.name, string.format("%d-%d-%d-%d", 0, 3, 1, 1))
  end,
})

yuqi:addEffect('on_lose', {
  on_lose = function(self, player, is_death)
    local room = player.room
    room:setPlayerMark(player, "ofl__yuqi1", 0)
    room:setPlayerMark(player, "ofl__yuqi2", 0)
    room:setPlayerMark(player, "ofl__yuqi3", 0)
    room:setPlayerMark(player, "ofl__yuqi4", 0)
    room:setPlayerMark(player, "@" .. yuqi.name, 0)
  end,
})

return yuqi
