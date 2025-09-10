local shiyao_active = fk.CreateSkill {
  name = "shiyao&",
}

Fk:loadTranslationTable{
  ["shiyao&"] = "试药",
  [":shiyao&"] = "出牌阶段限一次，你可以摸一张牌，令华雌获得一张【毒】并进行判定，若结果为：黑色，华雌减1点体力上限，你获得一张【毒】；"..
  "红色，你可以将一张红色牌当【桃】使用。",

  ["#shiyao&"] = "试药：摸一张牌，令华雌获得一张【毒】并进行判定",
}

shiyao_active:addEffect("active", {
  anim_type = "support",
  card_num = 0,
  target_num = 1,
  prompt = "#shiyao&",
  can_use = function(self, player)
    return table.find(Fk:currentRoom().alive_players, function (p)
      return p:hasSkill("shiyao") and p:usedSkillTimes("shiyao", Player.HistoryPhase) == 0
    end)
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, cards)
    return #selected == 0 and to_select:hasSkill("shiyao") and to_select:usedSkillTimes("shiyao", Player.HistoryPhase) == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    target:addSkillUseHistory("shiyao", 1)
    player:drawCards(1, "shiyao")
    if target.dead then return end
    local card = room:printCard("es__poison", Card.Spade, table.random({4, 5, 9, 10}))
    room:moveCardTo(card, Card.PlayerHand, target, fk.ReasonJustMove, "shiyao", nil, true, target)
    if target.dead then return end
    local judge = {
      who = target,
      reason = "shiyao",
      pattern = ".|.|^nosuit",
    }
    room:judge(judge)
    if judge.card.color == Card.Black then
      if not target.dead then
        room:changeMaxHp(target, -1)
      end
      if not player.dead then
        card = room:printCard("es__poison", Card.Spade, table.random({4, 5, 9, 10}))
        room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonJustMove, "shiyao", nil, true, player)
      end
    elseif judge.card.color == Card.Red then
      if not player.dead then
        room:askToUseVirtualCard(player, {
          name = "peach",
          skill_name = "shiyao",
          prompt = "#shiyao-peach",
          cancelable = true,
          card_filter = {
            n = 1,
            pattern = ".|.|heart,diamond",
          },
        })
      end
    end
  end,
})

return shiyao_active
