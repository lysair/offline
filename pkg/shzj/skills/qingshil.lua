local qingshil = fk.CreateSkill {
  name = "qingshil",
}

Fk:loadTranslationTable{
  ["qingshil"] = "倾师",
  [":qingshil"] = "准备阶段，你可以令至多你体力值数量的角色进行议事，若结果为：红色，直到本轮结束，意见为红色的角色与除其以外的角色互相"..
  "计算距离+1；黑色，你摸意见为黑色的角色数量的牌，然后你可以交给任意名意见为黑色的其他角色各一张牌。<br>"..
  "游戏开始时，将<a href=':shzj__dragon_phoenix'>【飞龙夺凤】</a>置入你的装备区。",

  ["#qingshil-choose"] = "倾师：你可以令至多%arg名角色议事",
  ["#qingshil-give"] = "倾师：你可以交给其中任意名角色各一张牌",
  ["@@qingshil-round"] = "倾师",
}

local U = require "packages/utility/utility"

qingshil:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(qingshil.name) and player.phase == Player.Start and
      table.find(player.room.alive_players, function(p)
        return not p:isKongcheng()
      end) and player.hp > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function(p)
      return not p:isKongcheng()
    end)
    local tos = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = player.hp,
      targets = targets,
      skill_name = qingshil.name,
      prompt = "#qingshil-choose:::"..player.hp,
      cancelable = true,
    })
    if #tos > 0 then
      room:sortByAction(tos)
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = event:getCostData(self).tos
    local discussion = U.Discussion(player, targets, qingshil.name)
    if discussion.color == "red" then
      for _, p in ipairs(targets) do
        if not p.dead and discussion.results[p].opinion == "red" then
          room:setPlayerMark(p, "@@qingshil-round", 1)
        end
      end
    elseif discussion.color == "black" then
      if player.dead then return end
      local n = #table.filter(targets, function (p)
        return discussion.results[p].opinion == "black"
      end)
      player:drawCards(n, qingshil.name)
      if player.dead or player:isNude() then return end
      targets = table.filter(targets, function (p)
        return discussion.results[p].opinion == "black" and not p.dead and p ~= player
      end)
      if #targets == 0 then return end
      room:askToYiji(player, {
        cards = player:getCardIds("he"),
        targets = targets,
        skill_name = qingshil.name,
        min_num = 0,
        max_num = #targets,
        prompt = "#qingshil-give",
        single_max = 1,
      })
    end
  end,
})

qingshil:addEffect(fk.GameStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(qingshil.name) and player:hasEmptyEquipSlot(Card.SubtypeWeapon)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local id = room:printCard("shzj__dragon_phoenix", Card.Spade, 2).id
    room:moveCardIntoEquip(player, id, qingshil.name, false, player)
  end,
})

qingshil:addEffect("distance", {
  correct_func = function(self, from, to)
    local ret = 0
    if from:getMark("@@qingshil-round") > 0 then
      ret = ret + 1
    end
    if to:getMark("@@qingshil-round") > 0 then
      ret = ret + 1
    end
    return ret
  end,
})

return qingshil
