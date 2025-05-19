local cuixi = fk.CreateSkill {
  name = "cuixi",
}

Fk:loadTranslationTable{
  ["cuixi"] = "摧袭",
  [":cuixi"] = "出牌阶段限两次，你可以弃置任意张手牌，选择两名体力值小于你的角色，你与这些角色依次亮出牌堆顶的一张牌，点数不为最大的角色"..
  "受到2点伤害。你可以令你的点数+X（X为你弃置的手牌数）。",

  ["#cuixi"] = "摧袭：弃置任意张手牌，与两名角色依次亮出牌堆顶一张牌，点数不为最大的角色受到2点伤害",
  ["#cuixi-add"] = "摧袭：是否令你的点数+%arg？",
}

cuixi:addEffect("active", {
  anim_type = "offensive",
  prompt = "#cuixi",
  min_card_num = 1,
  target_num = 2,
  times = function(self, player)
    return player.phase == Player.Play and
      2 - player:usedSkillTimes(cuixi.name, Player.HistoryPhase) or -1
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(cuixi.name, Player.HistoryPhase) < 2 and
      #table.filter(Fk:currentRoom().alive_players, function (p)
        return p.hp < player.hp
      end) > 1
  end,
  card_filter = function(self, player, to_select, selected)
    return not player:prohibitDiscard(to_select) and table.contains(player:getCardIds("h"), to_select)
  end,
  target_filter = function (self, player, to_select, selected, selected_cards)
    return to_select.hp < player.hp
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local targets = effect.tos
    room:throwCard(effect.cards, cuixi.name, player, player)
    if player.dead then return end
    table.insert(targets, player)
    room:sortByAction(targets)
    targets = table.filter(targets, function (p)
      return not p.dead
    end)
    local nums = {}
    for _, p in ipairs(targets) do
      local card = room:getNCards(1)
      table.insert(nums, Fk:getCardById(card[1]).number)
      room:turnOverCardsFromDrawPile(p, card, cuixi.name)
    end
    if room:askToSkillInvoke(player, {
      skill_name = cuixi.name,
      prompt = "#cuixi-add:::"..#effect.cards,
    }) then
      nums[1] = math.min(13, nums[1] + #effect.cards)
    end
    local max = math.max(table.unpack(nums))
    for i = 1, #targets do
      if nums[i] ~= max and not targets[i].dead then
        room:damage({
          from = nil,
          to = targets[i],
          damage = 2,
          skillName = cuixi.name,
        })
      end
    end
  end,
})

return cuixi
