local jiezhong = fk.CreateSkill {
  name = "shzj_guansuo__jiezhong",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable {
  ["shzj_guansuo__jiezhong"] = "竭忠",
  [":shzj_guansuo__jiezhong"] = "限定技，一名角色的准备阶段，你可以令其摸X张牌（X为你的体力值），若不为你，本轮结束时此技能视为未发动过。",

  ["#shzj_guansuo__jiezhong-invoke"] = "竭忠：你可以令 %dest 摸%arg张牌，本轮结束时重置此技能",
  ["#shzj_guansuo__jiezhong_self-invoke"] = "竭忠：你可以摸%arg张牌",

  ["$shzj_guansuo__jiezhong1"] = "",
  ["$shzj_guansuo__jiezhong2"] = "",
}

jiezhong:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(jiezhong.name) and target.phase == Player.Start and not target.dead and
      player.hp > 0 and player:usedSkillTimes(jiezhong.name, Player.HistoryGame) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if target == player then
      if room:askToSkillInvoke(player, {
        skill_name = jiezhong.name,
        prompt = "#shzj_guansuo__jiezhong_self-invoke:::"..player.hp,
      }) then
        event:setCostData(self, nil)
        return true
      end
    else
      if room:askToSkillInvoke(player, {
        skill_name = jiezhong.name,
        prompt = "#shzj_guansuo__jiezhong-invoke::"..target.id..":"..player.hp,
      }) then
        event:setCostData(self, {tos = {target}})
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    target:drawCards(player.hp, jiezhong.name)
    if target ~= player then
      room.logic:getCurrentEvent():findParent(GameEvent.Round):addCleaner(function()
        player:setSkillUseHistory(jiezhong.name, 0, Player.HistoryGame)
      end)
    end
  end,
})

return jiezhong
