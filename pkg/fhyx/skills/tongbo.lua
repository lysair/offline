local tongbo = fk.CreateSkill {
  name = "fhyx__tongbo",
}

Fk:loadTranslationTable{
  ["fhyx__tongbo"] = "通博",
  [":fhyx__tongbo"] = "摸牌阶段结束时，你可以用任意张牌替换等量的“书”，然后你可以将四张“书”任意分配给其他角色，若花色各不相同，"..
  "你回复1点体力，“书”的数量上限+1（至多增加等同于角色数的上限）。",

  ["#fhyx__tongbo-give"] = "通博：是否将四张“书”任意分配给其他角色？若花色各不相同，你回复1点体力，“书”的数量上限+1",
  ["#fhyx__tongbo-distribute"] = "通博：请将四张“书”任意分配给其他角色",
}

tongbo:addEffect(fk.EventPhaseEnd, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(tongbo.name) and player.phase == Player.Draw and
      #player:getPile("caiyong_book") > 0 and (not player:isNude() or #player:getPile("caiyong_book") > 3)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local piles = room:askToArrangeCards(player, {
      skill_name = tongbo.name,
      card_map = {"caiyong_book", player:getPile("caiyong_book"), player.general, player:getCardIds("he")},
    })
    room:swapCardsWithPile(player, piles[1], piles[2], tongbo.name, "caiyong_book")
    if player.dead or #player:getPile("caiyong_book") < 4 or #room:getOtherPlayers(player, false) == 0 then return end
    if room:askToSkillInvoke(player, {
        skill_name = tongbo.name,
        prompt = "#fhyx__tongbo-give",
      }) then
      local result = room:askToYiji(player, {
        cards = player:getPile("caiyong_book"),
        targets = room:getOtherPlayers(player, false),
        skill_name = tongbo.name,
        min_num = 4,
        max_num = 4,
        prompt = "#fhyx__tongbo-distribute",
        expand_pile = "caiyong_book",
      })
      if player.dead then return end
      local suits = {}
      for _, cards in pairs(result) do
        table.insertTableIfNeed(suits, table.map(cards, function (id)
          return Fk:getCardById(id).suit
        end))
      end
      table.removeOne(suits, Card.NoSuit)
      if #suits == 4 then
        if player:getMark("pizhuan_extra") < #room.players then
          room:addPlayerMark(player, "pizhuan_extra", 1)
        end
        if player:isWounded() then
          room:recover{
            who = player,
            num = 1,
            recoverBy = player,
            skillName = tongbo.name,
          }
        end
      end
    end
  end,
})

return tongbo
