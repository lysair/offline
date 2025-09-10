local cuanzun = fk.CreateSkill {
  name = "cuanzun",
}

Fk:loadTranslationTable{
  ["cuanzun"] = "篡尊",
  [":cuanzun"] = "当其他角色死亡时，你可以获得其所有牌并回复1点体力。",

  ["$cuanzun1"] = "生不带来，死不带去。",
  ["$cuanzun2"] = "有时候，死人比活人有用。",
}

cuanzun:addEffect(fk.Death, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(cuanzun.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if not target:isNude() then
      room:obtainCard(player, target:getCardIds("he"), false, fk.ReasonPrey, player, cuanzun.name)
      if player.dead then return end
    end
    room:recover{
      who = player,
      num = 1,
      recoverBy = player,
      skillName = cuanzun.name
    }
  end,
})

return cuanzun
