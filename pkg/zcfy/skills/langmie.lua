local langmie = fk.CreateSkill {
  name = "sxfy__langmie",
}

Fk:loadTranslationTable{
  ["sxfy__langmie"] = "狼灭",
  [":sxfy__langmie"] = "每轮每项限一次：1.当一名其他角色使用锦囊牌后，你可以弃置一张牌并获得之；2.当一名角色造成伤害后，你可以减1点体力上限，"..
  "令其受到等量的伤害。",

  ["#sxfy__langmie-prey"] = "狼灭：你可以弃一张牌，获得%arg",
  ["#sxfy__langmie-damage"] = "狼灭：你可以减1点体力上限，令 %dest 受到%arg点伤害",
}

langmie:addEffect(fk.CardUseFinished, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(langmie.name) and
      data.card.type == Card.TypeTrick and not player:isNude() and
      table.contains({Card.PlayerJudge, Card.Processing}, player.room:getCardArea(data.card)) and
      player:usedEffectTimes(self.name, Player.HistoryRound) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local card = room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = langmie.name,
      cancelable = true,
      prompt = "#sxfy__langmie-prey:::"..data.card:toLogString(),
      skip = true,
    })
    if #card > 0 then
      event:setCostData(self, {cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(event:getCostData(self).cards, langmie.name, player, player)
    if player.dead then return end
    if table.contains({Card.PlayerJudge, Card.Processing}, room:getCardArea(data.card)) then
      room:obtainCard(player, data.card, true, fk.ReasonJustMove, player, langmie.name)
    end
  end,
})

langmie:addEffect(fk.Damage, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(langmie.name) and target and
      not target.dead and player:usedEffectTimes(self.name, Player.HistoryRound) == 0
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = langmie.name,
      prompt = "#sxfy__langmie-damage::"..target.id..":"..data.damage,
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, -1)
    if not target.dead then
      room:damage{
        from = nil,
        to = target,
        damage = data.damage,
        skillName = langmie.name,
      }
    end
  end,
})
return langmie
