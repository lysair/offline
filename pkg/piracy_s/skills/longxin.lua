local longxin = fk.CreateSkill {
  name = "ofl__longxin",
}

Fk:loadTranslationTable{
  ["ofl__longxin"] = "龙心",
  [":ofl__longxin"] = "判定阶段开始时，你可以弃置一张装备牌，然后弃置你的判定区里的一张牌。",

  ["#ofl__longxin-invoke"] = "龙心：你可以弃置一张装备牌，弃置判定区里的一张牌",

  ["$ofl__longxin1"] = "",
  ["$ofl__longxin2"] = "",
}

longxin:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(longxin.name) and player.phase == Player.Judge and
      not player:isNude() and #player:getCardIds("j") > 0
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local cards = room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = longxin.name,
      pattern = ".|.|.|.|.|equip",
      prompt = "#ofl__longxin-invoke",
      cancelable = true,
      skip = true,
    })
    if #cards > 0 then
      event:setCostData(self, {cards = cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(event:getCostData(self).cards, longxin.name, player, player)
    local card = player:getCardIds("j")
    if player.dead or #card == 0 then return end
    if #card > 1 then
      card = room:askToChooseCard(player, {
        target = player,
        flag = "j",
        skill_name = longxin.name,
      })
    end
    room:throwCard(card, longxin.name, player, player)
  end,
})

return longxin
