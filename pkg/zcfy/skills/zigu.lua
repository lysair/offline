local zigu = fk.CreateSkill {
  name = "sxfy__zigu",
}

Fk:loadTranslationTable{
  ["sxfy__zigu"] = "自固",
  [":sxfy__zigu"] = "出牌阶段限一次，你可以弃置一张牌，然后获得场上一张装备牌。若你没有因此获得其他角色的牌，你回复1点体力。",
}

zigu:addEffect("active", {
  anim_type = "control",
  prompt = "#zigu",
  card_num = 1,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(zigu.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and not player:prohibitDiscard(to_select)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    room:throwCard(effect.cards, zigu.name, player, player)
    if player.dead then return end
    local targets = table.filter(room.alive_players, function(p)
      return #p:getCardIds("e") > 0
    end)
    if #targets > 0 then
      local to = room:askToChoosePlayers(player, {
        targets = targets,
        min_num = 1,
        max_num = 1,
        prompt = "#zigu-choose",
        skill_name = zigu.name,
        cancelable = false,
      })[1]
      local id = room:askToChooseCard(player, {
        target = to,
        flag = "e",
        skill_name = zigu.name,
        prompt = "#zigu-prey::"..to.id,
      })
      room:moveCardTo(id, Card.PlayerHand, player, fk.ReasonPrey, zigu.name, nil, true, player)
      if not player.dead and to == player then
        player:drawCards(1, zigu.name)
      end
    else
      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = zigu.name,
      }
    end
  end,
})

return zigu
