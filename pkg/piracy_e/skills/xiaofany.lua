local xiaofany = fk.CreateSkill {
  name = "xiaofany",
}

Fk:loadTranslationTable{
  ["xiaofany"] = "嚣反",
  [":xiaofany"] = "蜀势力角色受到伤害后，你可以对其造成1点伤害，然后你变更势力至吴；<br>"..
  "吴势力角色失去装备牌后，你可以与其各摸一张牌，然后你变更势力至群；<br>"..
  "群势力角色造成伤害后，你可以获得造成伤害的牌，然后你变更势力至蜀。",

  ["#xiaofany1-invoke"] = "嚣反：是否对 %dest 造成1点伤害并变更势力至吴？",
  ["#xiaofany2-invoke"] = "嚣反：是否与 %dest 各摸一张牌并变更势力至群？",
  ["#xiaofany3-invoke"] = "嚣反：是否获得%arg并变更势力至蜀？",
}

xiaofany:addEffect(fk.Damaged, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(xiaofany.name) and
      target.kingdom == "shu" and not target.dead
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = xiaofany.name,
      prompt = "#xiaofany1-invoke::"..target.id,
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:damage{
      from = player,
      to = target,
      damage = 1,
      skillName = xiaofany.name,
    }
    if not player.dead and player.kingdom ~= "wu" then
      room:changeKingdom(player, "wu", true)
    end
  end,
})

xiaofany:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(xiaofany.name) then
      for _, move in ipairs(data) do
        if move.from and move.from.kingdom == "wu" and not move.from.dead then
          for _, info in ipairs(move.moveInfo) do
            if Fk:getCardById(info.cardId).type == Card.TypeEquip then
              return true
            end
          end
        end
      end
    end
  end,
  on_trigger = function (self, event, target, player, data)
    local targets = {}
    for _, move in ipairs(data) do
      if move.from and move.from.kingdom == "wu" then
        for _, info in ipairs(move.moveInfo) do
          if Fk:getCardById(info.cardId).type == Card.TypeEquip then
            table.insertIfNeed(targets, move.from)
          end
        end
      end
    end
    player.room:sortByAction(targets)
    for _, p in ipairs(targets) do
      if not player:hasSkill(xiaofany.name) then break end
      if not p.dead and p.kingdom == "wu" then
        event:setCostData(self, {tos = {p}})
        self:doCost(event, target, player, data)
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    if room:askToSkillInvoke(player, {
      skill_name = xiaofany.name,
      prompt = "#xiaofany2-invoke::"..to.id,
    }) then
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    player:drawCards(1, xiaofany.name)
    if not to.dest then
      to:drawCards(1, xiaofany.name)
    end
    if not player.dead and player.kingdom ~= "qun" then
      room:changeKingdom(player, "qun", true)
    end
  end,
})

xiaofany:addEffect(fk.Damage, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(xiaofany.name) and target and data.card and
      target.kingdom == "qun" and player.room:getCardArea(data.card) == Card.Processing
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = xiaofany.name,
      prompt = "#xiaofany3-invoke:::"..data.card:toLogString(),
    })
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:obtainCard(player, data.card, true, fk.ReasonJustMove, player, xiaofany.name)
    if not player.dead and player.kingdom ~= "shu" then
      room:changeKingdom(player, "shu", true)
    end
  end,
})

return xiaofany
