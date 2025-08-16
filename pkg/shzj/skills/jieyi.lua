local jieyi = fk.CreateSkill{
  name = "jieyi",
}

Fk:loadTranslationTable{
  ["jieyi"] = "结衣",
  [":jieyi"] = "每轮开始时，你可以令一名男性角色交给你至少一张牌，其本轮称为“结衣”角色，然后若其手牌数大于其交给你的牌数，你可以失去1点体力，"..
  "令你本轮可以多发动一次〖理内〗。",

  ["#jieyi-choose"] = "结衣：你可以令一名男性角色交给你至少一张牌",
  ["@jieyi-round"] = "结衣",
  ["#jieyi-give"] = "结衣：请交给 %src 至少一张牌",
  ["#jieyi-invoke"] = "结衣：是否失去1点体力，本轮可以多发动一次“理内”？",
}

jieyi:addEffect(fk.RoundStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(jieyi.name) and
      table.find(player.room:getOtherPlayers(player, false), function (p)
        return p:isMale() and not p:isNude()
      end)
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player, false), function (p)
      return p:isMale() and not p:isNude()
    end)
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = jieyi.name,
      prompt = "#jieyi-choose",
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    room:setPlayerMark(player, "@jieyi-round", to)
    local cards = room:askToCards(to, {
      min_num = 1,
      max_num = 999,
      include_equip = true,
      skill_name = jieyi.name,
      prompt = "#jieyi-give:"..player.id,
      cancelable = false,
    })
    room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonGive, jieyi.name, nil, false, to)
    if to:getHandcardNum() > #cards and not player.dead and
      room:askToSkillInvoke(player, {
        skill_name = jieyi.name,
        prompt = "#jieyi-invoke",
      }) then
      room:addPlayerMark(player, "linei-round", 1)
      room:loseHp(player, 1, jieyi.name)
    end
  end,
})

return jieyi
