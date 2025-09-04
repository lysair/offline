local lueming = fk.CreateSkill {
  name = "ofl_tx__lueming",
}

Fk:loadTranslationTable{
  ["ofl_tx__lueming"] = "掠命",
  [":ofl_tx__lueming"] = "出牌阶段限一次，你选择一名装备区装备少于你的其他角色，令其选择一个点数，然后你进行判定："..
  "若点数相同，你对其造成2点伤害；不同，你获得其区域内的一张牌。",

  ["#ofl_tx__lueming"] = "掠命：令一名角色猜测判定牌点数，若相同则对其造成2点伤害，不同则你获得其牌",

  ["$ofl_tx__lueming1"] = "劫命掠财，毫不费力。",
  ["$ofl_tx__lueming2"] = "人财，皆掠之，哈哈！",
}

lueming:addEffect("active", {
  anim_type = "offensive",
  prompt = "#ofl_tx__lueming",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(lueming.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and #to_select:getCardIds("e") < #player:getCardIds("e")
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local choices = {}
    for i = 1, 13, 1 do
      table.insert(choices, tostring(i))
    end
    local choice = room:askToChoice(target, {
      choices = choices,
      skill_name = lueming.name,
    })
    room:sendLog{
      type = "#Choice",
      from = target.id,
      arg = choice,
      toast = true,
    }
    local judge = {
      who = player,
      reason = lueming.name,
      pattern = ".",
    }
    room:judge(judge)
    if tostring(judge.card.number) == choice then
      if not target.dead then
        room:damage{
          from = player,
          to = target,
          damage = 2,
          skillName = lueming.name,
        }
      end
    elseif not target:isAllNude() and not player.dead then
      local card = room:askToChooseCard(player, {
        target = target,
        flag = "hej",
        skill_name = lueming.name,
      })
      room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonPrey, lueming.name, nil, false, player)
    end
  end,
})

return lueming
