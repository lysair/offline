local tianyi = fk.CreateSkill({
  name = "ofl_tx__tianyi",
})

Fk:loadTranslationTable{
  ["ofl_tx__tianyi"] = "天义",
  [":ofl_tx__tianyi"] = "出牌阶段限一次，你可以与一名角色拼点，若你赢，直到此阶段结束，你可以多使用一张【杀】、使用【杀】无距离限制"..
  "且可以额外指定一个目标。",

  ["#ofl_tx__tianyi"] = "天义：与一名角色拼点，若赢，你本阶段使用【杀】获得增益",

  ["$ofl_tx__tianyi1"] = "请助我一臂之力！",
  ["$ofl_tx__tianyi2"] = "我当要替天行道！",
}

tianyi:addEffect("active", {
  anim_type = "offensive",
  prompt = "#ofl_tx__tianyi",
  max_phase_use_time = 1,
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return not player:isKongcheng() and player:usedSkillTimes(tianyi.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= player and player:canPindian(to_select)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local pindian = player:pindian({target}, tianyi.name)
    if player.dead then return end
    if pindian.results[target].winner == player then
      room:addPlayerMark(player, "ofl_tx__tianyi_win-phase", 1)
    end
  end,
})
tianyi:addEffect("targetmod", {
  residue_func = function(self, player, skill, scope)
    if skill.trueName == "slash_skill" and player:getMark("ofl_tx__tianyi_win-phase") > 0 and scope == Player.HistoryPhase then
      return 1
    end
  end,
  bypass_distances =  function(self, player, skill)
    return skill.trueName == "slash_skill" and player:getMark("ofl_tx__tianyi_win-phase") > 0
  end,
  extra_target_func = function(self, player, skill)
    if skill.trueName == "slash_skill" and player:getMark("ofl_tx__tianyi_win-phase") > 0 then
      return 1
    end
  end,
})

return tianyi
