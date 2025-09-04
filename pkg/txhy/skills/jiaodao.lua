
local jiaodao = fk.CreateSkill {
  name = "ofl_tx__jiaodao",
}

Fk:loadTranslationTable{
  ["ofl_tx__jiaodao"] = "狡盗",
  [":ofl_tx__jiaodao"] = "准备阶段和结束阶段，你可以消耗任意点<a href='os__baonue_href'>暴虐值</a>，获得等量名与你距离为1的角色各一张手牌。",

  ["#ofl_tx__jiaodao-choose"] = "狡盗：消耗至多%arg点暴虐值，获得等量角色各一张手牌",

  ["$ofl_tx__jiaodao1"] = "此机，我怎么会错失！",
  ["$ofl_tx__jiaodao2"] = "你的东西，现在是我的了！",
}

jiaodao.os__baonue = true

jiaodao:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jiaodao.name) and
      (player.phase == Player.Start or player.phase == Player.Finish) and
      player:getMark("@os__baonue") > 0 and
      table.find(player.room.alive_players, function (p)
        return p:distanceTo(player) == 1 and not p:isKongcheng()
      end)
  end,
  on_cost = function (self,event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function (p)
        return p:distanceTo(player) == 1 and not p:isKongcheng()
      end)
    local tos = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = player:getMark("@os__baonue"),
      targets = targets,
      skill_name = jiaodao.name,
      prompt = "#ofl_tx__jiaodao-choose:::"..player:getMark("@os__baonue"),
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
    local tos = event:getCostData(self).tos or {}
    room:removePlayerMark(player, "@os__baonue", #tos)
    for _, p in ipairs(tos) do
      if not p.dead and not p:isKongcheng() then
        local id = room:askToChooseCard(player, {
          target = p,
          flag = "h",
          skill_name = jiaodao.name,
        })
        room:moveCardTo(id, Card.PlayerHand, player, fk.ReasonPrey, jiaodao.name, nil, false, player)
        if player.dead then return end
      end
    end
  end,
})

jiaodao:addAcquireEffect(function(self, player)
  player.room:addSkill("#os__baonue_mark")
end)

return jiaodao
