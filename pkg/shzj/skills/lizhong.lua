local lizhong = fk.CreateSkill {
  name = "lizhong",
}

Fk:loadTranslationTable{
  ["lizhong"] = "厉众",
  [":lizhong"] = "结束阶段，你可以选择任意项：1.将任意张装备牌置入任意名角色的装备区；2.令你或任意名装备区里有牌的角色各摸一张牌，"..
  "以此法摸牌的角色本轮内手牌上限+2且可以将装备区里的牌当【无懈可击】使用。",

  ["#lizhong-invoke"] = "厉众：你可以将装备牌置入一名角色的装备区",
  ["#lizhong-choose"] = "厉众：令你或装备区有牌的角色各摸一张牌，本轮手牌上限+2且可以将装备当【无懈可击】使用",
  ["@@lizhong-round"] = "厉众",
}

lizhong:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(lizhong.name) and player.phase == Player.Finish
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if not player:isNude() then
      local success, dat = room:askToUseActiveSkill(player, {
        skill_name = "lizhong_active",
        prompt = "#lizhong-invoke",
        cancelable = true,
      })
      if success and dat then
        event:setCostData(self, { cards = dat.cards, tos = dat.targets, choice = 1 })
        return true
      end
    end
    local targets = table.filter(room.alive_players, function (p)
      return #p:getCardIds("e") > 0 or p == player
    end)
    local tos = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 10,
      targets = targets,
      skill_name = lizhong.name,
      prompt = "#lizhong-choose",
      cancelable = true,
    })
    if #tos > 0 then
      room:sortByAction(tos)
      event:setCostData(self, {tos = tos, choice = 2})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choice = event:getCostData(self).choice
    if choice == 1 then
      local to = event:getCostData(self).tos[1]
      room:moveCardIntoEquip(to, event:getCostData(self).cards, lizhong.name, false, player)
      while not player.dead and not player:isNude() do
        local success, dat = room:askToUseActiveSkill(player, {
          skill_name = "lizhong_active",
          prompt = "#lizhong-invoke",
          cancelable = true,
        })
        if success and dat then
          room:moveCardIntoEquip(dat.targets[1], dat.cards, lizhong.name, false, player)
        else
          break
        end
      end
      if player.dead then return end
    end
    local tos = event:getCostData(self).tos
    if choice == 1 then
      tos = table.filter(room.alive_players, function (p)
        return #p:getCardIds("e") > 0 or p == player
      end)
      tos = room:askToChoosePlayers(player, {
        min_num = 1,
        max_num = 10,
        targets = tos,
        skill_name = lizhong.name,
        prompt = "#lizhong-choose",
        cancelable = true,
      })
    end
    if #tos > 0 then
      room:sortByAction(tos)
      for _, p in ipairs(tos) do
        if not p.dead then
          p:drawCards(1, lizhong.name)
          if not p.dead then
            if p:getMark("@@lizhong-round") == 0 then
              room:setPlayerMark(p, "@@lizhong-round", 1)
              room:addPlayerMark(p, "AddMaxCards-round", 2)
            end
            if not p:hasSkill("lizhong&") then
              room:handleAddLoseSkills(p, "lizhong&", nil, false, true)
              room.logic:getCurrentEvent():findParent(GameEvent.Round):addCleaner(function()
                room:handleAddLoseSkills(p, "-lizhong&", nil, false, true)
              end)
            end
          end
        end
      end
    end
  end,
})

return lizhong
