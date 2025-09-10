local huangjin = fk.CreateSkill {
  name = "ofl_tx__huangjin",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_tx__huangjin"] = "黄巾",
  [":ofl_tx__huangjin"] = "锁定技，当你成为【杀】的目标时，你进行判定，若点数与此【杀】点数之差不大于1，此【杀】对你无效。",
}

huangjin:addEffect(fk.TargetConfirming, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(huangjin.name) and
      data.card.trueName == "slash"
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local pattern = "false"
    if data.card.number > 0 then
      if data.card.number == 1 then
        pattern = ".|1,2"
      elseif data.card.number == 13 then
        pattern = ".|12,13"
      else
        pattern = ".|"..(data.card.number - 1)..","..data.card.number..","..(data.card.number + 1)
      end
    end
    local judge = {
      who = player,
      reason = huangjin.name,
      pattern = pattern,
    }
    room:judge(judge)
    if judge:matchPattern() then
      data.nullified = true
    end
  end,
})

return huangjin
