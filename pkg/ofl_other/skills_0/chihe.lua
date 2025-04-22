local chihe = fk.CreateSkill {
  name = "ofl__chihe"
}

Fk:loadTranslationTable{
  ['ofl__chihe'] = '叱吓',
  ['#ofl__chihe-invoke'] = '叱吓：是否摸两张牌并与 %dest 点？若赢，此【杀】伤害+1；若没赢，你弃两张牌',
  ['#ofl__chihe-show'] = '叱吓：请展示两张手牌',
  [':ofl__chihe'] = '当你使用【杀】指定唯一目标/成为【杀】的唯一目标后，你可以摸两张牌并展示两张手牌，然后你与目标角色/使用者拼点：若你赢，此【杀】伤害+1；若你没赢，你弃置两张牌。',
  ['$ofl__chihe1'] = '想见圣上？哼哼，你怕是没这个福分了！',
  ['$ofl__chihe2'] = '哼，不过襟裾牛马，衣冠狗彘尓！'
}

chihe:addEffect(fk.TargetSpecified, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(chihe.name) and data.card.trueName == "slash" and
      #AimGroup:getAllTargets(data.tos) == 1
  end,
  on_cost = function (self, event, target, player, data)
    local to = data.to
    if player.room:askToSkillInvoke(player, {skill_name = chihe.name, prompt = "#ofl__chihe-invoke::"..to}) then
      event:setCostData(self, {tos = {to}})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    player:drawCards(2, chihe.name)
    if player.dead then return end
    if player:getHandcardNum() > 1 then
      local cards = room:askToCards(player, {min_num = 2, max_num = 2, pattern = nil, prompt = "#ofl__chihe-show"})
      player:showCards(cards)
      if player.dead then return end
    end
    local to = room:getPlayerById(data.to)
    if not to.dead and player:canPindian(to) then
      local pindian = player:pindian({to}, chihe.name)
      if pindian.results[to.id].winner == player then
        data.additionalDamage = (data.additionalDamage or 0) + 1
      elseif not player.dead then
        room:askToDiscard(player, {min_num = 2, max_num = 2, include_equip = true, skill_name = chihe.name})
      end
    end
  end,
})

chihe:addEffect(fk.TargetConfirmed, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(chihe.name) and data.card.trueName == "slash" and
      #AimGroup:getAllTargets(data.tos) == 1
  end,
  on_cost = function (self, event, target, player, data)
    local to = data.from
    if player.room:askToSkillInvoke(player, {skill_name = chihe.name, prompt = "#ofl__chihe-invoke::"..to}) then
      event:setCostData(self, {tos = {to}})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    player:drawCards(2, chihe.name)
    if player.dead then return end
    if player:getHandcardNum() > 1 then
      local cards = room:askToCards(player, {min_num = 2, max_num = 2, pattern = nil, prompt = "#ofl__chihe-show"})
      player:showCards(cards)
      if player.dead then return end
    end
    local to = room:getPlayerById(data.from)
    if not to.dead and player:canPindian(to) then
      local pindian = player:pindian({to}, chihe.name)
      if pindian.results[to.id].winner == player then
        data.additionalDamage = (data.additionalDamage or 0) + 1
      elseif not player.dead then
        room:askToDiscard(player, {min_num = 2, max_num = 2, include_equip = true, skill_name = chihe.name})
      end
    end
  end,
})

return chihe
