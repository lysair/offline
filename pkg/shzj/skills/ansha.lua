local ansha = fk.CreateSkill {
  name = "ansha",
}

Fk:loadTranslationTable{
  ["ansha"] = "暗杀",
  [":ansha"] = "其他角色回合开始时，你可以将一张牌当刺【杀】对其使用，此牌结算后，其计算与你距离视为1直到本轮结束。",

  ["#ansha-invoke"] = "暗杀：你可以将一张牌当刺【杀】对 %dest 使用，本轮其计算与你距离距离视为1",
}

ansha:addEffect(fk.TurnStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(ansha.name) and target ~= player and
      not target.dead and (#player:getHandlyIds() > 0 or #player:getCardIds("e") > 0)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local use = room:askToUseVirtualCard(player, {
      name = "stab__slash",
      skill_name = ansha.name,
      prompt = "#ansha-invoke:"..target.id,
      cancelable = true,
      extra_data = {
        bypass_distances = true,
        bypass_times = true,
        extraUse = true,
        exclusive_targets = {target.id},
      },
      card_filter = {
        n = 1,
      },
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
    if target.dead or player.dead then return end
    room:addTableMark(player, "ansha-round", target.id)
  end,
})

ansha:addEffect("distance", {
  fixed_func = function(self, from, to)
    if table.contains(to:getTableMark("ansha-round"), from.id) then
      return 1
    end
  end,
})

return ansha
