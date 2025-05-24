local yingshi = fk.CreateSkill {
  name = "ofl__yingshi",
}

Fk:loadTranslationTable{
  ["ofl__yingshi"] = "应势",
  [":ofl__yingshi"] = "出牌阶段开始时，你可以展示一张手牌并选择两名角色，令其中一名角色选择是否对另一名角色使用一张【杀】（无距离次数限制）。"..
  "此【杀】结算完成后，其获得你展示的牌；若此【杀】造成了伤害，其获得牌堆中一张与展示牌类别相同的牌。",

  ["#ofl__yingshi-invoke"] = "应势：展示一张手牌并选择两名角色，后者可以对前者使用一张【杀】",
  ["#ofl__yingshi-slash"] = "应势：你可以对 %dest 使用一张【杀】，然后获得展示牌",

  ["$ofl__yingshi1"] = "",
  ["$ofl__yingshi2"] = "",
}

yingshi:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yingshi.name) and player.phase == Player.Play and
      not player:isKongcheng() and #player.room:getOtherPlayers(player, false) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local tos, card = room:askToChooseCardsAndPlayers(player, {
      min_card_num = 1,
      max_card_num = 1,
      min_num = 2,
      max_num = 2,
      targets = room.alive_players,
      pattern = ".|.|.|hand",
      skill_name = yingshi.name,
      prompt = "#ofl__yingshi-invoke",
      cancelable = true,
    })
    if #tos == 2 and #card > 0 then
      event:setCostData(self, {extra_data = tos, cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local target1 = event:getCostData(self).extra_data[1]
    local target2 = event:getCostData(self).extra_data[2]
    room:doIndicate(player, {target2})
    room:doIndicate(target2, {target1})
    local id = event:getCostData(self).cards[1]
    local type = Fk:getCardById(id).type
    player:showCards(id)
    if target1.dead or target2.dead then return end
    local use = room:askToUseCard(target2, {
      skill_name = yingshi.name,
      pattern = "slash",
      prompt = "#ofl__yingshi-slash::"..target1.id,
      cancelable = true,
      extra_data = {
        bypass_distances = true,
        bypass_times = true,
        must_targets = {target1.id},
      }
    })
    if use then
      use.extraUse = true
      room:useCard(use)
      if not target2.dead and not table.contains(target2:getCardIds("h"), id) and
        (table.contains(player:getCardIds("he"), id) or table.contains(room.discard_pile, id)) then
        room:moveCardTo(id, Card.PlayerHand, target2, fk.ReasonPrey, yingshi.name, nil, true, target2)
      end
      if not target2.dead and use.damageDealt then
        local cards = room:getCardsFromPileByRule(".|.|.|.|.|"..type, 1)
        if #cards > 0 then
          room:moveCardTo(cards, Card.PlayerHand, target2, fk.ReasonJustMove, yingshi.name, nil, false, target2)
        end
      end
    end
  end,
})

return yingshi
