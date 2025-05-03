
local polu = fk.CreateSkill {
  name = "sxfy__polu",
}

Fk:loadTranslationTable{
  ["sxfy__polu"] = "破橹",
  [":sxfy__polu"] = "当你造成或受到伤害后，你可以弃置受伤角色装备区内的一张牌，若为你，你摸一张牌。",

  ["#sxfy__polu1-invoke"] = "破橹：是否弃置一张装备，摸一张牌？",
  ["#sxfy__polu2-invoke"] = "破橹：是否弃置 %dest 一张装备？",
}

local spec = {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(polu.name) and
      not data.to.dead and #data.to:getCardIds("e") > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if data.to == player then
      local card = room:askToDiscard(player, {
        min_num = 1,
        max_num = 1,
        include_equip = true,
        skill_name = polu.name,
        cancelable = true,
        pattern = ".|.|.|equip",
        prompt = "#sxfy__polu1-invoke",
      })
      if #card > 0 then
        event:setCostData(self, {cards = card})
        return true
      end
    else
      if room:askToSkillInvoke(player, {
        skill_name = polu.name,
        prompt = "#sxfy__polu2-invoke::"..data.to.id,
      }) then
        event:setCostData(self, {tos = {data.to}})
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if data.to == player then
      room:throwCard(event:getCostData(self).cards, polu.name, player, player)
      if player.dead then return end
      player:drawCards(1, polu.name)
    else
      local card = room:askToChooseCard(player, {
        target = data.to,
        flag = "e",
        skill_name = polu.name,
      })
      room:throwCard(card, polu.name, data.to, player)
    end
  end,
}

polu:addEffect(fk.Damage, spec)
polu:addEffect(fk.Damaged, spec)

return polu
