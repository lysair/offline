local shanshen = fk.CreateSkill {
  name = "ofl__shanshen",
}

Fk:loadTranslationTable{
  ["ofl__shanshen"] = "善身",
  [":ofl__shanshen"] = "当一名角色死亡时，你可以令〖隅泣〗中的一个数字+2（单项不能超过3）。若你没有对其造成过伤害，你回复1点体力。",

  ["#ofl__yuqi-upgrade"] = "%arg：选择令“隅泣”中的一个数字+%arg2",

  ["$ofl__shanshen1"] = "人家只想做安安静静的小淑女。",
  ["$ofl__shanshen2"] = "雪花纷飞，独存寒冬。",
}

local function AddYuqi(player, skillName, num)
  local room = player.room
  local choices = {}
  local all_choices = {}
  local yuqi_initial = {0, 3, 1, 1}
  for i = 1, 4, 1 do
    table.insert(all_choices, "ofl__yuqi" .. i)
    if player:getMark("ofl__yuqi" .. i) + yuqi_initial[i] < 3 then
      table.insert(choices, "ofl__yuqi" .. i)
    end
  end
  if #choices > 0 then
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = skillName,
      prompt = "#ofl__yuqi-upgrade:::"..skillName..":"..num,
      all_choices = all_choices,
    })
    room:setPlayerMark(player, choice, math.min(3 - yuqi_initial[table.indexOf(all_choices, choice)], player:getMark(choice) + num))
  end
end

shanshen:addEffect(fk.Death, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(shanshen.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if player:hasSkill("ofl__yuqi", true) then
      AddYuqi(player, shanshen.name, 2)
    end
    if player:isWounded() and
      #player.room.logic:getActualDamageEvents(1, function(e)
        local damage = e.data
        if damage.from == player and damage.to == target then
          return true
        end
      end, Player.HistoryGame) == 0 then
      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = shanshen.name,
      }
    end
  end,
})

return shanshen
