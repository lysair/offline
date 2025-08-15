local qianjunz = fk.CreateSkill {
  name = "qianjunz",
}

Fk:loadTranslationTable{
  ["qianjunz"] = "牵军",
  [":qianjunz"] = "当其他角色使用【杀】结算结束后，你可以对其中一名目标角色使用一张【杀】，若未对其造成伤害，你弃置其一张牌。",

  ["#qianjunz-use"] = "牵军：你可以对其中一名目标角色使用【杀】，若未对其造成伤害则弃置其一张牌",
}

qianjunz:addEffect(fk.CardUseFinished, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(qianjunz.name) and data.card.trueName == "slash" and
      table.find(data.tos, function (p)
        return not p.dead and player:canUseTo(Fk:cloneCard("slash"), p, { bypass_times = true })
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(data.tos, function (p)
      return not p.dead
    end)
    local use = room:askToUseCard(player, {
      pattern = "slash",
      skill_name = qianjunz.name,
      prompt = "#qianjunz-use:"..player.id,
      cancelable = true,
      extra_data = {
        bypass_distances = true,
        bypass_times = true,
        extraUse = true,
        exclusive_targets = table.map(targets, Util.IdMapper),
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
    local use = event:getCostData(self).extra_data
    room:useCard(use)
    local to = use.tos[1]
    if use and not use.damageDealt[to] and not to:isNude() then
      local card = room:askToChooseCard(player, {
        target = to,
        flag = "he",
        skill_name = qianjunz.name,
      })
      room:throwCard(card, qianjunz.name, to, player)
    end
  end,
})

return qianjunz
