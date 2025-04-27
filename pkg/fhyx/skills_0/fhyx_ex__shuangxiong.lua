local fhyx_ex__shuangxiong = fk.CreateSkill {
  name = "fhyx_ex__shuangxiong"
}

Fk:loadTranslationTable{
  ['fhyx_ex__shuangxiong'] = '双雄',
  ['@fhyx_ex__shuangxiong-phase'] = '双雄',
  ['#fhyx_ex__shuangxiong'] = '双雄：你可以将一张%arg手牌当【决斗】使用',
  ['#fhyx_ex__shuangxiong_trigger'] = '双雄',
  ['#fhyx_ex__shuangxiong-choose'] = '双雄：令一名角色弃置一张牌，此阶段你可以将与之颜色不同的手牌当【决斗】使用',
  ['#fhyx_ex__shuangxiong-discard'] = '双雄：请弃置一张牌，此阶段 %src 可以将与之颜色不同的手牌当【决斗】使用',
  [':fhyx_ex__shuangxiong'] = '出牌阶段开始时，你可以令一名角色弃置一张牌，若如此做，此阶段你可以将与此牌颜色不同的手牌当【决斗】使用。',
}

-- ViewAsSkill
fhyx_ex__shuangxiong:addEffect('viewas', {
  anim_type = "offensive",
  pattern = "duel",
  prompt = function(self, player)
    local color = "red"
    if player:getMark("@fhyx_ex__shuangxiong-phase") == "red" then
      color = "black"
    end
    return "#fhyx_ex__shuangxiong:::"..color
  end,
  card_filter = function(self, player, to_select, selected)
    if #selected == 1 then return false end
    local color = Fk:getCardById(to_select):getColorString()
    if color == "red" then
      color = "black"
    elseif color == "black" then
      color = "red"
    else
      return false
    end
    return table.contains(player:getHandlyIds(true), to_select) and player:getMark("@fhyx_ex__shuangxiong-phase") == color
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return end
    local c = Fk:cloneCard("duel")
    c:addSubcard(cards[1])
    c.skillName = fhyx_ex__shuangxiong.name
    return c
  end,
  enabled_at_play = function(self, player)
    return player:getMark("@fhyx_ex__shuangxiong-phase") ~= 0
  end,
  enabled_at_response = function(self, player)
    return player:getMark("@fhyx_ex__shuangxiong-phase") ~= 0
  end,
})

-- TriggerSkill
fhyx_ex__shuangxiong:addEffect(fk.EventPhaseStart, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(fhyx_ex__shuangxiong) and player.phase == Player.Play and
      table.find(player.room.alive_players, function(p)
        return not p:isNude()
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(player.room.alive_players, function(p)
      return not p:isNude()
    end)
    local to = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#fhyx_ex__shuangxiong-choose",
      skill_name = fhyx_ex__shuangxiong.name,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("fhyx_ex__shuangxiong")
    room:notifySkillInvoked(player, "fhyx_ex__shuangxiong", "control")
    player:revealBySkillName("fhyx_ex__shuangxiong")
    local to = room:getPlayerById(event:getCostData(self).tos[1])
    local card = room:askToDiscard(to, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = fhyx_ex__shuangxiong.name,
      prompt = "#fhyx_ex__shuangxiong-discard:"..player.id
    })
    if #card > 0 and not player.dead then
      local color = Fk:getCardById(card[1]):getColorString()
      if color ~= "nocolor" then
        room:setPlayerMark(player, "@fhyx_ex__shuangxiong-phase", color)
      end
    end
  end,
})

return fhyx_ex__shuangxiong
