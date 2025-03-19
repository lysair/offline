local huangen = fk.CreateSkill {
  name = "huangen"
}

Fk:loadTranslationTable{
  ['huangen'] = '皇恩',
  ['#huangen-choose'] = '皇恩：你可以取消至多 %arg 的目标，并令这些角色各摸一张牌',
  [':huangen'] = '当锦囊牌指定指定多于一个目标时，你可以取消至多X个目标（X为你的体力值），然后这些角色各摸一张牌。',
}

huangen:addEffect(fk.TargetSpecifying, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(huangen) and data.firstTarget and player.hp > 0 and
      data.card.type == Card.TypeTrick and #AimGroup:getAllTargets(data.tos) > 1
  end,
  on_cost = function(self, event, target, player, data)
    local tos = player.room:askToChoosePlayers(player, {
      targets = AimGroup:getAllTargets(data.tos),
      min_num = 1,
      max_num = player.hp,
      prompt = "#huangen-choose:::"..player.hp,
      skill_name = huangen.name
    })
    if #tos > 0 then
      player.room:sortPlayersByAction(tos)
      event:setCostData(self, tos)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, pid in ipairs(event:getCostData(self)) do
      AimGroup:cancelTarget(data, pid)
      local p = room:getPlayerById(pid)
      if not p.dead then
        p:drawCards(1, huangen.name)
      end
    end
    return table.contains(event:getCostData(self), data.to)
  end,
})

return huangen
