local juliaoh = fk.CreateSkill {
  name = "juliaoh",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["juliaoh"] = "拒疗",
  [":juliaoh"] = "锁定技，【毒】对你无效；当其他角色成为你使用的转化牌的目标后，其选择是否减1点体力上限令此牌对其无效。",

  ["#juliaoh-ask"] = "拒疗：是否减1点体力上限，令 %src 使用的%arg对你无效？",
}

juliaoh:addEffect(fk.PreHpLost, {
  anim_type = "defensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(juliaoh.name) and
      (data.skillName == "poison" or data.skillName == "es__poison")
  end,
  on_use = function (self, event, target, player, data)
    data:preventHpLost()
  end
})

juliaoh:addEffect(fk.TargetConfirmed, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(juliaoh.name) and data.from == player and target ~= player and
      data.card:isVirtual() and #Card:getIdList(data.card) > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(target, {
      skill_name = juliaoh.name,
      prompt = "#juliaoh-ask:"..player.id.."::"..data.card:toLogString(),
    }) then
      room:changeMaxHp(target, -1)
      data.nullified = true
    end
  end,
})

return juliaoh
