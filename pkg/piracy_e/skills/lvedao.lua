local lvedao = fk.CreateSkill {
  name = "lvedao",
}

Fk:loadTranslationTable{
  ["lvedao"] = "掠盗",
  [":lvedao"] = "当你使用【杀】对一名角色造成伤害时，你可以获得其一张牌并令其减1点体力上限，其获得〖避凶〗。",

  ["#lvedao-invoke"] = "掠盗：你可以获得 %dest 一张牌并令其减1点体力上限！",
}

lvedao:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(lvedao.name) and
      data.card and data.card.trueName == "slash" and
      not data.to:isNude()
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = lvedao.name,
      prompt = "#lvedao-invoke::"..data.to.id,
    }) then
      event:setCostData(self, {tos = {data.to}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = room:askToChooseCard(player, {
      target = data.to,
      flag = "he",
      skill_name = lvedao.name,
    })
    room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonPrey, lvedao.name, nil, false, player)
    if data.to.dead then return end
    room:changeMaxHp(data.to, -1)
    if data.to.dead then return end
    room:handleAddLoseSkills(data.to, "ofl__bixiong")
  end,
})

return lvedao
