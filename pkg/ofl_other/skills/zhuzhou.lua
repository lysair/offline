local zhuzhou = fk.CreateSkill {
  name = "zhuzhou"
}

Fk:loadTranslationTable{
  ['zhuzhou'] = '助纣',
  ['#zhuzhou-invoke'] = '助纣：是否令 %src 获得 %dest 一张手牌？',
  ['#zhuzhou-prey'] = '助纣：获得 %dest 一张手牌',
  [':zhuzhou'] = '每回合限一次，当手牌数最多的角色造成伤害后，你可以令其获得受伤角色的一张手牌。',
}

zhuzhou:addEffect(fk.Damage, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(zhuzhou.name) and target and not target.dead and target ~= data.to and
      player:usedSkillTimes(zhuzhou.name, Player.HistoryTurn) == 0 and
      not data.to.dead and not data.to:isKongcheng() and
      table.every(player.room.alive_players, function (p)
        return p:getHandcardNum() <= target:getHandcardNum()
      end)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = zhuzhou.name,
      prompt = "#zhuzhou-invoke:"..target.id..":"..data.to.id
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    room:delay(500)
    room:doIndicate(target.id, {data.to.id})
    local id = room:askToChooseCard(target, {
      target = data.to,
      flag = "h",
      skill_name = zhuzhou.name,
      prompt = "#zhuzhou-prey::"..data.to.id
    })
    room:moveCardTo(id, Card.PlayerHand, target, fk.ReasonPrey, zhuzhou.name, nil, false, target.id)
  end,
})

return zhuzhou
