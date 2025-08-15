
local guluo = fk.CreateSkill {
  name = "guluo",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["guluo"] = "孤落",
  [":guluo"] = "锁定技，当你进入濒死状态时，若你没有手牌，你减1点体力上限，然后回复至1点体力。",
}

guluo:addEffect(fk.EnterDying, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(guluo.name) and
      player.dying and player:isKongcheng()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, -1)
    if not player.dead and player.hp < 1 then
      room:recover{
        who = player,
        num = 1 - player.hp,
        recoverBy = player,
        skillName = guluo.name,
      }
    end
  end,
})

return guluo
