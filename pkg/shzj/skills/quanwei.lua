local quanwei = fk.CreateSkill {
  name = "quanwei",
}

Fk:loadTranslationTable{
  ["quanwei"] = "权威",
  [":quanwei"] = "准备阶段，你可以展示一张手牌，然后和一名其他角色议事，若议事结果与你展示的牌颜色相同，你依次跳过本回合下任意个阶段，"..
  "令至多两名角色回复等量的体力；否则，你可以减1点体力上限，获得与你意见不同的角色的所有手牌。",

  ["#quanwei-invoke"] = "权威：展示一张手牌，然后和一名角色议事，根据结果与你展示牌颜色是否相同执行效果",
  ["#quanwei-choose"] = "权威：与一名角色议事，根据结果与你展示牌颜色是否相同执行效果",
  ["#quanwei-maxhp"] = "权威：是否减1点体力上限，获得与你意见不同的角色所有手牌？",
  ["#quanwei-choice"] = "权威：你可以跳过本回合下任意个阶段，然后令至多两名角色回复等量体力",
  ["#quanwei-recover"] = "权威：令至多两名角色回复 %arg 点体力",
}

local U = require "packages/utility/utility"

quanwei:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(quanwei.name) and player.phase == Player.Start and
      not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cards = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = quanwei.name,
      prompt = "#quanwei-invoke",
      cancelable = true,
    })
    if #cards > 0 then
      event:setCostData(self, {cards = cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = event:getCostData(self).cards or {}
    local color1 = Fk:getCardById(card[1]):getColorString()
    player:showCards(card)
    if player.dead or player:isKongcheng() then return end
    local targets = table.filter(room:getOtherPlayers(player, false), function (p)
      return not p:isKongcheng()
    end)
    if #targets == 0 then return end
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = quanwei.name,
      prompt = "#quanwei-choose",
      cancelable = false,
    })[1]
    local discussion = U.Discussion(player, {player, to}, quanwei.name)
    if player.dead then return end
    if discussion.color == color1 then
      local current_turn = room.logic:getCurrentEvent():findParent(GameEvent.Turn, true)
      if current_turn == nil then return end
      local n, phase_data = 0 , nil
      for i = current_turn.data.phase_index + 1, #current_turn.data.phase_table, 1 do
        phase_data = current_turn.data.phase_table[i]
        if table.contains({
          Player.Start, Player.Judge, Player.Draw, Player.Play, Player.Discard, Player.Finish,
        }, phase_data.phase) and not phase_data.skipped then
          n = n + 1
        end
      end
      if n == 0 then return end
      local choices = {}
      for i = 1, n, 1 do
        table.insert(choices, tostring(i))
      end
      table.insert(choices, "Cancel")
      local choice = room:askToChoice(player, {
        choices = choices,
        skill_name = quanwei.name,
        prompt = "#quanwei-choice",
      })
      if choice == "Cancel" then return end
      choice = tonumber(choice)
      room:setPlayerMark(player, "quanwei-turn", choice)
      targets = table.filter(room.alive_players, function (p)
        return p:isWounded()
      end)
      if #targets == 0 then return end
      local tos = room:askToChoosePlayers(player, {
        min_num = 1,
        max_num = 2,
        targets = targets,
        skill_name = quanwei.name,
        prompt = "#quanwei-recover:::"..choice,
        cancelable = true,
      })
      if #tos > 0 then
        room:sortByAction(tos)
        for _, p in ipairs(tos) do
          if not p.dead then
            room:recover{
              who = p,
              num = choice,
              recoverBy = player,
              skillName = quanwei.name,
            }
          end
        end
      end
    elseif room:askToSkillInvoke(player, {
        skill_name = quanwei.name,
        prompt = "#quanwei-maxhp",
      }) then
      room:changeMaxHp(player, -1)
      if player.dead then return end
      if not to:isKongcheng() and discussion.results[to].opinion ~= discussion.results[player].opinion then
        room:moveCardTo(to:getCardIds("h"), Card.PlayerHand, player, fk.ReasonPrey, quanwei.name, nil, false, player)
      end
    end
  end,
})

quanwei:addEffect(fk.EventPhaseChanging, {
  can_refresh = function (self, event, target, player, data)
    return target == player and player:getMark("quanwei-turn") > 0 and
      table.contains({
        Player.Start, Player.Judge, Player.Draw, Player.Play, Player.Discard, Player.Finish,
      }, data.phase) and not data.skipped
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:removePlayerMark(player, "quanwei-turn", 1)
    data.skipped = true
  end,
})

return quanwei
