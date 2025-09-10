local zhongen = fk.CreateSkill {
  name = "zhongen",
}

Fk:loadTranslationTable{
  ["zhongen"] = "忠恩",
  [":zhongen"] = "一名角色的结束阶段，若你本回合失去或获得过手牌，你可以将一张【杀】当【无中生有】对其使用，或使用一张无距离限制的【杀】。",

  ["zhongen_ex_nihilo"] = "将一张【杀】当【无中生有】对%dest使用",
  ["zhongen_slash"] = "使用一张无距离限制的【杀】",
  ["#zhongen-ex_nihilo"] = "忠恩：将一张【杀】当【无中生有】对 %dest 使用",
  ["#zhongen-slash"] = "忠恩：使用一张无距离限制的【杀】",
}

zhongen:addEffect(fk.EventPhaseStart, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(zhongen.name) and target.phase == Player.Finish and
      #player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
        for _, move in ipairs(e.data) do
          if move.to == player and move.toArea == Card.PlayerHand then
            return true
          end
          if move.from == player then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.PlayerHand then
                return true
              end
            end
          end
        end
      end, Player.HistoryTurn) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local all_choices = {"zhongen_ex_nihilo::"..target.id, "zhongen_slash", "Cancel"}
    local choices = table.simpleClone(all_choices)
    if target.dead then
      table.remove(choices, 1)
    end
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = zhongen.name,
      all_choices = all_choices,
    })
    if choice == "zhongen_ex_nihilo::"..target.id then
      local cards = table.filter(player:getHandlyIds(), function (id)
        if Fk:getCardById(id).trueName ~= "slash" then
          return false
        end

        local card = Fk:cloneCard("ex_nihilo")
        card:addSubcard(id)
        return not player:isProhibited(target, card)
      end)
      cards = room:askToCards(player, {
        min_num = 1,
        max_num = 1,
        include_equip = false,
        skill_name = zhongen.name,
        pattern = tostring(Exppattern{ id = cards }),
        prompt = "#zhongen-ex_nihilo::"..target.id,
        cancelable = true,
      })
      if #cards > 0 then
        event:setCostData(self, {cards = cards, choice = 1})
        return true
      end
    elseif choice == "zhongen_slash" then
      local use = room:askToUseCard(player, {
        skill_name = zhongen.name,
        pattern = "slash",
        prompt = "#zhongen-slash",
        extra_data = {
          bypass_distances = true,
          bypass_times = true,
        }
      })
      if use then
        use.extraUse = true
        event:setCostData(self, {extra_data = use, choice = 2})
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(zhongen.name)
    local choice = event:getCostData(self).choice
    if choice == 1 then
      room:notifySkillInvoked(player, zhongen.name, "support")
      room:useVirtualCard("ex_nihilo", event:getCostData(self).cards, player, target, zhongen.name)
    else
      room:notifySkillInvoked(player, zhongen.name, "offensive")
      room:useCard(event:getCostData(self).extra_data)
    end
  end,
})

return zhongen
