local qiuyuan = fk.CreateSkill {
  name = "sxfy__qiuyuan",
}

Fk:loadTranslationTable{
  ["sxfy__qiuyuan"] = "求援",
  [":sxfy__qiuyuan"] = "当你成为一名角色使用【杀】的目标时，你可以令另一名角色选择交给你一张牌或成为此【杀】的额外目标。",

  ["#sxfy__qiuyuan-choose"] = "求援：令一名角色选择交给你一张牌或成为此【杀】的额外目标",
  ["#sxfy__qiuyuan-give"] = "求援：交给 %dest 一张牌，否则成为此【杀】额外目标",
}

qiuyuan:addEffect(fk.TargetConfirming, {
  anim_type = "control",
  can_trigger = function (self, event, target, player, data)
    if target == player and player:hasSkill(qiuyuan.name) and data.card.trueName == "slash" then
      return table.find(player.room.alive_players, function (p)
        return p ~= data.from and p ~= player and not table.contains(data.use.tos, p)
      end)
    end
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function (p)
      return p ~= data.from and p ~= player and not table.contains(data.use.tos, p)
    end)
    targets = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#sxfy__qiuyuan-choose",
      skill_name = qiuyuan.name,
      cancelable = true,
    })
    if #targets > 0 then
      event:setCostData(self, {tos = targets})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local cards = room:askToCards(to, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = qiuyuan.name,
      cancelable = true,
      prompt = "#sxfy__qiuyuan-give::"..player.id,
    })
    if #cards > 0 then
      room:moveCardTo(cards, Player.Hand, player, fk.ReasonGive, qiuyuan.name, nil, true, to)
    else
      --本意：此额外目标视为已生成过“成为目标时fk.TargetConfirming”时机，因此直接添加到AimData.Done中
      table.insert(data.tos[AimData.Done], to)
      table.insert(data.use.tos, to)
    end
  end,
})

return qiuyuan
