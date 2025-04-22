local zhanyan = fk.CreateSkill {
  name = "ofl__zhanyan",
}

Fk:loadTranslationTable{
  ["ofl__zhanyan"] = "绽焰",
  [":ofl__zhanyan"] = "出牌阶段限一次，你可以令你攻击范围内的所有角色依次选择一项：1.你对其造成1点火焰伤害；2.将手牌或弃牌堆中的一张"..
  "【火攻】或火【杀】置于牌堆顶。选择完成后，你摸X张牌（X为被选择次数较少的项被选择的次数）。",

  ["#ofl__zhanyan"] = "绽焰：令攻击范围内的角色选择受到火焰伤害或将【火攻】或火【杀】置于牌堆顶",
  ["#ofl__zhanyan-put"] = "绽焰：将一张【火攻】或火【杀】置于牌堆顶，点“取消”则受到1点火焰伤害",
}

zhanyan:addEffect("active", {
  anim_type = "offensive",
  prompt = "#ofl__zhanyan",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(zhanyan.name, Player.HistoryPhase) == 0 and
      table.find(Fk:currentRoom().alive_players, function(p) return player:inMyAttackRange(p) end)
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    local targets = table.filter(room:getOtherPlayers(player), function(p)
      return player:inMyAttackRange(p) end)
    if #targets == 0 then return end
    room:doIndicate(player, targets)
    local n1, n2 = 0, 0
    for _, target in ipairs(targets) do
      if not target.dead then
        local expand_pile = table.filter(room.discard_pile, function(id)
          return Fk:getCardById(id).name == "fire__slash" or Fk:getCardById(id).trueName == "fire_attack"
        end)
        local card = room:askToCards(target, {
          skill_name = zhanyan.name,
          min_num = 1,
          max_num = 1,
          include_equip = false,
          pattern = ".|.|.|.|fire__slash;fire_attack",
          prompt = "#ofl__zhanyan-put",
          expand_pile = expand_pile,
          cancelable = true,
        })
        if #card == 1 then
          n2 = n2 + 1
          if table.contains(target:getCardIds("h"), card[1]) then
            room:moveCards({
              ids = card,
              from = target,
              toArea = Card.DrawPile,
              moveReason = fk.ReasonPut,
              skillName = zhanyan.name,
              proposer = target,
              moveVisible = true,
            })
          else
            room:moveCards({
              ids = card,
              toArea = Card.DrawPile,
              moveReason = fk.ReasonPut,
              skillName = zhanyan.name,
              proposer = target,
              moveVisible = true,
            })
          end
        else
          n1 = n1 + 1
          room:damage{
            from = player,
            to = target,
            damage = 1,
            damageType = fk.FireDamage,
            skillName = zhanyan.name,
          }
        end
      end
    end
    if not player.dead and n1 ~= 0 and n2 ~= 0 then
      player:drawCards(math.min(n1, n2), zhanyan.name)
    end
  end,
})

return zhanyan
