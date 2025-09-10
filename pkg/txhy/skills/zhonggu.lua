local zhonggu = fk.CreateSkill {
  name = "ofl_tx__zhonggu",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_tx__zhonggu"] = "仲骨",
  [":ofl_tx__zhonggu"] = "锁定技，当拥有〖仲骨〗的其他角色死亡后，你增加X点体力上限并摸X张牌（X为其体力上限）。",
}

zhonggu:addEffect(fk.Deathed, {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(zhonggu.name) and
      target ~= player and target:hasSkill(zhonggu.name, false, true) and target.maxHp > 0
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local n = target.maxHp
    room:changeMaxHp(player, n)
    if not player.dead then
      player:drawCards(n, zhonggu.name)
    end
  end,
})

return zhonggu
