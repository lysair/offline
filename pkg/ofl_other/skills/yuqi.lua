local yuqi = fk.CreateSkill {
  name = "ofl__yuqi",
  dynamic_desc = function(self, player)
    return "ofl__yuqi_inner:"..player:getMark("ofl__yuqi1")..
      ":"..(player:getMark("ofl__yuqi2") + 3)..
      ":"..(player:getMark("ofl__yuqi3") + 1)..
      ":"..(player:getMark("ofl__yuqi4") + 1)
  end,
}

Fk:loadTranslationTable{
  ["ofl__yuqi"] = "隅泣",
  [":ofl__yuqi"] = "每回合限两次，当一名角色受到伤害后，若你与其距离0或者更少，你可以观看牌堆顶的3张牌，将其中至多1张交给受伤角色，"..
  "至多1张自己获得，剩余的牌放回牌堆顶。",

  [":ofl__yuqi_inner"] = "每回合限两次，当一名角色受到伤害后，若你与其距离{1}或者更少，你可以观看牌堆顶的{2}张牌，将其中至多{3}张交给受伤角色，"..
  "至多{4}张自己获得，剩余的牌放回牌堆顶。",

  ["ofl__yuqi1"] = "距离",
  ["ofl__yuqi2"] = "观看牌数",
  ["ofl__yuqi3"] = "交给受伤角色牌数",
  ["ofl__yuqi4"] = "自己获得牌数",
  ["#ofl__yuqi"] = "隅泣：请分配卡牌，余下的牌置于牌堆顶",

  ["$ofl__yuqi1"] = "玉儿摔倒了，要阿娘抱抱。",
  ["$ofl__yuqi2"] = "这么漂亮的雪花，为什么只能在寒冬呢？",
}

yuqi:addEffect(fk.Damaged, {
  anim_type = "masochism",
  times = function(self, player)
    return 2 - player:usedSkillTimes(yuqi.name, Player.HistoryTurn)
  end,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(yuqi.name) and not target.dead and
      player:usedSkillTimes(yuqi.name, Player.HistoryTurn) < 2 and
      player:distanceTo(target) <= player:getMark("ofl__yuqi1")
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = yuqi.name,
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n1, n2, n3 = player:getMark("ofl__yuqi2") + 3, player:getMark("ofl__yuqi3") + 1, player:getMark("ofl__yuqi4") + 1
    if n1 < 2 and n2 < 1 and n3 < 1 then return end
    local cards = room:getNCards(n1)
    room:turnOverCardsFromDrawPile(player, cards, yuqi.name, false)
    local result = room:askToArrangeCards(player, {
      skill_name = yuqi.name,
      card_map = {
        cards,
        "Top", target.general, player.general
      },
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
        to = target,
        toArea = Card.PlayerHand,
        moveReason = fk.ReasonGive,
        proposer = player,
        skillName = yuqi.name,
        moveVisible = false,
        visiblePlayers = player,
      })
    end
    if #bottom > 0 then
      table.insert(moveInfos, {
        ids = bottom,
        to = player,
        toArea = Card.PlayerHand,
        moveReason = fk.ReasonJustMove,
        proposer = player,
        moveVisible = false,
        skillName = yuqi.name,
      })
    end
    room:moveCards(table.unpack(moveInfos))
    room:returnCardsToDrawPile(player, cards, yuqi.name)
  end,
})

yuqi:addAcquireEffect(function (self, player, is_start)
  local room = player.room
  room:setPlayerMark(player, "ofl__yuqi1", 0)
  room:setPlayerMark(player, "ofl__yuqi2", 0)
  room:setPlayerMark(player, "ofl__yuqi3", 0)
  room:setPlayerMark(player, "ofl__yuqi4", 0)
end)

yuqi:addLoseEffect(function (self, player, is_death)
  local room = player.room
  room:setPlayerMark(player, "ofl__yuqi1", 0)
  room:setPlayerMark(player, "ofl__yuqi2", 0)
  room:setPlayerMark(player, "ofl__yuqi3", 0)
  room:setPlayerMark(player, "ofl__yuqi4", 0)
end)

return yuqi
