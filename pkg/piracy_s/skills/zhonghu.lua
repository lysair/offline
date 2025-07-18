local zhonghu = fk.CreateSkill {
  name = "ofl__zhonghu",
}

Fk:loadTranslationTable{
  ["ofl__zhonghu"] = "冢虎",
  [":ofl__zhonghu"] = "你的回合外有角色死亡后，你可以立即终止当前角色回合，并且游戏轮次跳至你的回合。",

  ["#ofl__zhonghu-invoke"] = "冢虎：是否立即跳至你的回合？",
}

zhonghu:addEffect(fk.Deathed, {
  anim_type = "offensive",
  priority = 0.001,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(zhonghu.name) and target.rest < 1 and player.phase == Player.NotActive and
      player.room.logic:getCurrentEvent():findParent(GameEvent.Turn) ~= nil
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = zhonghu.name,
      prompt = "#ofl__zhonghu-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setBanner(zhonghu.name, player.id)
    room.logic:breakTurn()
  end,
})

zhonghu:addEffect(fk.EventTurnChanging, {
  can_refresh = function (self, event, target, player, data)
    return player.room:getBanner(zhonghu.name) == player.id
  end,
  on_refresh = function (self, event, target, player, data)
    if data.to == player then
      player.room:setBanner(zhonghu.name, 0)
    else
      data.skipped = true
    end
  end,
})

return zhonghu
