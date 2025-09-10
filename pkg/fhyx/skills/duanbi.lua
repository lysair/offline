local duanbi = fk.CreateSkill {
  name = "ofl_shiji__duanbi",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable{
  ["ofl_shiji__duanbi"] = "锻币",
  [":ofl_shiji__duanbi"] = "限定技，出牌阶段，若所有角色的手牌数之和大于存活角色数的两倍，你可以令所有其他角色弃置X张手牌（X为其手牌数的一半，"..
  "向上取整且至多为3），然后你可以选择一名角色，随机将三张以此法弃置的牌交给其。",

  ["#ofl_shiji__duanbi"] = "锻币：令其他角色各弃置一半手牌（向上取整），然后可以将被弃置的牌交给一名角色！",
  ["#ofl_shiji__duanbi-give"] = "锻币：你可以将随机三张弃置的牌交给一名角色",

  ["$ofl_shiji__duanbi1"] = "欲除益州之弊，先定铜范之制。",
  ["$ofl_shiji__duanbi2"] = "范铸直百，重订蜀地币制。",
}

duanbi:addEffect("active", {
  anim_type = "control",
  prompt = "#ofl_shiji__duanbi",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    if player:usedSkillTimes(duanbi.name, Player.HistoryGame) == 0 then
      local n = 0
      for _, p in ipairs(Fk:currentRoom().alive_players) do
        n = n + p:getHandcardNum()
      end
      return n > 2 * #Fk:currentRoom().alive_players
    end
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local ids = {}
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if not p.dead and not p:isKongcheng() then
        local n = math.min(3, (p:getHandcardNum() + 1) // 2)
        local cards = room:askToDiscard(p, {
          min_num = n,
          max_num = n,
          include_equip = false,
          skill_name = duanbi.name,
          cancelable = false,
        })
        table.insertTableIfNeed(ids, cards)
      end
    end
    if player.dead then return end
    ids = table.filter(ids, function(id)
      return table.contains(room.discard_pile, id)
    end)
    if #ids > 0 then
      local to = room:askToChoosePlayers(player, {
        min_num = 1,
        max_num = 1,
        targets = room.alive_players,
        skill_name = duanbi.name,
        prompt = "#ofl_shiji__duanbi-give",
        cancelable = true,
      })
      if #to > 0 then
        room:moveCardTo(table.random(ids, 3), Player.Hand, to[1], fk.ReasonGive, duanbi.name, nil, true, player)
      end
    end
  end,
})

return duanbi
