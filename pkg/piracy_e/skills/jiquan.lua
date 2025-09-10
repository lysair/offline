local jiquan = fk.CreateSkill {
  name = "ofl__jiquan",
  tags = { Skill.Lord, Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl__jiquan"] = "集权",
  [":ofl__jiquan"] = "主公技，锁定技，西势力角色的回合开始时，你回复1点体力并摸一张牌。",
}

jiquan:addEffect(fk.TurnStart, {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    return target.kingdom == "west" and player:hasSkill(jiquan.name)
  end,
  on_use = function (self, event, target, player, data)
    player.room:recover{
      who = player,
      num = 1,
      recoverBy = player,
      skillName = jiquan.name,
    }
    if not player.dead then
      player:drawCards(1, jiquan.name)
    end
  end,
})

return jiquan
