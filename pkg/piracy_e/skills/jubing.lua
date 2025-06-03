local jubing = fk.CreateSkill {
  name = "jubing",
}

Fk:loadTranslationTable{
  ["jubing"] = "举兵",
  [":jubing"] = "每回合限一次，当一名角色受到伤害后，若其在群势力角色的攻击范围内，你可以弃置这些角色各一张牌，视为你对受伤角色使用X张【杀】"..
  "（X为你以此法弃置的牌数）。",

  ["#jubing-invoke"] = "举兵：是否弃置群势力角色的牌，视为对 %dest 使用【杀】？",
  ["#jubing-discard"] = "举兵：弃置 %dest 一张牌",
}

jubing:addEffect(fk.Damaged, {
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(jubing.name) and not target.dead and
      player:usedSkillTimes(jubing.name, Player.HistoryTurn) == 0 and
      table.find(player.room.alive_players, function (p)
        return p.kingdom == "qun" and p:inMyAttackRange(target) and not p:isNude()
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = jubing.name,
      prompt = "#jubing-invoke::"..target.id,
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getAlivePlayers(), function (p)
      return p.kingdom == "qun" and p:inMyAttackRange(target) and not p:isNude()
    end)
    local n = 0
    for _, p in ipairs(targets) do
      if player.dead then return end
      if not p:isNude() and not p.dead then
        if p == player then
          if #room:askToDiscard(player, {
            min_num = 1,
            max_num = 1,
            include_equip = true,
            skill_name = jubing.name,
            cancelable = false,
            prompt = "#jubing-discard::"..p.id,
          }) > 0 then
            n = n + 1
          end
        else
          n = n + 1
          local card = room:askToChooseCard(player, {
            target = p,
            flag = "he",
            skill_name = jubing.name,
            prompt = "#jubing-discard::"..p.id,
          })
          room:throwCard(card, jubing.name, p, player)
        end
      end
    end
    if n > 0 then
      for _ = 1, n do
        if not player.dead and not target.dead then
          room:useVirtualCard("slash", nil, player, target, jubing.name, true)
        else
          return
        end
      end
    end
  end,
})

return jubing
