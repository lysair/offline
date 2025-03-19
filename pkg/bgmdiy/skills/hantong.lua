local hantong = fk.CreateSkill {
  name = "hantong"
}

Fk:loadTranslationTable{
  ['hantong'] = '汉统',
  ['#hantong-active'] = '汉统：你可以移去一张“诏”，本回合获得〖护驾〗，〖激将〗，〖救援〗或〖血裔〗',
  ['bgm_edict'] = '诏',
  ['#hantong_trigger'] = '汉统',
  ['#hantong-invoke'] = '汉统：你可以将此阶段内弃置的牌置于武将牌上称为“诏”',
  ['#hantong-cost'] = '汉统：你可以移去一张“诏”，获得〖%arg〗直到回合结束',
  ['#hantong-two'] = '汉统：你可以移去至多两张“诏”，获得〖护驾〗或〖激将〗直到回合结束',
  ['#hantong-choice'] = '汉统：选择你要获得的技能',
  [':hantong'] = '弃牌阶段结束时，你可以将此阶段内你因游戏规则弃置的牌置于武将牌上，称为“诏”。你可以移去一张“诏”，获得〖护驾〗，〖激将〗，〖救援〗或〖血裔〗直到回合结束。 ',
}

hantong:addEffect('active', {
  card_num = 1,
  target_num = 0,
  prompt = "#hantong-active",
  expand_pile = "bgm_edict",
  derived_piles = "bgm_edict",
  interaction = function(self)
    local names = table.filter({"jijiang","hujia","xueyi","jiuyuan"}, function (skill)
      return not self.player:hasSkill(skill, true)
    end)
    if #names > 0 then
      return UI.ComboBox { choices = names }
    end
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and player:getPileNameOfId(to_select) == "bgm_edict"
  end,
  can_use = function(self, player)
    return #player:getPile("bgm_edict") > 0 and table.find({"jijiang","hujia","xueyi","jiuyuan"}, function (skill)
      return not player:hasSkill(skill, true)
    end)
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:moveCards({
      ids = effect.cards,
      from = player.id,
      toArea = Card.DiscardPile,
      moveReason = fk.ReasonPutIntoDiscardPile,
      skillName = hantong.name,
      proposer = player.id,
    })
    if player.dead then return end
    local skill = self.interaction.data
    room:handleAddLoseSkills(player, skill)
    room.logic:getCurrentEvent():findParent(GameEvent.Turn):addCleaner(function()
      room:handleAddLoseSkills(player, "-"..skill)
    end)
    player:broadcastSkillInvoke(skill)
  end,
})

hantong:addEffect(fk.EventPhaseEnd, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(hantong)) then return end
    if player.phase == Player.Discard then
      local ids = {}
      local logic = player.room.logic
      logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
        for _, move in ipairs(e.data) do
          if move.from == player.id and move.moveReason == fk.ReasonDiscard and move.skillName == "phase_discard" then
            for _, info in ipairs(move.moveInfo) do
              if player.room:getCardArea(info.cardId) == Card.DiscardPile then
                table.insertIfNeed(ids, info.cardId)
              end
            end
          end
        end
        return false
      end, Player.HistoryPhase)
      if #ids > 0 then
        event:setCostData(self, ids)
        return true
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    return room:askToSkillInvoke(player, {skill_name = hantong.name, prompt = "#hantong-invoke"})
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:addToPile("bgm_edict", event:getCostData(self), true, hantong.name)
  end,
})

hantong:addEffect(fk.PreHpRecover, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(hantong)) then return end
    if #player:getPile("bgm_edict") > 0 then
      if not player:hasSkill("jiuyuan", true) and data.card and data.card.trueName == "peach" and
        data.recoverBy and data.recoverBy.kingdom == "wu" and data.recoverBy ~= player then
        event:setCostData(self, {"jiuyuan"})
        return true
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cards = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      pattern = ".|.|.|bgm_edict",
      prompt = "#hantong-cost:::"..event:getCostData(self)[1],
      expand_pile = "bgm_edict"
    })
    if #cards > 0 then
      event:setCostData(self, {cards, event:getCostData(self)})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:moveCards({
      ids = event:getCostData(self)[1],
      from = player.id,
      toArea = Card.DiscardPile,
      moveReason = fk.ReasonPutIntoDiscardPile,
      skillName = hantong.name,
      proposer = player.id,
    })
    if player.dead then return end
    local skills = event:getCostData(self)[2]
    room:handleAddLoseSkills(player, table.concat(skills, "|"))
    room.logic:getCurrentEvent():findParent(GameEvent.Turn):addCleaner(function()
      room:handleAddLoseSkills(player, "-"..table.concat(skills, "|-"))
    end)
  end,
})

