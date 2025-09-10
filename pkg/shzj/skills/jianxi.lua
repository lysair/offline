local jianxi = fk.CreateSkill{
  name = "jianxi",
  dynamic_desc = function (self, player, lang)
    return "jianxi_inner:"..player:getMark(self.name)
  end,
}

Fk:loadTranslationTable{
  ["jianxi"] = "兼习",
  [":jianxi"] = "当你受到伤害后，你可以摸一张牌并展示之，然后你声明并获得一个描述中包含此牌牌名且不在场上的技能，或你使用基本牌的数值+1。",

  [":jianxi_inner"] = "当你受到伤害后，你可以摸一张牌并展示之，然后你声明并获得一个描述中包含此牌牌名且不在场上的技能，或你使用基本牌的数值+1"..
  "（已+{1}）。",

  ["#jianxi-choice"] = "兼习：获得一个技能，或直接点“确定”你使用基本牌数值+1",
}

local function jianxiSkills(player, name)
  local room = player.room
  local mapper = room:getBanner(jianxi.name)
  if mapper == nil or mapper[name] == nil then
    mapper = {}
    mapper[name] = mapper[name] or {}
    for g, general in pairs(Fk.generals) do
      if not table.contains(Fk:currentRoom().disabled_packs, general.package.name) and
        not table.contains(Fk:currentRoom().disabled_generals, g) then
        for _, s in ipairs(general:getSkillNameList()) do
          if string.find(Fk:translate(":"..s, "zh_CN"), "【"..Fk:translate(name, "zh_CN").."】") then
            table.insertIfNeed(mapper[name], s)
          end
        end
      end
    end
    room:setBanner(jianxi.name, mapper)
  end
  return table.filter(mapper[name], function(s)
    return not table.find(room.players, function (p)
        return p:hasSkill(s, true)
      end)
  end)
end

jianxi:addEffect(fk.Damaged, {
  anim_type = "masochism",
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = player:drawCards(1, jianxi.name)
    if #cards == 0 then return end
    cards = table.filter(cards, function (id)
      return table.contains(player:getCardIds("h"), id)
    end)
    if #cards == 0 then return end
    local name = Fk:getCardById(cards[1]).trueName
    player:showCards(cards[1])
    if player.dead then return end
    local skills = jianxiSkills(player, name)
    if #skills > 0 then
      local choice = room:askToCustomDialog(player, {
        skill_name = jianxi.name,
        qml_path = "packages/utility/qml/ChooseSkillBox.qml",
        extra_data = {
          skills, 0, 1, "#jianxi-choice",
        },
      })
      if #choice > 0 then
        room:handleAddLoseSkills(player, choice)
      else
        room:addPlayerMark(player, jianxi.name, 1)
      end
    else
      room:addPlayerMark(player, jianxi.name, 1)
    end
  end,
})

jianxi:addEffect(fk.CardUsing, {
  anim_type = "offensive",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark(jianxi.name) > 0 and
      data.card.type == Card.TypeBasic
  end,
  on_use = function(self, event, target, player, data)
    if data.card.is_damage_card then
      data.additionalDamage = (data.additionalDamage or 0) + player:getMark(jianxi.name)
    elseif data.card.name == "peach" then
      data.additionalRecover = (data.additionalRecover or 0) + player:getMark(jianxi.name)
    elseif data.card.name == "analeptic" then
      if data.extra_data and data.extra_data.analepticRecover then
        data.additionalRecover = (data.additionalRecover or 0) + player:getMark(jianxi.name)
      else
        data.extra_data = data.extra_data or {}
        data.extra_data.additionalDrank = (data.extra_data.additionalDrank or 0) + player:getMark(jianxi.name)
      end
    end
  end,
})

return jianxi
