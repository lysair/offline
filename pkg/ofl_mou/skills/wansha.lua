local wansha = fk.CreateSkill({
  name = "ofl_mou__wansha",
})

Fk:loadTranslationTable{
  ["ofl_mou__wansha"] = "完杀",
  [":ofl_mou__wansha"] = "你的回合内，不处于濒死状态的其他角色不能使用【桃】。<br>"..
  "每轮限一次，当一名角色进入濒死状态时，你可以观看其手牌并秘密选择其区域内的0~2张牌，然后令其选择一项："..
  "1.由你将被选择的牌分配给除其以外的角色；2.弃置所有未被选择的牌。",

  ["#ofl_mou__wansha-invoke"] = "完杀：你可以观看 %dest 的手牌并选择至多两张牌，其选择你分配之或弃置其余牌",
  ["#ofl_mou__wansha_give"] = "%src分配其选择的牌",
  ["#ofl_mou__wansha_throw"] = "弃置未被选择的牌",
  ["#ofl_mou__wansha-choice"] = "完杀：%src 秘密选择了你的若干张牌，你须选一项",
}

wansha:addEffect(fk.EnterDying, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(wansha.name) and player:usedSkillTimes(wansha.name, Player.HistoryRound) == 0 and
      not target:isAllNude()
  end,
  on_cost = function (self, event, target, player, data)
    if player.room:askToSkillInvoke(player, {
      skill_name = wansha.name,
      prompt = "#ofl_mou__wansha-invoke::" .. target.id,
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = room:askToChooseCards(player, {
      target = target,
      min = 0,
      max = 2,
      flag = "hej",
      skill_name = wansha.name,
    })
    local choice = room:askToChoice(target, {
      choices = { "ofl_mou__wansha_give:"..player.id, "ofl_mou__wansha_throw" },
      skill_name = wansha.name,
      prompt = "ofl_mou__wansha-choice:" .. player.id,
    })
    if choice:startsWith("ofl_mou__wansha_give") then
      if #cards == 0 then return end
      room:askToYiji(player, {
        cards = cards,
        targets = room:getOtherPlayers(target, false),
        skill_name = wansha.name,
        min_num = #cards,
        max_num = #cards,
        expand_pile = cards,
      })
    else
      local throw = table.filter(target:getCardIds("hej" or "h"), function (id)
        return not table.contains(cards, id) and not target:prohibitDiscard(id)
      end)
      if #throw > 0 then
        room:throwCard(throw, wansha.name, target, target)
      end
    end
  end,
})

wansha:addEffect("prohibit", {
  prohibit_use = function(self, player, card)
    return card and card.name == "peach" and Fk:currentRoom().current:hasSkill(wansha.name) and
      Fk:currentRoom().current ~= player and not player.dying
  end,
})

return wansha
