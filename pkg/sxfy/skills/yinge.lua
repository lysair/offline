local yinge = fk.CreateSkill {
  name = "sxfy__yinge",
}

Fk:loadTranslationTable{
  ["sxfy__yinge"] = "引戈",
  [":sxfy__yinge"] = "出牌阶段限一次，你可以令一名其他角色交给你一张牌，然后其视为对你或你攻击范围内的另一名角色使用一张【杀】。",

  ["#sxfy__yinge"] = "引戈：令一名角色交给你一张牌，然后其视为对你或你攻击范围内的一名角色使用【杀】",
  ["#sxfy__yinge-give"] = "引戈：请交给 %src 一张牌",
  ["#sxfy__yinge-slash"] = "引戈：请视为对 %src 或其攻击范围内一名角色使用【杀】",
}

yinge:addEffect("active", {
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  prompt = "#sxfy__yinge",
  can_use = function(self, player)
    return player:usedSkillTimes(yinge.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player and not to_select:isNude()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local card = room:askToCards(target, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = yinge.name,
      prompt = "#sxfy__yinge-give:"..player.id,
      cancelable = false,
    })
    room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonGive, yinge.name, nil, false, target)
    if player.dead or target.dead then return end
    local targets = table.filter(room.alive_players, function (p)
      return (p == player or player:inMyAttackRange(p)) and not target:isProhibited(p, Fk:cloneCard("slash"))
    end)
    if #targets == 0 then return end
    room:askToUseVirtualCard(target, {
      name = "slash",
      skill_name = yinge.name,
      prompt = "#sxfy__yinge-slash:"..player.id,
      extra_data = {
        bypass_distances = true,
        bypass_times = true,
        extraUse = true,
        exclusive_targets = table.map(targets, Util.IdMapper),
      },
      cancelable = false,
    })
  end,
})

return yinge
