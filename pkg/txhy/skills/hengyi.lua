local hengyi = fk.CreateSkill {
  name = "ofl_tx__hengyi",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_tx__hengyi"] = "恒毅",
  [":ofl_tx__hengyi"] = "锁定技，当你或<a href='os__coop'>同心角色</a>受到伤害后或使用的【杀】被【闪】抵消后，"..
  "你获得一枚“毅”标记（至多7枚）。<br>"..
  "你出牌阶段使用【杀】次数+X（X为“毅”标记数）。<br>"..
  "一名角色回合结束时，若你的“毅”标记数为7，你移去所有“毅”标记，然后执行<a href='os__coop'>同心效果</a>：回复1点体力。<br>"..
  "你回合开始时可以选择至多两名角色为<a href='os__coop'>同心角色</a>。",

  ["#ofl_tx__hengyi-tongxin"] = "选择至多两名角色成为你的 “恒毅” 同心角色",
  ["@[list]ofl_tx__hengyi_tongxin"] = "恒毅同心",
  ["@ofl_tx__hengyi"] = "毅",
}

hengyi:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(hengyi.name) and
      (target == player or table.contains(player:getTableMark("@[list]ofl_tx__hengyi_tongxin"), target)) and
      player:getMark("@ofl_tx__hengyi") < 7
  end,
  on_use = function (self, event, target, player, data)
    player.room:addPlayerMark(player, "@ofl_tx__hengyi", 1)
  end,
})

hengyi:addEffect(fk.CardEffectCancelledOut, {
  anim_type = "special",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(hengyi.name) and data.card.trueName == "slash" and
      (target == player or table.contains(player:getTableMark("@[list]ofl_tx__hengyi_tongxin"), target)) and
      player:getMark("@ofl_tx__hengyi") < 7
  end,
  on_use = function (self, event, target, player, data)
    player.room:addPlayerMark(player, "@ofl_tx__hengyi", 1)
  end,
})

hengyi:addEffect("targetmod", {
  residue_func = function (self, player, skill, scope, card, to)
    if player:hasSkill(hengyi.name) and card and card.trueName == "slash" and
      scope == Player.HistoryPhase then
      return player:getMark("@ofl_tx__hengyi")
    end
  end,
})

hengyi:addEffect(fk.TurnEnd, {
  anim_type = "support",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(hengyi.name) and player:getMark("@ofl_tx__hengyi") == 7
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@ofl_tx__hengyi", 0)
    local tongxin = player:getTableMark("@[list]ofl_tx__hengyi_tongxin")
    for _, p in ipairs(room:getAlivePlayers()) do
      if (p == player or table.contains(tongxin, p)) and not p.dead then
        room:recover{
          who = p,
          num = 1,
          recoverBy = player,
          skillName = hengyi.name,
        }
      end
    end
  end,
})

hengyi:addEffect(fk.TurnStart, {
  anim_type = "support",
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(hengyi.name) and
      #player.room:getOtherPlayers(player, false) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local tos = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 2,
      targets = room:getOtherPlayers(player, false),
      prompt = "#ofl_tx__hengyi-tongxin",
      skill_name = hengyi.name,
    })
    if #tos > 0 then
      room:sortByAction(tos)
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local tos = event:getCostData(self).tos
    player.room:setPlayerMark(player, "@[list]ofl_tx__hengyi_tongxin", tos)
  end,

  can_refresh = function(self, event, target, player, data)
    return target == player
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@[list]ofl_tx__hengyi_tongxin", 0)
  end,
})

hengyi:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, "@ofl_tx__hengyi", 0)
end)

return hengyi
