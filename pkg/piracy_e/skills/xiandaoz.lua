local xiandaoz = fk.CreateSkill({
  name = "xiandaoz",
})

Fk:loadTranslationTable{
  ["xiandaoz"] = "显道",
  [":xiandaoz"] = "当一名角色的判定牌生效前，你可以用一张黑色牌替换之，然后摸一张牌。",

  ["#xiandaoz-ask"] = "显道：你用一张黑色牌替换 %dest 的“%arg”判定，摸一张牌",
}

xiandaoz:addEffect(fk.AskForRetrial, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(xiandaoz.name) and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cards = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = xiandaoz.name,
      pattern = ".|.|spade,club",
      prompt = "#xiandaoz-ask::"..target.id..":"..data.reason,
      cancelable = true,
    })
    if #cards > 0 then
      event:setCostData(self, {cards = cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:changeJudge{
      card = Fk:getCardById(event:getCostData(self).cards[1]),
      player = player,
      data = data,
      skillName = xiandaoz.name,
      exchange = true,
    }
    if not player.dead then
      player:drawCards(1, xiandaoz.name)
    end
  end,
})

return xiandaoz
