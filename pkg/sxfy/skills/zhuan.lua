local zhuan = fk.CreateSkill {
  name = "sxfy__zhuan",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["sxfy__zhuan"] = "逐安",
  [":sxfy__zhuan"] = "锁定技，当你每回合首次受到伤害后，你摸三张牌，然后伤害来源获得你的一张牌。",

  ["#sxfy__zhuan-prey"] = "逐安：获得 %src 一张牌",
}

zhuan:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(zhuan.name) then
      local damage_events = player.room.logic:getActualDamageEvents(1, function(e)
        return e.data.to == player
      end, Player.HistoryTurn)
      return #damage_events == 1 and damage_events[1].data == data
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(3, zhuan.name)
    if player.dead or player:isNude() then return end
    if data.from and not data.from.dead then
      if data.from == player then
        if #player:getCardIds("e") > 0 then
          local card = room:askToChooseCard(player, {
            target = player,
            flag = "e",
            skill_name = zhuan.name,
            prompt = "#sxfy__zhuan-prey:"..player.id,
          })
          room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonPrey, zhuan.name, nil, true, player)
        end
      else
        room:doIndicate(data.from, {player})
        local card = room:askToChooseCard(data.from, {
          target = player,
          flag = "he",
          skill_name = zhuan.name,
          prompt = "#sxfy__zhuan-prey:"..player.id,
        })
        room:moveCardTo(card, Card.PlayerHand, data.from, fk.ReasonPrey, zhuan.name, nil, false, data.from)
      end
    end
  end,
})

return zhuan
