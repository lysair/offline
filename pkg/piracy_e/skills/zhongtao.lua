local zhongtao = fk.CreateSkill {
  name = "zhongtao",
}

Fk:loadTranslationTable{
  ["zhongtao"] = "众讨",
  [":zhongtao"] = "与你距离1以内的角色使用【杀】结算结束后，你可以将一张牌当【杀】对相同的目标角色使用。",

  ["#zhongtao-use"] = "众讨：你可以将一张牌当【杀】对目标使用",
}

zhongtao:addEffect(fk.CardUseFinished, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(zhongtao.name) and data.card.trueName == "slash" and
      target:distanceTo(player) <= 1 and
      table.find(data.tos, function (p)
        return not p.dead and player:canUseTo(Fk:cloneCard("slash"), p, { bypass_times = true })
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(data.tos, function (p)
        return not p.dead
      end)
    local use = room:askToUseVirtualCard(player, {
      name = "slash",
      skill_name = zhongtao.name,
      prompt = "#zhongtao-use:"..player.id,
      cancelable = true,
      extra_data = {
        bypass_times = true,
        extraUse = true,
        exclusive_targets = table.map(targets, Util.IdMapper),
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
    player.room:useCard(event:getCostData(self).extra_data)
  end,
})

return zhongtao
