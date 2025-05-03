local wuyou = fk.CreateSkill {
  name = "sxfy__wuyou",
}

Fk:loadTranslationTable{
  ["sxfy__wuyou"] = "武佑",
  [":sxfy__wuyou"] = "出牌阶段限一次，你可以与一名角色拼点，若你没赢，你本回合视为拥有〖武圣〗。然后拼点赢的角色视为对没赢的角色使用一张"..
  "【决斗】。",

  ["#sxfy__wuyou"] = "武佑：与一名角色拼点，若你没赢则本回合获得〖武圣〗，然后赢者视为对对方使用【决斗】",
}

wuyou:addEffect("active", {
  anim_type = "offensive",
  prompt = "#sxfy__wuyou",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(wuyou.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and player:canPindian(to_select)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local pindian = player:pindian({target}, wuyou.name)
    if pindian.results[target].winner ~= player then
      if not player.dead and not player:hasSkill("wusheng", true) then
        room:handleAddLoseSkills(player, "wusheng")
        room.logic:getCurrentEvent():findParent(GameEvent.Turn):addCleaner(function()
          room:handleAddLoseSkills(player, "-wusheng")
        end)
      end
    end
    local from, to = player, player
    if pindian.results[target].winner == player then
      to = target
    elseif pindian.results[target].winner == target then
      from = target
    end
    if from ~= to and not from.dead and not to.dead then
      room:useVirtualCard("duel", nil, from, to, wuyou.name)
    end
  end,
})

return wuyou
