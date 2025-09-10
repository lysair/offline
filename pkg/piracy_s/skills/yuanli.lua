local yuanli = fk.CreateSkill{
  name = "ofl__yuanli",
}

Fk:loadTranslationTable{
  ["ofl__yuanli"] = "媛丽",
  [":ofl__yuanli"] = "当一名角色跳过出牌阶段时，你可以与一名其他角色各摸一张牌。",

  ["#ofl__yuanli-choose"] = "媛丽：你可以与一名其他角色各摸一张牌",
}

yuanli:addEffect(fk.EventPhaseSkipped, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(yuanli.name) and data.phase == Player.Play and
      #player.room:getOtherPlayers(player, false) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room:getOtherPlayers(player, false),
      skill_name = yuanli.name,
      prompt = "#ofl__yuanli-choose",
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, yuanli.name)
    local to = event:getCostData(self).tos[1]
    if not to.dead then
      to:drawCards(1, yuanli.name)
    end
  end,
})

return yuanli
