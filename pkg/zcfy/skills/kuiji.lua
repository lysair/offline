local kuiji = fk.CreateSkill {
  name = "sxfy__kuiji",
}

Fk:loadTranslationTable{
  ["sxfy__kuiji"] = "溃击",
  [":sxfy__kuiji"] = "出牌阶段限一次，你可以将一张黑色基本牌当【兵粮寸断】对你使用。若如此做，你可以对体力值最大的"..
  "一名其他角色造成1点伤害并获得其一张手牌。",

  ["#sxfy__kuiji"] = "溃击：将一张黑色基本牌当【兵粮寸断】对你使用，然后对体力值最大的角色造成1点伤害并获得其一张手牌",
  ["#sxfy__kuiji-damage"] = "溃击：你可以对体力值最大的一名角色造成1点伤害并获得其一张手牌",
  ["#sxfy__kuiji-prey"] = "溃击：获得 %dest 一张手牌",
}

kuiji:addEffect("active", {
  anim_type = "offensive",
  prompt = "#sxfy__kuiji",
  target_num = 0,
  card_num = 1,
  can_use = function(self, player)
    return player:usedEffectTimes(kuiji.name, Player.HistoryPhase) == 0 and not player:hasDelayedTrick("supply_shortage")
  end,
  card_filter = function(self, player, to_select, selected)
    if #selected == 0 and Fk:getCardById(to_select).type == Card.TypeBasic and Fk:getCardById(to_select).color == Card.Black then
      local card = Fk:cloneCard("supply_shortage")
      card:addSubcard(to_select)
      return not player:prohibitUse(card) and not player:isProhibited(player, card)
    end
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    room:useVirtualCard("supply_shortage", effect.cards, player, player, kuiji.name)
    if player.dead then return end
    local targets = table.filter(room:getOtherPlayers(player, false), function(p)
      return table.every(room:getOtherPlayers(player, false), function(q)
        return q.hp <= p.hp
      end)
    end)
    local to = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#sxfy__kuiji-damage",
      skill_name = kuiji.name,
      cancelable = true,
    })
    if #to > 0 then
      to = to[1]
      room:damage{
        from = player,
        to = to,
        damage = 1,
        skillName = kuiji.name,
      }
      if not to.dead and not player.dead and not to:isKongcheng() then
        local card = room:askToChooseCard(player, {
          target = to,
          flag = "h",
          skill_name = kuiji.name,
          prompt = "#sxfy__kuiji-prey::"..to.id,
        })
        room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonPrey, kuiji.name, nil, false, player)
      end
    end
  end,
})

return kuiji
