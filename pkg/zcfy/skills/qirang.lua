local qirang = fk.CreateSkill {
  name = "sxfy__qirang",
}

Fk:loadTranslationTable{
  ["sxfy__qirang"] = "祈禳",
  [":sxfy__qirang"] = "每回合限一次，当装备牌移至你的装备区后，你可以视为使用一张普通锦囊牌。",

  ["#sxfy__qirang-invoke"] = "祈禳：你可以视为使用一张普通锦囊牌",
}

qirang:addEffect(fk.AfterCardsMove, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(qirang.name) and player:usedSkillTimes(qirang.name, Player.HistoryTurn) == 0 then
      for _, move in ipairs(data) do
        if move.to == player and move.toArea == Player.Equip then
          return #player:getViewAsCardNames(qirang.name, Fk:getAllCardNames("t"), nil, nil, { bypass_times  = true}) > 0
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local use = room:askToUseVirtualCard(player, {
      name = Fk:getAllCardNames("t"),
      skill_name = qirang.name,
      prompt = "#sxfy__qirang-invoke",
      cancelable = true,
      extra_data = {
        bypass_times = true,
        extraUse = true,
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

return qirang
