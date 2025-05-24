local kuishe = fk.CreateSkill {
  name = "ofl__kuishe",
}

Fk:loadTranslationTable{
  ["ofl__kuishe"] = "窥舍",
  [":ofl__kuishe"] = "出牌阶段限一次，你可以选择一名其他角色的一张牌，将之交另一名角色，然后失去牌的角色可以对你使用一张【杀】。",

  ["#ofl__kuishe"] = "窥舍：选择一名角色，将其一张牌交给另一名角色，其可以对你使用【杀】",
  ["#ofl__kuishe-choose"] = "窥舍：将这张牌交给另一名角色",
  ["#ofl__kuishe-slash"] = "窥舍：你可以对 %src 使用一张【杀】",
}

kuishe:addEffect("active", {
  anim_type = "control",
  prompt = "#ofl__kuishe",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(kuishe.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player and not to_select:isNude()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local id = room:askToChooseCard(player, {
      target = target,
      flag = "he",
      skill_name = kuishe.name,
    })
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room:getOtherPlayers(target, false),
      skill_name = kuishe.name,
      prompt = "#ofl__kuishe-choose",
      cancelable = false,
    })[1]
    room:obtainCard(to, id, false, fk.ReasonGive, player, kuishe.name)
    if player.dead or target.dead then return end
    local use = room:askToUseCard(target, {
      skill_name = kuishe.name,
      pattern = "slash",
      prompt = "#ofl__kuishe-slash:"..player.id,
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
  end,
})

return kuishe