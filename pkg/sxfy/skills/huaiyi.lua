local huaiyi = fk.CreateSkill {
  name = "sxfy__huaiyi",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["sxfy__huaiyi"] = "怀异",
  [":sxfy__huaiyi"] = "锁定技，准备阶段，你展示所有手牌，若颜色不全部相同，你弃置其中一种颜色的所有牌，获得至多等量名其他角色各一张牌，"..
  "若超过一名角色，你失去1点体力。",
}

huaiyi:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(huaiyi.name) and player.phase == Player.Start and
      not player:isKongcheng()
  end,
  on_use = function(self, event, target, player, data)
    Fk.skills["huaiyi"]:onUse(player.room, {
      from = player,
    })
  end,
})

return huaiyi
