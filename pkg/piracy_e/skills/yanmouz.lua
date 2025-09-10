local yanmouz = fk.CreateSkill {
  name = "ofl__yanmouz",
}

Fk:loadTranslationTable{
  ["ofl__yanmouz"] = "炎谋",
  [":ofl__yanmouz"] = "当其他角色的【火攻】、火【杀】因弃置或判定而置入弃牌堆后，你可以获得之；当你获得牌后，你可以使用其中一张【火攻】或火【杀】。",

  ["#ofl__yanmouz-invoke"] = "炎谋：你可以获得这些【火攻】和火【杀】",
  ["#ofl__yanmouz-use"] = "炎谋：你可以使用其中一张【火攻】或火【杀】",
}

yanmouz:addEffect(fk.AfterCardsMove, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(yanmouz.name) then
      local ids1 = {}
      local ids2 = {}
      for _, move in ipairs(data) do
        if move.toArea == Card.DiscardPile then
          if move.moveReason == fk.ReasonDiscard and move.from and move.from ~= player then
            for _, info in ipairs(move.moveInfo) do
              if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
                (Fk:getCardById(info.cardId).name == "fire__slash" or Fk:getCardById(info.cardId).trueName == "fire_attack") and
                table.contains(player.room.discard_pile, info.cardId) then
                table.insertIfNeed(ids1, info.cardId)
              end
            end
          elseif move.moveReason == fk.ReasonJudge then
            local judge_event = player.room.logic:getCurrentEvent():findParent(GameEvent.Judge)
            if judge_event and judge_event.data.who ~= player then
              for _, info in ipairs(move.moveInfo) do
                if info.fromArea == Card.Processing and
                  (Fk:getCardById(info.cardId).name == "fire__slash" or Fk:getCardById(info.cardId).name == "fire_attack") and
                  table.contains(player.room.discard_pile, info.cardId) then
                  table.insertIfNeed(ids1, info.cardId)
                end
              end
            end
          end
        elseif move.to == player and move.toArea == Player.Hand then
          for _, info in ipairs(move.moveInfo) do
            if Fk:getCardById(info.cardId).name == "fire__slash" or Fk:getCardById(info.cardId).name == "fire_attack" then
              table.insertIfNeed(ids2, info.cardId)
            end
          end
        end
      end
      ids1 = player.room.logic:moveCardsHoldingAreaCheck(ids1)
      if #ids1 > 0 or #ids2 > 0 then
        event:setCostData(self, {ids1 = ids1, ids2 = ids2})
        return true
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local dat = event:getCostData(self)
    if #dat.ids1 > 0 then
      if room:askToSkillInvoke(player, {
        skill_name = yanmouz.name,
        prompt = "#ofl__yanmouz-invoke",
      }) then
        event:setCostData(self, {choice = 1, ids1 = dat.ids1, ids2 = dat.ids2})
        return true
      end
    end
    if #dat.ids2 > 0 then
      local use = room:askToUseRealCard(player, {
        pattern = tostring(Exppattern{ id = dat.ids2 }),
        skill_name = yanmouz.name,
        prompt = "#ofl__yanmouz-use",
        extra_data = {
          bypass_times = true,
          extraUse = true,
        },
        cancelable = true,
        skip = true,
      })
      if use then
        event:setCostData(self, {choice = 2, extra_data = use})
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local use
    if event:getCostData(self).choice == 1 then
      local ids = table.simpleClone(event:getCostData(self).ids1)
      room:moveCardTo(ids, Card.PlayerHand, player, fk.ReasonJustMove, yanmouz.name)
      if not player.dead then
        ids = event:getCostData(self).ids2
        ids = table.filter(ids, function(id)
          return table.contains(player:getCardIds("h"), id) and
            (Fk:getCardById(id).name == "fire__slash" or Fk:getCardById(id).name == "fire_attack")
        end)
        if #ids > 0 then
          use = room:askToUseRealCard(player, {
            pattern = tostring(Exppattern{ id = ids }),
            skill_name = yanmouz.name,
            prompt = "#ofl__yanmouz-use",
            extra_data = {
              bypass_times = true,
              extraUse = true,
            },
            cancelable = true,
            skip = true,
          })
        end
      end
    else
      use = event:getCostData(self).extra_data
    end
    if use then
      room:useCard(use)
    end
  end,
})

return yanmouz
