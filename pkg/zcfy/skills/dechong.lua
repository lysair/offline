local dechong = fk.CreateSkill {
  name = "dechong",
}

Fk:loadTranslationTable {
  ["dechong"] = "得宠",
  [":dechong"] = "其他角色的准备阶段，你可以交给其至少一张牌，然后本回合弃牌阶段开始时，若其手牌数不小于体力值，你可以对其造成1点伤害。",

  ["#dechong-invoke"] = "得宠：交给 %dest 任意张牌，结束阶段若其手牌不少于体力值，可以对其造成伤害",
  ["@@dechong-turn"] = "得宠",
  ["#dechong-damage"] = "得宠：是否对 %dest 造成1点伤害？",
}

dechong:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(dechong.name) and target.phase == Player.Start and
      not target.dead and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local card = room:askToCards(player, {
      min_num = 1,
      max_num = 999,
      include_equip = true,
      skill_name = dechong.name,
      prompt = "#dechong-invoke::"..target.id,
      cancelable = true,
    })
    if #card > 0 then
      event:setCostData(self, {tos = {target}, cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:moveCardTo(event:getCostData(self).cards, Card.PlayerHand, target, fk.ReasonGive, dechong.name, nil, false, player)
    if not target.dead and not player.dead then
      room:addTableMarkIfNeed(target, "@@dechong-turn", player.id)
    end
  end,
})

dechong:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target.phase == Player.Discard and target:getHandcardNum() >= target.hp and
      table.contains(target:getTableMark("@@dechong-turn"), player.id)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = dechong.name,
      prompt = "#dechong-damage::"..target.id,
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    player.room:damage{
      from = player,
      to = target,
      damage = 1,
      skillName = dechong.name,
    }
  end,
})

return dechong
