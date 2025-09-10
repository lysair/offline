local duanbi = fk.CreateSkill {
  name = "sxfy__duanbi",
}

Fk:loadTranslationTable{
  ["sxfy__duanbi"] = "锻币",
  [":sxfy__duanbi"] = "结束阶段，你可以弃置所有手牌，然后令两名角色各摸两张牌。",

  ["#sxfy__duanbi-invoke"] = "锻币：是否弃置所有手牌，令两名角色各摸两张牌？",
  ["#sxfy__duanbi-choose"] = "锻币：令两名角色各摸两张牌",
}

duanbi:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(duanbi.name) and player.phase == Player.Finish
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
        skill_name = duanbi.name,
        prompt = "#sxfy__duanbi-invoke",
      })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:throwAllCards("h", duanbi.name)
    if player.dead or #room.alive_players < 2 then return end
    local tos = room:askToChoosePlayers(player, {
      min_num = 2,
      max_num = 2,
      targets = room.alive_players,
      skill_name = duanbi.name,
      prompt = "#sxfy__duanbi-choose",
      cancelable = false,
    })
    room:sortByAction(tos)
    for _, p in ipairs(tos) do
      if not p.dead then
        p:drawCards(2, duanbi.name)
      end
    end
  end,
})

return duanbi
