
local hemou = fk.CreateSkill{
  name = "ofl_tx__hemou",
}

Fk:loadTranslationTable{
  ["ofl_tx__hemou"] = "合谋",
  [":ofl_tx__hemou"] = "每回合限一次，当你使用普通锦囊牌指定唯一目标后，你可以执行<a href='os__coop'>同心效果</a>：摸一张牌；"..
  "若此牌生效，你在此牌结算结束后再执行一次<a href='os__coop'>同心效果</a>。",

  ["#ofl_tx__hemou-tongxin"] = "选择一名角色成为你的 “合谋” 同心角色",
  ["@ofl_tx__hemou_tongxin"] = "合谋同心",
  ["#ofl_tx__hemou-choice"] = "合谋：你需选择一个技能失效直到你受到伤害或回合结束",
}

hemou:addEffect(fk.TargetSpecified, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(hemou.name) and
      player:usedEffectTimes(self.name, Player.HistoryTurn) == 0 and
      data.card:isCommonTrick() and data:isOnlyTarget(data.to)
  end,
  on_use = function(self, event, target, player, data)
    local tongxin = player:getMark("@ofl_tx__hemou_tongxin")
    player:drawCards(1, hemou.name)
    if tongxin ~= 0 and not tongxin.dead then
      tongxin:drawCards(1, hemou.name)
    end
    data.extra_data = data.extra_data or {}
    data.extra_data.ofl_tx__hemou = player
  end,
})

hemou:addEffect(fk.CardEffectFinished, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return data.extra_data and data.extra_data.ofl_tx__hemou == player and not player.dead and data.to and
      not data.isCancellOut and not data.nullified and not table.contains(data.use.nullifiedTargets or {}, data.to)
  end,
  on_use = function(self, event, target, player, data)
    local tongxin = player:getMark("@ofl_tx__hemou_tongxin")
    player:drawCards(1, hemou.name)
    if tongxin and not tongxin.dead then
      tongxin:drawCards(1, hemou.name)
    end
  end,
})

hemou:addEffect(fk.TurnStart, {
  anim_type = "support",
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(hemou.name) and
      #player.room:getOtherPlayers(player, false) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room:getOtherPlayers(player, false),
      prompt = "#ofl_tx__hemou-tongxin",
      skill_name = hemou.name,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local to = event:getCostData(self).tos[1]
    player.room:setPlayerMark(player, "@ofl_tx__hemou_tongxin", to)
  end,

  can_refresh = function(self, event, target, player, data)
    return target == player
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@ofl_tx__hemou_tongxin", 0)
  end,
})

return hemou
