local cuiji = fk.CreateSkill {
  name = "ofl__cuiji"
}

Fk:loadTranslationTable{
  ['ofl__cuiji'] = '摧击',
  ['ofl__cuiji_viewas'] = '摧击',
  ['#ofl__cuiji-invoke'] = '摧击：你可以将任意张手牌当雷【杀】对 %dest 使用，若造成伤害你摸等量牌',
  [':ofl__cuiji'] = '其他角色的出牌阶段开始时，若你手牌数大于其，你可以将任意张手牌当一张雷【杀】对其使用，若你以此法造成了伤害，你摸等量的牌。',
}

cuiji:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(cuiji.name) and target ~= player and target.phase == Player.Play and not target.dead and
      player:getHandcardNum() > target:getHandcardNum() and
      player:canUseTo(Fk:cloneCard("thunder__slash"), target, {bypass_distances = true})
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local success, dat = room:askToUseActiveSkill(player, {
      skill_name = "ofl__cuiji_viewas",
      prompt = "#ofl__cuiji-invoke::" .. target.id,
      cancelable = true,
      extra_data = {
        bypass_distances = true,
        bypass_times = true,
        must_targets = {target.id},
      }
    })
    if success and dat then
      event:setCostData(self, {cards = dat.cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local use = room:useVirtualCard("thunder__slash", event:getCostData(self).cards, player, target, cuiji.name, true)
    if use and use.damageDealt and not player.dead then
      player:drawCards(#event:getCostData(self).cards, cuiji.name)
    end
  end,
})

return cuiji
