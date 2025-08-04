local jianjing = fk.CreateSkill({
  name = "ofl__jianjing",
})

Fk:loadTranslationTable{
  ["ofl__jianjing"] = "谏旌",
  [":ofl__jianjing"] = "出牌阶段限一次，你可以与一名角色拼点，赢的角色对其攻击范围内一名角色造成1点伤害。",

  ["#ofl__jianjing"] = "谏旌：与一名角色拼点，赢者对攻击范围内一名角色造成1点伤害",
  ["#ofl__jianjing-choose"] = "谏旌：对攻击范围内一名角色造成1点伤害",
}

jianjing:addEffect("active", {
  anim_type = "offensive",
  prompt = "#ofl__jianjing",
  max_phase_use_time = 1,
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return not player:isKongcheng() and player:usedSkillTimes(jianjing.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and player:canPindian(to_select)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local pindian = player:pindian({target}, jianjing.name)
    local winner = pindian.results[target].winner
    if winner and not winner.dead then
      local targets = table.filter(room.alive_players, function (p)
        return winner:inMyAttackRange(p)
      end)
      if #targets == 0 then return end
      local tos = room:askToChoosePlayers(winner, {
        min_num = 1,
        max_num = 1,
        targets = targets,
        skill_name = jianjing.name,
        prompt = "#ofl__jianjing-choose",
        cancelable = false,
      })
      room:damage{
        from = winner,
        to = tos[1],
        damage = 1,
        skillName = jianjing.name,
      }
    end
  end,
})

return jianjing
