local dingpan = fk.CreateSkill{
  name = "shzj_yiling__dingpan",
}

Fk:loadTranslationTable{
  ["shzj_yiling__dingpan"] = "定叛",
  [":shzj_yiling__dingpan"] = "出牌阶段限X次，你可以令一名装备区里有牌的角色摸一张牌，然后其选择一项：1.令你弃置其两张牌；"..
  "2.获得其装备区里的所有牌，你对其造成1点伤害（X为你本回合使用过牌的类别数）。",

  ["#shzj_yiling__dingpan"] = "定叛：令一名装备区里有牌的角色摸一张牌，然后其选择你弃置其两张牌或收回装备并受到伤害",
  ["shzj_yiling__dingpan_discard"] = "%src弃置你两张牌",
  ["#shzj_yiling__dingpan-discard"] = "定叛：弃置 %dest 两张牌",
}

dingpan:addEffect("active", {
  anim_type = "offensive",
  prompt = "#shzj_yiling__dingpan",
  card_num = 0,
  target_num = 1,
  times = function(self, player)
    return player.phase == Player.Play and
      #player:getTableMark("shzj_yiling__dingpan-turn") - player:usedSkillTimes(dingpan.name, Player.HistoryPhase) or -1
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(dingpan.name, Player.HistoryPhase) < #player:getTableMark("shzj_yiling__dingpan-turn")
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and #to_select:getCardIds("e") > 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    target:drawCards(1, dingpan.name)
    if player.dead or target.dead then return end
    local choice = room:askToChoice(target, {
      choices = {"shzj_yiling__dingpan_discard:"..player.id, "dingpan_damage:"..player.id},
      skill_name = dingpan.name,
    })
    if choice:startsWith("shzj_yiling__dingpan_discard") then
      if target == player then
        room:askToDiscard(player, {
          min_num = 2,
          max_num = 2,
          include_equip = true,
          skill_name = dingpan.name,
          cancelable = false,
          prompt = "#shzj_yiling__dingpan-discard::"..target.id,
        })
      else
        local cards = room:askToChooseCards(player, {
          target = target,
          min = 2,
          max = 2,
          flag = "he",
          skill_name = dingpan.name,
          prompt = "#shzj_yiling__dingpan-discard::"..target.id,
        })
        room:throwCard(cards, dingpan.name, target, player)
      end
    else
      room:moveCardTo(target:getCardIds("e"), Card.PlayerHand, target, fk.ReasonJustMove, dingpan.name, nil, true, target.id)
      if not target.dead then
        room:damage{
          from = player,
          to = target,
          damage = 1,
          skillName = dingpan.name,
        }
      end
    end
  end,
})

dingpan:addAcquireEffect(function (self, player, is_start)
  if player.phase == Player.Play then
    local room = player.room
    local types = {}
    room.logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
      local use = e.data
      if use.from == player then
        table.insertIfNeed(types, use.card.type)
      end
    end, Player.HistoryTurn)
    room:setPlayerMark(player, "shzj_yiling__dingpan-turn", types)
  end
end)

dingpan:addEffect(fk.AfterCardUseDeclared, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(dingpan.name, true) and player.phase == Player.Play
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:addTableMarkIfNeed(player, "shzj_yiling__dingpan-turn", data.card.type)
  end,
})

return dingpan
