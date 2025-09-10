local meibu = fk.CreateSkill {
  name = "sxfy__meibu",
}

Fk:loadTranslationTable{
  ["sxfy__meibu"] = "魅步",
  [":sxfy__meibu"] = "当装备区内有武器牌的角色使用【杀】时，你可以令其弃置一张手牌。",

  ["#sxfy__meibu-invoke"] = "魅步：你可以令 %dest 弃置一张手牌",
}

meibu:addEffect(fk.CardUsing, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(meibu.name) and data.card.trueName == "slash" and
      #target:getEquipments(Card.SubtypeWeapon) > 0 and not target.dead and not target:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = meibu.name,
      prompt = "#sxfy__meibu-invoke::"..target.id,
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:askToDiscard(target, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = meibu.name,
      cancelable = false,
    })
  end,
})

return meibu
