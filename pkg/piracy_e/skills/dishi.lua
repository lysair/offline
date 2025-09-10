local dishi = fk.CreateSkill {
  name = "ofl__dishi",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable{
  ["ofl__dishi"] = "地逝",
  [":ofl__dishi"] = "限定技，出牌阶段开始时，若你已受伤，你可以将所有手牌当一张无距离限制且伤害为X的【杀】使用（X为你的手牌数）。",

  ["#ofl__dishi-invoke"] = "地逝：你可以将所有手牌当一张无距离限制的【杀】使用，伤害为牌数！",
}

dishi:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(dishi.name) and player.phase == Player.Play and
      player:isWounded() and not player:isKongcheng() and player:usedSkillTimes(dishi.name, Player.HistoryGame) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local use = room:askToUseVirtualCard(player, {
      name = "slash",
      skill_name = dishi.name,
      subcards = player:getCardIds("h"),
      prompt = "#ofl__dishi-invoke",
      cancelable = true,
      extra_data = {
        bypass_distances = true,
        bypass_times = true,
        extraUse = true,
      },
      skip = true,
    })
    if use then
      event:setCostData(self, {extra_data = use})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local use = table.simpleClone(event:getCostData(self).extra_data)
    use.additionalDamage = player:getHandcardNum() - 1
    player.room:useCard(use)
  end,
})

return dishi
