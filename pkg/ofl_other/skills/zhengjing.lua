local zhengjing = fk.CreateSkill {
  name = "ofl__zhengjing",
}

Fk:loadTranslationTable {
  ["ofl__zhengjing"] = "整经",
  [":ofl__zhengjing"] = "出牌阶段限一次，你可以进行一次判定，若因此判定结果的点数之和不大于21，你选择一项：1.选择其中任意张牌令一名其他角色"..
  "获得，跳过其下个判定阶段和摸牌阶段，你获得其余判定牌；2.继续进行判定。",

  ["#ofl__zhengjing"] = "整经：进行判定，若点数之和不大于21可以继续判定或分配判定牌",
  ["#ofl__zhengjing-invoke"] = "整经：是否继续判定？（当前总点数：%arg）",
  ["#ofl__zhengjing-give"] = "整经：你可以令一名其他角色获得其中任意张牌，其跳过下个判定阶段和摸牌阶段",
  ["@@ofl__zhengjing"] = "整经",

  ["$ofl__zhengjing1"] = "此经已著毕，汝可视观之。",
  ["$ofl__zhengjing2"] = "举吾一家之见，其反诸位之解。",
}

zhengjing:addEffect("active", {
  anim_type = "drawcard",
  card_num = 0,
  target_num = 0,
  prompt = "#ofl__zhengjing",
  can_use = function(self, player)
    return player:usedSkillTimes(zhengjing.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    local cards, total, pattern = {}, 0, "."
    while not player.dead do
      local judge = {
        who = player,
        reason = zhengjing.name,
        pattern = pattern,
      }
      room:judge(judge)
      if judge.card then
        table.insertTableIfNeed(cards, Card:getIdList(judge.card))
        total = total + judge.card.number
        local rest = math.min(21 - total, 14)
        rest = math.max(rest, 1)
        pattern = ".|0~"..rest
        if total > 21 then
          return
        elseif not room:askToSkillInvoke(player, {
          skill_name = zhengjing.name,
          prompt = "#ofl__zhengjing-invoke:::"..total
        }) then
          break
        end
      end
    end
    if not player.dead then
      cards = table.filter(cards, function (id)
        return table.contains(room.discard_pile, id)
      end)
      if #cards > 0 then
        if #room:getOtherPlayers(player, false) > 0 then
          local tos, ids = room:askToChooseCardsAndPlayers(player, {
            min_num = 1,
            max_num = 1,
            min_card_num = 1,
            max_card_num = #cards,
            targets = room:getOtherPlayers(player, false),
            pattern = tostring(Exppattern{ id = cards }),
            skill_name = zhengjing.name,
            prompt = "#ofl__zhengjing-give",
            cancelable = true,
            expand_pile = cards,
          })
          if #tos > 0 and #ids > 0 then
            local to = tos[1]
            room:setPlayerMark(to, "@@ofl__zhengjing", {Player.Judge, Player.Draw})
            room:moveCardTo(ids, Card.PlayerHand, to, fk.ReasonJustMove, zhengjing.name, nil, true, player)
          end
          cards = table.filter(cards, function (id)
            return table.contains(room.discard_pile, id)
          end)
        end
        if #cards > 0 and not player.dead then
          room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonJustMove, zhengjing.name, nil, true, player)
        end
      end
    end
  end,
})

zhengjing:addEffect(fk.EventPhaseChanging, {
  can_refresh = function (self, event, target, player, data)
    return target == player and table.contains(player:getTableMark("@@ofl__zhengjing"), data.phase) and not data.skipped
  end,
  on_refresh = function (self, event, target, player, data)
    data.skipped = true
    player.room:removeTableMark(player, "@@ofl__zhengjing", data.phase)
  end,
})

return zhengjing
