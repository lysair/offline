local langgu = fk.CreateSkill {
  name = "langgu"
}

Fk:loadTranslationTable{
  ['langgu'] = '狼顾',
  ['#langgu-card'] = '狼顾：选择要弃置的牌',
  ['langgu_all'] = '全部弃置',
  ['#langgu-ask'] = '狼顾：你可以打出一张手牌代替判定牌 %arg',
  [':langgu'] = '每当你受到1点伤害后，你可以进行判定且你可以打出一张手牌代替此判定牌，若如此做，你观看伤害来源的所有手牌，然后你可以弃置其中任意张与判定结果花色相同的牌。 ',
}

langgu:addEffect(fk.Damaged, {
  anim_type = "masochism",
  on_trigger = function(self, event, target, player, data)
    skill.cancel_cost = false
    for i = 1, data.damage do
      if skill.cancel_cost or not player:hasSkill(langgu.name) then break end
      skill:doCost(event, target, player, data)
    end
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askToSkillInvoke(player, {skill_name = langgu.name}) then
      return true
    end
    skill.cancel_cost = true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local judge = {
      who = player,
      reason = langgu.name,
      pattern = ".",
    }
    room:judge(judge)
    if player.dead or not data.from or data.from:isKongcheng() then return end
    room:doIndicate(player.id, {data.from.id})
    local all = data.from:getCardIds("h")
    local cards = table.filter(all, function(id) return Fk:getCardById(id).suit == judge.card.suit end)
    local throw, choice = player.room:askToChooseCardsAndPlayers(player, {
      min_card_num = math.min(#cards, 1),
      max_card_num = #cards,
      targets = {data.from.id},
      min_target_num = 0,
      max_target_num = 0,
      pattern = ".",
      prompt = "#langgu-card",
      cancelable = false,
      extra_data = {"langgu_all", "Cancel"},
    })
    if choice == "langgu_all" then
      throw = cards
    end
    if #throw > 0 then
      room:throwCard(throw, langgu.name, data.from, player)
    end
  end,
})

langgu:addEffect(fk.AskForRetrial, {
  name = "#langgu_delay",
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return data.reason == "langgu" and player == data.who and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local prompt = "#langgu-ask:::" .. data.card:toLogString()
    local ids = table.filter(player:getCardIds("h"), function(id) return not player:prohibitResponse(Fk:getCardById(id)) end)
    local card = player.room:askToAG(player, {
      id_list = ids,
      cancelable = true,
      skill_name = langgu.name,
      prompt = prompt
    })
    if #card > 0 then
      event:setCostData(skill, card[1])
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:retrial(Fk:getCardById(event:getCostData(skill)), player, data, "langgu")
  end,
})

return langgu
