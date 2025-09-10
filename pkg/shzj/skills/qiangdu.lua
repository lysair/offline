local qiangdu = fk.CreateSkill {
  name = "qiangdu",
}

Fk:loadTranslationTable{
  ["qiangdu"] = "羌督",
  [":qiangdu"] = "其他角色的出牌阶段开始时，你可以摸一张牌并交给其一张牌，然后当其本回合首次使用仅指定唯一目标的【杀】或普通锦囊牌结算结束后，"..
  "你可以视为使用此牌（无距离限制），若你指定的目标与其指定的目标不完全相同，你失去1点体力。",

  ["#qiangdu-invoke"] = "羌督：你可以摸一张牌并交给 %dest 一张牌",
  ["#qiangdu-give"] = "羌督：请交给 %dest 一张牌",
  ["@@qiangdu-turn"] = "羌督",
  ["#qiangdu-use"] = "羌督：你可以视为使用【%arg】，若与 %dest 指定的目标不同，你失去1点体力",
}

qiangdu:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(qiangdu.name) and target.phase == Player.Play and
      not target.dead
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = qiangdu.name,
      prompt = "#qiangdu-invoke::"..target.id,
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(1, qiangdu.name)
    if player:isNude() or target.dead then return end
    local cards = room:askToCards(player, {
      skill_name = qiangdu.name,
      include_equip = true,
      min_num = 1,
      max_num = 1,
      prompt = "#qiangdu-give::"..target.id,
      cancelable = false,
    })
    room:moveCardTo(cards, Player.Hand, target, fk.ReasonGive, qiangdu.name, nil, false, player)
    if player.dead or target.dead or player:usedSkillTimes(qiangdu.name, Player.HistoryTurn) > 1 then return end
    room:setPlayerMark(player, "@@qiangdu-turn", target.id)
  end,
})

qiangdu:addEffect(fk.CardUseFinished, {
  anim_type = "control",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return player:getMark("@@qiangdu-turn") == target.id and
      (data.card.trueName == "slash" or data.card:isCommonTrick()) and
      #data.tos > 0 and data:isOnlyTarget(data.tos[1])
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@@qiangdu-turn", 0)
    local use = room:askToUseVirtualCard(player, {
      name = data.card.name,
      skill_name = qiangdu.name,
      prompt = "#qiangdu-use::"..target.id..":"..data.card.name,
      cancelable = true,
      extra_data = {
        bypass_distances = true,
        bypass_times = true,
        extraUse = true,
      },
    })
    if use and not player.dead and (#use.tos ~= 1 or data.tos[1] ~= use.tos[1]) then
      room:loseHp(player, 1, qiangdu.name)
    end
  end,
})

return qiangdu
