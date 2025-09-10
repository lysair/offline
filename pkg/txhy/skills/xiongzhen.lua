local xiongzhen = fk.CreateSkill({
  name = "ofl_tx__xiongzhen",
})

Fk:loadTranslationTable{
  ["ofl_tx__xiongzhen"] = "凶振",
  [":ofl_tx__xiongzhen"] = "出牌阶段限一次，你可以弃置一张牌，消耗任意点<a href='os__baonue_href'>暴虐值</a>，选择等量名角色，"..
  "直到这些角色各自的下个结束阶段开始，其使用【杀】伤害基数值+1，若其拥有〖凶军〗则额外+1。",

  ["#ofl_tx__xiongzhen"] = "凶振：弃置一张牌，消耗任意点暴虐值，令等量角色使用【杀】伤害增加",
  ["@ofl_tx__xiongzhen"] = "凶振",
}

xiongzhen.os__baonue = true

xiongzhen:addEffect("active", {
  anim_type = "offensive",
  prompt = "#ofl_tx__xiongzhen",
  card_num = 1,
  min_target_num = 1,
  max_target_num = function (self, player)
    return player:getMark("@os__baonue")
  end,
  can_use = function (self, player)
    return player:usedSkillTimes(xiongzhen.name, Player.HistoryPhase) == 0 and player:getMark("@os__baonue") > 0
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and not player:prohibitDiscard(to_select)
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected < player:getMark("@os__baonue")
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local targets = effect.tos
    room:sortByAction(targets)
    room:removePlayerMark(player, "@os__baonue", #targets)
    room:throwCard(effect.cards, xiongzhen.name, player, player)
    for _, p in ipairs(targets) do
      if not p.dead then
        room:addPlayerMark(p, "@ofl_tx__xiongzhen", 1)
      end
    end
  end,
})

xiongzhen:addEffect(fk.PreCardUse, {
  can_refresh = function (self, event, target, player, data)
    return target == player and data.card.trueName == "slash" and player:getMark("@ofl_tx__xiongzhen") > 0
  end,
  on_refresh = function (self, event, target, player, data)
    local n = player:getMark("@ofl_tx__xiongzhen")
    if player:hasSkill("ofl_tx__xiongjun", true) then
      n = n * 2
    end
    data.additionalDamage = (data.additionalDamage or 0) + n
  end,
})

xiongzhen:addEffect(fk.EventPhaseStart, {
  can_refresh = function (self, event, target, player, data)
    return target == player and player.phase == Player.Finish
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:setPlayerMark(player, "@ofl_tx__xiongzhen", 0)
  end,
})

xiongzhen:addAcquireEffect(function(self, player)
  player.room:addSkill("#os__baonue_mark")
end)

return xiongzhen
