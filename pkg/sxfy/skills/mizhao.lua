local mizhao = fk.CreateSkill {
  name = "sxfy__mizhao",
}

Fk:loadTranslationTable{
  ["sxfy__mizhao"] = "密诏",
  [":sxfy__mizhao"] = "结束阶段，你可以将所有手牌交给一名其他角色，其可以与你选择的另一名角色各失去1点体力。",

  ["#sxfy__mizhao-choose"] = "密诏：将所有手牌交给一名角色，其可以与另一名角色各失去1点体力",
  ["#sxfy__mizhao2-choose"] = "密诏：选择另一名角色，%dest 可以与其各失去1点体力",
  ["#sxfy__mizhao-ask"] = "密诏：是否与 %dest 各失去1点体力？",
}

mizhao:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(mizhao.name) and player.phase == Player.Finish and
      not player:isKongcheng() and #player.room:getOtherPlayers(player, false) > 0
  end,
  on_cost = function (self,event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room:getOtherPlayers(player, false),
      skill_name = mizhao.name,
      prompt = "#sxfy__mizhao-choose",
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    room:moveCardTo(player:getCardIds("h"), Card.PlayerHand, to, fk.ReasonGive, mizhao.name, nil, true, player)
    if player.dead or to.dead then return end
    local p = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room:getOtherPlayers(to, false),
      skill_name = mizhao.name,
      prompt = "#sxfy__mizhao2-choose::"..to.id,
      cancelable = false,
      no_indicate = true,
    })[1]
    room:doIndicate(to, {p})
    if room:askToSkillInvoke(to, {
      skill_name = mizhao.name,
      prompt = "#sxfy__mizhao-ask::"..p.id,
    }) then
      room:loseHp(to, 1, mizhao.name)
      if not p.dead then
        room:loseHp(p, 1, mizhao.name)
      end
    end
  end,
})

return mizhao
