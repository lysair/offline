local conqueror = fk.CreateSkill {
  name = "conqueror",
}

Fk:loadTranslationTable{
  ["conqueror"] = "Conqueror",
  [":conqueror"] = "When you use a <b>Strike</b> and successfully target another hero, you may declare a card type"..
  "(Basic, Equipment, or Scroll) and then the target must select one of the following: <br> 1. Negate the effect of the"..
  "<b>Strike</b> and give you a card of the declared type. <br> 2. That <b>Strike</b> may not be <b>Dodged</b>.",

  ["#conqueror-choice"] = "Conqueror: You may declare a card type, %dest shall give you a card of the declared type<br>"..
  "to negate the effect, or the %arg may not be Dodged",
  ["#conqueror-give"] = "Conqueror: You shall give %src a %arg to negate the effect, or the Strike may not be Dodged",
}

conqueror:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(conqueror.name) and
      data.card.trueName == "slash" and data.to ~= player and not data.to.dead
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local choice = room:askToChoice(player, {
      choices = {"basic", "equip", "trick", "Cancel"},
      skill_name = conqueror.name,
      prompt = "#conqueror-choice::"..data.to.id..":"..data.card:toLogString()
    })
    if choice ~= "Cancel" then
      event:setCostData(self, {tos = {data.to}, choice = choice})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if not data.to:isNude() then
      local type = event:getCostData(self).choice
      local card = room:askToCards(data.to, {
        min_num = 1,
        max_num = 1,
        include_equip = true,
        skill_name = conqueror.name,
        cancelable = true,
        pattern = ".|.|.|.|.|"..type,
        prompt = "#conqueror-give:"..player.id.."::"..type,
      })
      if #card > 0 then
        room:obtainCard(player, card, true, fk.ReasonGive, data.to, conqueror.name)
        data.use.nullifiedTargets = data.use.nullifiedTargets or {}
        table.insertIfNeed(data.use.nullifiedTargets, data.to)
        return
      end
    end
    data.disresponsive = true
  end,
})

return conqueror
