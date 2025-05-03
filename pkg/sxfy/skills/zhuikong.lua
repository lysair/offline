local zhuikong = fk.CreateSkill {
  name = "sxfy__zhuikong",
}

Fk:loadTranslationTable{
  ["sxfy__zhuikong"] = "惴恐",
  [":sxfy__zhuikong"] = "其他角色准备阶段，你可以用【杀】与其拼点，赢的角色可以使用对方的拼点牌。",

  ["#sxfy__zhuikong-invoke"] = "惴恐：你可以用一张【杀】与 %dest 拼点，赢的角色可以使用对方的拼点牌",
  ["#sxfy__zhuikong-use"] = "惴恐：你可以使用对方的拼点牌",
}

zhuikong:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(zhuikong.name) and target ~= player and target.phase == Player.Start and
      not target.dead and player:canPindian(target)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cards = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = zhuikong.name,
      pattern = "slash",
      prompt = "#sxfy__zhuikong-invoke::"..target.id,
      cancelable = true,
    })
    if #cards > 0 then
      event:setCostData(self, {tos = {target}, cards = cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local pindian = player:pindian({target}, zhuikong.name, Fk:getCardById(event:getCostData(self).cards[1]))
    local winner = pindian.results[target].winner
    if winner and not winner.dead then
      local card = 0
      if winner == player then
        if pindian.results[target].toCard then
          card = pindian.results[target].toCard:getEffectiveId()
        end
      else
        card = pindian.fromCard:getEffectiveId()
      end
      if not table.contains(room.discard_pile, card) then return end
      room:askToUseRealCard(winner, {
        pattern = {card},
        skill_name = zhuikong.name,
        prompt = "#sxfy__zhuikong-use",
        extra_data = {
          bypass_times = true,
          extraUse = true,
          expand_pile = {card},
        },
      })
    end
  end,
})

return zhuikong
