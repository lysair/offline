local baoquan = fk.CreateSkill {
  name = "ofl__baoquan",
}

Fk:loadTranslationTable{
  ["ofl__baoquan"] = "保全",
  [":ofl__baoquan"] = "当你受到伤害时，你可以弃置一张锦囊牌，防止此伤害。",

  ["#ofl__baoquan-invoke"] = "保全：你可以弃置一张锦囊牌，防止受到的伤害",
}

baoquan:addEffect(fk.DamageInflicted, {
  anim_type = "defensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(baoquan.name) and not player:isKongcheng()
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local card = room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = baoquan.name,
      cancelable = true,
      pattern = ".|.|.|.|.|trick",
      prompt = "#ofl__baoquan-invoke",
      skip = true,
    })
    if #card > 0 then
      event:setCostData(self, {cards = card})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    data:preventDamage()
    room:throwCard(event:getCostData(self).cards, baoquan.name, player, player)
  end,
})

return baoquan
