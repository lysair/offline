local qixi = fk.CreateSkill {
  name = "ofl_mou__qixi",
}

Fk:loadTranslationTable{
  ["ofl_mou__qixi"] = "奇袭",
  [":ofl_mou__qixi"] = "出牌阶段限一次，你可以选择一张手牌并选择一名其他角色，令其猜测此牌的花色。若猜错，该角色从未猜测过的花色中再次猜测；"..
  "若猜对，你弃置此牌，然后你弃置其区域内X-1张牌（X为该角色猜测的次数，不足则全弃）。",

  ["#ofl_mou__qixi"] = "奇袭：选择一张手牌，令一名角色猜测此牌花色，你弃置此牌并弃置其猜测次数-1的牌",
  ["#ofl_mou__qixi-choice"] = "奇袭：请猜测 %src 选择的手牌的花色",

  ["$ofl_mou__qixi1"] = "百甲倾袭出，片刻得胜归！",
  ["$ofl_mou__qixi2"] = "奇袭中军帐，誓斩曹孟德！",
}

qixi:addEffect("active", {
  anim_type = "control",
  prompt = "#ofl_mou__qixi",
  can_use = function(self, player)
    return player:usedSkillTimes(qixi.name, Player.HistoryPhase) == 0
  end,
  card_num = 1,
  target_num = 1,
  card_filter = function (self, player, to_select, selected)
    return #selected == 0 and table.contains(Self:getCardIds("h"), to_select)
  end,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local suits = {"log_spade", "log_heart", "log_club", "log_diamond"}
    local num = 0
    while #suits > 0 do
      local choice = room:askToChoice(target, {
        choices = suits,
        skill_name = qixi.name,
        prompt = "#ofl_mou__qixi-choice:"..player.id,
      })
      num = num + 1
      room:sendLog{
        type = "#Choice",
        from = target.id,
        arg = choice,
        toast = true,
      }
      if Fk:getCardById(effect.cards[1]):getSuitString(true) ~= choice then
        table.removeOne(suits, choice)
      else
        if not player:prohibitDiscard(effect.cards[1]) then
          room:throwCard(effect.cards, qixi.name, player, player)
        end
        break
      end
    end
    local throw_num = math.min(#target:getCardIds("hej"), num - 1)
    if player.dead or target.dead or throw_num == 0 then return end
    local throw = room:askToChooseCards(player, {
      target = target,
      min = throw_num,
      max = throw_num,
      flag = "hej",
      skill_name = qixi.name,
    })
    room:throwCard(throw, qixi.name, target, player)
  end,
})

return qixi
