local suozhou = fk.CreateSkill {
  name = "ofl__suozhou",
}

Fk:loadTranslationTable{
  ["ofl__suozhou"] = "索舟",
  [":ofl__suozhou"] = "每回合限一次，当你成为♣牌的目标时或当你使用♣牌时，你可以令所有处于连环状态的角色各摸一张牌。",

  ["#ofl__suozhou-invoke"] = "索舟：你可以令所有处于连环状态的角色各摸一张牌",
}

local spec = {
  anim_type = "support",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(suozhou.name) and
      data.card.suit == Card.Club and
      player:usedSkillTimes(suozhou.name, Player.HistoryTurn) == 0 and
      table.find(player.room.players, function (p)
        return p.chained
      end)
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = suozhou.name,
      prompt = "#ofl__suozhou-invoke",
    }) then
      local tos = table.filter(room:getAlivePlayers(), function (p)
        return p.chained
      end)
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    for _, p in ipairs(event:getCostData(self).tos) do
      if not p.dead then
        p:drawCards(1, suozhou.name)
      end
    end
  end,
}

suozhou:addEffect(fk.TargetConfirming, spec)
suozhou:addEffect(fk.CardUsing, spec)

return suozhou
