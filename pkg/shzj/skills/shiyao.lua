local shiyao = fk.CreateSkill {
  name = "shiyao",
  attached_skill_name = "shiyao&",
}

Fk:loadTranslationTable{
  ["shiyao"] = "试药",
  [":shiyao"] = "每名角色出牌阶段限一次，其可以摸一张牌，令你获得一张【毒】并进行判定，若结果为：黑色，你减1点体力上限，其获得一张【毒】；"..
  "红色，其可以将一张红色牌当【桃】使用。",

  ["#shiyao"] = "试药：摸一张牌并获得一张【毒】，然后判定",
  ["#shiyao-peach"] = "试药：你可以将一张红色牌当【桃】使用",
}

shiyao:addEffect("active", {
  anim_type = "drawcard",
  prompt = "#shiyao",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(shiyao.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    player:drawCards(1, shiyao.name)
    if player.dead then return end
    local card = room:printCard("es__poison", Card.Spade, table.random({4, 5, 9, 10}))
    room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonJustMove, shiyao.name, nil, true, player)
    if player.dead then return end
    local judge = {
      who = player,
      reason = shiyao.name,
      pattern = ".|.|^nosuit",
    }
    room:judge(judge)
    if judge.card.color == Card.Black then
      if not player.dead then
        room:changeMaxHp(player, -1)
      end
      if not player.dead then
        card = room:printCard("es__poison", Card.Spade, table.random({4, 5, 9, 10}))
        room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonJustMove, shiyao.name, nil, true, player)
      end
    elseif judge.card.color == Card.Red then
      if not player.dead then
        room:askToUseVirtualCard(player, {
          name = "peach",
          skill_name = shiyao.name,
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

return shiyao
