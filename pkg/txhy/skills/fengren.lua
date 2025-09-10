local fengren = fk.CreateSkill {
  name = "ofl_tx__fengren",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_tx__fengren"] = "锋刃",
  [":ofl_tx__fengren"] = "锁定技，当一次拼点结算结束后，你摸X张牌（X为赢者拼点牌点数的一半，向上取整）。",
}

fengren:addEffect(fk.PindianFinished, {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(fengren.name) then
      for _, v in pairs(data.results) do
        if v.winner then
          return true
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local n = 0
    for _, v in pairs(data.results) do
      if v.winner then
        if v.winner == data.from then
          n = (data.fromCard.number + 1) // 2
        else
          n = (v.toCard.number + 1) // 2
        end
        break
      end
    end
    player:drawCards(n, fengren.name)
  end,
})

return fengren
