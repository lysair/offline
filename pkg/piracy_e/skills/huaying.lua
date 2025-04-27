local huaying = fk.CreateSkill {
  name = "huaying",
}

Fk:loadTranslationTable{
  ["huaying"] = "花影",
  [":huaying"] = "当一名起义军杀死除其以外的角色后或死亡后，你可以令一名起义军复原武将牌且视为其未发动过〖缭乱〗。",

  ["#huaying-choose"] = "花影：你可以令一名起义军复原武将牌且视为其未发动过“缭乱”",
}

local U = require "packages/offline/ofl_util"

huaying:addEffect(fk.Deathed, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(huaying.name) and
      (U.isInsurrectionary(target) or (data.killer and U.isInsurrectionary(data.killer) and target ~= data.killer)) and
      table.find(player.room.alive_players, function (p)
        return U.isInsurrectionary(p)
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function (p)
      return U.isInsurrectionary(p)
    end)
    local to = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#huaying-choose",
      skill_name = huaying.name,
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local to = event:getCostData(self).tos[1]
    to:setSkillUseHistory("liaoluan", 0, Player.HistoryGame)
    to:reset()
  end,
})

return huaying
