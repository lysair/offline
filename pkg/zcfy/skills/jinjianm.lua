local jinjianm = fk.CreateSkill {
  name = "sxfy__jinjianm",
}

Fk:loadTranslationTable{
  ["sxfy__jinjianm"] = "劲坚",
  [":sxfy__jinjianm"] = "当你造成或受到伤害后，你可以与受伤角色/伤害来源拼点，若你赢，你回复1点体力。",

  ["#sxfy__jinjianm-invoke"] = "劲坚：你可以与 %dest 拼点，若赢，你回复1点体力",
}

local spec = {
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local pindian = player:pindian({to}, jinjianm.name)
    if pindian.results[to].winner == player and not player.dead then
      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = jinjianm.name,
      }
    end
  end,
}

jinjianm:addEffect(fk.Damage, {
  anim_type = "support",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(jinjianm.name) and
      data.to and not data.to.dead and player:canPindian(data.to)
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = jinjianm.name,
      prompt = "#sxfy__jinjianm-invoke::"..data.to.id,
    }) then
      event:setCostData(self, {tos = {data.to}})
      return true
    end
  end,
  on_use = spec.on_use,
})

jinjianm:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(jinjianm.name) and
      data.from and not data.from.dead and player:canPindian(data.from)
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = jinjianm.name,
      prompt = "#sxfy__jinjianm-invoke::"..data.from.id,
    }) then
      event:setCostData(self, {tos = {data.from}})
      return true
    end
  end,
  on_use = spec.on_use,
})

return jinjianm
