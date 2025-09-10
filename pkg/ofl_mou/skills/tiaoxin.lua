local tiaoxin = fk.CreateSkill {
  name = "ofl_mou__tiaoxin",
}

Fk:loadTranslationTable{
  ["ofl_mou__tiaoxin"] = "挑衅",
  [":ofl_mou__tiaoxin"] = "出牌阶段限一次，你可以令至多X名其他角色依次选择一项（X为你的体力值）：1.对你使用一张【杀】（无距离限制），" ..
  "若此【杀】未造成伤害，你获得其一张牌；2.令你获得其一张牌。",

  ["#ofl_mou__tiaoxin"] = "挑衅：令至多%arg名角色选择是否对你使用【杀】，若未造成伤害，你获得其一张牌",
  ["#ofl_mou__tiaoxin-use"] = "挑衅：对 %src 使用【杀】，若未造成伤害，其获得你一张牌",

  ["$ofl_mou__tiaoxin1"] = "你就这点本领吗？哈哈哈哈哈~",
  ["$ofl_mou__tiaoxin2"] = "就你？不过如此！",
}

tiaoxin:addEffect("active", {
  anim_type = "control",
  prompt = function (self, player, selected_cards, selected_targets)
    return "#ofl_mou__tiaoxin:::"..player.hp
  end,
  max_phase_use_time = 1,
  card_num = 0,
  min_target_num = 1,
  max_target_num = function (self, player)
    return player.hp
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(tiaoxin.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected < player.hp and to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local targets = table.simpleClone(effect.tos)
    room:sortByAction(targets)
    for _, target in ipairs(targets) do
      if player.dead then return end
      if not target.dead then
        local use = room:askToUseCard(target, {
          skill_name = tiaoxin.name,
          pattern = "slash",
          prompt = "#ofl_mou__tiaoxin-use:"..player.id,
          extra_data = {
            bypass_distances = true,
            bypass_times = true,
            exclusive_targets = {player.id},
          }
        })
        if use then
          use.extraUse = true
          room:useCard(use)
        end
        if not (use and use.damageDealt) and not target:isNude() then
          local card = room:askToChooseCard(player, {
            target = target,
            skill_name = tiaoxin.name,
            flag = "he",
          })
          room:obtainCard(player, card, false, fk.ReasonPrey, player, tiaoxin.name)
        end
      end
    end
  end,
})

return tiaoxin
