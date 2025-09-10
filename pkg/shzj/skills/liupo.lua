local liupo = fk.CreateSkill {
  name = "liupo",
  tags = { Skill.Switch },
}

Fk:loadTranslationTable{
  ["liupo"] = "流魄",
  [":liupo"] = "转换技，回合开始时，你令本轮：阳：所有角色不能使用【桃】；阴：所有即将造成的伤害均视为体力流失。",

  ["@liupo_yang-round"] = "禁止用桃",
  ["@liupo_yin-round"] = "伤害改为体力流失",
}

liupo:addEffect(fk.TurnStart, {
  anim_type = "switch",
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setBanner("@liupo_"..player:getSwitchSkillState(liupo.name, true, true).."-round", 1)
  end,
})

liupo:addEffect(fk.PreDamage, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return data.to == player and player.room:getBanner("@liupo_yin-round")
  end,
  on_use = function(self, event, target, player, data)
    player.room:loseHp(player, data.damage, liupo.name)
    data:preventDamage()
  end,
})

liupo:addEffect("prohibit", {
  prohibit_use = function(self, player, card)
    return card and card.name == "peach" and
      Fk:currentRoom():getBanner("@liupo_yang-round")
  end,
})

return liupo
