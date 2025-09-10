local skill = fk.CreateSkill {
  name = "jielve__looting_skill",
}

Fk:loadTranslationTable{
  ["jielve__looting_skill"] = "趁火打劫",
  ["#jielve__looting_skill"] = "选择一名有手牌的其他角色，其展示手牌，你选择将其中一张牌交给你指定的角色或对其造成1点伤害",
  ["#jielve__looting-choose"] = "趁火打劫：选择一名角色将%arg交给其，或点“取消”对 %dest 造成1点伤害",
}

skill:addEffect("active", {
  prompt = "#jielve__looting_skill",
  target_num = 1,
  mod_target_filter = function(self, player, to_select, _, _, _)
    return to_select ~= player and not to_select:isKongcheng()
  end,
  target_filter = Util.CardTargetFilter,
  on_effect = function(self, room, effect)
    local player = effect.from
    local target = effect.to
    if player.dead or target.dead or target:isKongcheng() then return end
    target:showCards(target:getCardIds("h"))
    if target.dead then return end
    if target:isKongcheng() then
      room:damage{
        from = player,
        to = target,
        card = effect.card,
        damage = 1,
        skillName = skill.name,
      }
      return
    end
    if player.dead then return end
    local id = room:askToChooseCard(player, {
      target = target,
      flag = { card_data = {{ target.general, target:getCardIds("h") }} },
      skill_name = skill.name,
    })
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room:getOtherPlayers(target, false),
      skill_name = skill.name,
      prompt = "#jielve__looting-choose",
      cancelable = true,
    })
    if #to > 0 then
      room:obtainCard(to[1], id, true, fk.ReasonGive, player, skill.name)
    else
      room:damage{
        from = player,
        to = target,
        card = effect.card,
        damage = 1,
        skillName = skill.name,
      }
    end
  end,
})

return skill
