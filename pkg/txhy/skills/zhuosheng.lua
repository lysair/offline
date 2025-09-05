local zhuosheng = fk.CreateSkill {
  name = "ofl_tx__zhuosheng",
}

Fk:loadTranslationTable{
  ["ofl_tx__zhuosheng"] = "擢升",
  [":ofl_tx__zhuosheng"] = "出牌阶段开始时，你可以弃置一张牌，<a href='os__qiangling_href'>强令</a>一名其他角色在其下回合结束前"..
  "获得至少五张牌。<br>成功：其加1点体力上限并回复1点体力，然后交给你一张非基本牌。",

  ["#ofl_tx__zhuosheng-choose"] = "擢升：你可以弃一张牌，强令一名角色在其下回合结束前获得至少五张牌",
  ["@ofl_tx__zhuosheng"] = "擢升",
  ["#ofl_tx__zhuosheng-give"] = "擢升：请交给 %src 一张非基本牌",
}

zhuosheng:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zhuosheng.name) and player.phase == Player.Play and
      #player.room:getOtherPlayers(player, false) > 0 and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to, card = room:askToChooseCardsAndPlayers(player, {
      min_card_num = 1,
      max_card_num = 1,
      min_num = 1,
      max_num = 1,
      targets = room:getOtherPlayers(player, false),
      skill_name = zhuosheng.name,
      prompt = "#ofl_tx__zhuosheng-choose",
      cancelable = true,
      will_throw = true,
    })
    if #to > 0 and #card > 0 then
      event:setCostData(self, {tos = to, cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local card = event:getCostData(self).cards or {}
    room:throwCard(card, zhuosheng.name, player, player)
    if player.dead or to.dead then return end
    if to:getMark("@ofl_tx__zhuosheng") == 0 then
      room:setPlayerMark(to, "@ofl_tx__zhuosheng", "0/5")
    end
    room:addTableMark(to, zhuosheng.name, { player.id, 0 })
  end
})

zhuosheng:addEffect(fk.AfterCardsMove, {
  can_refresh = function(self, event, target, player, data)
    if player:getMark("@ofl_tx__zhuosheng") ~= 0 then
      for _, move in ipairs(data) do
        if move.to == player and move.toArea == Card.PlayerHand then
          return true
        end
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local n = 0
    for _, move in ipairs(data) do
      if move.to == player and move.toArea == Card.PlayerHand then
        n = n + #move.moveInfo
      end
    end
    local mark = player:getTableMark(zhuosheng.name)
    for _, info in ipairs(mark) do
      info[2] = info[2] + n
    end
    room:setPlayerMark(player, zhuosheng.name, mark)
    if player:getMark("@ofl_tx__zhuosheng") ~= "quest_succeed" then
      local orig, new = player:getMark("@ofl_tx__zhuosheng"), ""
      local n1 = tonumber(string.sub(orig, 1, 1))
      if n1 + n >= 5 then
        new = "quest_succeed"
      else
        new = tostring(n1 + n).."/5"
      end
      room:setPlayerMark(player, "@ofl_tx__zhuosheng", new)
    end
  end
})

zhuosheng:addEffect(fk.TurnEnd, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@ofl_tx__zhuosheng") ~= 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@ofl_tx__zhuosheng", 0)
    local mark = player:getTableMark(zhuosheng.name)
    room:setPlayerMark(player, zhuosheng.name, 0)
    for _, info in ipairs(mark) do
      if player.dead then return end
      if info[2] > 4 then
        room:changeMaxHp(player, 1)
        if player.dead then return end
        room:recover{
          who = player,
          num = 1,
          recoverBy = player,
          skillName = zhuosheng.name,
        }
        if player.dead then return end
        local src = room:getPlayerById(info[1])
        if not src.dead then
          room:doIndicate(src, {player})
          local card = room:askToCards(player, {
            min_num = 1,
            max_num = 1,
            include_equip = true,
            skill_name = zhuosheng.name,
            pattern = ".|.|.|.|.|^basic",
            prompt = "#ofl_tx__zhuosheng-give:"..src.id,
            cancelable = false,
          })
          if #card > 0 then
            room:moveCardTo(card, Card.PlayerHand, src, fk.ReasonGive, zhuosheng.name, nil, false, player)
          end
        end
      end
    end
  end
})

return zhuosheng
