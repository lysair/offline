local tianjie = fk.CreateSkill {
  name = "qshm__tianjie",
}

Fk:loadTranslationTable{
  ["qshm__tianjie"] = "天劫",
  [":qshm__tianjie"] = "每个回合结束时，若本回合牌堆进行过洗牌，你可以令至多三名其他角色展示手牌，对这些角色分别造成X点雷电伤害"..
  "（X为其手牌中【闪】的数量且至少为1）。",

  ["#qshm__tianjie-choose"] = "天劫：你可以令至多三名角色展示手牌，并根据其【闪】数造成雷电伤害",

  ["$qshm__tianjie1"] = "雷池铸剑，今霜刃即成，当振天下于大白。",
  ["$qshm__tianjie2"] = "汝辈食民脂、靡民膏，当受天劫而死！",
}

tianjie:addEffect(fk.TurnEnd, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(tianjie.name) and player:getMark("qshm__tianjie-turn") > 0 and
      #player.room:getOtherPlayers(player, false) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local tos = room:askToChoosePlayers(player, {
      skill_name = tianjie.name,
      min_num = 1,
      max_num = 3,
      targets = room:getOtherPlayers(player, false),
      prompt = "#qshm__tianjie-choose",
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
    for _, p in ipairs(event:getCostData(self).tos) do
      if not p.dead then
        local n = 1
        if not p:isKongcheng() then
          n = math.max(1, #table.filter(p:getCardIds("h"), function(id)
          return Fk:getCardById(id).trueName == "jink"
        end))
          p:showCards(p:getCardIds("h"))
        end
        if not p.dead then
          room:damage{
            from = player,
            to = p,
            damage = n,
            damageType = fk.ThunderDamage,
            skillName = tianjie.name,
          }
        end
      end
    end
  end,
})

tianjie:addEffect(fk.AfterDrawPileShuffle, {
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(tianjie.name, true) and
      player.room.logic:getCurrentEvent():findParent(GameEvent.Turn, true)
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "qshm__tianjie-turn", 1)
  end,
})

return tianjie
