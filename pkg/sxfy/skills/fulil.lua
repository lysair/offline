local fulil = fk.CreateSkill {
  name = "sxfy__fulil",
}

Fk:loadTranslationTable{
  ["sxfy__fulil"] = "抚黎",
  [":sxfy__fulil"] = "出牌阶段限一次，你可以展示所有手牌并弃置其中所有伤害类牌，然后令一名其他角色也如此做并回复1点体力。",

  ["#sxfy__fulil"] = "抚黎：展示手牌并弃置所有伤害类牌，然后令一名其他角色也如此做并回复1点体力",
  ["#sxfy__fulil-choose"] = "抚黎：令一名角色展示手牌、弃置所有伤害类牌、回复1点体力",
}

fulil:addEffect("active", {
  anim_type = "support",
  prompt = "#sxfy__fulil",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return not player:isKongcheng() and player:usedSkillTimes(fulil.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    player:showCards(player:getCardIds("h"))
    if player.dead then return end
    local cards = table.filter(player:getCardIds("h"), function(id)
      return Fk:getCardById(id).is_damage_card and not player:prohibitDiscard(id)
    end)
    if #cards > 0 then
      room:throwCard(cards, fulil.name, player, player)
      if player.dead then return end
    end
    local targets = table.filter(room:getOtherPlayers(player, false), function(p)
      return not p:isKongcheng()
    end)
    if #targets == 0 then return end
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = fulil.name,
      prompt = "#sxfy__fulil-choose",
      cancelable = false,
    })[1]
    to:showCards(to:getCardIds("h"))
    if to.dead then return end
    cards = table.filter(to:getCardIds("h"), function(id)
      return Fk:getCardById(id).is_damage_card and not to:prohibitDiscard(id)
    end)
    if #cards > 0 then
      room:throwCard(cards, fulil.name, to, to)
      if to.dead then return end
    end
    room:recover{
      who = to,
      num = 1,
      recoverBy = player,
      skillName = fulil.name,
    }
  end,
})

return fulil
