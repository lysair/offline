local longyin = fk.CreateSkill {
  name = "shzj_guansuo__longyin",
}

Fk:loadTranslationTable{
  ["shzj_guansuo__longyin"] = "龙吟",
  [":shzj_guansuo__longyin"] = "每回合限一次，当一名角色于其出牌阶段内使用红色【杀】时，你可以摸一张牌并展示之，令此【杀】不计次数。"..
  "若展示牌为红色，你可以令此【杀】额外结算一次。",

  ["#shzj_guansuo__longyin-invoke"] = "龙吟：你可以摸一张牌，令 %dest 的【杀】不计入次数",
  ["#shzj_guansuo__longyin-extra"] = "龙吟：是否令此【杀】额外结算一次？",

  ["$shzj_guansuo__longyin1"] = "",
  ["$shzj_guansuo__longyin2"] = "",
}

longyin:addEffect(fk.CardUsing, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(longyin.name) and target.phase == Player.Play and
      data.card.trueName == "slash" and data.card.color == Card.Red and
      player:usedSkillTimes(longyin.name, Player.HistoryTurn) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = longyin.name,
      prompt = "#shzj_guansuo__longyin-invoke::"..target.id,
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if not data.extraUse then
      target:addCardUseHistory(data.card.trueName, -1)
      data.extraUse = true
    end
    local card = player:drawCards(1, longyin.name)
    if #card == 0 then return end
    local yes = Fk:getCardById(card[1]).color == Card.Red
    player:showCards(card)
    if yes and not player.dead and
      room:askToSkillInvoke(player, {
      skill_name = longyin.name,
      prompt = "#shzj_guansuo__longyin-extra",
    }) then
      data.additionalEffect = (data.additionalEffect or 0) + 1
    end
  end,
})

return longyin
