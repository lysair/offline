
local zhongjianh = fk.CreateSkill{
  name = "ofl_tx__zhongjianh",
}

Fk:loadTranslationTable{
  ["ofl_tx__zhongjianh"] = "忠谏",
  [":ofl_tx__zhongjianh"] = "当你受到其他角色造成的1点伤害后，你可以与其各摸一张牌并展示之，你使用以此法获得的基本牌无次数限制，"..
  "你使用以此法获得的普通锦囊牌不能被响应。",

  ["#ofl_tx__zhongjianh-invoke"] = "忠谏：你可以与 %dest 各摸一张牌",
  ["@@ofl_tx__zhongjianh-inhand"] = "忠谏",
}

zhongjianh:addEffect(fk.Damaged, {
  anim_type = "masochism",
  trigger_times = function(self, event, target, player, data)
    return data.damage
  end,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zhongjianh.name) and
      data.from and data.from ~= player and not data.from.dead
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = zhongjianh.name,
      prompt = "#ofl_tx__zhongjianh-invoke::"..data.from.id,
    }) then
      event:setCostData(self, {tos = {data.from}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, zhongjianh.name, nil, "@@ofl_tx__zhongjianh-inhand")
    if not data.from.dead then
      data.from:drawCards(1, zhongjianh.name)
    end
  end,
})

zhongjianh:addEffect(fk.PreCardUse, {
  can_refresh = function (self, event, target, player, data)
    return target == player and data.card:getMark("@@ofl_tx__zhongjianh-inhand") > 0
  end,
  on_refresh = function (self, event, target, player, data)
    if data.card.type == Card.TypeBasic then
      data.extraUse = true
    elseif data.card:isCommonTrick() then
      data.disresponsiveList = table.simpleClone(player.room.players)
    end
  end,
})

zhongjianh:addEffect("targetmod", {
  bypass_times = function (self, player, skill, scope, card, to)
    return card and card.type == Card.TypeBasic and card:getMark("@@ofl_tx__zhongjianh-inhand") > 0
  end,
})

return zhongjianh
