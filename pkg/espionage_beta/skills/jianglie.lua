local jianglie = fk.CreateSkill {
  name = "jianglie",
}

Fk:loadTranslationTable{
  ["jianglie"] = "将烈",
  [":jianglie"] = "出牌阶段限一次，当你使用【杀】指定一个目标后，你可以令其展示所有手牌，然后其需弃置其中一种颜色所有的牌。",

  ["#jianglie-invoke"] = "将烈：你可以令 %dest 展示手牌并弃置其中一种颜色的牌",
  ["#jianglie-discard"] = "将烈：你需弃置一种颜色的所有手牌",
}

jianglie:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jianglie.name) and player.phase == Player.Play and
      data.card.trueName == "slash" and player:usedSkillTimes(jianglie.name, Player.HistoryPhase) == 0 and
      not data.to.dead and not data.to:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = jianglie.name,
      prompt = "#jianglie-invoke::" .. data.to.id,
    }) then
      event:setCostData(self, {tos = {data.to}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local colors = {}
    local red = table.filter(data.to:getCardIds("h"), function (id)
      return Fk:getCardById(id).color == Card.Red and not data.to:prohibitDiscard(id)
    end)
    local black = table.filter(data.to:getCardIds("h"), function (id)
      return Fk:getCardById(id).color == Card.Black and not data.to:prohibitDiscard(id)
    end)
    if #red > 0 then
      table.insert(colors, "red")
    end
    if #black > 0 then
      table.insert(colors, "black")
    end
    if #colors == 0 then return end
    local color = room:askToChoice(data.to, {
      choices = colors,
      skill_name = jianglie.name,
      prompt = "#jianglie-discard",
      all_choices = {"red", "black"},
    })
    local cards = color == "red" and red or black
    room:throwCard(cards, jianglie.name, data.to, data.to)
  end,
})

return jianglie
