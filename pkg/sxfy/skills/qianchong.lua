local qianchong = fk.CreateSkill {
  name = "sxfy__qianchong",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["sxfy__qianchong"] = "谦冲",
  [":sxfy__qianchong"] = "锁定技，若你的装备区的牌数为偶数/奇数，你使用牌无距离/次数限制。",
}

qianchong:addEffect("targetmod", {
  bypass_times = function (self, player, skill, scope, card, to)
    return card and player:hasSkill(qianchong.name) and #player:getCardIds("e") % 2 == 1
  end,
  bypass_distances = function (self, player, skill, card, to)
    return card and player:hasSkill(qianchong.name) and #player:getCardIds("e") % 2 == 0
  end,
})

return qianchong
