local kuangli = fk.CreateSkill {
  name = "qshm__kuangli",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["qshm__kuangli"] = "狂戾",
  [":qshm__kuangli"] = "锁定技，出牌阶段开始时，所有其他角色依次进行判定；每阶段限两次，当你于出牌阶段内使用牌指定一名"..
  "以此法判定点数为最大或最小的角色为目标后，你弃置你与其各一张牌，然后你摸两张牌。",

  ["@@qshm__kuangli-turn"] = "狂戾",
}

kuangli:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(kuangli.name) and player.phase == Player.Play and
      #player.room:getOtherPlayers(player, false) > 0
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:doIndicate(player, room:getOtherPlayers(player, false))
    local mapper = {}
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if not p.dead then
        local judge = {
          who = p,
          reason = kuangli.name,
          pattern = ".",
        }
        room:judge(judge)
        mapper[p] = judge.card.number
      end
    end
    if not player.dead then
      local max, min = 0, 14
      for _, num in pairs(mapper) do
        if num > max then
          max = num
        end
        if num < min then
          min = num
        end
      end
      for _, p in ipairs(room:getOtherPlayers(player, false)) do
        if mapper[p] == max or mapper[p] == min then
          room:setPlayerMark(p, "@@qshm__kuangli-turn", 1)
        end
      end
    end
  end,
})

kuangli:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(kuangli.name) and player.phase == Player.Play and
      not data.to.dead and data.to:getMark("@@qshm__kuangli-turn") > 0 and
      player:usedEffectTimes(self.name, Player.HistoryPhase) < 2
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = kuangli.name,
      cancelable = false,
    })
    if player.dead then return end
    if not data.to:isNude() and not data.to.dead then
      local card = room:askToChooseCard(player, {
        target = data.to,
        flag = "he",
        skill_name = kuangli.name,
      })
      room:throwCard(card, kuangli.name, data.to, player)
    end
    if not player.dead then
      player:drawCards(2, kuangli.name)
    end
  end,
})

return kuangli
