local lezong = fk.CreateSkill {
  name = "lezong",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["lezong"] = "乐纵",
  [":lezong"] = "锁定技，当你成为【杀】或延时锦囊牌的目标时，使用者需交给你一张相同类别的手牌，否则此牌无效。",

  ["#lezong-ask"] = "乐纵：你须交给 %src 一张%arg2手牌，否则此%arg无效",

  ["$lezong1"] = "冷眼观棋棋不语，笑对樽酒问三分。",
  ["$lezong2"] = "大江东流尽，独唱太平谣。",
}

lezong:addEffect(fk.TargetConfirming, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(lezong.name) and
      (data.card.trueName == "slash" or data.card.sub_type == Card.SubtypeDelayedTrick)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if data.from.dead or data.from:isKongcheng() or data.from == player then
      data.use.nullifiedTargets = table.simpleClone(room.players)
    else
      local card = room:askToCards(data.from, {
        min_num = 1,
        max_num = 1,
        include_equip = false,
        skill_name = lezong.name,
        pattern = ".|.|.|.|.|"..data.card:getTypeString(),
        prompt = "#lezong-ask:"..player.id.."::"..data.card:toLogString()..":"..data.card:getTypeString(),
        cancelable = true,
      })
      if #card > 0 then
        room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonGive, lezong.name, nil, true, data.from)
      else
        data.use.nullifiedTargets = table.simpleClone(room.players)
      end
    end
  end,
})

return lezong
