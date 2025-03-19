local ofl_shiji__yinge = fk.CreateSkill {
  name = "ofl_shiji__yinge"
}

Fk:loadTranslationTable{
  ['ofl_shiji__yinge'] = '引戈',
  ['#ofl_shiji__yinge'] = '引戈：令一名角色将一张手牌置入仁区，然后其可以使用一张仁区牌，若为伤害牌则额外指定你为目标',
  ['#ofl_shiji__yinge-card'] = '引戈：请将一张手牌置入仁区，然后你可以使用一张仁区牌',
  ['#ofl_shiji__yinge-use'] = '引戈：你可以使用一张仁区牌，若为伤害牌，额外指定 %src 为目标',
  [':ofl_shiji__yinge'] = '出牌阶段限一次，你可以令一名其他角色将一张手牌置入<a href=>“仁”区</a>，然后其可以使用一张“仁”区牌，若此牌为伤害类牌，额外指定你为目标。',
}

ofl_shiji__yinge:addEffect('active', {
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  prompt = "#ofl_shiji__yinge",
  can_use = function(self, player)
    return player:usedSkillTimes(ofl_shiji__yinge.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= player.id and not Fk:currentRoom():getPlayerById(to_select):isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local card = room:askToCards(target, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = ofl_shiji__yinge.name,
      cancelable = false,
      pattern = nil,
      prompt = "#ofl_shiji__yinge-card",
    })
    U.AddToRenPile(room, card[1], ofl_shiji__yinge.name, target.id)
    local cards = U.GetRenPile(room)
    if target.dead or #cards == 0 then return end
    local use = room:askToUseRealCard(target, {
      pattern = cards,
      skill_name = ofl_shiji__yinge.name,
      prompt = "#ofl_shiji__yinge-use:"..player.id,
      extra_data = {
        bypass_times = true,
        expand_pile = cards,
        extraUse = true,
      },
      cancelable = true,
      skip = true,
    })
    if use then
      if use.card.is_damage_card and not use.card.multiple_targets and
        table.contains(room:getUseExtraTargets(use, true), player.id) then
        table.insert(use.tos, {player.id})
      end
      room:useCard(use)
    end
  end,
})

return ofl_shiji__yinge
