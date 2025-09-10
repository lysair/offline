local duliang = fk.CreateSkill {
  name = "fhyx__duliang",
}

Fk:loadTranslationTable{
  ["fhyx__duliang"] = "督粮",
  [":fhyx__duliang"] = "出牌阶段限一次，你可以获得一名其他角色至多X张手牌（X为其已损失体力值且至少为1），然后选择一项："..
  "1.其观看牌堆顶的两倍的牌，获得其中任意张基本牌；2.其下个摸牌阶段多摸等量的牌。",

  ["#fhyx__duliang"] = "督粮：获得一名角色其已损失体力值张手牌（至少一张），然后令其获得基本牌或其下个摸牌阶段多摸牌",
  ["#fhyx__duliang-prey"] = "督粮：获得 %dest 至多%arg张手牌",
  ["#fhyx__duliang-choice"] = "督粮：选择令 %dest 执行的一项",
  ["fhyx__duliang_view"] = "其观看牌堆顶%arg张牌，获得其中的基本牌",
  ["fhyx__duliang_draw"] = "其下个摸牌阶段额外摸%arg张牌",
  ["#fhyx__duliang-get"] = "督粮：你可以获得其中任意张基本牌",

  ["$fhyx__duliang1"] = "积粮囤草，以备战时之用。",
  ["$fhyx__duliang2"] = "粮食充裕，怎可撤军。",
}

duliang:addEffect("active", {
  anim_type = "support",
  prompt = "#fhyx__duliang",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(duliang.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player and not to_select:isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local n = math.max(target:getLostHp(), 1)
    local cards = room:askToChooseCards(player, {
      target = target,
      min = 1,
      max = n,
      flag = "h",
      skill_name = duliang.name,
      prompt = "#fhyx__duliang-prey::"..target.id..":"..n,
    })
    n = #cards
    room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonPrey, duliang.name, nil, false, player)
    if player.dead or target.dead then return end
    local choice = room:askToChoice(player, {
      choices = {"fhyx__duliang_view:::"..(2*n), "fhyx__duliang_draw:::"..n},
      skill_name = duliang.name,
      prompt = "#fhyx__duliang-choice::"..target.id,
    })
    if choice:startsWith("fhyx__duliang_view") then
      local all_cards = room:getNCards(2 * n)
      cards = table.filter(all_cards, function(id)
        return Fk:getCardById(id).type == Card.TypeBasic
      end)
      cards = room:askToCards(target, {
        min_num = 1,
        max_num = #cards,
        include_equip = false,
        skill_name = duliang.name,
        pattern = tostring(Exppattern{ id = cards }),
        prompt = "#fhyx__duliang-get",
        cancelable = true,
        expand_pile = all_cards,
      })
      if #cards > 0 then
        room:moveCardTo(cards, Card.PlayerHand, target, fk.ReasonJustMove, duliang.name, nil, false, target)
      end
    else
      room:addPlayerMark(target, "@duliang", n)
    end
  end,
})

duliang:addEffect(fk.DrawNCards, {
  can_refresh = function(self, event, target, player, data)
    return player:getMark("@duliang") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    data.n = data.n + player:getMark("@duliang")
    player.room:setPlayerMark(player, "@duliang", 0)
  end,
})

return duliang
