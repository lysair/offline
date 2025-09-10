local gangjian = fk.CreateSkill {
  name = "sxfy__gangjian",
}

Fk:loadTranslationTable{
  ["sxfy__gangjian"] = "刚谏",
  [":sxfy__gangjian"] = "其他角色的准备阶段，你可以令其视为对你使用一张【杀】，若此【杀】未造成伤害，其本回合不能使用锦囊牌。",

  ["#sxfy__gangjian-invoke"] = "刚谏：视为 %dest 对你使用【杀】，若未造成伤害则其本回合不能使用锦囊牌",
  ["@@sxfy__gangjian-turn"] = "刚谏",
}

gangjian:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(gangjian.name) and target.phase == Player.Start and
      not target.dead
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = gangjian.name,
      prompt = "#sxfy__gangjian-invoke::"..target.id,
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local use = room:useVirtualCard("slash", nil, target, player, gangjian.name, true)
    if not (use and use.damageDealt) and not target.dead then
      room:setPlayerMark(target, "@@sxfy__gangjian-turn", 1)
    end
  end,
})

gangjian:addEffect("prohibit", {
  prohibit_use = function (self, player, card)
    return card and player:getMark("@@sxfy__gangjian-turn") > 0 and card.type == Card.TypeTrick
  end,
})

return gangjian
