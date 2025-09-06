
local maojin = fk.CreateSkill{
  name = "ofl_tx__maojin",
}

Fk:loadTranslationTable{
  ["ofl_tx__maojin"] = "冒进",
  [":ofl_tx__maojin"] = "敌方角色出牌阶段开始时，你可以依次对其使用至多X张【杀】（X为其技能数）。"..
  "<a href='os__override'>凌越·体力</a>：此【杀】伤害+1。你以此法使用的【杀】结算结束后，若未造成伤害，你失去1点体力。",

  ["#ofl_tx__maojin-use"] = "冒进：你可以对 %dest 使用【杀】（还剩%arg张！）",
  ["#ofl_tx__maojin_override-use"] = "冒进：你可以对 %dest 使用伤害+1的【杀】（还剩%arg张！）",
}

maojin:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(maojin.name) and target:isEnemy(player) and target.phase == Player.Play and
      not target.dead and #target:getSkillNameList() > 0
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local prompt = "#ofl_tx__maojin-use::"..target.id..":"..#target:getSkillNameList()
    if player.hp > target.hp then
      prompt = "#ofl_tx__maojin_override-use::"..target.id..":"..#target:getSkillNameList()
    end
    local use = room:askToUseCard(player, {
      skill_name = maojin.name,
      pattern = "slash",
      prompt = prompt,
      cancelable = true,
      extra_data = {
        bypass_times = true,
        bypass_distances = true,
        extraUse = true,
        must_targets = { target.id }
      },
    })
    if use then
      event:setCostData(self, { extra_data = use })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local use = event:getCostData(self).extra_data
    local total = #target:getSkillNameList() - 1
    if player.hp > target.hp then
      use.additionalDamage = (use.additionalDamage or 0) + 1
    end
    room:useCard(use)
    if not use.damageDealt and not player.dead then
      room:loseHp(player, 1, maojin.name)
    end
    while not player.dead and not target.dead and total > 0 do
      local prompt = "#ofl_tx__maojin-use::"..target.id..":"..total
      if player.hp > target.hp then
        prompt = "#ofl_tx__maojin_override-use::"..target.id..":"..total
      end
      use = room:askToUseCard(player, {
        skill_name = maojin.name,
        pattern = "slash",
        prompt = prompt,
        cancelable = true,
        extra_data = {
          bypass_times = true,
          bypass_distances = true,
          extraUse = true,
          must_targets = { target.id }
        },
      })
      if use then
        total = total - 1
        if player.hp > target.hp then
          use.additionalDamage = (use.additionalDamage or 0) + 1
        end
        room:useCard(use)
        if not use.damageDealt and not player.dead then
          room:loseHp(player, 1, maojin.name)
        end
      else
        return
      end
    end
  end,
})

return maojin
