local qianshou = fk.CreateSkill {
  name = "qianshou",
  tags = { Skill.Switch },
}

Fk:loadTranslationTable{
  ["qianshou"] = "谦守",
  [":qianshou"] = "转换技，其他角色回合开始时，若其体力值大于你，或其未处于横置状态，阳：你可以展示并交给其一张红色牌，本回合你不能使用手牌"..
  "且你与其不能成为牌的目标；阴：你可以令其展示并交给你一张牌，若不为黑色，你失去1点体力。<br>"..
  "游戏开始时，将<a href=':imperial_sword'>【尚方宝剑】</a>置入你的装备区。",

  ["#qianshou-yang"] = "谦守：是否交给 %dest 一张红色牌，令你本回合不能使用手牌、你与其不能成为牌的目标？",
  ["#qianshou-yin"] = "谦守：是否令 %dest 交给你一张牌？若不为黑色，你失去1点体力",
  ["#qianshou-give"] = "谦守：请交给 %src 一张牌，若不为黑色，其失去1点体力",
  ["@@qianshou-turn"] = "谦守",
}

qianshou:addEffect(fk.TurnStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(qianshou.name) and target ~= player and
      (target.hp > player.hp or not target.chained) and not target.dead then
      if player:getSwitchSkillState(qianshou.name, false) == fk.SwitchYang then
        return not player:isNude()
      else
        return not target:isNude()
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if player:getSwitchSkillState(qianshou.name, false) == fk.SwitchYang then
      local card = room:askToCards(player, {
        min_num = 1,
        max_num = 1,
        include_equip = true,
        skill_name = qianshou.name,
        pattern = ".|.|heart,diamond",
        prompt = "#qianshou-yang::"..target.id,
        cancelable = true,
      })
      if #card > 0 then
        event:setCostData(self, {tos = {target}, cards = card})
        return true
      end
    else
      if room:askToSkillInvoke(player, {
        skill_name = qianshou.name,
        prompt = "#qianshou-yin::"..target.id,
      }) then
        event:setCostData(self, {tos = {target}})
        return true
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if player:getSwitchSkillState(qianshou.name, true) == fk.SwitchYang then
      local card = event:getCostData(self).cards[1]
      player:showCards(card)
      if player.dead or target.dead or not table.contains(player:getCardIds("he"), card) then return end
      room:setPlayerMark(player, "@@qianshou-turn", 1)
      room:setPlayerMark(target, "@@qianshou-turn", 1)
      room:moveCardTo(card, Card.PlayerHand, target, fk.ReasonGive, qianshou.name, nil, true, player)
    else
      local card = room:askToCards(target, {
        min_num = 1,
        max_num = 1,
        include_equip = true,
        skill_name = qianshou.name,
        prompt = "#qianshou-give:"..player.id,
        cancelable = false,
      })
      local color = Fk:getCardById(card[1]).color
      target:showCards(card)
      if player.dead or target.dead or not table.contains(target:getCardIds("he"), card[1]) then return end
      room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonGive, qianshou.name, nil, true, target)
      if not player.dead and color ~= Card.Black then
        room:loseHp(player, 1, qianshou.name)
      end
    end
  end,
})

qianshou:addEffect("prohibit", {
  prohibit_use = function (self, player, card)
    if player:getMark("@@qianshou-turn") > 0 and player:usedSkillTimes(qianshou.name, Player.HistoryTurn) > 0 then
      local subcards = card:isVirtual() and card.subcards or {card.id}
      return #subcards > 0 and table.every(subcards, function(id)
        return table.contains(player:getCardIds("h"), id)
      end)
    end
  end,
  is_prohibited = function(self, from, to, card)
    return to:getMark("@@qianshou-turn") > 0
  end,
})

qianshou:addEffect(fk.GameStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(qianshou.name) and player:hasEmptyEquipSlot(Card.SubtypeWeapon)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local id = room:printCard("imperial_sword", Card.Spade, 5).id
    room:moveCardIntoEquip(player, id, qianshou.name, false, player)
  end,
})

return qianshou
