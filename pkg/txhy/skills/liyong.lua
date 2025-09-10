local liyong = fk.CreateSkill {
  name = "ofl_tx__liyong",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_tx__liyong"] = "戾涌",
  [":ofl_tx__liyong"] = "锁定技，当你使用【杀】指定目标后，随机弃置X张牌，令此【杀】伤害+1（X为你本回合发动此技能次数）。"..
  "每回合限一次，若你因此弃置了所有手牌，此【杀】结算结束后你执行<a href='os__coop'>同心效果</a>：从游戏外获得一张【杀】和【酒】。",

  ["#ofl_tx__liyong-tongxin"] = "选择一名角色成为你的 “戾涌” 同心角色",
  ["@ofl_tx__liyong_tongxin"] = "戾涌同心",
}

liyong:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(liyong.name) and
      data.firstTarget and data.card.trueName == "slash"
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    data.additionalDamage = (data.additionalDamage or 0) + 1
    local n = player:usedEffectTimes(self.name, Player.HistoryTurn)
    local cards = table.filter(player:getCardIds("he"), function (id)
      return not player:prohibitDiscard(id)
    end)
    if #cards > 0 then
      cards = table.random(cards, n)
      if not player:isKongcheng() and
        table.every(player:getCardIds("h"), function (id)
          return table.contains(cards, id)
        end) then
        data.extra_data = data.extra_data or {}
        data.extra_data.ofl_tx__liyong = player
      end
      room:throwCard(cards, liyong.name, player, player)
    end
  end,
})

liyong:addEffect(fk.CardUseFinished, {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(liyong.name) and
      data.extra_data and data.extra_data.ofl_tx__liyong == player and
      player:usedEffectTimes(self.name, Player.HistoryTurn) == 0
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local tongxin = player:getMark("@ofl_tx__liyong_tongxin")
    local ids = {}
    for _, name in ipairs({"slash", "analeptic"}) do
      local cards = table.filter(room:getBanner(liyong.name), function (id)
        return room:getCardArea(id) == Card.Void and Fk:getCardById(id).name == name
      end)
      if #cards > 0 then
        table.insert(ids, table.random(cards))
      end
    end
    if #ids > 0 then
      for _, id in ipairs(ids) do
        room:setCardMark(Fk:getCardById(id), MarkEnum.DestructIntoDiscard, 1)
      end
      room:moveCardTo(ids, Card.PlayerHand, player, fk.ReasonJustMove, liyong.name, nil, true, player)
    else
      return
    end
    if tongxin ~= 0 and not tongxin.dead then
      ids = {}
      for _, name in ipairs({"slash", "analeptic"}) do
        local cards = table.filter(room:getBanner(liyong.name), function (id)
          return room:getCardArea(id) == Card.Void and Fk:getCardById(id).name == name
        end)
        if #cards > 0 then
          table.insert(ids, table.random(cards))
        end
      end
      if #ids > 0 then
        for _, id in ipairs(ids) do
          room:setCardMark(Fk:getCardById(id), MarkEnum.DestructIntoDiscard, 1)
        end
        room:moveCardTo(ids, Card.PlayerHand, tongxin, fk.ReasonJustMove, liyong.name, nil, true, tongxin)
      end
    end
  end,
})

liyong:addEffect(fk.TurnStart, {
  anim_type = "support",
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(liyong.name) and
      #player.room:getOtherPlayers(player, false) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room:getOtherPlayers(player, false),
      prompt = "#ofl_tx__liyong-tongxin",
      skill_name = liyong.name,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local to = event:getCostData(self).tos[1]
    player.room:setPlayerMark(player, "@ofl_tx__liyong_tongxin", to)
  end,

  can_refresh = function(self, event, target, player, data)
    return target == player
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@ofl_tx__liyong_tongxin", 0)
  end,
})

liyong:addAcquireEffect(function (self, player, is_start)
  local room = player.room
  local banner = room:getBanner(liyong.name) or {}
  for _, info in ipairs({
    {"slash", Card.Spade, 9},
    {"slash", Card.Spade, 9},
    {"analeptic", Card.Club, 9},
    {"analeptic", Card.Club, 9},
  }) do
    local id = room:printCard(info[1], info[2], info[3]).id
    table.insert(banner, id)
  end
  room:setBanner(liyong.name, banner)
end)

return liyong
