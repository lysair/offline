local lilu = fk.CreateSkill {
  name = "ofl__lilu",
}

Fk:loadTranslationTable{
  ["ofl__lilu"] = "礼赂",
  [":ofl__lilu"] = "摸牌阶段，你可以放弃摸牌，改为弃置任意张牌并将手牌摸至体力上限（最多摸至5张），然后将至少一张手牌交给一名其他角色；"..
  "若你交出的牌数大于上次以此法交出的牌数，你增加1点体力上限并回复1点体力。",

  ["#ofl__lilu-invoke"] = "礼赂：你可以放弃摸牌，弃置任意张牌并将手牌摸至体力上限，然后将任意张手牌交给一名其他角色",
  ["@ofl__lilu"] = "礼赂",

  ["$ofl__lilu1"] = "卿天人之姿，请纳此薄礼以修两家之好！",
  ["$ofl__lilu2"] = "昔吕氏奇货天下，吾观君姿胜异人十倍！"
}

lilu:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(lilu.name) and player.phase == Player.Draw
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = lilu.name,
      prompt = "#lilu-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    data.phase_end = true
    room:askToDiscard(player, {
      min_num = 1,
      max_num = 999,
      include_equip = true,
      skill_name = lilu.name,
      cancelable = false,
    })
    if player.dead then return end
    local n = math.min(player.maxHp, 5) - player:getHandcardNum()
    if n > 0 then
      player:drawCards(n, lilu.name)
      if player.dead or player:isKongcheng() then return end
    end
    if #room:getOtherPlayers(player, false) == 0 then return end
    local x = player:getMark("@ofl__lilu")
    local to, cards = room:askToChooseCardsAndPlayers(player, {
      min_card_num = 1,
      max_card_num = 999,
      min_num = 1,
      max_num = 1,
      targets = room:getOtherPlayers(player, false),
      pattern = ".|.|.|hand",
      skill_name = lilu.name,
      prompt = "#lilu-give:::"..x,
      cancelable = false,
    })
    room:moveCardTo(cards, Card.PlayerHand, to[1], fk.ReasonGive, lilu.name, nil, false, player)
    if player.dead then return end
    room:setPlayerMark(player, "@ofl__lilu", #cards)
    if #cards > x then
      room:changeMaxHp(player, 1)
      if player:isAlive() then
        room:recover{
          who = player,
          num = 1,
          recoverBy = player,
          skillName = lilu.name,
        }
      end
    end
  end,
})

return lilu
