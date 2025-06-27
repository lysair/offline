local jianshu = fk.CreateSkill {
  name = "ofl__jianshu",
}

Fk:loadTranslationTable{
  ["ofl__jianshu"] = "间书",
  [":ofl__jianshu"] = "出牌阶段限一次，你可以将一张牌交给一名其他角色，然后选择另一名其他角色，令这两名角色拼点：赢的角色弃置两张牌，"..
  "没赢的角色失去1点体力。",

  ["#ofl__jianshu"] = "间书：将一张牌交给一名角色，令其与你选择的角色拼点，赢者弃牌，没赢者失去体力",
  ["#ofl__jianshu-choose"] = "间书：选择另一名其他角色，令其和 %dest 拼点",
}

jianshu:addEffect("active", {
  anim_type = "control",
  prompt = "#ofl__jianshu",
  card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(jianshu.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0
  end,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    room:obtainCard(target, Fk:getCardById(effect.cards[1]), false, fk.ReasonGive)
    if player.dead or target.dead then return end
    local targets = table.filter(room:getOtherPlayers(target, false), function (p)
      return p ~= player and target:canPindian(p)
    end)
    if #targets == 0 then return end
    local to = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#ofl__jianshu-choose::"..target.id,
      skill_name = jianshu.name,
      cancelable = false,
    })[1]
    local pindian = target:pindian({to}, jianshu.name)
    if pindian.results[to].winner then
      local winner, loser
      if pindian.results[to].winner == target then
        winner = target
        loser = to
      else
        winner = to
        loser = target
      end
      if not winner.dead then
        room:askToDiscard(winner, {
          min_num = 2,
          max_num = 2,
          include_equip = true,
          skill_name = jianshu.name,
          cancelable = false,
        })
      end
      if not loser.dead then
        room:loseHp(loser, 1, jianshu.name)
      end
    else
      targets = {target, to}
      room:sortByAction(targets)
      for _, p in ipairs(targets) do
        if not p.dead then
          room:loseHp(p, 1, jianshu.name)
        end
      end
    end
  end,
})

return jianshu
