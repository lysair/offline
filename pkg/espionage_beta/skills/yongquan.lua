local yongquan = fk.CreateSkill {
  name = "yongquan$"
}

Fk:loadTranslationTable{
  ['#yongquan-give'] = '拥权：你可以交给 %src 一张牌',
}

yongquan:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yongquan.name) and player.phase == Player.Finish and
      table.find(player.room:getOtherPlayers(player, false), function(p) return p.kingdom == "qun" and not p:isNude() end)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, table.map(table.filter(room:getOtherPlayers(player), function(p)
      return p.kingdom == "qun" end), function(p) return p.id end))
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if player.dead then return end
      if p.kingdom == "qun" and not p:isNude() and not p.dead then
        local card = room:askToCards(p, {
          min_num = 1,
          max_num = 1,
          include_equip = true,
          skill_name = yongquan.name,
          cancelable = true,
          prompt = "#yongquan-give:" .. player.id
        })
        if #card > 0 then
          room:obtainCard(player, card[1], false, fk.ReasonGive)
        end
      end
    end
  end,
})

return yongquan
