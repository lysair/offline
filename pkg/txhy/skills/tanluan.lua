local tanluan = fk.CreateSkill {
  name = "ofl_tx__tanluan",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_tx__tanluan"] = "贪乱",
  [":ofl_tx__tanluan"] = "锁定技，当你获得<a href='os__baonue_href'>暴虐值</a>后，你可以消耗之，获得当前回合角色区域内的一张牌，"..
  "若当前回合角色为你则改为摸两张牌。",

  ["#ofl_tx__tanluan-prey"] = "贪乱：是否消耗1点暴虐值，获得 %dest 区域内一张牌？",
  ["#ofl_tx__tanluan-draw"] = "贪乱：是否消耗1点暴虐值，摸两张牌？",
}

tanluan.os__baonue = true

local spec = {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(tanluan.name) and
      data.extra_data and data.extra_data.ofl_tx__tanluan and
      player:getMark("@os__baonue") > data.extra_data.ofl_tx__tanluan
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local prompt = "#ofl_tx__tanluan-draw"
    if room.current ~= player then
      if room.current:isAllNude() then return end
      prompt = "#ofl_tx__tanluan-prey::"..room.current.id
    end
    if room:askToSkillInvoke(player, {
      skill_name = tanluan.name,
      prompt = prompt,
    }) then
      room:removePlayerMark(player, "@os__baonue", 1)
      if room.current ~= player then
        room:doIndicate(player, {room.current})
        local id = room:askToChooseCard(player, {
          target = room.current,
          flag = "hej",
          skill_name = tanluan.name,
        })
        room:moveCardTo(id, Card.PlayerHand, player, fk.ReasonPrey, tanluan.name, nil, false, player)
      else
        player:drawCards(2, tanluan.name)
      end
    end
  end,

  can_refresh = function (self, event, target, player, data)
    return target == player
  end,
  on_refresh = function (self, event, target, player, data)
    data.extra_data = data.extra_data or {}
    data.extra_data.ofl_tx__tanluan = player:getMark("@os__baonue")
  end,
}
tanluan:addEffect(fk.Damage, spec)
tanluan:addEffect(fk.Damaged, spec)

tanluan:addAcquireEffect(function(self, player)
  player.room:addSkill("#os__baonue_mark")
end)

return tanluan
