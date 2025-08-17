local shouwei = fk.CreateSkill {
  name = "shzj_juedai__shouwei",
}

Fk:loadTranslationTable{
  ["shzj_juedai__shouwei"] = "守卫",
  [":shzj_juedai__shouwei"] = "每回合每项限一次，当其他角色失去体力后，你摸一张牌或回复1点体力。",
}

shouwei:addEffect(fk.HpLost, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if target ~= player and player:hasSkill(shouwei.name) then
      if not table.contains(player:getTableMark("shzj_juedai__shouwei-turn"), "draw1") then
        return true
      else
        return player:isWounded() and not table.contains(player:getTableMark("shzj_juedai__shouwei-turn"), "recover")
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choices = {}
    if not table.contains(player:getTableMark("shzj_juedai__shouwei-turn"), "draw1") then
      table.insert(choices, "draw1")
    end
    if player:isWounded() and not table.contains(player:getTableMark("shzj_juedai__shouwei-turn"), "recover") then
      table.insert(choices, "recover")
    end
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = shouwei.name,
    })
    room:addTableMark(player, "shzj_juedai__shouwei-turn", choice)
    if choice == "draw1" then
      player:drawCards(1, shouwei.name)
    else
      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = shouwei.name
      }
    end
  end,
})

return shouwei
