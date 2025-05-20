local guolun = fk.CreateSkill {
  name = "qshm__guolun",
}

Fk:loadTranslationTable{
  ["qshm__guolun"] = "过论",
  [":qshm__guolun"] = "当你于出牌阶段使用牌指定一名其他角色为唯一目标后，你可以展示其一张手牌，然后你可以用一张牌交换此牌，"..
  "以此法获得点数大的牌的角色摸一张牌。",

  ["#qshm__guolun-invoke"] = "过论：你可以展示 %dest 的一张手牌，然后你可以用一张牌与其交换",
  ["#qshm__guolun-card"] = "过论：你可以用一张牌交换 %dest 的%arg，点数小的角色摸一张牌",
}

guolun:addEffect(fk.TargetSpecified, {
  anim_type = "control",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(guolun.name) and player.phase == Player.Play and
      data:isOnlyTarget(data.to) and data.to ~= player and not data.to:isKongcheng()
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = guolun.name,
      prompt = "#qshm__guolun-invoke::"..data.to.id,
    }) then
      event:setCostData(self, {tos = {data.to}})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local id1 = room:askToChooseCard(player, {
      target = data.to,
      flag = "h",
      skill_name = guolun.name,
    })
    local n1 = Fk:getCardById(id1).number
    data.to:showCards(id1)
    if not data.to.dead and not player:isNude() and table.contains(data.to:getCardIds("h"), id1) then
      local card = room:askToCards(player, {
        min_num = 1,
        max_num = 1,
        include_equip = true,
        skill_name = guolun.name,
        cancelable = true,
        prompt = "#qshm__guolun-card::"..data.to.id..":"..Fk:getCardById(id1):toLogString(),
      })
      if #card > 0 then
        local n2 = Fk:getCardById(card[1]).number
        room:swapCards(player, {
          {player, card},
          {data.to, {id1}},
        }, guolun.name)
        if n2 > n1 and not target.dead then
          target:drawCards(1, guolun.name)
        elseif n1 > n2 and not player.dead then
          player:drawCards(1, guolun.name)
        end
      end
    end
  end,
})

return guolun