hantong:addEffect(fk.EventPhaseStart, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(hantong)) then return end
    if #player:getPile("bgm_edict") > 0 then
      if not player:hasSkill("xueyi", true) and player.phase == Player.Discard
        and table.find(player.room.alive_players, function (p) return p ~= player and p.kingdom == "qun" end) then
        event:setCostData(self, {"xueyi"})
        return true
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cards = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      pattern = ".|.|.|bgm_edict",
      prompt = "#hantong-cost:::"..event:getCostData(self)[1],
      expand_pile = "bgm_edict"
    })
    if #cards > 0 then
      event:setCostData(self, {cards, event:getCostData(self)})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:moveCards({
      ids = event:getCostData(self)[1],
      from = player.id,
      toArea = Card.DiscardPile,
      moveReason = fk.ReasonPutIntoDiscardPile,
      skillName = hantong.name,
      proposer = player.id,
    })
    if player.dead then return end
    local skills = event:getCostData(self)[2]
    room:handleAddLoseSkills(player, table.concat(skills, "|"))
    room.logic:getCurrentEvent():findParent(GameEvent.Turn):addCleaner(function()
      room:handleAddLoseSkills(player, "-"..table.concat(skills, "|-"))
    end)
  end,
})

hantong:addEffect(fk.AskForCardUse, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(hantong)) then return end
    if #player:getPile("bgm_edict") > 0 then
      local list = {}
      if not player:hasSkill("hujia", true) and (data.extraData == nil or data.extraData.hujia_ask == nil)
        and (data.cardName == "jink" or (data.pattern and Exppattern:Parse(data.pattern):matchExp("jink|0|nosuit|none")))
        and table.find(player.room.alive_players, function (p) return p ~= player and p.kingdom == "wei" end) then
        table.insert(list, "hujia")
      end
      if not player:hasSkill("jijiang", true)
        and (data.cardName == "slash" or (data.pattern and Exppattern:Parse(data.pattern):matchExp("slash|0|nosuit|none")))
        and table.find(player.room.alive_players, function (p) return p ~= player and p.kingdom == "shu" end) then
        table.insert(list, "jijiang")
      end
      if #list > 0 then
        event:setCostData(self, list)
        return true
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local x = 1
    local prompt = "#hantong-cost:::"..event:getCostData(self)[1]
    if #event:getCostData(self) > 1 then
      prompt = "#hantong-two"
      x = 2
    end
    local cards = room:askToCards(player, {
      min_num = 1,
      max_num = x,
      pattern = ".|.|.|bgm_edict",
      prompt = prompt,
      expand_pile = "bgm_edict"
    })
    if #cards > 0 then
      local choices = (#cards == #event:getCostData(self)) and event:getCostData(self) or
      {room:askToChoice(player, {
        choices = event:getCostData(self),
        skill_name = hantong.name,
        prompt = "#hantong-choice"
      })}
      event:setCostData(self, {cards, choices})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:moveCards({
      ids = event:getCostData(self)[1],
      from = player.id,
      toArea = Card.DiscardPile,
      moveReason = fk.ReasonPutIntoDiscardPile,
      skillName = hantong.name,
      proposer = player.id,
    })
    if player.dead then return end
    local skills = event:getCostData(self)[2]
    room:handleAddLoseSkills(player, table.concat(skills, "|"))
    room.logic:getCurrentEvent():findParent(GameEvent.Turn):addCleaner(function()
      room:handleAddLoseSkills(player, "-"..table.concat(skills, "|-"))
    end)
  end,
})

return hantong
