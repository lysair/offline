local ofl__conghan = fk.CreateSkill {
  name = "ofl__conghan"
}

Fk:loadTranslationTable{
  ['ofl__conghan'] = '从汉',
  ['#ofl__conghan-use'] = '从汉：你可以对 %dest 使用一张【杀】',
  [':ofl__conghan'] = '蜀势力技，当一号位造成伤害后，你可以对受到此伤害的角色使用一张【杀】。',
}

ofl__conghan:addEffect(fk.Damage, {
  can_trigger = function(self, event, target, player, data)
    return
      player:hasSkill(ofl__conghan.name) and
      target and
      target.seat == 1 and
      player:canUseTo(Fk:cloneCard("slash"), data.to, {bypass_distances = true, bypass_times = true})
  end,
  on_cost = function(self, event, target, player, data)
    local use = player.room:askToUseCard(player, {
      skill_name = ofl__conghan.name,
      pattern = "slash",
      prompt = "#ofl__conghan-use::" .. data.to.id,
      cancelable = true,
      extra_data = { must_targets = {data.to.id}, bypass_distances = true, bypass_times = true }
    })
    if use then
      event:setCostData(self, use)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:useCard(event:getCostData(self))
  end,
})

return ofl__conghan
