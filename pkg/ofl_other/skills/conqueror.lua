local conqueror = fk.CreateSkill {
  name = "conqueror"
}

Fk:loadTranslationTable{
  ['conqueror'] = 'Conqueror',
}

conqueror:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(conqueror.name) and data.card.trueName == "slash" and data.to ~= player.id and
      not player.room:getPlayerById(data.to).dead
  end,
  on_cost = function(self, event, target, player, data)
    local choice = player.room:askToChoice(player, {
      choices = {"Cancel", "basic", "equip", "trick"},
      skill_name = conqueror.name,
      prompt = "#conqueror-choice::"..data.to..":"..data.card:toLogString()
    })
    if choice ~= "Cancel" then
      event:setCostData(skill, choice)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(data.to)
    if not to:isNude() then
      local card = room:askToCards(to, {
        min_num = 1,
        max_num = 1,
        include_equip = true,
        skill_name = conqueror.name,
        cancelable = true,
        pattern = ".|.|.|.|.|"..event:getCostData(skill),
        prompt = "#conqueror-give:"..player.id.."::"..event:getCostData(skill)
      })
      if #card > 0 then
        room:obtainCard(player.id, card[1], true, fk.ReasonGive, to.id, conqueror.name)
        table.insertIfNeed(data.nullifiedTargets, data.to)
        return
      end
    end
    data.disresponsiveList = data.disresponsiveList or {}
    table.insert(data.disresponsiveList, data.to)
  end,
})

return conqueror
