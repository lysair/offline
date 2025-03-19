local jianglie = fk.CreateSkill {
  name = "jianglie"
}

Fk:loadTranslationTable{
  ['jianglie'] = '将烈',
  ['#jianglie-invoke'] = '将烈：你可以令 %dest 展示手牌并弃置其中一种颜色的牌',
  ['#jianglie-discard'] = '将烈：选择你要弃置手牌的颜色',
  [':jianglie'] = '出牌阶段限一次，当你使用【杀】指定一个目标后，你可以令其展示所有手牌，然后其需弃置其中一种颜色所有的牌。',
}

jianglie:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(jianglie.name) and player.phase == Player.Play and
      data.card.trueName == "slash" and data.firstTarget and player:usedSkillTimes(jianglie.name, Player.HistoryPhase) == 0 then
      local to = player.room:getPlayerById(data.to)
      return not to.dead and not to:isKongcheng()
    end
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = jianglie.name,
      prompt = "#jianglie-invoke::" .. data.to
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(data.to)
    to:showCards(to:getCardIds("h"))
    if not to.dead then
      local choices = {}
      if table.find(to:getCardIds("h"), function(id) return Fk:getCardById(id).color == Card.Red end) then
        table.insert(choices, "red")
      end
      if table.find(to:getCardIds("h"), function(id) return Fk:getCardById(id).color == Card.Black end) then
        table.insert(choices, "black")
      end
      local choice = room:askToChoice(to, {
        choices = choices,
        skill_name = jianglie.name,
        prompt = "#jianglie-discard"
      })
      room:throwCard(table.filter(to:getCardIds("h"), function(id)
        return Fk:getCardById(id):getColorString() == choice end), jianglie.name, to, to)
    end
  end,
})

return jianglie
