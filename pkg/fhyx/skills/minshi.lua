local minshi = fk.CreateSkill {
  name = "ofl_shiji__minshi",
}

Fk:loadTranslationTable{
  ["ofl_shiji__minshi"] = "悯施",
  [":ofl_shiji__minshi"] = "出牌阶段限一次，你可以选择所有手牌数少于体力值的角色并观看额外牌堆中至多三张基本牌，"..
  "将其中任意张牌交给任意角色。然后你选择的角色中每有一名未获得牌的角色，你失去1点体力。",

  ["#ofl_shiji__minshi"] = "悯施：你可以将额外牌堆三张基本牌任意分配",
  ["#ofl_shiji__minshi-give"] = "悯施：分配这些牌，每有一名没获得牌的目标角色，你失去1点体力",
}

local U = require "packages/offline/ofl_util"

minshi:addEffect("active", {
  anim_type = "support",
  card_num = 0,
  target_num = 0,
  prompt = "#ofl_shiji__minshi",
  can_use = function(self, player)
    return player:usedSkillTimes(minshi.name, Player.HistoryPhase) == 0 and
      table.find(Fk:currentRoom().alive_players, function(p)
        return p:getHandcardNum() < p.hp
      end) and
      table.find(Fk:currentRoom():getBanner("@$fhyx_extra_pile"), function(id)
        return Fk:getCardById(id).type == Card.TypeBasic
      end)
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    local targets = table.filter(room.alive_players, function(p)
      return p:getHandcardNum() < p.hp
    end)
    if #targets == 0 then return end
    room:doIndicate(player, targets)
    local cards = table.filter(room:getBanner("@$fhyx_extra_pile"), function(id)
      return Fk:getCardById(id).type == Card.TypeBasic
    end)
    cards = table.random(cards, 3)
    if #cards == 0 then return end
    local result = room:askToYiji(player, {
      targets = room.alive_players,
      cards = cards,
      skill_name = minshi.name,
      min_num = 0,
      max_num = #cards,
      prompt = "#ofl_shiji__minshi-give",
      expand_pile = cards,
    })
    local n = #table.filter(targets, function(p)
      return #result[p.id] == 0
    end)
    if n > 0 and not player.dead then
      room:loseHp(player, n, minshi.name)
    end
  end,
})

minshi:addAcquireEffect(function (self, player, is_start)
  U.PrepareExtraPile(player.room)
end)

return minshi
