local jianwei = fk.CreateSkill {
  name = "ofl__jianwei",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable{
  ["ofl__jianwei"] = "僭位",
  [":ofl__jianwei"] = "限定技，回合开始时，你可以失去1点体力，然后与一名其他角色交换区域内所有牌。",

  ["#ofl__jianwei-choose"] = "僭位：你可以失去1点体力，与一名其他角色交换区域内所有牌！",
}

jianwei:addEffect(fk.TurnStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jianwei.name) and
      player:usedSkillTimes(jianwei.name, Player.HistoryGame) == 0 and
      #player.room:getOtherPlayers(player, false) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room:getOtherPlayers(player, false),
      skill_name = jianwei.name,
      prompt = "#ofl__jianwei-choose",
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    room:loseHp(player, 1, jianwei.name)
    if player.dead or to.dead or (player:isAllNude() and to:isAllNude()) then return end
    local cards1 = {
      h = table.simpleClone(player:getCardIds("h")),
      e = table.simpleClone(player:getCardIds("e")),
      j = table.simpleClone(player:getCardIds("j")),
    }
    local cards2 = {
      h = table.simpleClone(to:getCardIds("h")),
      e = table.simpleClone(to:getCardIds("e")),
      j = table.simpleClone(to:getCardIds("j")),
    }
    local moveInfos = {}
    for _, key in ipairs({"h", "e", "j"}) do
      if #cards1[key] > 0 then
        table.insert(moveInfos, {
          from = player,
          ids = cards1[key],
          toArea = Card.Processing,
          moveReason = fk.ReasonExchange,
          proposer = player,
          skillName = jianwei.name,
          moveVisible = false,
        })
      end
      if #cards2[key] > 0 then
        table.insert(moveInfos, {
          from = to,
          ids = cards2[key],
          toArea = Card.Processing,
          moveReason = fk.ReasonExchange,
          proposer = player,
          skillName = jianwei.name,
          moveVisible = false,
        })
      end
    end
    if #moveInfos > 0 then
      room:moveCards(table.unpack(moveInfos))
    end
    moveInfos = {}
    if not to.dead then
      local h = table.filter(cards1.h, function (id)
        return room:getCardArea(id) == Card.Processing
      end)
      if #h > 0 then
        table.insert(moveInfos, {
          ids = h,
          fromArea = Card.Processing,
          to = to,
          toArea = Card.PlayerHand,
          moveReason = fk.ReasonExchange,
          proposer = player,
          skillName = jianwei.name,
          moveVisible = false,
          visiblePlayers = to,
        })
      end
      local e = table.filter(cards1.e, function (id)
        return room:getCardArea(id) == Card.Processing and #to:getAvailableEquipSlots(Fk:getCardById(id).sub_type) > 0
      end)
      if #e > 0 then
        table.insert(moveInfos, {
          ids = e,
          fromArea = Card.Processing,
          to = to,
          toArea = Card.PlayerEquip,
          moveReason = fk.ReasonExchange,
          proposer = player,
          skillName = jianwei.name,
          moveVisible = true,
          visiblePlayers = to,
        })
      end
      local j = table.filter(cards1.j, function (id)
        return room:getCardArea(id) == Card.Processing and not table.contains(to.sealedSlots, Player.JudgeSlot)
      end)
      if #j > 0 then
        table.insert(moveInfos, {
          ids = j,
          fromArea = Card.Processing,
          to = to,
          toArea = Card.PlayerJudge,
          moveReason = fk.ReasonExchange,
          proposer = player,
          skillName = jianwei.name,
          moveVisible = true,
          visiblePlayers = to,
        })
      end
    end
    if not player.dead then
      local h = table.filter(cards2.h, function (id)
        return room:getCardArea(id) == Card.Processing
      end)
      if #h > 0 then
        table.insert(moveInfos, {
          ids = h,
          fromArea = Card.Processing,
          to = player,
          toArea = Card.PlayerHand,
          moveReason = fk.ReasonExchange,
          proposer = player,
          skillName = jianwei.name,
          moveVisible = false,
          visiblePlayers = to,
        })
      end
      local e = table.filter(cards2.e, function (id)
        return room:getCardArea(id) == Card.Processing and #player:getAvailableEquipSlots(Fk:getCardById(id).sub_type) > 0
      end)
      if #e > 0 then
        table.insert(moveInfos, {
          ids = e,
          fromArea = Card.Processing,
          to = player,
          toArea = Card.PlayerEquip,
          moveReason = fk.ReasonExchange,
          proposer = player,
          skillName = jianwei.name,
          moveVisible = true,
          visiblePlayers = player,
        })
      end
      local j = table.filter(cards2.j, function (id)
        return room:getCardArea(id) == Card.Processing and not table.contains(player.sealedSlots, Player.JudgeSlot)
      end)
      if #j > 0 then
        table.insert(moveInfos, {
          ids = j,
          fromArea = Card.Processing,
          to = player,
          toArea = Card.PlayerJudge,
          moveReason = fk.ReasonExchange,
          proposer = player,
          skillName = jianwei.name,
          moveVisible = true,
          visiblePlayers = player,
        })
      end
    end
    if #moveInfos > 0 then
      room:moveCards(table.unpack(moveInfos))
    end
    room:cleanProcessingArea(table.connect(cards1, cards2))
  end,
})

return jianwei
