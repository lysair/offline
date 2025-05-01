local bianzhua = fk.CreateSkill {
  name = "bianzhua",
}

Fk:loadTranslationTable{
  ["bianzhua"] = "鞭挝",
  [":bianzhua"] = "每回合限一次，当你成为伤害类牌的目标后，你可以将之置于你的武将牌上，称为“怨”。结束阶段，你可以依次使用“怨”。",

  ["$fanjiangzhangda_yuan"] = "怨",
  ["#bianzhua-invoke"] = "鞭挝：是否将%arg置为“怨”？",
  ["#bianzhua-use"] = "鞭挝：你可以使用“怨”",
}

bianzhua:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(bianzhua.name) and player.phase == Player.Finish and
      #player:getPile("$fanjiangzhangda_yuan") > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local use = room:askToUseRealCard(player, {
      pattern = player:getPile("$fanjiangzhangda_yuan"),
      skill_name = bianzhua.name,
      prompt = "#bianzhua-use",
      extra_data = {
        bypass_times = true,
        expand_pile = player:getPile("$fanjiangzhangda_yuan"),
        extraUse = true,
      },
      cancelable = true,
      skip = true,
    })
    if use then
      event:setCostData(self, {extra_data = use})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:useCard(event:getCostData(self).extra_data)
    while not player.dead and #player:getPile("$fanjiangzhangda_yuan") > 0 do
      local use = room:askToUseRealCard(player, {
        pattern = player:getPile("$fanjiangzhangda_yuan"),
        skill_name = bianzhua.name,
        prompt = "#bianzhua-use",
        extra_data = {
          bypass_times = true,
          expand_pile = player:getPile("$fanjiangzhangda_yuan"),
          extraUse = true,
        },
        cancelable = true,
        skip = true,
      })
      if use then
        room:useCard(use)
      else
        return
      end
    end
  end,
})

bianzhua:addEffect(fk.TargetConfirmed, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(bianzhua.name) and
      data.card.is_damage_card and player.room:getCardArea(data.card) == Card.Processing and
      player:usedEffectTimes(self.name, Player.HistoryTurn) == 0
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = bianzhua.name,
      prompt = "#bianzhua-invoke:::"..data.card:toLogString(),
    })
  end,
  on_use = function (self, event, target, player, data)
    player:addToPile("$fanjiangzhangda_yuan", data.card, true, bianzhua.name, player)
  end,
})

return bianzhua
