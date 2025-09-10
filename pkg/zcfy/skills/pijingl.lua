local pijingl = fk.CreateSkill{
  name = "sxfy__pijingl",
}

Fk:loadTranslationTable{
  ["sxfy__pijingl"] = "披荆",
  [":sxfy__pijingl"] = "当你使用【杀】或普通锦囊牌结算结束后，你可以令一名其他角色交给你一张牌，然后其可以将一张牌当【杀】对你使用或摸一张牌。",

  ["#sxfy__pijingl-choose"] = "披荆：你可以令一名其他角色交给你一张牌",
  ["#sxfy__pijingl-give"] = "披荆：请交给 %src 一张牌",
  ["#sxfy__pijingl-slash"] = "披荆：将一张牌当【杀】对 %src 使用，或点“取消”摸一张牌",
}

pijingl:addEffect(fk.CardUseFinished, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(pijingl.name) and
      (data.card.trueName == "slash" or data.card:isCommonTrick()) and
      table.find(player.room:getOtherPlayers(player, false), function(p)
        return not p:isNude()
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player, false), function(p)
      return not p:isNude()
    end)
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = pijingl.name,
      prompt = "#sxfy__pijingl-choose",
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local cards = room:askToCards(to, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = pijingl.name,
      prompt = "#sxfy__pijingl-give:"..player.id,
      cancelable = false,
    })
    room:obtainCard(player, cards, false, fk.ReasonGive, to, pijingl.name)
    if to.dead then return end
    if player.dead then
      to:drawCards(1, pijingl.name)
    else
      if not room:askToUseVirtualCard(to, {
        name = "slash",
        skill_name = pijingl.name,
        prompt = "#sxfy__pijingl-slash:"..player.id,
        cancelable = true,
        extra_data = {
          bypass_distances = true,
          bypass_times = true,
          extraUse = true,
          exclusive_targets = {player.id},
        },
        card_filter = {
          n = 1,
        },
      }) then
        to:drawCards(1, pijingl.name)
      end
    end
  end,
})

return pijingl
