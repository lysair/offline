local jinzhong = fk.CreateSkill {
  name = "jinzhong",
}

Fk:loadTranslationTable{
  ["jinzhong"] = "尽忠",
  [":jinzhong"] = "出牌阶段开始时或当你受到伤害后，你可以选择一项：1.失去1点体力，令一号位或刘备回复1点体力；2.交给一名角色至多两张手牌。",

  ["jinzhong_recover"] = "失去1点体力，令一号位或刘备回复1点体力",
  ["jinzhong_give"] = "交给一名角色至多两张手牌",
  ["#jinzhong-choose"] = "尽忠：失去1点体力，令一号位或刘备回复1点体力",
  ["#jinzhong-give"] = "尽忠：交给一名角色至多两张手牌",
}

local spec = {
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local choices = {}
    if not player:isKongcheng() and #player.room:getOtherPlayers(player, false) > 0 then
      table.insert(choices, "jinzhong_give")
    end
    local targets = {}
    if player.hp > 0 then
      targets = table.filter(room.alive_players, function (p)
        return p:isWounded() and (string.find(p.general, "liubei") ~= nil or string.find(p.deputyGeneral, "liubei") ~= nil)
      end)
      if room:getPlayerBySeat(1):isWounded() and not room:getPlayerBySeat(1).dead then
        table.insert(targets, room:getPlayerBySeat(1))
      end
    end
    if #targets > 0 then
      table.insert(choices, "jinzhong_recover")
    end
    table.insert(choices, "Cancel")
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = jinzhong.name,
    })
    if choice ~= "Cancel" then
      if choice == "jinzhong_give" then
        local to, cards = room:askToChooseCardsAndPlayers(player, {
          min_card_num = 1,
          max_card_num = 2,
          min_num = 1,
          max_num = 1,
          targets = room:getOtherPlayers(player, false),
          pattern = ".|.|.|hand",
          skill_name = jinzhong.name,
          prompt = "#jinzhong-give",
          cancelable = true,
        })
        if #to > 0 and #cards > 0 then
          event:setCostData(self, {tos = to, cards = cards})
          return true
        end
      else
        local to = room:askToChoosePlayers(player, {
          min_num = 1,
          max_num = 1,
          targets = targets,
          skill_name = jinzhong.name,
          prompt = "#jinzhong-choose",
          cancelable = true,
        })
        if #to > 0 then
          event:setCostData(self, {tos = to})
          return true
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local cards = event:getCostData(self).cards or {}
    if #cards == 0 then
      room:loseHp(player, 1, jinzhong.name)
      if not to.dead then
        room:recover{
          who = to,
          num = 1,
          recoverBy = player,
          skillName = jinzhong.name,
        }
      end
    else
      room:moveCardTo(cards, Card.PlayerHand, to, fk.ReasonGive, jinzhong.name, nil, false, player)
    end
  end,
}

jinzhong:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(jinzhong.name) and player.phase == Player.Start then
      if not player:isKongcheng() and #player.room:getOtherPlayers(player, false) > 0 then
        return true
      elseif player.hp > 0 then
        if player.room:getPlayerBySeat(1):isWounded() and not player.room:getPlayerBySeat(1).dead then
          return true
        else
          return table.find(player.room.alive_players, function (p)
            return p:isWounded() and (string.find(p.general, "liubei") ~= nil or string.find(p.deputyGeneral, "liubei") ~= nil)
          end)
        end
      end
    end
  end,
  on_cost = spec.on_cost,
  on_use = spec.on_use,
})

jinzhong:addEffect(fk.Damaged, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(jinzhong.name) then
      if not player:isKongcheng() and #player.room:getOtherPlayers(player, false) > 0 then
        return true
      elseif player.hp > 0 then
        if player.room:getPlayerBySeat(1):isWounded() and not player.room:getPlayerBySeat(1).dead then
          return true
        else
          return table.find(player.room.alive_players, function (p)
            return p:isWounded() and (string.find(p.general, "liubei") ~= nil or string.find(p.deputyGeneral, "liubei") ~= nil)
          end)
        end
      end
    end
  end,
  on_cost = spec.on_cost,
  on_use = spec.on_use,
})

return jinzhong
