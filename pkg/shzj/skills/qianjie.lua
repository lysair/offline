local qianjie = fk.CreateSkill {
  name = "shzj_juedai__qianjie",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["shzj_juedai__qianjie"] = "谦节",
  [":shzj_juedai__qianjie"] = "锁定技，当你横置前，防止之；你不能成为延时锦囊牌的目标；你不能拼点。",

  ["$shzj_juedai__qianjie1"] = "",
  ["$shzj_juedai__qianjie2"] = "",
}

qianjie:addEffect(fk.BeforeChainStateChange, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(qianjie.name) and not player.chained
  end,
  on_use = function (self, event, target, player, data)
    data.prevented = true
  end,
})

qianjie:addEffect("prohibit", {
  is_prohibited = function(self, from, to, card)
    return to:hasSkill(qianjie.name) and card and card.sub_type == Card.SubtypeDelayedTrick
  end,
  prohibit_pindian = function(self, from, to)
    return to:hasSkill(qianjie.name) or from:hasSkill(qianjie.name)
  end
})

return qianjie
