local qianxun = fk.CreateSkill {
  name = "shzj_guansuo__qianxun",
}

Fk:loadTranslationTable{
  ["shzj_guansuo__qianxun"] = "谦逊",
  [":shzj_guansuo__qianxun"] = "判定阶段开始时，你可以弃置两张手牌，然后弃置判定区里的一张牌；出牌阶段，你可以弃置两张手牌，摸一张牌。",

  ["#shzj_guansuo__qianxun"] = "谦逊：你可以弃置两张手牌，摸一张牌",
  ["#shzj_guansuo__qianxun-invoke"] = "谦逊：你可以弃置两张手牌，弃置判定区里的一张牌",

  ["$shzj_guansuo__qianxun1"] = "谦虚谨慎，乃乱世立身之道。",
  ["$shzj_guansuo__qianxun2"] = "谦谦君子，卑以自牧也。",
}

qianxun:addEffect("active", {
  anim_type = "drawcard",
  prompt = "#shzj_guansuo__qianxun",
  card_num = 2,
  target_num = 0,
  can_use = Util.TrueFunc,
  card_filter = function(self, player, to_select, selected)
    return #selected < 2 and table.contains(player:getCardIds("h"), to_select) and not player:prohibitDiscard(to_select)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    room:throwCard(effect.cards, qianxun.name, player, player)
    if not player.dead then
      player:drawCards(1, qianxun.name)
    end
  end,
})

qianxun:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(qianxun.name) and player.phase == Player.Judge and
      player:getHandcardNum() >= 2 and #player:getCardIds("j") > 0
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local cards = room:askToDiscard(player, {
      min_num = 2,
      max_num = 2,
      include_equip = false,
      skill_name = qianxun.name,
      prompt = "#shzj_guansuo__qianxun-invoke",
      cancelable = true,
      skip = true,
    })
    if #cards == 2 then
      event:setCostData(self, {cards = cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(event:getCostData(self).cards, qianxun.name, player, player)
    local card = player:getCardIds("j")
    if player.dead or #card == 0 then return end
    if #card > 1 then
      card = room:askToChooseCard(player, {
        target = player,
        flag = "j",
        skill_name = qianxun.name,
      })
    end
    room:throwCard(card, qianxun.name, player, player)
  end,
})

return qianxun
