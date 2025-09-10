local huangen = fk.CreateSkill {
  name = "huangen",
}

Fk:loadTranslationTable{
  ["huangen"] = "皇恩",
  [":huangen"] = "当锦囊牌指定指定多于一个目标时，你可以取消至多X个目标（X为你的体力值），然后这些角色各摸一张牌。",

  ["#huangen-choose"] = "皇恩：你可以取消此%arg至多%arg2个目标，并令这些角色各摸一张牌",
}

huangen:addEffect(fk.TargetSpecifying, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(huangen.name) and data.firstTarget and
      data.card.type == Card.TypeTrick and #data.use.tos > 1 and player.hp > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local tos = room:askToChoosePlayers(player, {
      targets = data.use.tos,
      min_num = 1,
      max_num = player.hp,
      prompt = "#huangen-choose:::"..data.card:toLogString()..":"..player.hp,
      skill_name = huangen.name
    })
    if #tos > 0 then
      room:sortByAction(tos)
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    for _, p in ipairs(event:getCostData(self).tos) do
      data:cancelTarget(p)
      if not p.dead then
        p:drawCards(1, huangen.name)
      end
    end
  end,
})

return huangen
