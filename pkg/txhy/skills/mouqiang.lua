local mouqiang = fk.CreateSkill {
  name = "ofl_tx__mouqiang",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_tx__mouqiang"] = "谋强",
  [":ofl_tx__mouqiang"] = "锁定技，当你受到大于1点的伤害后，你获得伤害来源X张牌，其中每有一张基本牌你回复1点体力，"..
  "每有一张非基本牌你对其造成1点伤害（X为本次伤害值的一半，向下取整）。",

  ["#ofl_tx__mouqiang-prey"] = "谋强：获得 %dest %arg张牌，基本牌回复体力，非基本牌造成伤害",
}

mouqiang:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(mouqiang.name) and
      data.damage > 1 and data.from and not data.from:isNude()
  end,
  on_cost = function (self, event, target, player, data)
    event:setCostData(self, {tos = {data.from}})
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = data.damage // 2
    local cards = room:askToChooseCards(player, {
      target = data.from,
      min = n,
      max = n,
      flag = "he",
      skill_name = mouqiang.name,
      prompt = "#ofl_tx__mouqiang-prey::"..data.from.id..":"..n,
    })
    local basic = #table.filter(cards, function (id)
      return Fk:getCardById(id).type == Card.TypeBasic
    end)
    if data.from == player then
      local get = table.filter(cards, function (id)
        return table.contains(player:getCardIds("e"), id)
      end)
      if #get > 0 then
        room:moveCardTo(get, Card.PlayerHand, player, fk.ReasonPrey, mouqiang.name, nil, true, player)
      end
    else
      room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonPrey, mouqiang.name, nil, false, player)
    end
    if basic > 0 and not player.dead then
      room:recover{
        who = player,
        num = basic,
        recoverBy = player,
        skillName = mouqiang.name,
      }
    end
    if #cards > basic and not data.from.dead then
      room:damage{
        from = player,
        to = data.from,
        damage = #cards - basic,
        skillName = mouqiang.name,
      }
    end
  end,
})

return mouqiang
