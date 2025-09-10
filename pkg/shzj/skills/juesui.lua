local juesui = fk.CreateSkill {
  name = "juesui",
}

Fk:loadTranslationTable{
  ["juesui"] = "玦碎",
  [":juesui"] = "每名角色限一次，当一名角色进入濒死状态时，你可以令其选择是否回复体力至1点并废除所有装备栏。"..
  "若其如此做，本局游戏其可以将黑色非基本牌当无次数限制的【杀】使用或打出。",

  ["#juesui-invoke"] = "玦碎：是否令 %dest 可以回复体力至1点并废除所有装备栏？",
  ["#juesui-ask"] = "玦碎：是否将体力值回复体力至1点并废除所有装备栏？",
  ["@@juesui"] = "玦碎",
}

juesui:addEffect(fk.EnterDying, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(juesui.name) and not target.dead and
      not table.contains(player:getTableMark(juesui.name), target.id)
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askToSkillInvoke(player, {
      skill_name = juesui.name,
      prompt = "#juesui-invoke::"..target.id,
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:addTableMark(player, juesui.name, target.id)
    if player ~= target and not room:askToSkillInvoke(target, {
      skill_name = juesui.name,
      prompt = "#juesui-ask",
    }) then return false end
    room:recover{
      who = target,
      num = 1 - target.hp,
      recoverBy = player,
      skillName = juesui.name,
    }
    if target.dead then return end
    local slots = target:getAvailableEquipSlots()
    if #slots > 0 then
      room:abortPlayerArea(target, slots)
    end
    if target.dead then return end
    room:setPlayerMark(target, "@@juesui", 1)
    room:handleAddLoseSkills(target, "juesui&")
  end,
})

juesui:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, juesui.name, 0)
end)

return juesui
