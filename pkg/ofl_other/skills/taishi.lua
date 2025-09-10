local taishi = fk.CreateSkill {
  name = "taishi",
  tags = { Skill.Lord, Skill.Limited },
}

Fk:loadTranslationTable{
  ["taishi"] = "泰始",
  [":taishi"] = "主公技，限定技，一名角色的回合开始前，你可以令所有隐匿角色依次登场。",
}

local U = require "packages/utility/utility"

taishi:addEffect(fk.Damage, {
  priority = 2,
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(taishi.name) and player:usedSkillTimes(taishi.name, Player.HistoryGame) == 0 and
      table.find(player.room.alive_players, function(p)
        return p:getMark("__hidden_general") ~= 0 or p:getMark("__hidden_deputy") ~= 0
      end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room:getAlivePlayers()) do
      U.GeneralAppear(p, taishi.name)
    end
  end,
})

return taishi
