local xianjing = fk.CreateSkill {
  name = "ofl__xianjing",
}

Fk:loadTranslationTable{
  ["ofl__xianjing"] = "娴静",
  [":ofl__xianjing"] = "准备阶段，你可以令〖隅泣〗中的一个数字+1（单项不能超过3）。若你满体力值，则再令〖隅泣〗中的一个数字+1。",

  ["$ofl__xianjing1"] = "得父母之爱，享公主之礼遇。",
  ["$ofl__xianjing2"] = "哼，可不要小瞧女孩子啊。",
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

xianjing:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(xianjing.name) and player.phase == Player.Start and
      player:hasSkill("ofl__yuqi", true) then
      local yuqi_initial = {0, 3, 1, 1}
      for i = 1, 4 do
        if player:getMark("ofl__yuqi"..i) + yuqi_initial[i] < 3 then
          return true
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    AddYuqi(player, xianjing.name, 1)
    if not player:isWounded() then
      AddYuqi(player, xianjing.name, 1)
    end
  end,
})

return xianjing
