
local junshen = fk.CreateSkill{
  name = "junshen",
}

Fk:loadTranslationTable{
  ["junshen"] = "军神",
  [":junshen"] = "你可以将一张红色牌当【杀】使用或打出。"..
  "当你以此法使用【杀】对一名角色造成伤害时，其弃置装备区所有牌，你可以重复X次，选择一项（X为其以此法弃置的装备数，至少为1）："..
  "1.弃置其一张手牌；2.此伤害+1。<br>"..
  "你使用<font color='red'>♦</font>【杀】无距离限制、<font color='red'>♥</font>【杀】可以多指定一个目标。",

  ["#junshen"] = "军神：将一张红色牌当【杀】使用或打出",
  ["#junshen-choose"] = "军神：你可以为此%arg额外指定一个目标",
  ["#junshen-choice"] = "军神：你可以选择一项（第%arg次，共%arg2次）",
  ["junshen_discard"] = "弃置%dest一张手牌",
  ["junshen_damage"] = "此伤害+1",
}

junshen:addEffect("viewas", {
  anim_type = "offensive",
  pattern = "slash",
  prompt = "#junshen",
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).color == Card.Red
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return end
    local c = Fk:cloneCard("slash")
    c.skillName = junshen.name
    c:addSubcard(cards[1])
    return c
  end,
})

junshen:addEffect("targetmod", {
  bypass_distances = function (self, player, skill, card)
    return player:hasSkill(junshen.name) and card and skill.trueName == "slash_skill" and card.suit == Card.Diamond
  end
})

junshen:addEffect(fk.AfterCardTargetDeclared, {
  anim_type = "control",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(junshen.name) and
      data.card.trueName == "slash" and data.card.suit == Card.Heart and
      #data:getExtraTargets() > 0
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = data:getExtraTargets(),
      skill_name = junshen.name,
      prompt = "#junshen-choose:::"..data.card:toLogString(),
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local to = event:getCostData(self).tos[1]
    player.room:sendLog{
      type = "#AddTargetsBySkill",
      from = player.id,
      to = {to.id},
      arg = junshen.name,
      arg2 = data.card:toLogString()
    }
    data:addTarget(to)
  end,
})

junshen:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(junshen.name) and
      data.card and table.contains(data.card.skillNames, junshen.name)
  end,
  on_cost = function (self, event, target, player, data)
    event:setCostData(self, {tos = {data.to}})
    return true
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local n = #data.to:getCardIds("e")
    if n > 0 then
      data.to:throwAllCards("e", junshen.name)
    end
    n = math.min(n, 1)
    for i = 1, n do
      if data.to.dead or player.dead then return end
      local all_choices = {
        "junshen_discard::"..data.to.id,
        "junshen_damage",
        "Cancel",
      }
      local choices = table.simpleClone(all_choices)
      if data.to:isKongcheng() then
        table.remove(choices, 1)
      end
      local choice = room:askToChoice(player, {
        choices = choices,
        skill_name = junshen.name,
        prompt = "#junshen-choice:::"..i..":"..n,
      })
      if choice == "Cancel" then
        break
      elseif choice:startsWith("junshen_discard") then
        if data.to == player then
        room:askToDiscard(player, {
          min_num = 1,
          max_num = 1,
          include_equip = false,
          skill_name = junshen.name,
          cancelable = false,
        })
        else
          local card = room:askToChooseCard(player, {
            target = data.to,
            flag = "h",
            skill_name = junshen.name,
          })
          room:throwCard(card, junshen.name, data.to, player)
        end
      elseif choice:startsWith("junshen_damage") then
        data:changeDamage(1)
      end
    end
  end,
})

return junshen
