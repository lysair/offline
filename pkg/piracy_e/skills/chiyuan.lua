local chiyuan = fk.CreateSkill {
  name = "ofl__chiyuan",
}

Fk:loadTranslationTable{
  ["ofl__chiyuan"] = "驰援",
  [":ofl__chiyuan"] = "出牌阶段，你可以交给任意名角色各一枚“驻”标记。有“驻”标记的角色受到伤害时，你可以弃置一张牌，然后选择一项："..
  "1.防止此伤害，然后移除其一枚“驻”标记；2.对伤害来源造成1点伤害。",

  ["#ofl__chiyuan"] = "驰援：交给任意名角色各一枚“驻”标记，当其受到伤害时你可以弃一张牌执行效果",
  ["#ofl__chiyuan-invoke"] = "驰援：%dest 受到伤害，你可以弃一张牌执行效果",
  ["ofl__chiyuan1"] = "防止%dest受到的伤害，移除其一枚“驻”标记",
  ["ofl__chiyuan2"] = "对%dest造成1点伤害",
}

chiyuan:addEffect("active", {
  anim_type = "support",
  prompt = "#ofl__chiyuan",
  card_num = 0,
  min_target_num = 1,
  can_use = function(self, player)
    return player:getMark("@ofl__zhuying") > 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function (self, player, to_select, selected, selected_cards)
    return to_select ~= player and #selected < player:getMark("@ofl__zhuying")
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    room:removePlayerMark(player, "@ofl__zhuying", #effect.tos)
    for _, p in ipairs(effect.tos) do
      room:addPlayerMark(p, "@ofl__zhuying", 1)
    end
  end,
})

chiyuan:addEffect(fk.DamageInflicted, {
  anim_type = "support",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(chiyuan.name) and
      target:getMark("@ofl__zhuying") > 0 and not player:isNude()
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local card = room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = chiyuan.name,
      prompt = "#ofl__chiyuan-invoke::"..target.id,
      cancelable = true,
      skip = true,
    })
    if #card > 0 then
      event:setCostData(self, {cards = card})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:throwCard(event:getCostData(self).cards, chiyuan.name, player, player)
    if player.dead then return end
    local choices = {}
    if not target.dead then
      table.insert(choices, "ofl__chiyuan1::"..target.id)
    end
    if data.from and not data.from.dead then
      table.insert(choices, "ofl__chiyuan2::"..data.from.id)
    end
    if #choices == 0 then return end
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = chiyuan.name,
    })
    if choice:startsWith("ofl__chiyuan1") then
      data:preventDamage()
      room:removePlayerMark(target, "@ofl__zhuying", 1)
    else
      room:doIndicate(player, {data.from})
      room:damage{
        from = player,
        to = data.from,
        damage = 1,
        skillName = chiyuan.name,
      }
    end
  end,
})

chiyuan:addLoseEffect(function (self, player, is_death)
  local room = player.room
  if not table.find(room.alive_players, function (p)
    return p:hasSkill(chiyuan.name, true) or p:hasSkill("ofl__zhuying", true)
  end) then
    for _, p in ipairs(room.alive_players) do
      room:setPlayerMark(p, "@ofl__zhuying", 0)
    end
  end
end)

return chiyuan
