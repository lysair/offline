local xingsha = fk.CreateSkill {
  name = "xingsha",
}

Fk:loadTranslationTable{
  ["xingsha"] = "刑杀",
  [":xingsha"] = "出牌阶段限一次，你可以将至多两张牌置于你的武将牌上，称为“怨”。结束阶段，你可以将两张“怨”当一张无距离限制的【杀】使用。",

  ["#xingsha"] = "刑杀：将至多两张牌置为“怨”",
  ["#xingsha-slash"] = "刑杀：你可以将两张“怨”当一张无距离限制的【杀】使用",
}

xingsha:addEffect("active", {
  anim_type = "offensive",
  prompt = "#xingsha",
  min_card_num = 1,
  max_card_num = 2,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(xingsha.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected < 2
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    player:addToPile("$fanjiangzhangda_yuan", effect.cards, false, xingsha.name, player)
  end,
})

xingsha:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xingsha.name) and player.phase == Player.Finish and
      #player:getPile("$fanjiangzhangda_yuan") > 1 and
      player:canUse(Fk:cloneCard("slash"), {bypass_distances = true, bypass_times = true})
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local use = room:askToUseVirtualCard(player, {
      name = "slash",
      skill_name = xingsha.name,
      prompt = "#xingsha-slash",
      cancelable = true,
      extra_data = {
        bypass_distances = true,
        bypass_times = true,
        extraUse = true,
      },
      card_filter = {
        n = 2,
        cards = player:getPile("$fanjiangzhangda_yuan"),
      },
      skip = true,
    })
    if use then
      event:setCostData(self, {extra_data = use})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:useCard(event:getCostData(self).extra_data)
  end,
})

return xingsha
