local mixin = fk.CreateSkill {
  name = "mixin"
}

Fk:loadTranslationTable{
  ['mixin'] = '密信',
  ['#mixin'] = '密信：先选交给牌的角色，再选其需要使用【杀】的目标',
  ['#mixin-slash'] = '密信：你需对 %src 使用一张【杀】，否则其观看你手牌并获得其中一张',
  [':mixin'] = '出牌阶段限一次，你可以将一张手牌交给一名其他角色，该角色须对你选择的另一名角色使用一张【杀】（无距离限制），否则你选择的角色观看其手牌并获得其中一张。',
}

mixin:addEffect('active', {
  anim_type = "offensive",
  can_use = function(self, player)
    return player:usedSkillTimes(mixin.name, Player.HistoryPhase) == 0
  end,
  prompt = "#mixin",
  card_num = 1,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and table.contains(player.player_cards[Player.Hand], to_select)
  end,
  target_num = 2,
  target_filter = function(self, player, to_select, selected, cards)
    if #cards ~= 1 then return end
    if #selected == 0 then
      return to_select ~= player.id
    elseif #selected == 1 then
      return selected[1] ~= player.id
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local to = room:getPlayerById(effect.tos[1])
    local victim = room:getPlayerById(effect.tos[2])
    room:moveCardTo(effect.cards, Player.Hand, to, fk.ReasonGive, mixin.name, nil, false, player.id)
    if to.dead or victim.dead then return end
    local use = room:askToUseCard(to, {
      pattern = "slash",
      prompt = "#mixin-slash:"..victim.id,
      cancelable = true,
      extra_data = { bypass_distances = true, exclusive_targets = {victim.id} }
    })
    if use then
      use.extraUse = true
      room:useCard(use)
    elseif not victim.dead and not to:isKongcheng() then
      local card = room:askToChooseCard(victim, {
        target = to,
        flag = { card_data = { { "$Hand", to.player_cards[Player.Hand] } } },
        skill_name = mixin.name
      })
      room:moveCardTo(card, Player.Hand, victim, fk.ReasonPrey, mixin.name, nil, false, victim.id)
    end
  end,
})

return mixin
