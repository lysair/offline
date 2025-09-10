local mowang = fk.CreateSkill {
  name = "ofl_tx__mowang",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_tx__mowang"] = "魔王",
  [":ofl_tx__mowang"] = "锁定技，当你的体力上限变化后，你摸X张牌（X为你当前体力上限），然后对一名角色造成2点伤害。",

  ["#ofl_tx__mowang-choose"] = "魔王：对一名角色造成2点伤害！",
}

mowang:addEffect(fk.MaxHpChanged, {
  anim_type = "offensive",
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(player.maxHp, mowang.name)
    if player.dead then return end
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room.alive_players,
      skill_name = mowang.name,
      prompt = "#ofl_tx__mowang-choose",
      cancelable = false,
    })[1]
    room:damage{
      from = player,
      to = to,
      damage = 2,
      skillName = mowang.name,
    }
  end,
})

return mowang
