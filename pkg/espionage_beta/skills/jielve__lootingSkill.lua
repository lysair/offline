local jielve = fk.CreateSkill {
  name = "jielve"
}

Fk:loadTranslationTable{
  ['jielve__looting_skill'] = '趁火打劫',
  ['#jielve__looting-choose'] = '趁火打劫：选择一名角色将%arg交给其，或点“取消”对 %dest 造成1点伤害',
}

jielve:addEffect('active', {
  name = "jielve__looting_skill",
  target_num = 1,
  mod_target_filter = function(self, player, to_select, selected)
    return to_select ~= player.id and not Fk:currentRoom():getPlayerById(to_select):isKongcheng()
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return to_select ~= player.id and not Fk:currentRoom():getPlayerById(to_select):isKongcheng()
  end,
  on_effect = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.to)
    if player.dead or target.dead or target:isKongcheng() then return end
    target:showCards(target:getCardIds("h"))
    if player.dead or target.dead or target:isKongcheng() then return end
    local id = room:askToChooseCard(player, {
      target = target,
      flag = {card_data = {{target.general, target:getCardIds("h")}}},
      skill_name = jielve.name
    })
    local targets = table.map(room:getOtherPlayers(target), function(p) return p.id end)
    local to = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#jielve__looting-choose::"..target.id..":"..Fk:getCardById(id, true):toLogString(),
      skill_name = jielve.name
    })
    if #to > 0 then
      room:obtainCard(to[1], id, false, fk.ReasonGive)
    else
      room:damage({
        from = player,
        to = target,
        card = effect.card,
        damage = 1,
        skillName = jielve.name
      })
    end
  end
})

return jielve
