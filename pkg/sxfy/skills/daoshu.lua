local daoshu = fk.CreateSkill {
  name = "sxfy__daoshu",
}

Fk:loadTranslationTable{
  ["sxfy__daoshu"] = "盗书",
  [":sxfy__daoshu"] = "每轮限一次，一名角色准备阶段，你可以展示其以外的角色一张手牌并令其获得之，然后你与其本回合不能使用与之花色相同的手牌。",

  ["#sxfy__daoshu-choose"] = "盗书：展示一名角色一张手牌，令 %dest 获得之，本回合你与其不能使用此花色手牌",
  ["#sxfy__daoshu-card"] = "盗书：选择 %dest 的一张手牌，令 %src 获得之",
  ["@sxfy__daoshu-turn"] = "盗书",
}

daoshu:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(daoshu.name) and target.phase == Player.Start and not target.dead and
      player:usedSkillTimes(daoshu.name, Player.HistoryRound) == 0 and
      table.find(player.room:getOtherPlayers(target, false), function(p)
        return not p:isKongcheng()
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(target, false), function(p)
      return not p:isKongcheng()
    end)
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = self.name,
      prompt = "#sxfy__daoshu-choose::"..target.id,
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = {target, to}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[2]
    local card = room:askToChooseCard(player, {
      target = to,
      flag = "h",
      skill_name = daoshu.name,
      prompt = "#sxfy__daoshu-card:"..target.id..":"..to.id,
    })
    local suit = Fk:getCardById(card):getSuitString(true)
    to:showCards(card)
    if target.dead or not table.contains(to:getCardIds("h"), card) then return end
    room:moveCardTo(card, Card.PlayerHand, target, fk.ReasonPrey, daoshu.name, nil, true, target)
    if suit == "log_nosuit" then return end
    if not player.dead then
      room:addTableMarkIfNeed(player, "@sxfy__daoshu-turn", suit)
    end
    if target ~= player and not target.dead then
      room:addTableMarkIfNeed(target, "@sxfy__daoshu-turn", suit)
    end
  end,
})

daoshu:addEffect("prohibit", {
  prohibit_use = function(self, player, card)
    if player:getMark("@sxfy__daoshu-turn") ~= 0 and card then
      local subcards = card:isVirtual() and card.subcards or {card.id}
      return #subcards > 0 and table.every(subcards, function(id)
        return table.contains(player:getCardIds("h"), id) and
          table.contains(player:getTableMark("@sxfy__daoshu-turn"), Fk:getCardById(id):getSuitString(true))
      end)
    end
  end,
})

return daoshu
