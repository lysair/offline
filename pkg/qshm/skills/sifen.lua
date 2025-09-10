local sifen = fk.CreateSkill{
  name = "sifen",
}

Fk:loadTranslationTable{
  ["sifen"] = "俟奋",
  [":sifen"] = "出牌阶段限一次，你可以令一名其他角色将任意张牌当一张【决斗】使用，然后你摸两张牌，此阶段你可以将等量张红色牌当【决斗】对其使用。",

  ["#sifen"] = "俟奋：令一名角色将任意张牌当【决斗】，你摸两张牌，此阶段你可以将等量红色牌当【决斗】对其使用",
  ["#sifen-use"] = "俟奋：请将任意张牌当【决斗】使用",
}

sifen:addEffect("active", {
  anim_type = "offensive",
  prompt = "#sifen",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(sifen.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= player and
      (#to_select:getHandlyIds() + #to_select:getCardIds("e")) > 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local success, dat = room:askToUseActiveSkill(target, {
      skill_name = "sifen_viewas",
      prompt = "#sifen-use",
      cancelable = false,
    })
    if not (success and dat) then
      dat = {}
      local all_cards = table.simpleClone(target:getHandlyIds())
      table.insertTable(all_cards, table.simpleClone(target:getCardIds("e")))
      dat.cards = table.random(all_cards, math.random(#all_cards))
      dat.targets = {}
    end
    local card = Fk:cloneCard("duel")
    card:addSubcards(dat.cards)
    card.skillName = sifen.name
    if #dat.targets == 0 then
      dat.targets = card:getDefaultTarget(target)
      if #dat.targets == 0 then return end
    end
    local use = {
      from = target,
      tos = dat.targets,
      card = card,
    }
    room:useCard(use)
    if player.dead then return end
    player:drawCards(2, sifen.name)
    if player.dead then return end
    if not target.dead then
      local data = player:getMark("sifen-phase")
      if data ~= 0 then
        for _, info in ipairs(data) do
          if info[1] == target.id then
            info[2] = math.min(info[2], #dat.cards)
          end
        end
      else
        data = {{target.id, #dat.cards}}
      end
      room:setPlayerMark(player, "sifen-phase", data)
      room:handleAddLoseSkills(player, "sifen&")
      room.logic:getCurrentEvent():findParent(GameEvent.Phase):addCleaner(function()
        room:handleAddLoseSkills(player, "-sifen&")
      end)
    end
  end,
})

return sifen
