local longdan = fk.CreateSkill({
  name = "ofl_tx__longdan",
})

Fk:loadTranslationTable{
  ["ofl_tx__longdan"] = "龙胆",
  [":ofl_tx__longdan"] = "你可以将【杀】当【闪】、【闪】当【杀】使用或打出，你以此法使用或打出牌时摸一张牌。",

  ["#ofl_tx__longdan"] = "龙胆：将一张【杀】当【闪】、【闪】当【杀】使用或打出并摸一张牌",

  ["$ofl_tx__longdan1"] = "能进能退，乃真正法器！",
  ["$ofl_tx__longdan2"] = "吾乃常山赵子龙也！",
}

longdan:addEffect("viewas", {
  pattern = "slash,jink",
  prompt = "#ofl_tx__longdan",
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    if #selected == 1 then return end
    local _c = Fk:getCardById(to_select)
    local c
    if _c.trueName == "slash" then
      c = Fk:cloneCard("jink")
    elseif _c.name == "jink" then
      c = Fk:cloneCard("slash")
    else
      return false
    end
    return (Fk.currentResponsePattern == nil and player:canUse(c)) or
      (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(c))
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return end
    local _c = Fk:getCardById(cards[1])
    local c
    if _c.trueName == "slash" then
      c = Fk:cloneCard("jink")
    elseif _c.name == "jink" then
      c = Fk:cloneCard("slash")
    end
    c.skillName = longdan.name
    c:addSubcard(cards[1])
    return c
  end,
})

local spec = {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and not player.dead and
      table.contains(data.card.skillNames, longdan.name)
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, longdan.name)
  end,
}
longdan:addEffect(fk.CardUsing, spec)
longdan:addEffect(fk.CardResponding, spec)

longdan:addAI(nil, "vs_skill")

return longdan
