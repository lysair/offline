local zhaoyuan = fk.CreateSkill {
  name = "zhaoyuan",
}

Fk:loadTranslationTable {
  ["zhaoyuan"] = "诏援",
  [":zhaoyuan"] = "出牌阶段，你可以将所有手牌交给一名其他角色，然后令该角色与你指定的另一名角色拼点，拼点赢的角色视为使用一张无距离限制的【杀】。",

  ["#zhaoyuan"] = "诏援：将所有手牌交给一名角色，令其与另一名角色拼点",
  ["#zhaoyuan-choose"] = "诏援：选择与 %dest 拼点的角色，赢者视为使用无距离限制的【杀】",
  ["#zhaoyuan-slash"] = "诏援：请视为使用一张无距离限制的【杀】",

  ["$zhaoyuan1"] = "愿卿纠合忠义之士，按此血诏行事！",
  ["$zhaoyuan2"] = "环顾朝堂，朕……唯赖爱卿！",
}

zhaoyuan:addEffect("active", {
  anim_type = "control",
  prompt = "#zhaoyuan",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return not player:isKongcheng()
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    room:obtainCard(target, player:getCardIds("h"), false, fk.ReasonGive, player)
    if player.dead or target.dead or target:isKongcheng() then return end
    local targets = table.filter(room.alive_players, function(p)
      return target:canPindian(p) and p ~= target
    end)
    if #targets == 0 then return end
    local to = room:askToChoosePlayers(player, {
      skill_name = zhaoyuan.name,
      min_num = 1,
      max_num = 1,
      targets = targets,
      prompt = "#zhaoyuan-choose::"..target.id,
      cancelable = false,
    })[1]
    local pindian = target:pindian({to}, zhaoyuan.name)
    local winner = pindian.results[to].winner
    if winner and not winner.dead then
      room:askToUseVirtualCard(winner, {
        name = "slash",
        skill_name = zhaoyuan.name,
        prompt = "#zhaoyuan-slash",
        cancelable = false,
        extra_data = {
          bypass_distances = true,
          bypass_times = true,
          extraUse = true,
        },
      })
    end
  end
})

return zhaoyuan
