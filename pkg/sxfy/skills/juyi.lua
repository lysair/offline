local juyi = fk.CreateSkill {
  name = "sxfy__juyi",
  tags = { Skill.Lord },
}

Fk:loadTranslationTable{
  ["sxfy__juyi"] = "据益",
  [":sxfy__juyi"] = "主公技，其他群势力角色每回合首次对你造成伤害时，其可以防止此伤害，然后获得你一张牌。",

  ["#sxfy__juyi-invoke"] = "据益：是否防止对 %src 造成的伤害，获得其一张牌？",
}

juyi:addEffect(fk.DamageInflicted, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(juyi.name) and
      data.from and data.from.kingdom == "qun" and data.from ~= player and not data.from.dead and
      player:usedSkillTimes(juyi.name, Player.HistoryTurn) == 0 and
      #player.room.logic:getActualDamageEvents(1, function(e)
        return e.data.from == data.from and e.data.to == player
      end) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(data.from, {
      skill_name = self.name,
      prompt = "#sxfy__juyi-invoke:"..player.id,
    }) then
      room:doIndicate(data.from, {player})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    data:preventDamage()
    if not player:isNude() then
      local card = room:askToChooseCard(data.from, {
        target = player,
        flag = "he",
        skill_name = juyi.name,
      })
      room:moveCardTo(card, Card.PlayerHand, data.from, fk.ReasonPrey, juyi.name, nil, false, data.from)
    end
  end,
})

return juyi
