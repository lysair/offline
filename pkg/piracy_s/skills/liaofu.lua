local liaofu = fk.CreateSkill {
  name = "ofl__liaofu",
  derived_piles = "$ofl__liaofu",
}

Fk:loadTranslationTable{
  ["ofl__liaofu"] = "燎伏",
  [":ofl__liaofu"] = "出牌阶段限一次，你可以扣置一张未以此法扣置过的类别的【杀】，其他角色于你的回合外使用【杀】时，"..
  "你可以移去一张相同的【杀】，对其造成1点此【杀】属性的伤害。",

  ["#ofl__liaofu"] = "燎伏：扣置一张【杀】，其他角色使用同样的【杀】时，你可以移去之并对其造成伤害",
  ["$ofl__liaofu"] = "燎伏",
  ["#ofl__liaofu-invoke"] = "燎伏：是否移去【%arg】，对 %dest 造成1点相同属性的伤害？",
}

liaofu:addEffect("active", {
  anim_type = "offensive",
  prompt = "#ofl__liaofu",
  card_num = 1,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(liaofu.name, Player.HistoryPhase) == 0
  end,
  card_filter = function (self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).trueName == "slash" and
      not table.find(player:getPile("$ofl__liaofu"), function (id)
        return Fk:getCardById(id).name == Fk:getCardById(to_select).name
      end)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    player:addToPile("$ofl__liaofu", effect.cards, false, liaofu.name, player)
  end,
})

liaofu:addEffect(fk.CardUsing, {
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    return target ~= player and player:hasSkill(liaofu.name) and
      data.card.trueName == "slash" and not target.dead and
      table.find(player:getPile("$ofl__liaofu"), function (id)
        return Fk:getCardById(id).name == data.card.name
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cards = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = liaofu.name,
      pattern = ".|.|.|$ofl__liaofu|"..data.card.name,
      prompt = "#ofl__liaofu-invoke::"..target.id..":"..data.card.name,
      cancelable = true,
      expand_pile = "$ofl__liaofu",
    })
    if #cards > 0 then
      event:setCostData(self, {tos = {target}, cards = cards})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:moveCardTo(event:getCostData(self).cards, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, liaofu.name, nil, true, player)
    if not target.dead then
      data.card.skill:onEffect(room, {
        from = player,
        to = target,
        card = nil,
      })
    end
  end,
})

return liaofu