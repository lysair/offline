local sixiong = fk.CreateSkill({
  name = "sixiong",
})

Fk:loadTranslationTable{
  ["sixiong"] = "肆凶",
  [":sixiong"] = "出牌阶段开始时，你可以展示所有手牌并弃置其中至少一种颜色的所有牌，若弃置：黑色，你获得等量张“惧”；红色，你对攻击范围内"..
  "所有其他角色依次造成1点伤害。",

  ["#sixiong-discard"] = "肆凶：弃置一至两种颜色的手牌，若弃置黑色则获得“惧”，若弃置红色则造成伤害",
  ["#sixiong-choose"] = "肆凶：获得一名角色的“惧”（还剩%arg张！）",
}

local U = require "packages/utility/utility"

sixiong:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(sixiong.name) and player.phase == Player.Play and
      not player:isKongcheng()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:showCards(player:getCardIds("h"))
    if player.dead or player:isKongcheng() then return end
    local listNames = { "black", "red" }
    local listCards = { {}, {} }
    for _, id in ipairs(player:getCardIds("h")) do
      local color = Fk:getCardById(id).color
      if color ~= Card.NoColor and not player:prohibitDiscard(id) then
        table.insert(listCards[color], id)
      end
    end
    local choices = U.askForChooseCardList(room, player, listNames, listCards, 1, 2, sixiong.name, "#sixiong-discard", false, false)
    local all_cards = {}
    for i = 1, 2 do
      if table.contains(choices, listNames[i]) then
        table.insertTable(all_cards, listCards[i])
      end
    end
    room:throwCard(all_cards, sixiong.name, player, player)
    if player.dead then return end
    if table.contains(choices, "black") then
      local n = #listCards[Card.Black]
      while n > 0 and not player.dead do
        local targets = table.filter(room.alive_players, function (p)
          return #p:getPile("$weiju") > 0
        end)
        if #targets == 0 then break end
        local to = room:askToChoosePlayers(player, {
          min_num = 1,
          max_num = 1,
          targets = targets,
          skill_name = sixiong.name,
          prompt = "#sixiong-choose:::"..n,
          cancelable = false,
        })[1]
        local cards = to:getPile("$weiju")
        if #cards > 1 then
          cards = room:askToChooseCards(player, {
            target = to,
            min = 1,
            max = n,
            flag = { card_data = {{ to.general, to:getPile("$weiju") }} },
            skill_name = sixiong.name,
          })
        end
        n = n - #cards
        room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonPrey, sixiong.name, nil, false, player)
      end
    end
    if table.contains(choices, "red") then
      for _, p in ipairs(room:getOtherPlayers(player)) do
        if player:inMyAttackRange(p) and not p.dead then
          room:damage{
            from = player,
            to = p,
            damage = 1,
            skillName = sixiong.name,
          }
        end
      end
    end
  end,
})

return sixiong
