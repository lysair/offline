local hehe = fk.CreateSkill {
  name = "sxfy__hehe",
}

Fk:loadTranslationTable{
  ["sxfy__hehe"] = "和合",
  [":sxfy__hehe"] = "摸牌阶段结束时，你可以令至多两名手牌数与你相同的其他角色各摸一张牌。",

  ["#sxfy__hehe-invoke"] = "和合：令至多两名手牌数与你相同的其他角色各摸一张牌",
}

hehe:addEffect(fk.EventPhaseEnd, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(hehe.name) and player.phase == Player.Draw and
      table.find(player.room:getOtherPlayers(player, false), function (p)
        return p:getHandcardNum() == player:getHandcardNum()
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player, false), function (p)
      return p:getHandcardNum() == player:getHandcardNum()
    end)
    local tos = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 2,
      targets = targets,
      skill_name = hehe.name,
      prompt = "#sxfy__hehe-invoke",
      cancelable = true,
    })
    if #tos > 0  then
      room:sortByAction(tos)
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    for _, p in ipairs(event:getCostData(self).tos) do
      if not p.dead then
        p:drawCards(1, hehe.name)
      end
    end
  end,
})

return hehe
