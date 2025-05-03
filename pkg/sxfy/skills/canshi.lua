local canshi = fk.CreateSkill {
  name = "sxfy__canshi",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["sxfy__canshi"] = "残蚀",
  [":sxfy__canshi"] = "锁定技，摸牌阶段，你改为摸受伤角色数的牌（至少一张），然后你本回合使用【杀】或普通锦囊牌指定受伤角色为目标时，"..
  "你须弃置一张牌。",
}

canshi:addEffect(fk.DrawNCards, {
  anim_type = "drawcard",
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = #table.filter(room.alive_players, function (p)
      return p:isWounded() or (player:hasSkill("guiming") and p.kingdom == "wu" and p ~= player)
    end)
    data.n = math.max(1, n)
  end,
})

canshi:addEffect(fk.TargetSpecifying, {
  anim_type = "negative",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and data.firstTarget and
      (data.card.trueName == "slash" or data.card:isCommonTrick()) and
      player:usedSkillTimes(canshi.name, Player.HistoryTurn) > 0 and not player:isNude() and
      table.find(data.use.tos, function(p)
        return p:isWounded() or (player:hasSkill("guiming") and p.kingdom == "wu" and p ~= player)
      end)
  end,
  on_use = function(self, event, target, player, data)
    player.room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = canshi.name,
      cancelable = false,
    })
  end,
})

return canshi
