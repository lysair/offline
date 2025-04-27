local jieyue = fk.CreateSkill({
  name = "ofl_mou__jieyue",
})

Fk:loadTranslationTable{
  ["ofl_mou__jieyue"] = "节钺",
  [":ofl_mou__jieyue"] = "结束阶段，你可以令一名其他角色摸两张牌并获得1点护甲，然后其交给你两张牌。",

  ["#ofl_mou__jieyue-choose"] = "节钺：令一名角色摸两张牌并获得1点护甲，然后其交给你两张牌。",
  ["#ofl_mou__jieyue-give"] = "节钺：请交给 %src 两张牌",

  ["$ofl_mou__jieyue1"] = "静守勿应，敌军自退。",
  ["$ofl_mou__jieyue2"] = "有我统军，必破其计！",
}

jieyue:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(jieyue.name) and target == player and player.phase == Player.Finish and
      #player.room:getOtherPlayers(player, false) > 0
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      targets = room:getOtherPlayers(player, false),
      min_num = 1,
      max_num = 1,
      prompt = "#ofl_mou__jieyue-choose",
      skill_name = jieyue.name,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    to:drawCards(2, jieyue.name)
    if to.dead then return end
    room:changeShield(to, 1)
    if not to:isNude() and not player.dead then
      local cards = room:askToCards(to, {
        min_num = 2,
        max_num = 2,
        include_equip = true,
        skill_name = jieyue.name,
        prompt = "#ofl_mou__jieyue-give:" .. player.id,
        cancelable = false,
      })
      room:obtainCard(player, cards, false, fk.ReasonGive, to, jieyue.name)
    end
  end,
})

return jieyue
