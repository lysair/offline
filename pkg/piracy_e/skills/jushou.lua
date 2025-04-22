local jushou = fk.CreateSkill {
  name = "ofl__jushou",
}

Fk:loadTranslationTable{
  ["ofl__jushou"] = "据守",
  [":ofl__jushou"] = "结束阶段，你可以翻面并摸X张牌（X为存活角色数），然后你可以令所有角色翻面并各摸三张牌，若如此做，你弃置场上所有装备牌，"..
  "失去〖据守〗，获得〖突围〗。",

  ["#ofl__jushou-invoke"] = "据守：是否令所有角色翻面、摸三张牌、弃置装备，然后你失去“据守”获得“突围”？",
}

jushou:addEffect(fk.EventPhaseEnd, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jushou.name) and player.phase == Player.Finish
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(#room.alive_players, jushou.name)
    if player.dead then return end
    player:turnOver()
    if player.dead then return end
    if room:askToSkillInvoke(player, {
      skill_name = jushou.name,
      prompt = "#ofl__jushou-invoke",
    }) then
      room:doIndicate(player, room.alive_players)
      for _, p in ipairs(room:getAlivePlayers()) do
        if not p.dead then
          p:turnOver()
        end
        if not p.dead then
          p:drawCards(3, jushou.name)
        end
      end
      for _, p in ipairs(room:getAlivePlayers()) do
        if not p.dead then
          p:throwAllCards("e", jushou.name)
        end
      end
      if player.dead then return end
      room:handleAddLoseSkills(player, "-ofl__jushou|ofl__tuwei")
    end
  end,
})

return jushou
