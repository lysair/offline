local andong = fk.CreateSkill {
  name = "ofl__andong",
}

Fk:loadTranslationTable{
  ["ofl__andong"] = "安东",
  [":ofl__andong"] = "每回合限一次，当你受到其他角色造成的伤害时，你可以观看其手牌，弃置其中一至两张牌，然后你获得弃置的"..
  "<font color='red'>♥</font>牌，该角色摸X张牌，若X为2，你防止此伤害（X为你弃置的非<font color='red'>♥</font>牌数）。",

  ["#ofl__andong-invoke"] = "安东：你可以观看 %dest 的手牌并弃置其中一至两张牌",
  ["#ofl__andong-discard"] = "安东：弃置其中一至两张牌，你获得<font color='red'>♥</font>牌，若弃置两张非<font color='red'>♥</font>"..
  "则防止你受到的伤害",

  ["$ofl__andong1"] = "得司空看重，以萧何、寇恂比之，如何不感激涕零？",
  ["$ofl__andong2"] = "既受司空之令，任河东太守，安敢不竭心用命？",
}

andong:addEffect(fk.DamageInflicted, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(andong.name) and
      data.from and data.from ~= player and not data.from:isKongcheng() and not data.from.dead and
      player:usedSkillTimes(andong.name, Player.HistoryTurn) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = andong.name,
      prompt = "#ofl__andong-invoke::"..data.from.id,
    }) then
      event:setCostData(self, {tos = {data.from}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = room:askToChooseCards(player, {
      target = data.from,
      min = 1,
      max = 2,
      flag = { card_data = {{ data.from.general, data.from:getCardIds("h") }} },
      skill_name = andong.name,
    })
    local heart = table.filter(cards, function (id)
      return Fk:getCardById(id).suit == Card.Heart
    end)
    room:throwCard(cards, andong.name, data.from, player)
    local n = #cards - #heart
    if n == 2 then
      data:preventDamage()
    end
    heart = table.filter(heart, function (id)
      return table.contains(room.discard_pile, id)
    end)
    if #heart > 0 and not player.dead then
      room:moveCardTo(heart, Card.PlayerHand, player, fk.ReasonJustMove, andong.name, nil, true, player)
    end
    if n > 0 and not data.from.dead then
      data.from:drawCards(n, andong.name)
    end
  end,
})

return andong
