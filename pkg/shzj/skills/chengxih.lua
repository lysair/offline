local chengxih = fk.CreateSkill {
  name = "chengxih",
}

Fk:loadTranslationTable{
  ["chengxih"] = "乘袭",
  [":chengxih"] = "当你使用牌指定唯一目标时，你可以令目标角色展示所有手牌，然后其重铸至少一张牌，此牌额外结算其未重铸的花色数次。",

  ["#chengxih-invoke"] = "乘袭：令 %dest 展示手牌并重铸任意张牌，其每少重铸一种花色便额外结算一次",
  ["#chengxih-recast"] = "乘袭：重铸至少一张牌，每少重铸一种花色此%arg额外结算一次！",
}

chengxih:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(chengxih.name) and
      data:isOnlyTarget(data.to) and not data.to:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = chengxih.name,
      prompt = "#chengxih-invoke::"..data.to.id,
    }) then
      event:setCostData(self, {tos = {data.to}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    data.to:showCards(data.to:getCardIds("h"))
    if data.to.dead then return end
    local cards = {}
    if not data.to:isNude() then
      cards = room:askToCards(data.to, {
        min_num = 1,
        max_num = 999,
        include_equip = true,
        skill_name = chengxih.name,
        prompt = "#chengxih-recast:::"..data.card:toLogString(),
        cancelable = false,
      })
    end
    local suits = {Card.Spade, Card.Heart, Card.Diamond, Card.Club}
    for _, id in ipairs(cards) do
      table.removeOne(suits, Fk:getCardById(id).suit)
    end
    if #suits > 0 then
      data.use.additionalEffect = (data.use.additionalEffect or 0) + #suits
    end
    if #cards > 0 then
      room:recastCard(cards, data.to, chengxih.name)
    end
  end,
})

return chengxih
