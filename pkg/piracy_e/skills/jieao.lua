local jieao = fk.CreateSkill {
  name = "jieao",
  tags = { Skill.Compulsory }
}

Fk:loadTranslationTable{
  ["jieao"] = "桀骜",
  [":jieao"] = "锁定技，当你翻面时，防止之，然后令所有其他角色依次失去1点体力。",
}

jieao:addEffect(fk.BeforeTurnOver, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jieao.name)
  end,
  on_use = function (self, event, target, player, data)
    data.prevented = true
    local room = player.room
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if not p.dead then
        room:loseHp(p, 1, jieao.name)
      end
    end
  end,
})

return jieao
