local cuiji = fk.CreateSkill {
  name = "ofl__cuiji",
}

Fk:loadTranslationTable{
  ["ofl__cuiji"] = "摧击",
  [":ofl__cuiji"] = "其他角色的出牌阶段开始时，若你手牌数大于其，你可以将任意张手牌当一张雷【杀】对其使用，若你以此法造成了伤害，你摸等量的牌。",

  ["#ofl__cuiji-invoke"] = "摧击：你可以将任意张手牌当雷【杀】对 %dest 使用，若造成伤害你摸等量牌",
}

cuiji:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(cuiji.name) and target ~= player and target.phase == Player.Play and
      not target.dead and player:getHandcardNum() > target:getHandcardNum() and
      player:canUseTo(Fk:cloneCard("thunder__slash"), target, {bypass_distances = true})
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local use = room:askToUseVirtualCard(player, {
      name = "thunder__slash",
      skill_name = cuiji.name,
      prompt = "#ofl__cuiji-invoke::" .. target.id,
      cancelable = true,
      extra_data = {
        bypass_distances = true,
        bypass_times = true,
        must_targets = {target.id},
      },
      card_filter = {
        n = { 1, 999 },
        cards = player:getHandlyIds(),
      },
      skip = true,
    })
    if use then
      event:setCostData(self, {extra_data = use})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local use = event:getCostData(self).extra_data
    room:useCard(use)
    if use and use.damageDealt and not player.dead then
      player:drawCards(#Card:getIdList(use.card), cuiji.name)
    end
  end,
})

return cuiji
