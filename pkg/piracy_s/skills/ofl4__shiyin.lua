local shiyin = fk.CreateSkill {
  name = "ofl4__shiyin",
}

Fk:loadTranslationTable{
  ["ofl4__shiyin"] = "识音",
  [":ofl4__shiyin"] = "游戏开始时，你可以将一张手牌置于武将牌上，称为“杂音”；出牌阶段开始时，你可以用一张手牌替换“杂音”。",

  ["ofl__shiyin_pile"] = "杂音",
  ["#ofl4__shiyin-ask"] = "识音：你可以将一张手牌置为“杂音”",
  ["#ofl4__shiyin-exchange"] = "识音：你可以用一张手牌替换“杂音”",
}

shiyin:addEffect(fk.GameStart, {
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(shiyin.name) and not player:isKongcheng()
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local card = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = shiyin.name,
      prompt = "#ofl4__shiyin-ask",
      cancelable = true,
    })
    if #card > 0 then
      event:setCostData(self, {cards = card})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    player:addToPile("ofl__shiyin_pile", event:getCostData(self).cards, true, shiyin.name, player)
  end,
})

shiyin:addEffect(fk.EventPhaseStart, {
  anim_type = "switch",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(shiyin.name) and player.phase == Player.Play and
      not player:isKongcheng() and #player:getPile("ofl__shiyin_pile") > 0
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local card = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = shiyin.name,
      prompt = "#ofl4__shiyin-exchange",
      cancelable = true,
    })
    if #card > 0 then
      event:setCostData(self, {cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local cards1 = event:getCostData(self).cards
    local cards2 = player:getPile("ofl__shiyin_pile")
    player.room:swapCardsWithPile(player, cards1, cards2, shiyin.name, "ofl__shiyin_pile", true, player)
  end,
})

return shiyin
