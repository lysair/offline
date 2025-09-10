local liufangc = fk.CreateSkill {
  name = "liufangc",
}

Fk:loadTranslationTable{
  ["liufangc"] = "流放",
  [":liufangc"] = "出牌阶段限一次或当你受到伤害后，你可以令一名角色摸X张牌并翻面，若X大于1，其进行一次【闪电】判定（X为你已损失的体力值）。",

  ["#liufangc"] = "流放：你可以令一名角色摸%arg张牌并翻面",
  ["#liufangc2"] = "流放：你可以令一名角色摸%arg张牌并翻面，然后其进行【闪电】判定",

  ["$liufangc1"] = "现在走，是你最好的选择。",
  ["$liufangc2"] = "这是本王最后的仁慈。",
}

liufangc:addEffect("active", {
  anim_type = "control",
  prompt = function (self, player, selected_cards, selected_targets)
    if player:getLostHp() < 2 then
      return "#liufangc:::"..player:getLostHp()
    else
      return "#liufangc2:::"..player:getLostHp()
    end
  end,
  card_num = 0,
  target_num = 1,
  can_use = function (self, player)
    return player:usedEffectTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target  = effect.tos[1]
    local n = player:getLostHp()
    if n > 0 then
      target:drawCards(n, liufangc.name)
      if target.dead then return end
    end
    target:turnOver()
    if target.dead then return end
    if n > 1 then
      local judge = {
        who = target,
        reason = "lightning",
        pattern = ".|2~9|spade",
      }
      room:judge(judge)
      if judge:matchPattern() then
        room:damage{
          to = target,
          damage = 3,
          damageType = fk.ThunderDamage,
          skillName = "lightning_skill",
        }
      end
    end
  end,
})

liufangc:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(liufangc.name)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local prompt = "#liufangc:::" .. player:getLostHp()
    if player:getLostHp() > 1 then
      prompt = "#liufangc2:::" .. player:getLostHp()
    end
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room.alive_players,
      skill_name = liufangc.name,
      prompt = prompt,
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local skill = Fk.skills[liufangc.name]
    skill:onUse(player.room, {
      from = player,
      tos = event:getCostData(self).tos,
    })
  end,
})

return liufangc
