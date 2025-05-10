local juqi = fk.CreateSkill {
  name = "juqi",
  tags = { Skill.Switch },
}

Fk:loadTranslationTable{
  ["juqi"] = "举棋",
  [":juqi"] = "转换技，阳：准备阶段，你摸三张牌/其他角色的准备阶段，其可以展示并交给你一张黑色手牌；" ..
  "阴：准备阶段，令你本回合使用牌无次数限制且造成的伤害+1/其他角色的准备阶段，其可以展示并交给你一张红色手牌。",

  ["@@juqi-turn"] = "举棋 进攻",
  ["#juqi-give"] = "举棋：你可以交给 %dest 一张对应颜色的手牌，切换其“举棋”状态",
}

juqi:addEffect(fk.EventPhaseStart, {
  anim_type = "switch",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(juqi.name) and target.phase == Player.Start and
      (target == player or not (target:isKongcheng() or target.dead))
  end,
  on_cost = function(self, event, target, player, data)
    if target ~= player then
      local room = player.room
      local cards = room:askToCards(target, {
        min_num = 1,
        max_num = 1,
        include_equip = false,
        skill_name = juqi.name,
        pattern = player:getSwitchSkillState(juqi.name) == fk.SwitchYin and ".|.|diamond,heart" or ".|.|club,spade",
        prompt = "#juqi-give::" .. player.id,
        cancelable = true,
      })
      if #cards > 0 then
        event:setCostData(self, {cards = cards})
        return true
      end
    else
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if target ~= player then
      local cards = event:getCostData(self).cards
      target:showCards(cards)
      if not player.dead then
        cards = table.filter(cards, function (id)
          return table.contains(target:getCardIds("h"), id)
        end)
        if #cards > 0 then
          room:obtainCard(player, cards, true, fk.ReasonGive, target, juqi.name)
        end
      end
    else
      if player:getSwitchSkillState(juqi.name, true) == fk.SwitchYin then
        room:setPlayerMark(player, "@@juqi-turn", 1)
      else
        player:drawCards(3, juqi.name)
      end
    end
  end,
})

juqi:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@@juqi-turn") > 0 and data.card
  end,
  on_use = function(self, event, target, player, data)
    data:changeDamage(1)
  end,
})

juqi:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card, to)
    return card and player:getMark("@@juqi-turn") > 0
  end,
})

return juqi
