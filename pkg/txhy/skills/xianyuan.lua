local xianyuan = fk.CreateSkill{
  name = "ofl_tx__xianyuan",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_tx__xianyuan"] = "陷渊",
  [":ofl_tx__xianyuan"] = "锁定技，当你使用牌时，你弃置一张手牌。",
}

xianyuan:addEffect(fk.CardUsing, {
  anim_type = "negative",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xianyuan.name)
  end,
  on_use = function(self, event, target, player, data)
    player.room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = xianyuan.name,
      cancelable = false,
    })
  end,
})

return xianyuan
