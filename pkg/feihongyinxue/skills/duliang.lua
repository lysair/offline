local duliang = fk.CreateSkill {
  name = "fhyx__duliang"
}

Fk:loadTranslationTable{
  ['fhyx__duliang'] = '督粮',
  ['#fhyx__duliang'] = '督粮：获得一名角色其已损失体力值张手牌（至少一张），然后令其获得基本牌或其下个摸牌阶段多摸牌',
  ['#fhyx__duliang-prey'] = '督粮：获得 %dest 至多%arg张手牌',
  ['fhyx__duliang_view'] = '其观看牌堆顶%arg张牌，获得其中的基本牌',
  ['fhyx__duliang_draw'] = '其下个摸牌阶段额外摸%arg张牌',
  ['#fhyx__duliang-choice'] = '督粮：选择令 %dest 执行的一项',
  ['#fhyx__duliang-get'] = '督粮：你可以获得其中任意张基本牌',
  [':fhyx__duliang'] = '出牌阶段限一次，你可以获得一名其他角色至多X张手牌（X为其已损失体力值且至少为1），然后选择一项：1.其观看牌堆顶的两倍的牌，获得其中任意张基本牌；2.其下个摸牌阶段多摸等量的牌。',
  ['$fhyx__duliang1'] = '积粮囤草，以备战时之用。',
  ['$fhyx__duliang2'] = '粮食充裕，怎可撤军。',
}

-- 主动技能效果
duliang:addEffect('active', {
  anim_type = "support",
  card_num = 0,
  target_num = 1,
  prompt = "#fhyx__duliang",
  can_use = function(self, player)
    return player:usedSkillTimes(duliang.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= player.id and not Fk:currentRoom():getPlayerById(to_select):isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local n = math.max(target:getLostHp(), 1)
    local cards = room:askToChooseCards(player, {
      min_num = 1,
      max_num = n,
      flag = "h",
      skill_name = duliang.name,
      prompt = "#fhyx__duliang-prey::"..target.id..":"..n
    })
    n = #cards
    room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonPrey, duliang.name, nil, false, player.id)
    if player.dead or target.dead then return end
    local choice = room:askToChoice(player, {
      choices = {"fhyx__duliang_view:::"..(2*n), "fhyx__duliang_draw:::"..n},
      skill_name = duliang.name,
      prompt = "#fhyx__duliang-choice::"..target.id
    })
    if string.startswith(choice, "fhyx__duliang_view") then
      local all_cards = room:getNCards(2 * n)
      cards = table.filter(all_cards, function (id)
        return Fk:getCardById(id).type == Card.TypeBasic
      end)
      cards = U.askToChooseCardsAndPlayers(target, {
        min_card_num = 0,
        max_card_num = #cards,
        targets = {},
        skill_name = duliang.name,
        prompt = "#fhyx__duliang-get",
        cancelable = true,
        expand_pile = all_cards
      })
      if #cards > 0 then
        room:moveCardTo(cards, Card.PlayerHand, target, fk.ReasonJustMove, duliang.name, nil, false, target.id)
      end
    else
      room:addPlayerMark(target, "@duliang", n)
    end
  end,
})

-- 触发技效果
duliang:addEffect(fk.DrawNCards, {
  can_refresh = function(self, event, player, data)
    return player:getMark("@duliang") > 0
  end,
  on_refresh = function(self, event, player, data)
    data.n = data.n + player:getMark("@duliang")
    player.room:setPlayerMark(player, "@duliang", 0)
  end,
})

return duliang
