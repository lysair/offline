local ofl__yanmouz = fk.CreateSkill {
  name = "ofl__yanmouz"
}

Fk:loadTranslationTable{
  ['ofl__yanmouz'] = '炎谋',
  ['#ofl__yanmouz-invoke'] = '炎谋：你可以获得其中的【火攻】和火【杀】',
  ['#ofl__yanmouz-use'] = '炎谋：你可以使用其中一张【火攻】或火【杀】',
  ['#ofl__yanmouz-choose'] = '炎谋：选择要获得的牌',
  [':ofl__yanmouz'] = '当其他角色的【火攻】、火【杀】因弃置或判定而置入弃牌堆后，你可以获得之；当你获得牌后，你可以使用其中一张【火攻】或火【杀】。',
}

ofl__yanmouz:addEffect(fk.AfterCardsMove, {
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(ofl__yanmouz.name) then
      local dat = 1
      local ids = {}
      local room = player.room
      for _, move in ipairs(data) do
        if move.toArea == Card.DiscardPile then
          if move.moveReason == fk.ReasonDiscard and move.from and move.from ~= player.id then
            for _, info in ipairs(move.moveInfo) do
              if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
                (Fk:getCardById(info.cardId).name == "fire__slash" or Fk:getCardById(info.cardId).trueName == "fire_attack") and
                room:getCardArea(info.cardId) == Card.DiscardPile then
                table.insertIfNeed(ids, info.cardId)
              end
            end
          elseif move.moveReason == fk.ReasonJudge then
            local judge_event = room.logic:getCurrentEvent():findParent(GameEvent.Judge)
            if judge_event and judge_event.data[1].who ~= player then
              for _, info in ipairs(move.moveInfo) do
                if info.fromArea == Card.Processing and
                  (Fk:getCardById(info.cardId).name == "fire__slash" or Fk:getCardById(info.cardId).trueName == "fire_attack") and
                  room:getCardArea(info.cardId) == Card.DiscardPile then
                  table.insertIfNeed(ids, info.cardId)
                end
              end
            end
          end
        elseif move.to == player.id and move.toArea == Player.Hand then
          for _, info in ipairs(move.moveInfo) do
            if (Fk:getCardById(info.cardId).name == "fire__slash" or Fk:getCardById(info.cardId).trueName == "fire_attack") then
              table.insertIfNeed(ids, info.cardId)
              dat = 2
            end
          end
        end
      end
      ids = U.moveCardsHoldingAreaCheck(room, ids)
      if #ids > 0 then
        event:setCostData(self, {ids, dat})
        return true
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cost_data = event:getCostData(self)
    if cost_data[2] == 1 then
      return room:askToSkillInvoke(player, {
        skill_name = ofl__yanmouz.name,
        prompt = "#ofl__yanmouz-invoke",
      })
    else
      local use = room:askToUseRealCard(player, {
        pattern = cost_data[1],
        skill_name = ofl__yanmouz.name,
        prompt = "#ofl__yanmouz-use",
        extra_data = {
          bypass_times = true,
          extraUse = true,
        },
        cancelable = false,
      })
      if use then
        event:setCostData(self, {use, 2})
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cost_data = event:getCostData(self)
    if cost_data[2] == 1 then
      local ids = table.simpleClone(cost_data[1])
      if #ids == 0 then return end
      local cards, _ = U.askforChooseCardsAndChoice(player, ids, {"OK"}, ofl__yanmouz.name, "#ofl__yanmouz-choose", {"get_all"}, 1, #ids)
      if #cards > 0 then
        ids = cards
      end
      room:moveCardTo(ids, Card.PlayerHand, player, fk.ReasonPrey, ofl__yanmouz.name)
    else
      room:useCard(table.simpleClone(cost_data[1]))
    end
  end,
})

return ofl__yanmouz
