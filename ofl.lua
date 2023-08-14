local extension = Package("ofl")
extension.extensionName = "offline"

Fk:loadTranslationTable{
  ["ofl"] = "线下",
}

local caesar = General(extension, "caesar", "god", 4)
local conqueror = fk.CreateTriggerSkill{
  name = "conqueror",
  anim_type = "offensive",
  events = {fk.TargetSpecified},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.card.trueName == "slash" and
      not player.room:getPlayerById(data.to).dead
  end,
  on_cost = function(self, event, target, player, data)
    local choice = player.room:askForChoice(player, {"Cancel", "basic", "equip", "trick"}, self.name,
      "#conqueror-choice::"..data.to..":"..data.card:toLogString())
    if choice ~= "Cancel" then
      self.cost_data = choice
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(data.to)
    if to:isNude() then
      data.disresponsiveList = data.disresponsiveList or {}
      table.insert(data.disresponsiveList, data.to)
    else
      local card = room:askForCard(to, 1, 1, true, self.name, true, ".|.|.|.|.|"..self.cost_data,
        "#conqueror-give:"..player.id.."::"..self.cost_data)
      if #card > 0 then
        room:obtainCard(player.id, card[1], true, fk.ReasonGive)
        return true
      else
        data.disresponsiveList = data.disresponsiveList or {}
        table.insert(data.disresponsiveList, data.to)
      end
    end
  end,
}
caesar:addSkill(conqueror)
Fk:loadTranslationTable{
  ["caesar"] = "Caesar",
  ["conqueror"] = "Conqueror",
  [":conqueror"] = "When you use a <b>Strike</b> and successfully target another hero, you may declare a card type "..
  "(Basic, Equipment, or Scroll) and then the target must select one of the following: <br> 1. Negate the effect of the <b>Strike</b> and "..
  "give you a card of the declared type. <br> 2. That <b>Strike</b> may not be <b>Dodged</b>.",
  ["#conqueror-choice"] = "Conqueror: You may declare a card type, %dest shall give you a card of the declared type<br>"..
  "to negate the effect, or the %arg may not be Dodged",
  ["#conqueror-give"] = "Conqueror: You shall give %src a %arg to negate the effect, or the Strike may not be Dodged",
}

return extension
