local yongdiz = fk.CreateSkill {
  name = "sxfy__yongdiz",
}

Fk:loadTranslationTable {
  ["sxfy__yongdiz"] = "拥帝",
  [":sxfy__yongdiz"] = "每轮限一次，一名角色的准备阶段，你可以令其本回合使用【杀】次数+1且无距离限制，本回合其弃牌阶段，"..
  "若其本回合造成过伤害，则跳过此阶段。",

  ["#sxfy__yongdiz-invoke"] = "拥帝：是否令 %dest 本回合使用【杀】次数+1且无距离限制？",
  ["@@sxfy__yongdiz-turn"] = "拥帝",
}

yongdiz:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(yongdiz.name) and target.phase == Player.Start and
      not target.dead and player:usedSkillTimes(yongdiz.name, Player.HistoryRound) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = yongdiz.name,
      prompt = "#sxfy__yongdiz-invoke::"..target.id,
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(target, "@@sxfy__yongdiz-turn", 1)
    room:addPlayerMark(target, MarkEnum.SlashResidue.."-turn", 1)
  end,
})

yongdiz:addEffect("targetmod", {
  bypass_distances = function (self, player, skill, card, to)
    return player:getMark("@@sxfy__yongdiz-turn") > 0 and card and card.trueName == "slash"
  end,
})

yongdiz:addEffect(fk.EventPhaseChanging, {
  can_refresh = function (self, event, target, player, data)
    return target == player and data.phase == Player.Discard and player:getMark("@@sxfy__yongdiz-turn") > 0 and
      #player.room.logic:getActualDamageEvents(1, function (e)
        return e.data.from == player
      end, Player.HistoryTurn) > 0
  end,
  on_refresh = function (self, event, target, player, data)
    data.skipped = true
  end,
})

return yongdiz
