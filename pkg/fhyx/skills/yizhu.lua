
local yizhu = fk.CreateSkill {
  name = "ofl_shiji__yizhu",
}

Fk:loadTranslationTable{
  ["ofl_shiji__yizhu"] = "遗珠",
  [":ofl_shiji__yizhu"] = "结束阶段，你可以依次将至多两张花色不同的红色牌正面朝上置于牌堆顶前X张的任意位置（X为角色数）。"..
  "当其他角色获得“遗珠”牌后，你可以与其各摸一张牌。",

  ["ofl_shiji__yizhu_active"] = "遗珠",
  ["#ofl_shiji__yizhu-put"] = "遗珠：将一张%arg牌置于牌堆前%arg2张的位置，其他角色获得遗珠牌后你可以与其各摸一张牌",
  ["#ofl_shiji__yizhu_toast"] = "%from 将 %card 置于牌堆顶第%arg张",
  ["#ofl_shiji__yizhu-invoke"] = "遗珠：是否与 %dest 各摸一张牌？",

  ["$ofl_shiji__yizhu1"] = "尝闻日久可消愁思，然却难愈遗珠之痛。",
  ["$ofl_shiji__yizhu2"] = "乱世天子尚如浮萍，更况吾女天香国色。",
}

yizhu:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yizhu.name) and player.phase == Player.Finish and
      not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local num = math.min(#room.players, #room.draw_pile)
    local success, dat = room:askToUseActiveSkill(player, {
      skill_name = "ofl_shiji__yizhu_active",
      prompt = "#ofl_shiji__yizhu-put:::red:"..num,
      cancelable = true,
      extra_data = {
        ofl_shiji__yizhu_pattern = ".|.|heart,diamond",
        ofl_shiji__yizhu_num = num,
      }
    })
    if success and dat then
      event:setCostData(self, {cards = dat.cards, choice = dat.interaction})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = event:getCostData(self).cards
    local choice = event:getCostData(self).choice
    room:moveCards({
      ids = cards,
      from = player,
      toArea = Card.DrawPile,
      moveReason = fk.ReasonJustMove,
      skillName = yizhu.name,
      drawPilePosition = choice,
    })
    room:sendLog{
      type = "#ofl_shiji__yizhu_toast",
      from = player.id,
      arg = choice,
      card = cards,
      toast = true,
    }
    if not player.dead then
      room:addTableMarkIfNeed(player, "ofl_shiji__yizhu_cards", cards[1])
    end
    if player.dead or player:isNude() then return end
    local arg, pattern = "log_heart", ".|.|heart"
    if Fk:getCardById(cards[1]).suit == Card.Heart then
      arg, pattern = "log_diamond", ".|.|diamond"
    end
    local num = math.min(#room.players, #room.draw_pile)
    local success, dat = room:askToUseActiveSkill(player, {
      skill_name = "ofl_shiji__yizhu_active",
      prompt = "#ofl_shiji__yizhu-put:::"..arg..":"..num,
      cancelable = true,
      extra_data = {
        ofl_shiji__yizhu_pattern = pattern,
        ofl_shiji__yizhu_num = num,
      }
    })
    if success and dat then
      room:moveCards({
        ids = dat.cards,
        from = player,
        toArea = Card.DrawPile,
        moveReason = fk.ReasonJustMove,
        skillName = yizhu.name,
        drawPilePosition = dat.interaction,
      })
      room:sendLog{
        type = "#ofl_shiji__yizhu_toast",
        from = player.id,
        arg = dat.interaction,
        card = dat.cards,
        toast = true,
      }
      if not player.dead then
        room:addTableMarkIfNeed(player, "ofl_shiji__yizhu_cards", dat.cards[1])
      end
    end
  end,
})

yizhu:addEffect(fk.AfterCardsMove, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    local mark = player:getTableMark("ofl_shiji__yizhu_cards")
    if #mark > 0 then
      for _, move in ipairs(data) do
        for _, info in ipairs(move.moveInfo) do
          if table.contains(mark, info.cardId) then
            return true
          end
        end
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    local room = player.room
    local tos = {}
    for _, move in ipairs(data) do
      for _, info in ipairs(move.moveInfo) do
        if room:removeTableMark(player, "ofl_shiji__yizhu_cards", info.cardId) then
          if move.to and move.toArea == Card.PlayerHand then
            table.insertIfNeed(tos, move.to)
          end
        end
      end
    end
    if #tos > 0 then
      for _, to in ipairs(tos) do
        if not player:hasSkill(yizhu.name) then break end
        if not to.dead then
          event:setCostData(self, {tos = {to}})
          self:doCost(event, target, player, data)
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = yizhu.name,
      prompt = "#ofl_shiji__yizhu-invoke::"..event:getCostData(self).tos[1].id,
    })
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, yizhu.name)
    local to = event:getCostData(self).tos[1]
    if not to.dead then
      to:drawCards(1, yizhu.name)
    end
  end,
})

return yizhu
