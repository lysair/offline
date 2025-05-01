
local junshen = fk.CreateSkill{
  name = "junshen",
}

Fk:loadTranslationTable{
  ["junshen"] = "军神",
  [":junshen"] = "你可以将一张红色牌当【杀】使用或打出。"..
  "当你以此法使用【杀】对一名角色造成伤害时，其选择一项：1.弃置装备区内所有牌；2.此伤害+1。<br>"..
  "你使用<font color='red'>♦</font>【杀】无距离限制、<font color='red'>♥</font>【杀】可以多选择一个目标。",

  ["#junshen"] = "军神：将一张红色牌当【杀】使用或打出",
  ["#junshen-choose"] = "军神：你可以为此%arg额外指定一个目标",
  ["#junshen-ask"] = "军神：弃置装备区所有牌，或点“取消”此伤害+1。",
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
    if #data.to:getCardIds("e") == 0 or
      not room:askToSkillInvoke(data.to, {
        skill_name = junshen.name,
        prompt = "#junshen-ask",
      }) then
      data:changeDamage(1)
    else
      data.to:throwAllCards("e", junshen.name)
    end
  end,
})

return junshen
