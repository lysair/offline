local gushe = fk.CreateSkill {
  name = "sxfy__gushe",
}

Fk:loadTranslationTable{
  ["sxfy__gushe"] = "鼓舌",
  [":sxfy__gushe"] = "出牌阶段限一次，你可以与一名角色拼点，拼点赢的角色摸一张牌，然后拼点输的角色可以与对方重复此流程。",

  ["#sxfy__gushe"] = "鼓舌：与一名角色拼点，赢的角色摸一张牌，输的角色可以继续拼点",
  ["#sxfy__gushe-invoke"] = "鼓舌：是否继续与 %dest 拼点？",
}

gushe:addEffect("active", {
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  prompt = "#sxfy__gushe",
  can_use = function(self, player)
    return player:usedSkillTimes(gushe.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and player:canPindian(to_select)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    while not player.dead and not target.dead do
      local pindian = player:pindian({target}, gushe.name)
      local from, to = player, player
      if pindian.results[target].winner == player then
        to = target
      elseif pindian.results[target].winner == target then
        from = target
      end
      if from ~= to and not from.dead then
        from:drawCards(1, gushe.name)
      end
      if from ~= to and not from.dead and not to.dead and to:canPindian(from) and
        room:askToSkillInvoke(to, {
          skill_name = gushe.name,
          prompt = "#sxfy__gushe-invoke::"..from.id,
        }) then
        player, target = to, from
        room:doIndicate(to, {from})
      else
        return
      end
    end
  end,
})

return gushe
