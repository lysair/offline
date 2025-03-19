-- <这里是你重构后的代码>
local ofl_shiji__yizhu = fk.CreateSkill {
  name = "ofl_shiji__yizhu"
}

Fk:loadTranslationTable{
  ['ofl_shiji__yizhu'] = '遗珠',
  ['ofl_shiji__yizhu_active'] = '遗珠',
  ['#ofl_shiji__yizhu_toast'] = '%from 将 %card 置于牌堆顶第%arg张',
  ['#ofl_shiji__yizhu-put'] = '遗珠：你可以将一张%arg牌置于牌堆前%arg2张的位置，其他角色获得遗珠牌后你可以与其各摸一张牌',
  ['#ofl_shiji__yizhu-invoke'] = '遗珠：是否与 %dest 各摸一张牌？',
  [':ofl_shiji__yizhu'] = '结束阶段，你可以依次将至多两张花色不同的红色牌正面朝上置于牌堆顶前X张的任意位置（X为角色数）。当其他角色获得“遗珠”牌后，你可以与其各摸一张牌。',
  ['$ofl_shiji__yizhu1'] = '尝闻日久可消愁思，然却难愈遗珠之痛。',
  ['$ofl_shiji__yizhu2'] = '乱世天子尚如浮萍，更况吾女天香国色。',
}

-- 主技能
ofl_shiji__yizhu:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player)
    return target == player and player:hasSkill(ofl_shiji__yizhu.name) and player.phase == Player.Finish and not player:isNude()
  end,
  on_cost = function(self, event, target, player)
    local room = player.room
    local num = math.min(#room.players, #room.draw_pile)
    room:setPlayerMark(player, "ofl_shiji__yizhu-tmp", {".|.|heart,diamond", num})
    local success, dat = room:askToUseActiveSkill(player, {
      skill_name = "ofl_shiji__yizhu_active",
      prompt = "#ofl_shiji__yizhu-put:::red:"..num,
      cancelable = true
    })
    room:setPlayerMark(player, "ofl_shiji__yizhu-tmp", 0)
    if success and dat then
      event:setCostData(self, {cards = dat.cards, choice = dat.interaction})
      return true
    end
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    room:moveCards({
      ids = event:getCostData(self).cards,
      from = player.id,
      toArea = Card.DrawPile,
      moveReason = fk.ReasonJustMove,
      skillName = ofl_shiji__yizhu.name,
      drawPilePosition = tonumber(event:getCostData(self).choice),
    })
    room:sendLog{
      type = "#ofl_shiji__yizhu_toast",
      from = player.id,
      arg = event:getCostData(self).choice,
      card = event:getCostData(self).cards,
      toast = true,
    }
    if not player.dead then
      room:addTableMark(player, "ofl_shiji__yizhu_cards", event:getCostData(self).cards[1])
    end
    if player.dead or player:isNude() then return end
    local arg, pattern = "log_heart", ".|.|heart"
    if Fk:getCardById(event:getCostData(self).cards[1]).suit == Card.Heart then
      arg, pattern = "log_diamond", ".|.|diamond"
    end
    local num = math.min(#room.players, #room.draw_pile)
    room:setPlayerMark(player, "ofl_shiji__yizhu-tmp", {pattern, num})
    local success, dat = room:askToUseActiveSkill(player, {
      skill_name = "ofl_shiji__yizhu_active",
      prompt = "#ofl_shiji__yizhu-put:::"..arg..":"..num,
      cancelable = true
    })
    room:setPlayerMark(player, "ofl_shiji__yizhu-tmp", 0)
    if success and dat then
      room:moveCards({
        ids = dat.cards,
        from = player.id,
        toArea = Card.DrawPile,
        moveReason = fk.ReasonJustMove,
        skillName = ofl_shiji__yizhu.name,
        drawPilePosition = tonumber(dat.interaction),
      })
      room:sendLog{
        type = "#ofl_shiji__yizhu_toast",
        from = player.id,
        arg = dat.interaction,
        card = dat.cards,
        toast = true,
      }
      if not player.dead then
        room:addTableMark(player, "ofl_shiji__yizhu_cards", dat.cards[1])
      end
    end
  end,
})

-- 触发技
ofl_shiji__yizhu:addEffect(fk.AfterCardsMove, {
  mute = true,
  can_trigger = function(self, event, target, player)
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
  on_trigger = function(self, event, target, player)
    local room = player.room
    local mark = player:getTableMark("ofl_shiji__yizhu_cards")
    local tos = {}
    if #mark > 0 then
      for _, move in ipairs(data) do
        for _, info in ipairs(move.moveInfo) do
          if table.contains(mark, info.cardId) then
            room:removeTableMark(player, "ofl_shiji__yizhu_cards", info.cardId)
            if move.to and move.toArea == Card.PlayerHand then
              table.insert(tos, move.to)
            end
          end
        end
      end
    end
    if #tos > 0 then
      for _, id in ipairs(tos) do
        if player.dead then break end
        local to = room:getPlayerById(id)
        if not to.dead then
          self:doCost(event, to, player, data)
        end
      end
    end
  end,
  on_cost = function(self, event, target, player)
    return player.room:askToSkillInvoke(player, {skill_name = "ofl_shiji__yizhu", prompt = "#ofl_shiji__yizhu-invoke::"..target.id})
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    player:broadcastSkillInvoke("ofl_shiji__yizhu")
    room:notifySkillInvoked(player, "ofl_shiji__yizhu", "support")
    player:drawCards(1, ofl_shiji__yizhu.name)
    if not target.dead then
      target:drawCards(1, ofl_shiji__yizhu.name)
    end
  end,
})

return ofl_shiji__yizhu
