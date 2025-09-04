
local shicheng = fk.CreateSkill {
  name = "ofl_tx__shicheng",
}

Fk:loadTranslationTable{
  ["ofl_tx__shicheng"] = "噬城",
  [":ofl_tx__shicheng"] = "摸牌阶段，你可以改为消耗任意点<a href='os__baonue_href'>暴虐值</a>，"..
  "令等量名与你距离为1的已受伤角色各减1点体力上限，你增加等量的体力上限。",

  ["#ofl_tx__shicheng-choose"] = "噬城：放弃摸牌并消耗至多%arg点暴虐值，令等量角色减1点体力上限，你加等量体力上限",
}

shicheng.os__baonue = true

shicheng:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(shicheng.name) and player.phase == Player.Draw and
      not data.skipped and player:getMark("@os__baonue") > 0 and
      table.find(player.room.alive_players, function (p)
        return p:distanceTo(player) == 1 and p:isWounded()
      end)
  end,
  on_cost = function (self,event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function (p)
      return p:distanceTo(player) == 1 and p:isWounded()
    end)
    local tos = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = player:getMark("@os__baonue"),
      targets = targets,
      skill_name = shicheng.name,
      prompt = "#ofl_tx__shicheng-choose:::"..player:getMark("@os__baonue"),
      cancelable = true,
    })
    if #tos > 0 then
      room:sortByAction(tos)
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    data.phase_end = true
    local tos = event:getCostData(self).tos or {}
    room:removePlayerMark(player, "@os__baonue", #tos)
    local n = 0
    for _, p in ipairs(tos) do
      if not p.dead and room:changeMaxHp(p, -1) then
        n = n + 1
      end
    end
    if not player.dead then
      room:changeMaxHp(player, n)
    end
  end,
})

shicheng:addAcquireEffect(function(self, player)
  player.room:addSkill("#os__baonue_mark")
end)

return shicheng
