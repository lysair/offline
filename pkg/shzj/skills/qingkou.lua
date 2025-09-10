local qingkou = fk.CreateSkill {
  name = "qingkou",
}

Fk:loadTranslationTable{
  ["qingkou"] = "轻寇",
  [":qingkou"] = "结束阶段，你可以摸一张牌并展示之，然后你可以将此牌当【杀】或牌名字数与你体力值相同的普通锦囊牌使用。",

  ["#qingkou-use"] = "轻寇：你可以将%arg当【杀】或锦囊牌使用",
}

qingkou:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(qingkou.name) and player.phase == Player.Finish
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = player:drawCards(1, qingkou.name)
    if player.dead or #card < 1 then return end
    card = table.filter(card, function (id)
      return table.contains(player:getCardIds("h"), id)
    end)
    if #card == 0 then return end
    player:showCards(card)
    card = table.filter(card, function (id)
      return table.contains(player:getCardIds("h"), id)
    end)
    if player.dead or #card < 1 then return end
    local id = card[1]
    local names = table.filter(Fk:getAllCardNames("t", false), function (name)
      return Fk:translate(Fk:cloneCard(name).name, "zh_CN"):len() == player.hp
    end)
    table.insert(names, 1, "slash")
    room:askToUseVirtualCard(player, {
      name = names,
      skill_name = qingkou.name,
      prompt = "#qingkou-use:::"..Fk:getCardById(id):toLogString(),
      cancelable = true,
      extra_data = {
        bypass_times = true,
        extraUse = true,
      },
      subcards = {id},
    })
  end,
})


return qingkou
