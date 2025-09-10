local linei = fk.CreateSkill{
  name = "linei",
}

Fk:loadTranslationTable{
  ["linei"] = "理内",
  [":linei"] = "每轮限一次，当“结衣”角色获得牌后，若其手牌数大于体力值，你可以获得其X张牌并令其回复1点体力（X为其手牌数与体力值之差，至多为3）。",

  ["#linei-invoke"] = "理内：是否获得 %dest %arg张牌并令其回复1点体力？",
}

linei:addEffect(fk.AfterCardsMove, {
  anim_type = "control",
  times = function(self, player)
    return 1 + player:getMark("linei-round") - player:usedSkillTimes(linei.name, Player.HistoryRound)
  end,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(linei.name) and player:getMark("@jieyi-round") ~= 0 and
      player:getMark("@jieyi-round"):getHandcardNum() > player:getMark("@jieyi-round").hp and
      player:usedEffectTimes(linei.name, Player.HistoryRound) < 1 + player:getMark("linei-round") then
      for _, move in ipairs(data) do
        if move.to == player:getMark("@jieyi-round") and move.toArea == Card.PlayerHand then
          return true
        end
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local to = player:getMark("@jieyi-round")
    local n = math.min(to:getHandcardNum() - to.hp, 3)
    if room:askToSkillInvoke(player, {
      skill_name = linei.name,
      prompt = "#linei-invoke::"..to.id..":"..n,
    }) then
      event:setCostData(self, {tos = {to}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local n = math.min(to:getHandcardNum() - to.hp, 3)
    local cards = room:askToChooseCards(player, {
      target = to,
      min = n,
      max = n,
      flag = "he",
      skill_name = linei.name,
    })
    room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonPrey, linei.name, nil, false, player)
    if not to.dead then
      room:recover{
        who = to,
        num = 1,
        recoverBy = player,
        skillName = linei.name,
      }
    end
  end,
})

return linei
