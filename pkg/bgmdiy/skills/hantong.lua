local hantong = fk.CreateSkill {
  name = "hantong",
}

Fk:loadTranslationTable{
  ["hantong"] = "汉统",
  [":hantong"] = "弃牌阶段结束时，你可以将此阶段内你弃置的牌置于武将牌上，称为“诏”。你可以移去一张“诏”发动〖护驾〗〖激将〗〖救援〗〖血裔〗"..
  "并获得对应的技能直到回合结束。 ",

  ["bgm_edict"] = "诏",
  ["#hantong-put"] = "汉统：你可以将此阶段内弃置的牌置为“诏”",
  ["#hantong-invoke"] = "汉统：你可以移去一张“诏”发动“%arg”",
}

hantong:addEffect("viewas", {
  anim_type = "offensive",
  pattern = "slash",
  prompt = "#hantong-invoke:::jijiang",
  expand_pile = "bgm_edict",
  card_filter = function (self, player, to_select, selected)
    return #selected == 0 and table.contains(player:getPile("bgm_edict"), to_select)
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard("slash")
    card.skillName = "jijiang"
    card:addFakeSubcards(cards)
    return card
  end,
  before_use = function(self, player, use)
    local room = player.room
    if #use.tos > 0 and not use.noIndicate then
      room:doIndicate(player, use.tos)
    end
    room:moveCards({
      ids = use.card.fake_subcards,
      from = player,
      toArea = Card.DiscardPile,
      moveReason = fk.ReasonPutIntoDiscardPile,
      skillName = hantong.name,
      proposer = player,
    })
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if p.kingdom == "shu" then
        local respond = room:askToResponse(p, {
          skill_name = "jijiang",
          pattern = "slash",
          prompt = "#jijiang-ask:"..player.id,
          cancelable = true,
        })
        if respond then
          respond.skipDrop = true
          room:responseCard(respond)

          use.card = respond.card
          return
        end
      end
    end
    return "jijiang"
  end,
  enabled_at_play = function(self, player)
    return #player:getPile("bgm_edict") > 0 and
      table.find(Fk:currentRoom().alive_players, function(p)
        return p.kingdom == "shu" and p ~= player
      end)
  end,
  enabled_at_response = function(self, player)
    return #player:getPile("bgm_edict") > 0 and
      table.find(Fk:currentRoom().alive_players, function(p)
        return p.kingdom == "shu" and p ~= player
      end)
  end,
})

hantong:addEffect(fk.EventPhaseEnd, {
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(hantong.name) and  player.phase == Player.Discard then
      local ids = {}
      player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
        for _, move in ipairs(e.data) do
          if move.from == player and move.moveReason == fk.ReasonDiscard then
            for _, info in ipairs(move.moveInfo) do
              if table.contains(player.room.discard_pile, info.cardId) then
                table.insertIfNeed(ids, info.cardId)
              end
            end
          end
        end
      end, Player.HistoryPhase)
      if #ids > 0 then
        event:setCostData(self, {cards = ids})
        return true
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = hantong.name,
      prompt = "#hantong-put",
    })
  end,
  on_use = function(self, event, target, player, data)
    player:addToPile("bgm_edict", event:getCostData(self).cards, true, hantong.name)
  end,
})

local spec_on_cost = function(self, event, target, player, skill_name)
  local room = player.room
  local cards = room:askToCards(player, {
    skill_name = hantong.name,
    min_num = 1,
    max_num = 1,
    pattern = ".|.|.|bgm_edict",
    prompt = "#hantong-invoke:::"..skill_name,
    expand_pile = "bgm_edict",
  })
  if #cards > 0 then
    event:setCostData(self, {cards = cards})
    return true
  end
end

local spec_on_use = function(self, event, target, player, skill_name)
  local room = player.room
  room:moveCards({
    ids = event:getCostData(self).cards,
    from = player,
    toArea = Card.DiscardPile,
    moveReason = fk.ReasonPutIntoDiscardPile,
    skillName = hantong.name,
    proposer = player,
  })
  if player.dead then return end
  room:handleAddLoseSkills(player, skill_name)
  room.logic:getCurrentEvent():findParent(GameEvent.Turn):addCleaner(function()
    room:handleAddLoseSkills(player, "-"..skill_name)
  end)
end

hantong:addEffect(fk.PreHpRecover, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(hantong.name) and
      #player:getPile("bgm_edict") > 0 and not player:hasSkill("jiuyuan", true) then
      player.room:handleAddLoseSkills(player, "jiuyuan", nil, false, true)
      if Fk.skills["jiuyuan"]:triggerable(event, target, player, data) then
        player.room:handleAddLoseSkills(player, "-jiuyuan", nil, false, true)
        return true
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    return spec_on_cost(self, event, target, player, "jiuyuan")
  end,
  on_use = function(self, event, target, player, data)
    spec_on_use(self, event, target, player, "jiuyuan")
  end,
})

hantong:addEffect(fk.EventPhaseStart, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(hantong.name) and player.phase == Player.Discard and
      #player:getPile("bgm_edict") > 0 and not player:hasSkill("xueyi", true)
  end,
  on_cost = function(self, event, target, player, data)
    return spec_on_cost(self, event, target, player, "xueyi")
  end,
  on_use = function(self, event, target, player, data)
    spec_on_use(self, event, target, player, "xueyi")
  end,
})

local hujia_epec = {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(hantong.name) and
      #player:getPile("bgm_edict") > 0 and not player:hasSkill("hujia", true) then
      player.room:handleAddLoseSkills(player, "hujia", nil, false, true)
      if Fk.skills["hujia"]:triggerable(event, target, player, data) then
        player.room:handleAddLoseSkills(player, "-hujia", nil, false, true)
        return true
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    return spec_on_cost(self, event, target, player, "hujia")
  end,
  on_use = function(self, event, target, player, data)
    spec_on_use(self, event, target, player, "hujia")
  end,
}
hantong:addEffect(fk.AskForCardUse, hujia_epec)
hantong:addEffect(fk.AskForCardResponse, hujia_epec)

return hantong
